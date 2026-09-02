#!/bin/bash
set -euo pipefail

# This is needed now
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt install libcurl4:i386

if [ -z "${BYOND_MAJOR+x}" ]; then
  source _build_dependencies.sh
  # if some other build step hasn't specified the specific BYOND version we're not
  # gonna get it straight from _build_dependencies.sh so one more fallback here
  BYOND_MAJOR=$STABLE_BYOND_MAJOR
  BYOND_MINOR=$STABLE_BYOND_MINOR

  if [ -z "$1" ]; then
    echo "No arg specified. Assuming STABLE."
  else
    if [ "$1" == "BETA" ]; then
      BYOND_MAJOR=$BETA_BYOND_MAJOR
      BYOND_MINOR=$BETA_BYOND_MINOR
    fi
  fi
fi

if [ -d "$HOME/BYOND/byond/bin" ] && grep -Fxq "${BYOND_MAJOR}.${BYOND_MINOR}" $HOME/BYOND/version.txt;
then
  echo "Using cached directory."
else
  echo "Setting up BYOND."
  rm -rf "$HOME/BYOND"
  mkdir -p "$HOME/BYOND"
  cd "$HOME/BYOND"
  curl -H "User-Agent: ParadiseSS13/1.0 CI Script" "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip
  unzip byond.zip
  rm byond.zip
  cd byond
  make here
  echo "$BYOND_MAJOR.$BYOND_MINOR" > "$HOME/BYOND/version.txt"
  cd ~/
fi
