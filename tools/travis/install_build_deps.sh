#!/bin/bash
set -euo pipefail

source _build_dependencies.sh

source ~/.nvm/nvm.sh
nvm install $NODE_VERSION

pip install --user PyYaml -q
pip install --user beautifulsoup4 -q

phpenv global $PHP_VERSION
