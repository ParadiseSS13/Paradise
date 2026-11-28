#!/bin/bash
set -euo pipefail

original_cwd=$(pwd)

cd tools/ci/input_checker
cargo build --release
cd $original_cwd
tools/ci/input_checker/target/release/dmb-inputs paradise.dmb
