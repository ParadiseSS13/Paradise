#!/bin/bash

./InstallDeps.sh

set -e
set -x

# Load dep exports
# Need to switch to game dir for Dockerfile weirdness
original_dir=$PWD
cd "$1"
. _build_dependencies.sh
cd "$original_dir"


# update rust-g
if [ ! -d "rust-g-tg" ]; then
	echo "Cloning rust-g..."
	git clone https://github.com/ss220club/rust-g-tg
	cd rust-g-tg
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
else
	echo "Fetching rust-g..."
	cd rust-g-tg
	git fetch
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
fi

echo "Deploying rust-g..."
RUSTFLAGS="-C target-cpu=native"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --features all --target=i686-unknown-linux-gnu
rm -f "$original_dir/../GameStaticFiles/librust_g_ss220.so"
mv target/i686-unknown-linux-gnu/release/librust_g.so "$original_dir/../GameStaticFiles/librust_g_ss220.so"
cd ..

# SS220 TODO: compile aa's rustg natively too

# SS220 TODO: tg like compile tgui
# compile tgui
# echo "Compiling tgui..."
# cd "$1"
# env TG_BOOTSTRAP_CACHE="$original_dir" TG_BOOTSTRAP_NODE_LINUX=1 CBT_BUILD_MODE="TGS" tools/bootstrap/node tools/build/build.js
