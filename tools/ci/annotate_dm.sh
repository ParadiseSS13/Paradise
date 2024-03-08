#!/bin/bash

set -euo pipefail
python tools/ci/annotate_dm.py "$@"
