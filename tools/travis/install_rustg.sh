#!/usr/bin/env bash
set -euo pipefail

source _build_dependencies.sh

mkdir -p ~/.byond/bin
wget -O ~/.byond/bin/librust_g.so "https://github.com/ParadiseSS13/rust-g/releases/download/$RUSTG_VERSION/librust_g.so"
chmod +x ~/.byond/bin/librust_g.so
ldd ~/.byond/bin/librust_g.so
