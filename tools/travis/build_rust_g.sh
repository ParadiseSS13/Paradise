#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/ParadiseSS13/rust-g.git --depth 1

cd rust-g
# Install and prepare rust for building
source ~/.cargo/env
curl https://sh.rustup.rs -sSf | sh -s -- -y --default-host i686-unknown-linux-gnu

# Build it
cargo build --release

# Symlink it to the next dir down (Server root)
ln -s $PWD/target/release/librust_g.so ../librust_g.so
