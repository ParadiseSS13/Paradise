#!/bin/bash

# Make is fail early if theres a problem
set -euo pipefail

# Get to our folder first
cd rust

WINDOWS_TARGET="i686-pc-windows-gnu"
LINUX_TARGET="i686-unknown-linux-gnu"

# Handle building on windows
if [[ "$OSTYPE" == "msys" ]]; then
	WINDOWS_TARGET="i686-pc-windows-msvc"
fi

# Build it for CI
cargo build --release --target $LINUX_TARGET
cp target/$LINUX_TARGET/release/librustlibs.so ../tools/ci/librustlibs_ci.so
#cargo clean
#cargo build --release --target $LINUX_TARGET --no-default-features --features byond-516
#cp target/$LINUX_TARGET/release/librustlibs.so ../tools/ci/librustlibs_ci_516.so

# Build it for Windows
cargo build --release --target $WINDOWS_TARGET
cp target/$WINDOWS_TARGET/release/rustlibs.dll ../rustlibs.dll
#cargo clean
#cargo build --release --target $WINDOWS_TARGET --no-default-features --features byond-516
#cp target/$WINDOWS_TARGET/release/rustlibs.dll ../rustlibs_516.dll

# Build the para-specific version
export RUSTFLAGS='-C target-cpu=znver5'
cargo build --release --target=$WINDOWS_TARGET
cp target/$WINDOWS_TARGET/release/rustlibs.dll ../rustlibs_prod.dll
#cargo clean
#cargo build --release --target=$WINDOWS_TARGET --no-default-features --features byond-516
#cp target/$WINDOWS_TARGET/release/rustlibs.dll ../rustlibs_516_prod.dll
