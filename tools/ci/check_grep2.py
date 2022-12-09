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


def check_multiple_lattices(filename, lines):
    for line in lines:
        if re.match(
            r'"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/area/.+?\)',
            line,
        ):
            return (
                "ERROR: Found multiple lattices on the same tile, please remove them."
            )


def check_multiple_airlocks(filename, lines):
    for line in lines:
        if re.match(
            r'"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/area/.+\)',
            line,
        ):
            return (
                "ERROR: Found multiple airlocks on the same tile, please remove them."
            )


def check_multiple_firelocks(filename, lines):
    for line in lines:
        if re.match(
            r'"\w+" = \(\n[^)]*?/obj/machinery/door/firedoor[/\w]*?,\n[^)]*?/obj/machinery/door/firedoor[/\w]*?,\n[^)]*?/area/.+\)',
            line,
        ):
            return (
                "ERROR: Found multiple firelocks on the same tile, please remove them."
            )


def check_apc_pixel_shifts(filename, lines):
    invalid_res = [
        r"/obj/machinery/power/apc[/\w]*?[{]\n[^}]*?pixel_[xy] = -?[013-9]\d*?[^\d]*?\s*?[}],?\n",
        r"/obj/machinery/power/apc[/\w]*?[{]\n[^}]*?pixel_[xy] = -?\d+?[0-46-9][^\d]*?\s*?[}],?\n",
        r"/obj/machinery/power/apc[/\w]*?[{]\n[^}]*?pixel_[xy] = -?\d{3,1000}[^\d]*?\s*?[}],?\n",
    ]
    for line in lines:
        for invalid_re in invalid_res:
            if re.match(invalid_re, line):
                return "ERROR: Found an APC with a manually set pixel_x or pixel_y that is not +-25. Use the directional variants when possible."


def check_lattice_and_wall_stacking(filename, lines):
    for line in lines:
        if re.match(
            r'"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/turf/simulated/wall[/\w]*?,\n[^)]*?/area/.+?\)',
            line,
        ):
            return "ERROR: Found a lattice stacked within a wall, please remove them."


def check_window_and_wall_stacking(filename, lines):
    for line in lines:
        if re.match(
            r'"\w+" = \(\n[^)]*?/obj/structure/window[/\w]*?,\n[^)]*?/turf/simulated/wall[/\w]*?,\n[^)]*?/area/.+?\)',
            line,
        ):
            return "ERROR: Found a window stacked within a wall, please remove it."


def check_airlock_and_wall_stacking(filename, lines):
    for line in lines:
        if re.match(
            r'"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/turf/simulated/wall[/\w]*?,\n[^)]*?/area/.+?\)',
            line,
        ):
            return "ERROR: Found an airlock stacked within a wall, please remove it."


def check_grille_and_window_stacking(filename, lines):
    for line in lines:
        if re.match(
            r'"\w+" = \(\n[^)]*?/obj/structure/grille,\n[^)]*?/obj/structure/window/full[/\w]*?,\n[^)]*?/area/.+\)',
            line,
        ):
            return "ERROR: Found grille above a fulltile window. Please replace it with the proper structure spawner."
        if re.match(
            r'"\w+" = \(\n[^)]*?/obj/structure/grille,\n[^)]*?/obj/structure/window/full/plasmareinforced,\n[^)]*?/area/.+\)',
            line,
        ):
            return "ERROR: Found grille above a fulltile plastitanium window. Please replace it with the proper structure spawner."


def check_area_varedits(filename, lines):
    for line in lines:
        if re.match(r"^/area/.+[{]", line):
            return "ERROR: Variable editted /area path use detected in a map, please replace with a proper area path."


def check_base_turf_type(filename, lines):
    for line in lines:
        if re.match(r"/turf\s*[,\){]", line):
            return "ERROR: Base /turf path use detected in maps, please replace it with a proper turf path."


def check_multiple_turfs(filename, lines):
    for line in lines:
        if re.match(
            r'"\w+" = \(\n[^)]*?/turf/[/\w]*?,\n[^)]*?/turf/[/\w]*?,\n[^)]*?/area/.+?\)',
            line,
        ):
            return "ERROR: Multiple turfs detected on the same tile! Please choose only one turf!"


def check_multiple_areas(filename, lines):
    for line in lines:
        if re.match(r'"\w+" = \(\n[^)]*?/area/.+?,\n[^)]*?/area/.+?\)', line):
            return "ERROR: Multiple areas detected on the same tile! Please choose only one area!"


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
    for line in lines:
        if re.match(r"^ {2,}[^\*]", line):
            return "ERROR: Space indentation detected, please use tab indentation."


def check_mixed_indentation(filename, lines):
    for line in lines:
        if re.match(r"^(\t+ | +\t)\s*[^ \*]", line):
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


MAP_SECTIONS = OrderedDict(
    {
        "map_issues": (
            check_tgm,
            check_comments,
            check_conflict_markers,
            check_conflict_marker_object,
            check_iconstate_tags,
            check_step_varedits,
            check_pixel_varedits,
            check_multiple_lattices,
            check_multiple_airlocks,
            check_multiple_firelocks,
            check_apc_pixel_shifts,
            check_lattice_and_wall_stacking,
            check_window_and_wall_stacking,
            check_airlock_and_wall_stacking,
            check_grille_and_window_stacking,
            check_area_varedits,
            check_base_turf_type,
            check_multiple_turfs,
            check_multiple_areas,
            check_common_spelling_mistakes,
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


if __name__ == "__main__":
    print("check_grep2 started")

    failure = False

    start = time.time()
    for section, parts in MAP_SECTIONS.items():
        print(f"{BLUE}Checking for {section}...{NC}")

        for idx, part in enumerate(parts):
            print(f"{GREEN} {idx+1:02} - {part.__name__.replace('_', ' ')}{NC}")

            for map_filepath in Path(".").glob("**/*.dmm"):
                with open(map_filepath) as map:
                    result = part(map_filepath, map)
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
