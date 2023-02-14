from pathlib import Path
import re
import sys
import time
from collections import OrderedDict

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color

MAP_COMMENT = "//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE"
IGNORE_515_PROC_MARKER = "__byond_version_compat.dm"

#
# Basic map issues
#
# Basic map issues operate on a line-by-line basis.
#
def check_tgm(filename, lines):
    for line in lines:
        if re.match(r"^\".+\" = \(.+\)", line):
            return "ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!"


def check_comments(filename, lines):
    for line in lines:
        if (
            re.match(r"//", line)
            and not re.match(MAP_COMMENT, line)
            and not re.match("name|desc", line)
        ):
            return "ERROR: Unexpected commented out line detected in this map file. Please remove it."


def check_conflict_markers(filename, lines):
    for line in lines:
        if "Map Merge Marker" in line:
            return "ERROR: Merge conflict markers detected in map, please resolve all merge failures!"


def check_conflict_marker_object(filename, lines):
    for line in lines:
        if "/obj/merge_conflict/marker" in line:
            return "ERROR: Merge conflict markers detected in map, please resolve all merge failures!"


def check_iconstate_tags(filename, lines):
    for line in lines:
        if re.match(r'^\ttag = "icon', line):
            return "ERROR: Tag vars from icon state generation detected in maps, please remove them."


def check_step_varedits(filename, lines):
    for line in lines:
        if re.match(r"step_[xy]", line):
            return (
                "ERROR: step_x/step_y variables detected in maps, please remove them."
            )


def check_pixel_varedits(filename, lines):
    for line in lines:
        if re.match(r"pixel_[^xy]", line):
            return "ERROR: incorrect pixel offset variables detected in maps, please remove them."


def check_area_varedits(filename, lines):
    for line in lines:
        if re.match(r"^/area/.+[{]", line):
            return "ERROR: Variable editted /area path use detected in a map, please replace with a proper area path."


def check_base_turf_type(filename, lines):
    for line in lines:
        if re.match(r"/turf\s*[,\){]", line):
            return "ERROR: Base /turf path use detected in maps, please replace it with a proper turf path."


#
# Full content map issues
#
# Full content map issues require looking at the entire DMM file at
# once, and thus are separated out from more basic checks (such as
# single spelling errors) that can be done line-by-line, and thus
# faster.
#
MULTIPLE_LATTICES_RE = re.compile(
    r'"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?[,\{]\n[^)]*?/obj/structure/lattice[/\w]*?[,\{]\n[^)]*?/area/.+?\)'
)


def check_multiple_lattices(content):
    """
    >>> content = '''"abc" = (
    ... /obj/structure/lattice{
    ... \\tdir=8
    ... \\t},
    ... /obj/machinery/door/airlock/security,
    ... /obj/structure/chair,
    ... /area/security/range)'''
    >>> bool(check_multiple_lattices(content))
    False

    >>> content = '''"abc" = (
    ... /obj/structure/lattice{
    ... \\tdir=8
    ... \\t},
    ... /obj/machinery/door/airlock/security,
    ... /obj/structure/chair,
    ... /obj/structure/lattice,
    ... /turf/simulated/wall/r_wall,
    ... /area/security/range)'''
    >>> bool(check_multiple_lattices(content))
    True
    """
    if match := MULTIPLE_LATTICES_RE.search(content):
        return f"At position {match.start(0)} found multiple lattices on the same tile, please remove them."


MULTIPLE_AIRLOCKS_RE = re.compile(
    r'"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/area/.+\)'
)


def check_multiple_airlocks(content):
    if match := MULTIPLE_AIRLOCKS_RE.search(content):
        return f"At position {match.start(0)} found multiple airlocks on the same tile, please remove them."


MULTIPLE_FIRELOCKS_RE = re.compile(
    r'"\w+" = \(\n[^)]*?/obj/machinery/door/firedoor[/\w]*?[,\{]\n[^)]*?/obj/machinery/door/firedoor[/\w]*?[,\{]\n[^)]*?/area/.+\)'
)


def check_multiple_firelocks(content):
    if match := MULTIPLE_FIRELOCKS_RE.search(content):
        return f"At position {match.start(0)} found multiple firelocks on the same tile, please remove them."


APC_PIXEL_SHIFT_RE = re.compile(r"/obj/machinery/power/apc[/\w]*?[{]\n[^}]*?pixel_[xy] = (-?\d*?)[^\d]*?\s*?[}],?\n")


