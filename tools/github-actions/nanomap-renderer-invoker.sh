#!/bin/bash
set -e
# Generate maps
tools/github-actions/dmm-tools-para minimap --enable nanomaps --width 2040 --height 2040 "./_maps/map_files/stations/boxstation.dmm"
tools/github-actions/dmm-tools-para minimap --enable nanomaps --width 2040 --height 2040 "./_maps/map_files/stations/deltastation.dmm"
tools/github-actions/dmm-tools-para minimap --enable nanomaps --width 2040 --height 2040 "./_maps/map_files/stations/metastation.dmm"
tools/github-actions/dmm-tools-para minimap --enable nanomaps --width 2040 --height 2040 "./_maps/map_files/stations/cerestation.dmm"
tools/github-actions/dmm-tools-para minimap --enable nanomaps --width 2040 --height 2040 "./_maps/map_files/stations/emeraldstation.dmm"
# Move and rename files so the game understands them
mv "data/minimaps/boxstation-1.png" "icons/_nanomaps/BoxStation_nanomap_z1.png"
mv "data/minimaps/deltastation-1.png" "icons/_nanomaps/DeltaStation_nanomap_z1.png"
mv "data/minimaps/metastation-1.png" "icons/_nanomaps/MetaStation_nanomap_z1.png"
mv "data/minimaps/cerestation-1.png" "icons/_nanomaps/CereStation_nanomap_z1.png"
mv "data/minimaps/emeraldstation-1.png" "icons/_nanomaps/EmeraldStation_nanomap_z1.png"
