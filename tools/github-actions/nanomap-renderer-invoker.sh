#!/bin/bash
set -e
# Generate maps
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/stations/boxstation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/stations/deltastation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/stations/metastation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/stations/cerestation.dmm"
# Move and rename files so the game understands them
cd "data/nanomaps"
mv "boxstation_nanomap_z1.png" "Cyberiad_nanomap_z1.png"
mv "deltastation_nanomap_z1.png" "Delta_nanomap_z1.png"
mv "metastation_nanomap_z1.png" "MetaStation_nanomap_z1.png"
mv "cerestation_nanomap_z1.png" "CereStation_nanomap_z1.png"
cd "../../"
cp "data/nanomaps/Cyberiad_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Delta_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/MetaStation_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/CereStation_nanomap_z1.png" "icons/_nanomaps"