def check_apc_pixel_shifts(content):
    """
    >>> content = '''"Y" = (
    ... /obj/machinery/power/apc{
    ... \\tpixel_x = 16;
    ... \\tpixel_y = -16
    ... \\t},
    ... /turf/simulated/wall/mineral/titanium,
    ... /area/shuttle/arrival/station)'''
    >>> bool(check_apc_pixel_shifts(content))
    True
    """
    if match := APC_PIXEL_SHIFT_RE.search(content):
        if abs(int(match.group(1))) != 24:
            return f"At position {match.start(1)} Found an APC with a manually set pixel_x or pixel_y that is not +-24. Use the directional variants when possible."


LATTICE_AND_WALL_STACKING_RE = re.compile(
    r'"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?[,\{]\n[^)]*?/turf/simulated/wall[/\w]*?[,\{]\n[^)]*?/area/.+?\)'
)


def check_lattice_and_wall_stacking(content):
    """
    >>> content = '''"abc" = (
    ... /obj/structure/window/reinforced{
    ... \\tdir=8
    ... \\t},
    ... /obj/machinery/door/airlock/security,
    ... /obj/structure/chair,
    ... /area/security/range)'''
    >>> bool(check_lattice_and_wall_stacking(content))
    False

    >>> content = '''"abc" = (
    ... /obj/structure/lattice,
    ... /turf/simulated/wall/mineral/titanium,
    ... /area/shuttle/arrival/station)'''
    >>> bool(check_lattice_and_wall_stacking(content))
    True
    """
    if match := LATTICE_AND_WALL_STACKING_RE.search(content):
        return f"At position {match.start(0)} Found a lattice stacked within a wall, please remove them."


WINDOW_AND_WALL_STACKING_RE = re.compile(
    r'"\w+" = \(\n[^)]*?/obj/structure/window[/\w]*?[,\{]\n[^)]*?/turf/simulated/wall[/\w]*?[,\{]\n[^)]*?/area/.+?\)',
)


def check_window_and_wall_stacking(content):
    """
    >>> content = '''"abc" = (
    ... /obj/structure/window/reinforced{
    ... \\tdir=8
    ... \\t},
    ... /obj/machinery/door/airlock/security,
    ... /obj/structure/chair,
    ... /turf/simulated/floor/mineral/titanium/blue,
    ... /area/security/range)'''
    >>> bool(check_window_and_wall_stacking(content))
    False

    >>> content = '''"abc" = (
    ... /obj/structure/window/reinforced{
    ... \\tdir=8
    ... \\t},
    ... /obj/machinery/door/airlock/security,
    ... /obj/structure/chair,
    ... /turf/simulated/wall/r_wall,
    ... /area/security/range)'''
    >>> bool(check_window_and_wall_stacking(content))
    True
    """
    if match := WINDOW_AND_WALL_STACKING_RE.search(content):
        return f"At position {match.start(0)} found a window stacked within a wall, please remove it."


AIRLOCK_AND_WALL_STACKING_RE = re.compile(
    r'"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?[,\{]\n[^)]*?/turf/simulated/wall[/\w]*?[,\{]\n[^)]*?/area/.+?\)',
)


def check_airlock_and_wall_stacking(content):
    """
    >>> content = '''"abc" = (
    ... /obj/machinery/door/airlock/security,
    ... /obj/structure/chair,
    ... /area/security/range)'''
    >>> bool(check_airlock_and_wall_stacking(content))
    False

    >>> content = '''"abc" = (
    ... /obj/machinery/door/airlock/security{
    ... \\tname = "Foo Bar",
    ... \\t},
    ... /obj/structure/chair,
    ... /turf/simulated/wall/r_wall,
    ... /area/security/range)'''
    >>> bool(check_airlock_and_wall_stacking(content))
    True
    """
    if match := AIRLOCK_AND_WALL_STACKING_RE.search(content):
        return f"At position {match.start(0)} found an airlock stacked within a wall, please remove it."


GRILL_AND_FULLTILE_WINDOW_STACKING_RE = re.compile(
    r'"\w+" = \(\n[^)]*?/obj/structure/grille[,\{]\n[^)]*?/obj/structure/window/full[/\w]*?[,\{]\n[^)]*?/area/.+\)'
)

GRILL_AND_PLASTINIUM_FULLTILE_WINDOW_STACKING_RE = re.compile(
    r'"\w+" = \(\n[^)]*?/obj/structure/grille[,\{]\n[^)]*?/obj/structure/window/full/plasmareinforced[,\{]\n[^)]*?/area/.+\)'
)


