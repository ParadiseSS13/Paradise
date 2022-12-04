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

# check for ripgrep
if command -v rg >/dev/null 2>&1; then
	grep=rg
	pcre2_support=1
	if [ ! rg -P '' >/dev/null 2>&1 ] ; then
		pcre2_support=0
	fi
	code_files="-g *.dm"
	map_files="-g *.dmm"
	ignore_515_proc_marker='-g !__byond_version_compat.dm'
else
	pcre2_support=0
	grep=grep
	code_files="-r --include=*.dm"
	map_files="-r --include=*.dmm"
	ignore_515_proc_marker="--exclude=__byond_version_compat.dm"
fi

echo -e "${BLUE}Using grep provider at $(which $grep)${NC}"

part=0
section() {
	echo -e "${BLUE}Checking for $1${NC}..."
	part=0
}

part() {
	part=$((part+1))
	padded=$(printf "%02d" $part)
	echo -e "${GREEN} $padded- $1${NC}"
}


section "map issues"
part "TGM"
if $grep -U '^".+" = \(.+\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!${NC}"
	st=1
fi;
part "comments"
if $grep '//' $map_files | $grep -v '//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE' | $grep -v 'name|desc'; then
	echo
	echo -e "${RED}ERROR: Unexpected commented out line detected in this map file. Please remove it.${NC}"
	st=1
fi;
part "conflict markers"
if $grep 'Merge Conflict Marker' $map_files; then
	echo
	echo -e "${RED}ERROR: Merge conflict markers detected in map, please resolve all merge failures!${NC}"
	st=1
fi;
# We check for this as well to ensure people aren't actually using this mapping effect in their maps.
part "conflict marker object"
if $grep '/obj/merge_conflict_marker' $map_files; then
	echo
	echo -e "${RED}ERROR: Merge conflict markers detected in map, please resolve all merge failures!${NC}"
	st=1
fi;
part "iconstate tags"
if $grep '^\ttag = "icon' $map_files;	then
	echo
	echo -e "${RED}ERROR: Tag vars from icon state generation detected in maps, please remove them.${NC}"
	st=1
fi;
part "step varedits"
if $grep 'step_[xy]' $map_files;	then
	echo
	echo -e "${RED}ERROR: step_x/step_y variables detected in maps, please remove them.${NC}"
	st=1
fi;
part "pixel varedits"
if $grep 'pixel_[^xy]' $map_files;	then
	echo
	echo -e "${RED}ERROR: incorrect pixel offset variables detected in maps, please remove them.${NC}"
	st=1
fi;
part "multiple lattices"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Found multiple lattices on the same tile, please remove them.${NC}"
	st=1
fi;
part "multiple airlocks"
if $grep -U '"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/area/.+\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Found multiple airlocks on the same tile, please remove them.${NC}"
	st=1
fi;
part "multiple firelocks"
if $grep -U '"\w+" = \(\n[^)]*?/obj/machinery/door/firedoor[/\w]*?,\n[^)]*?/obj/machinery/door/firedoor[/\w]*?,\n[^)]*?/area/.+\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Found multiple firelocks on the same tile, please remove them.${NC}"
	st=1
fi;
part "apc pixel shifts"
if $grep -U '/obj/machinery/power/apc[/\w]*?[{]\n[^}]*?pixel_[xy] = -?[013-9]\d*?[^\d]*?\s*?[}],?\n' $map_files ||
	$grep -U '/obj/machinery/power/apc[/\w]*?[{]\n[^}]*?pixel_[xy] = -?\d+?[0-46-9][^\d]*?\s*?[}],?\n' $map_files ||
	$grep -U '/obj/machinery/power/apc[/\w]*?[{]\n[^}]*?pixel_[xy] = -?\d{3,1000}[^\d]*?\s*?[}],?\n' $map_files ;	then
	echo
	echo -e "${RED}ERROR: Found an APC with a manually set pixel_x or pixel_y that is not +-25. Use the directional variants when possible.${NC}"
	st=1
