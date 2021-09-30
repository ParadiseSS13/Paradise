#!/bin/bash
source _build_dependencies.sh

wget -O ~/dreamchecker "https://github.com/SpaceManiac/SpacemanDMM/releases/download/$SPACEMANDMM_TAG/dreamchecker"
chmod +x ~/dreamchecker
~/dreamchecker --version
