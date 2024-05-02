#!/bin/bash

./InstallDeps.sh

set -e
set -x

#load dep exports
#need to switch to game dir for Dockerfile weirdness
original_dir=$PWD
cd "$1"
. dependencies.sh
cd "$original_dir"

git config --global user.name
if [ $? -eq 1 ]
then
    git config --global user.name "paradise_tgs_script"
fi

git config --global user.email
if [ $? -eq 1 ]
then
    git config --global user.email "paradise_tgs_script@invalid.com"
fi

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
./apply-patches.sh
cd paradise-rust-g
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --features all --target=i686-unknown-linux-gnu
mv target/i686-unknown-linux-gnu/release/librust_g.so "$1/librust_g.so"
cd ..

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

echo "Deploying rust-g ss220..."
RUSTFLAGS="-C target-cpu=native"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --features all --target=i686-unknown-linux-gnu
rm -f "$original_dir/../GameStaticFiles/librust_g_ss220.so"
mv target/i686-unknown-linux-gnu/release/librust_g.so "$original_dir/../GameStaticFiles/librust_g_ss220.so"
cd ../../
