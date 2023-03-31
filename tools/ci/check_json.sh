#!/bin/bash
set -euo pipefail

# We probably could validate literally everything as json5, but let's be cautions for no good reason here.
find .vscode/ -name "*.json" -print0 | xargs -0 python3 tools/ci/json_verifier.py -5
find . -name "*.json" -not -path "*/node_modules/*" -and -not -path "./.vscode/*" -print0 | xargs -0 python3 tools/ci/json_verifier.py
