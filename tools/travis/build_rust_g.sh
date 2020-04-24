#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/ParadiseSS13/rust-g.git --depth 1

cd rust-g
cargo build --release

ln -s $PWD/target/release/librust_g.so ../librust_g.so
