#!/bin/bash
set -euo pipefail

cp config/example/* config/

#Apply test DB config for SQL connectivity
rm config/dbconfig.txt
cp tools/ci/dbconfig.txt config

# Now run the server and the unit tests
DreamDaemon paradise.dmb -close -trusted -verbose

# Check if the unit tests actually suceeded
cat data/clean_run.lk
