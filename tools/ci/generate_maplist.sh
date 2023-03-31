#!/bin/bash
set -euo pipefail

# This script loops through every subdir here to generate a list of all maps programatically to avoid the list getting out of date

cd _maps
find | grep -Ei ".dmm" | grep -v -e ".before" -e ".backup" > ci_map_testing.dm
sed -i -e 's/.*/#include \"&\"/' ci_map_testing.dm
echo "Generated map compile file with `wc -l ci_map_testing.dm` maps"