def check_grille_and_window_stacking(content):
    """
    >>> content = '''"abc" = (
    ... /obj/structure/grille,
    ... /turf/space,
    ... /area/space)'''
    >>> bool(check_grille_and_window_stacking(content))
    False

    >>> content = '''"abc" = (
    ... /obj/structure/cable{
    ... \\td2 = 2;
    ... \\ticon_state = "0-2"
    ... \\t},
    ... /obj/structure/grille,
    ... /obj/structure/window/full,
    ... /turf/space,
    ... /area/space)'''
    >>> bool(check_grille_and_window_stacking(content))
    True
    """
    if match := GRILL_AND_FULLTILE_WINDOW_STACKING_RE.search(content):
        return f"At position {match.start(0)} found grille above a fulltile window. Please replace it with the proper structure spawner."

    if match := GRILL_AND_PLASTINIUM_FULLTILE_WINDOW_STACKING_RE.search(content):
        return f"At position {match.start(0)} found grille above a fulltile plastitanium window. Please replace it with the proper structure spawner."


MULTIPLE_TURFS_RE = re.compile(
    r'"\w+" = \(\n[^)]*?/turf/[/\w]*?[,\{]\n[^)]*?/turf/[/\w]*?[,\{]\n[^)]*?/area/.+?\)'
)


def check_multiple_turfs(content):
    """
    >>> content = '''"abc" = (
    ... /turf/space,
    ... /area/space)'''
    >>> bool(check_multiple_turfs(content))
    False

    >>> content = '''"abc" = (
    ... /turf/space,
    ... /turf/space,
    ... /area/space)'''
    >>> bool(check_multiple_turfs(content))
    True
    """
    if match := MULTIPLE_TURFS_RE.search(content):
        return f"At position {match.start(0)} multiple turfs detected on the same tile. Please choose only one turf."


MULTIPLE_AREAS_RE = re.compile(r'"\w+" = \(\n[^)]*?/area/.+?,\n[^)]*?/area/.+?\)')


def check_multiple_areas(content):
    """
    >>> content = '''"abc" = (
    ... /turf/space,
    ... /area/space)'''
    >>> bool(check_multiple_areas(content))
    False

    >>> content = '''"abc" = (
    ... /turf/space,
    ... /area/foobar,
    ... /area/space)'''
    >>> bool(check_multiple_areas(content))
    True
    """
    if match := MULTIPLE_AREAS_RE.search(content):
        return f"At position {match.start(0)} multiple areas detected on the same tile. Please choose only one area."


def check_common_spelling_mistakes(filename, lines):
    for line in lines:
        if "nanotransen" in line.lower():
            return "ERROR: Misspelling of Nanotrasen detected in maps, please remove the extra N(s)."


def check_515_proc_syntax(filename, lines):
    if filename == IGNORE_515_PROC_MARKER:
        return

    for line in lines:
        if re.match(r"\.proc/", line):
            return "ERROR: Outdated proc reference use detected in code, please use proc reference helpers."


def check_space_indentation(filename, lines):
    """
    Check specifically for space-significant indentation. Excludes dmdoc
    block comment lines so long as there is an asterisk immediately after the
    leading spaces.

    >>> bool(check_space_indentation(None, ["  foo"]))
    True

    >>> bool(check_space_indentation(None, ["\\tfoo"]))
    False
    >>> bool(check_space_indentation(None, ["  * foo"]))
    False
    """
    for line in lines:
        if re.match(r"^ {2,}[^\*]", line):
            return "ERROR: Space indentation detected, please use tab indentation."


def check_mixed_indentation(filename, lines):
    """
    Check specifically for leading whitespace which contains a mix of tab and
    space characters. Excludes dmdoc block comment lines so long as there is an
    asterisk immediately after the leading whitespace.

    >>> bool(check_mixed_indentation(None, ["\\t\\t foo"]))
    True
    >>> bool(check_mixed_indentation(None, ["\\t \\t foo"]))
    True
    >>> bool(check_mixed_indentation(None, ["\\t // foo"]))
    True
    >>> bool(check_mixed_indentation(None, [" \\tfoo"]))
    True
    >>> bool(check_mixed_indentation(None, ["  \\t  foo"]))
    True

    >>> bool(check_mixed_indentation(None, ["\\t  * foo"]))
    False
    >>> bool(check_mixed_indentation(None, ["\\t\\t* foo"]))
    False
    >>> bool(check_mixed_indentation(None, ["\\t \\t  * foo"]))
    False
    """
    for line in lines:
        if re.match(r"^(\t+ | +\t)\s*[^\s\*]", line):
            return "ERROR: Mixed <tab><space> indentation detected, please stick to tab indentation."


