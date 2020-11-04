#!/bin/bash
# Generate maps
tools/github-actions/nanomap-renderer minimap "./_maps/map_files/cyberiad/cyberiad.dmm"
tools/github-actions/nanomap-renderer minimap "./_maps/map_files/Delta/delta.dmm"
tools/github-actions/nanomap-renderer minimap "./_maps/map_files/MetaStation/MetaStation.v41A.II.dmm"
# Move and rename files so the game understands them
cd "data/nanomaps"
mv "cyberiad_nanomap_z1.png" "Cyberiad_nanomap_z1.png"
mv "delta_nanomap_z1.png" "Delta_nanomap_z1.png"
mv "MetaStation.v41A.II_nanomap_z1.png" "MetaStation_nanomap_z1.png"
cd "../../"
cp "data/nanomaps/Cyberiad_nanomap_z1.png" "nano/images"
cp "data/nanomaps/Delta_nanomap_z1.png" "nano/images"
cp "data/nanomaps/MetaStation_nanomap_z1.png" "nano/images"
