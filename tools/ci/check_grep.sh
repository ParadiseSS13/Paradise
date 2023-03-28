#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

st=0

echo -e "${BLUE}Checking for map issues...${NC}"

if grep -El '^\".+\" = \(.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!${NC}"
	echo
    st=1
fi;
if grep -P 'Merge Conflict Marker' _maps/**/*.dmm; then
    echo -e "${RED}ERROR: Merge conflict markers detected in map, please resolve all merge failures!${NC}"
	echo
    st=1
fi;
# We check for this as well to ensure people aren't actually using this mapping effect in their maps.
if grep -P '/obj/merge_conflict_marker' _maps/**/*.dmm; then
    echo -e "${RED}ERROR: Merge conflict markers detected in map, please resolve all merge failures!${NC}"
	echo
    st=1
fi;
# TODO: Uncomment in the future, when our maps are standardized
# if grep -P '^\ttag = \"icon' _maps/**/*.dmm;	then
#     echo -e "${RED}ERROR: Tag vars from icon state generation detected in maps, please remove them.${NC}"
# 	echo
#     st=1
# fi;
if grep -P 'step_[xy]' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: step_x/step_y variables detected in maps, please remove them.${NC}"
	echo
    st=1
fi;
if grep -P 'pixel_[^xy]' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: incorrect pixel offset variables detected in maps, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/cable,\n[^)]*?/obj/structure/cable,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple cables on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple lattices on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/atmospherics/pipe/(?<type>[/\w]*),\n[^)]*?/obj/machinery/atmospherics/pipe/\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple identical pipes on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/barricade(?<type>[/\w]*),\n[^)]*?/obj/structure/barricade\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple identical barricades on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/table(?<type>[/\w]*),\n[^)]*?/obj/structure/table\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple identical tables on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/chair(?<type>[/\w]*),\n[^)]*?/obj/structure/chair\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple identical chairs on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple airlocks on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/door/firedoor[/\w]*?,\n[^)]*?/obj/machinery/door/firedoor[/\w]*?,\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple firelocks on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/closet(?<type>[/\w]*),\n[^)]*?/obj/structure/closet\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple identical closets on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/grille(?<type>[/\w]*),\n[^)]*?/obj/structure/grille/\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple identical grilles on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/girder(?<type>[/\w]*),\n[^)]*?/obj/structure/girder\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple identical girders on the same tile, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?(/[^{]+\{[^}]*?(((\n\s*(?<var>\w+)\s*=.*);[^}]*?\n\s*(\g{var})\s*=.*)+)[^}]*?\})+[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found multiple set of same atom variable, please remove them.${NC}"
	echo
    st=1
fi;
# TODO: Uncomment in the future, when our maps are standardized
# if grep -rzoP 'machinery/door.*{([^}]|\n)*name = .*("|\s)(?!of|and|to)[a-z].*\n' _maps/**/*.dmm;	then
#     echo -e "${RED}ERROR: Found door names without proper upper-casing. Please upper-case your door names.${NC}"
#     echo
#     st=1
# fi;
# TODO: Uncomment in the future, when our maps are standardized
# if grep -Pzo '/obj/machinery/power/apc[/\w]*?\{\n[^}]*?pixel_[xy] = -?[013-9]\d*?[^\d]*?\s*?\},?\n' _maps/map_files/cyberiad/cyberiad.dmm ||
# 	grep -Pzo '/obj/machinery/power/apc[/\w]*?\{\n[^}]*?pixel_[xy] = -?\d+?[0-46-9][^\d]*?\s*?\},?\n' _maps/map_files/cyberiad/cyberiad.dmm ||
# 	grep -Pzo '/obj/machinery/power/apc[/\w]*?\{\n[^}]*?pixel_[xy] = -?\d{3,1000}[^\d]*?\s*?\},?\n' _maps/map_files/cyberiad/cyberiad.dmm ;	then
#     echo -e "${RED}ERROR: Found an APC with a manually set pixel_x or pixel_y that is not +-25. Use the directional variants when possible.${NC}"
# 	echo
#     st=1
# fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/turf/closed/wall[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found a lattice stacked with a wall, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found a lattice stacked within a wall, please remove them.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/window[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found a window stacked within a wall, please remove it.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found an airlock stacked within a wall, please remove it.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/grille,\n[^)]*?/obj/structure/window[/\w]*?fulltile,\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found grille above a fulltile window. Please replace it with the proper structure spawner.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/grille,\n[^)]*?/obj/structure/window/reinforced/plasma/plastitanium,\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Found grille above a fulltile plastitanium window. Please replace it with the proper structure spawner.${NC}"
	echo
    st=1
fi;
if grep -P '^/area/.+[\{]' _maps/**/*.dmm;	then
    echo -e "${RED}ERROR: Variable editted /area path use detected in a map, please replace with a proper area path.${NC}"
	echo
    st=1
fi;
if grep -P '\W\/turf\s*[,\){]' _maps/**/*.dmm; then
    echo -e "${RED}ERROR: Base /turf path use detected in maps, please replace a with proper turf path.${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/turf/[/\w]*?,\n[^)]*?/turf/[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm; then
    echo -e "${RED}ERROR: Multiple turfs detected on the same tile! Please choose only one turf!${NC}"
	echo
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/area/.+?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm; then
    echo -e "${RED}ERROR: Multiple areas detected on the same tile! Please choose only one area!${NC}"
	echo
    st=1
fi;
if grep -ni 'nanotransen' _maps/**/*.dmm; then
    echo -e "${RED}ERROR: Misspelling of Nanotrasen detected in maps, please remove the extra N(s).${NC}"
	echo
    st=1
fi;

echo -e "${BLUE}Checking for whitespace issues...${NC}"

# TODO: Uncomment in the future, when our code are standardized
# if grep -P '(^ {2})|(^ [^ * ])|(^    +)' code/**/*.dm; then
#     echo -e "${RED}ERROR: Space indentation detected, please use tab indentation.${NC}"
# 	echo
#     st=1
# fi;
# TODO: Uncomment in the future, when our code are standardized
# if grep -P '^\t+ [^ *]' code/**/*.dm; then
#     echo -e "${RED}ERROR: Mixed <tab><space> indentation detected, please stick to tab indentation.${NC}"
# 	echo
#     st=1
# fi;
nl='
'
nl=$'\n'
while read f; do
    t=$(tail -c2 "$f"; printf x); r1="${nl}$"; r2="${nl}${r1}"
    if [[ ! ${t%x} =~ $r1 ]]; then
        echo -e "${RED}ERROR: file $f is missing a trailing newline.${NC}"
		echo
        st=1
    fi;
done < <(find . -type f -name '*.dm')

echo -e "${BLUE}Checking for common mistakes...${NC}"

if grep -P 'to_chat\((?!.*,).*\)' code/**/*.dm; then
    echo -e "${RED}ERROR: to_chat() missing arguments.${NC}"
	echo
    st=1
fi;
if grep -P 'addtimer\((?=.*TIMER_OVERRIDE)(?!.*TIMER_UNIQUE).*\)' code/**/*.dm; then
    echo -e "${RED}ERROR: TIMER_OVERRIDE used without TIMER_UNIQUE.${NC}"
	echo
    st=1
fi;
if grep -P '^/*var/' code/**/*.dm; then
    echo -e "${RED}ERROR: Unmanaged global var use detected in code, please use the helpers.${NC}"
	echo
    st=1
fi;
# TODO: Uncomment in the future, when our code are standardized
# if grep -P '^/[\w/]\S+\(.*(var/|, ?var/.*).*\)' code/**/*.dm; then
#     echo -e "${RED}ERROR: Changed files contains a proc argument starting with 'var'.${NC}"
# 	echo
#     st=1
# fi;
if grep -ni 'nanotransen' code/**/*.dm; then
    echo -e "${RED}ERROR: Misspelling(s) of Nanotrasen detected in code, please remove the extra N(s).${NC}"
	echo
    st=1
fi;
if grep -i '/obj/effect/mapping_helpers/custom_icon' _maps/**/*.dmm; then
    echo -e "${RED}ERROR: Custom icon helper found. Please include DMI files as standard assets instead for repository maps.${NC}"
	echo
    st=1
fi;

if [ $st = 0 ]; then
    echo -e "${GREEN}No errors found using grep!${NC}"
    echo
fi;

if [ $st = 1 ]; then
    echo -e "${RED}Errors found, please fix them and try again.${NC}"
    echo
fi;

exit $st
