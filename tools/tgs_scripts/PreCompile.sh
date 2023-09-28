#!/bin/bash

./InstallDeps.sh

set -e
set -x

# Load dep exports
# Need to switch to game dir for Dockerfile weirdness
original_dir=$PWD
cd "$1"
. build_dependencies.sh
cd "$original_dir"


# update rust-g
if [ ! -d "rust-g-tg" ]; then
	echo "Cloning rust-g..."
	git clone https://github.com/ss220-space/rust-g-tg # Aziz one
	cd rust-g-tg
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
else
	echo "Fetching rust-g..."
	cd rust-g-tg
	git fetch
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
fi

echo "Deploying rust-g..."
git checkout "$RUST_G_VERSION"
RUSTFLAGS="-C target-cpu=native"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --features all --target=i686-unknown-linux-gnu
mv target/i686-unknown-linux-gnu/release/librust_g_ss220.so "$1/librust_g_ss220.so"
cd ..

# SS220 TODO: #22629 tg like compile tgui
# compile tgui
# echo "Compiling tgui..."
# cd "$1"
# env TG_BOOTSTRAP_CACHE="$original_dir" TG_BOOTSTRAP_NODE_LINUX=1 CBT_BUILD_MODE="TGS" tools/bootstrap/node tools/build/build.js
