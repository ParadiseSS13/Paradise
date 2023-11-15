#!/bin/bash
set -e
# Generate maps
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files220/cyberiad/cyberiad.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files220/delta/delta.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files220/MetaStation/MetaStation.dmm"
# Move and rename files so the game understands them
cd "data/nanomaps"
mv "cyberiad_nanomap_z1.png" "Cyberiad220_nanomap_z1.png"
mv "delta_nanomap_z1.png" "Delta220_nanomap_z1.png"
mv "MetaStation_nanomap_z1.png" "MetaStation220_nanomap_z1.png"
cd "../../"
cp "data/nanomaps/Cyberiad220_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Delta220_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/MetaStation220_nanomap_z1.png" "icons/_nanomaps"