def check_trailing_newlines(filename, lines):
    last_line = [x for x in lines][-1]
    if not last_line.endswith("\n"):
        return f"ERROR: File {filename} is missing a trailing newline"


def check_global_vars(filename, lines):
    for line in lines:
        if re.match(r"^/*var/", line):
            return "ERROR: Unmanaged global var use detected in code, please use the helpers."


def check_proc_args_with_var_prefix(filename, lines):
    for line in lines:
        if re.match(r"^/[\w/]\S+\(.*(var/|, ?var/.*).*\)", line):
            return "ERROR: Changed files contains a proc argument starting with 'var'"


BASIC_MAP_ISSUES = OrderedDict(
    {
        "basic_map_issues": (
            check_tgm,
            check_comments,
            check_conflict_markers,
            check_conflict_marker_object,
            check_iconstate_tags,
            check_step_varedits,
            check_pixel_varedits,
            check_area_varedits,
            check_base_turf_type,
            check_common_spelling_mistakes,
        ),
    }
)

FULL_CONTENT_MAP_ISSUES = OrderedDict(
    {
        "full_content_map_issues": (
            check_multiple_lattices,
            check_multiple_airlocks,
            check_multiple_firelocks,
            check_apc_pixel_shifts,
            check_lattice_and_wall_stacking,
            check_window_and_wall_stacking,
            check_airlock_and_wall_stacking,
            check_grille_and_window_stacking,
            check_multiple_turfs,
            check_multiple_areas,
        ),
    }
)

CODE_SECTIONS = OrderedDict(
    {
        "515 proc_syntax": (check_515_proc_syntax,),
        "whitespace issues": (
            check_space_indentation,
            check_mixed_indentation,
            check_trailing_newlines,
        ),
        "common mistakes": (
            check_global_vars,
            check_proc_args_with_var_prefix,
        ),
    }
)

MAP_FILE_CACHE = {}


if __name__ == "__main__":
    print("check_grep2 started")

    failure = False

    start = time.time()
    for section, parts in BASIC_MAP_ISSUES.items():
        print(f"{BLUE}Checking for {section}...{NC}")

        for idx, part in enumerate(parts):
            print(f"{GREEN} {idx+1:02} - {part.__name__.replace('_', ' ')}{NC}")

            for map_filepath in Path(".").glob("**/*.dmm"):
                if map_filepath not in MAP_FILE_CACHE:
                    MAP_FILE_CACHE[map_filepath] = open(map_filepath).read()
                map = MAP_FILE_CACHE[map_filepath]
                result = part(map_filepath, map.split("\n"))
                if result:
                    failure = True
                    print(f"{map_filepath}: {RED}{result}{NC}")

    for section, parts in FULL_CONTENT_MAP_ISSUES.items():
        print(f"{BLUE}Checking for {section}...{NC}")

        for idx, part in enumerate(parts):
            print(f"{GREEN} {idx+1:02} - {part.__name__.replace('_', ' ')}{NC}")

            for map_filepath in Path(".").glob("**/*.dmm"):
                if map_filepath not in MAP_FILE_CACHE:
                    MAP_FILE_CACHE[map_filepath] = open(map_filepath).read()
                map = MAP_FILE_CACHE[map_filepath]
                result = part(map)
                if result:
                    failure = True
                    print(f"{map_filepath}: {RED}{result}{NC}")

    for section, parts in CODE_SECTIONS.items():
        print(f"{BLUE}Checking for {section}...{NC}")

        for idx, part in enumerate(parts):
            print(f"{GREEN} {idx+1:02} - {part.__name__.replace('_', ' ')}{NC}")

            for code_filepath in Path(".").glob("**/*.dm"):
                with open(code_filepath, encoding="UTF-8") as code:
                    result = part(code_filepath, code)
                    if result:
                        failure = True
                        print(f"{code_filepath}: {RED}{result}{NC}")

    end = time.time()
    print(f"\ncheck_grep2 tests completed in {end - start:.2f}s\n")

    if failure:
        sys.exit(1)
