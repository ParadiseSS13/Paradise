#!/bin/bash
set -uo pipefail

# Compiles with DreamMaker, the arguments are passed through
# Compile errors and warnings are also shown on the lines they are on in the PR's changed files
log="$(mktemp)"
DreamMaker "$@" 2>&1 | tee "$log"
result=${PIPESTATUS[0]}

# Lines look like "code/file.dm:12:error: message" or "code/file.dm:12:warning (unused_var): message"
sed -nE 's/^([^:]+):([0-9]+):(error|warning)[^:]*: (.*)$/::\3 file=\1,line=\2::\4/p' "$log"
rm -f "$log"
exit $result