fi;
part "lattice and wall stacking"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/turf/simulated/wall[/\w]*?,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Found a lattice stacked within a wall, please remove them.${NC}"
	st=1
fi;
part "window and wall stacking"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/window[/\w]*?,\n[^)]*?/turf/simulated/wall[/\w]*?,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Found a window stacked within a wall, please remove it.${NC}"
	st=1
fi;
part "airlock and wall stacking"
if $grep -U '"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/turf/simulated/wall[/\w]*?,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Found an airlock stacked within a wall, please remove it.${NC}"
	st=1
fi;
part "grille and window stacking"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/grille,\n[^)]*?/obj/structure/window/full[/\w]*?,\n[^)]*?/area/.+\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Found grille above a fulltile window. Please replace it with the proper structure spawner.${NC}"
	st=1
fi;
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/grille,\n[^)]*?/obj/structure/window/full/plasmareinforced,\n[^)]*?/area/.+\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Found grille above a fulltile plastitanium window. Please replace it with the proper structure spawner.${NC}"
	st=1
fi;
part "area varedits"
if $grep '^/area/.+[{]' $map_files;	then
	echo
	echo -e "${RED}ERROR: Variable editted /area path use detected in a map, please replace with a proper area path.${NC}"
	st=1
fi;
part "base turf type"
if $grep '/turf\s*[,\){]' $map_files; then
	echo
	echo -e "${RED}ERROR: Base /turf path use detected in maps, please replace it with a proper turf path.${NC}"
	st=1
fi;
part "multiple turfs"
if $grep -U '"\w+" = \(\n[^)]*?/turf/[/\w]*?,\n[^)]*?/turf/[/\w]*?,\n[^)]*?/area/.+?\)' $map_files; then
	echo
	echo -e "${RED}ERROR: Multiple turfs detected on the same tile! Please choose only one turf!${NC}"
	st=1
fi;
part "multiple areas"
if $grep -U '"\w+" = \(\n[^)]*?/area/.+?,\n[^)]*?/area/.+?\)' $map_files; then
	echo
	echo -e "${RED}ERROR: Multiple areas detected on the same tile! Please choose only one area!${NC}"
	st=1
fi;
part "common spelling mistakes"
if $grep -i 'nanotransen' $map_files; then
	echo
	echo -e "${RED}ERROR: Misspelling of Nanotrasen detected in maps, please remove the extra N(s).${NC}"
	st=1
fi;



section "515 Proc Syntax"
part "proc ref syntax"
if $grep '\.proc/' $code_files $ignore_515_proc_marker; then
	echo
	echo -e "${RED}ERROR: Outdated proc reference use detected in code, please use proc reference helpers.${NC}"
	st=1
fi;



section "whitespace issues"
part "space indentation"
if $grep '(^ {2})|(^ [^ * ])|(^	+)' $code_files; then
	echo
	echo -e "${RED}ERROR: Space indentation detected, please use tab indentation.${NC}"
	st=1
fi;
part "mixed indentation"
if $grep '^\t+ [^ *]' $code_files; then
	echo
	echo -e "${RED}ERROR: Mixed <tab><space> indentation detected, please stick to tab indentation.${NC}"
	st=1
fi;
part "trailing newlines"
nl='
'
nl=$'\n'
while read f; do
	t=$(tail -c2 "$f"; printf x); r1="${nl}$"; r2="${nl}${r1}"
	if [[ ! ${t%x} =~ $r1 ]]; then
		echo "${RED}ERROR: File $f is missing a trailing newline"
		st=1
	fi;
done < <(find . -type f -name '*.dm')


section "common mistakes"
part "global vars"
if $grep '^/*var/' $code_files; then
	echo
	echo -e "${RED}ERROR: Unmanaged global var use detected in code, please use the helpers.${NC}"
	st=1
fi;
part "proc args with var/"
if $grep '^/[\w/]\S+\(.*(var/|, ?var/.*).*\)' $code_files; then
	echo
	echo -e "${RED}ERROR: Changed files contains a proc argument starting with 'var'.${NC}"
	st=1
fi;



exit $st
