#!/bin/bash
set -euo pipefail

source ~/.nvm/nvm.sh

cd tgui
bin/tgui --ci
cd ..
