#!/bin/bash

#find out what we have (+e is important for this)
set +e
has_git="$(command -v git)"
has_curl="$(command -v curl)"
has_cargo="$(command -v ~/.cargo/bin/cargo)"
has_sudo="$(command -v sudo)"
set -e
set -x

# apt packages, libssl needed by rust-g but not included in TGS barebones install
# These basically only work on ubuntu+debian
if ! ( [ -x "$has_git" ] && [ -x "$has_curl" ] && [ -f "/usr/lib/i386-linux-gnu/libssl.so" ] ); then
	echo "Installing apt dependencies..."
	if ! [ -x "$has_sudo" ]; then
		dpkg --add-architecture i386
		apt-get update
		apt-get install -y lib32z1 git pkg-config libssl-dev:i386 libssl-dev zlib1g-dev:i386 curl gcc libdbus-1-dev
		apt-get install -y gcc:i386
	else
		sudo dpkg --add-architecture i386
		sudo apt-get update
		sudo apt-get install -y lib32z1 git pkg-config libssl-dev:i386 libssl-dev zlib1g-dev:i386 curl gcc libdbus-1-dev
		sudo apt-get install -y gcc:i386
	fi
fi

# install cargo if needed
if ! [ -x "$has_cargo" ]; then
	echo "Installing rust..."
	curl https://sh.rustup.rs -sSf | sh -s -- -y
	. ~/.profile
fi
