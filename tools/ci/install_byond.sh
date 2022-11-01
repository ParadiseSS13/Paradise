#!/bin/bash
set -eo pipefail

source _build_dependencies.sh

TARGET_MAJOR=$STABLE_BYOND_MAJOR
TARGET_MINOR=$STABLE_BYOND_MINOR

if [ -z "$1" ]; then
	echo "No arg specified. Assuming STABLE."
else
	if [ "$1" == "BETA" ]; then
		TARGET_MAJOR=$BETA_BYOND_MAJOR
		TARGET_MINOR=$BETA_BYOND_MINOR
	fi
fi

if [ -d "$HOME/BYOND/byond/bin" ] && grep -Fxq "${TARGET_MAJOR}.${TARGET_MINOR}" $HOME/BYOND/version.txt;
then
  echo "Using cached directory."
else
  echo "Setting up BYOND."
  rm -rf "$HOME/BYOND"
  mkdir -p "$HOME/BYOND"
  cd "$HOME/BYOND"
  curl "http://www.byond.com/download/build/${TARGET_MAJOR}/${TARGET_MAJOR}.${TARGET_MINOR}_byond_linux.zip" -o byond.zip
  unzip byond.zip
  rm byond.zip
  cd byond
  make here
  echo "$TARGET_MAJOR.$TARGET_MINOR" > "$HOME/BYOND/version.txt"
  cd ~/
fi
