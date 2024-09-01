#!/bin/bash

./InstallDeps.sh

set -e
set -x

#load dep exports
#need to switch to game dir for Dockerfile weirdness
original_dir=$PWD
cd "$1"
. _build_dependencies.sh
cd "$original_dir"

# update rust-g
if [ ! -d "rust-g" ]; then
	echo "Cloning rust-g..."
	git clone https://github.com/ParadiseSS13/rust-g
	cd rust-g
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
else
	echo "Fetching rust-g..."
	cd rust-g
	git fetch
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
fi

echo "Deploying rust-g..."
git reset --hard "$RUSTG_VERSION"
./apply_patches.sh
cd paradise-rust-g
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --features all --target=i686-unknown-linux-gnu
mv target/i686-unknown-linux-gnu/release/librust_g.so "$1/librust_g.so"
cd ../../

if [ ! -d "rust-utils" ]; then
	echo "Cloning rust-utils..."
	git clone https://github.com/ss220club/rust-utils
	cd rust-utils
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
else
	echo "Fetching rust-utils..."
	cd rust-utils
	git fetch
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
fi

echo "Deploying rustutils..."
RUSTFLAGS="-C target-cpu=native"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --all-features --target=i686-unknown-linux-gnu
mv target/i686-unknown-linux-gnu/release/librust_utils.so "$1/librust_utils.so"
cd ../../

echo "Deploying MILLA..."
cd $1/milla
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --features all --target=i686-unknown-linux-gnu
mv target/i686-unknown-linux-gnu/release/libmilla.so "$1/libmilla.so"
cd ..
