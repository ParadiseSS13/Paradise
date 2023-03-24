#!/bin/bash
# Generate maps
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/cyberiad/cyberiad.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/Delta/delta.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/cerestation/cerestation.dmm"
# Move and rename files so the game understands them
cd "data/nanomaps"
mv "cyberiad_nanomap_z1.png" "Cyberiad_nanomap_z1.png"
mv "delta_nanomap_z1.png" "Delta_nanomap_z1.png"
mv "cerestation_nanomap_z1.png" "Cerestation_nanomap_z1.png"
cd "../../"
cp "data/nanomaps/Cyberiad_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Delta_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Cerestation_nanomap_z1.png" "icons/_nanomaps"
