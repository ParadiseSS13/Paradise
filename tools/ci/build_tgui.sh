#!/bin/bash
set -euo pipefail

source _build_dependencies.sh

source ~/.nvm/nvm.sh
nvm use $NODE_VERSION
cd tgui
bin/tgui --ci
cd ..
