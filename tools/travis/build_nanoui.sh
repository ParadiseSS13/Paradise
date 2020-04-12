#!/bin/bash
set -euo pipefail

npm install -g gulp-cli
cd nano
npm install --loglevel=error
node node_modules/gulp/bin/gulp.js --require less-loader
