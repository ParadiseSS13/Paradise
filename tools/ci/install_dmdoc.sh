#!/bin/bash
source _build_dependencies.sh

wget -O ~/dmdoc "https://github.com/SpaceManiac/SpacemanDMM/releases/download/$SPACEMANDMM_TAG/dmdoc"
chmod +x ~/dmdoc
~/dmdoc --version
