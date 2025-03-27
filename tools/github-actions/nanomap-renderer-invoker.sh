#!/bin/bash
set -e
# Generate maps
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/stations/boxstation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/stations/deltastation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/stations/metastation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/stations/cerestation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/stations/emeraldstation.dmm"
# Move and rename files so the game understands them
cd "data/nanomaps"
mv "boxstation_nanomap_z1.png" "BoxStation_nanomap_z1.png"
mv "deltastation_nanomap_z1.png" "DeltaStation_nanomap_z1.png"
mv "metastation_nanomap_z1.png" "MetaStation_nanomap_z1.png"
mv "cerestation_nanomap_z1.png" "CereStation_nanomap_z1.png"
mv "emeraldstation_nanomap_z1.png" "EmeraldStation_nanomap_z1.png"
cd "../../"
cp "data/nanomaps/BoxStation_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/DeltaStation_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/MetaStation_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/CereStation_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/EmeraldStation_nanomap_z1.png" "icons/_nanomaps"
