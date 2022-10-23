#!/usr/bin/env bash
set -euo pipefail

source _build_dependencies.sh

mkdir -p ~/.byond/bin
wget -O ~/.byond/bin/libdmjit.so "https://github.com/ss220-space/dmjit/releases/download/$DMJIT_VERSION/libdmjit.so"
chmod +x ~/.byond/bin/libdmjit.so
ldd ~/.byond/bin/libdmjit.so
