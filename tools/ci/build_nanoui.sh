#!/bin/bash
set -euo pipefail

cd nano
source ~/.nvm/nvm.sh
npm install --loglevel=error
node node_modules/gulp/bin/gulp.js --require less-loader
cd ..
