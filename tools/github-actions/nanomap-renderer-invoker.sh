#!/bin/bash
set -e
# Generate maps
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files220/stations/boxstation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files220/stations/deltastation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files220/stations/metastation.dmm"
# Move and rename files so the game understands them
cd "data/nanomaps"
mv "boxstation_nanomap_z1.png" "Cyberiad220_nanomap_z1.png"
mv "deltastation_nanomap_z1.png" "Delta220_nanomap_z1.png"
mv "metastation_nanomap_z1.png" "MetaStation220_nanomap_z1.png"
cd "../../"
cp "data/nanomaps/Cyberiad220_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Delta220_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/MetaStation220_nanomap_z1.png" "icons/_nanomaps"
