#!/bin/bash
set -euo pipefail

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

# BYOND needs the 32-bit libcurl. The packages are kept in the BYOND cache, so cached runs skip apt-get update
sudo dpkg --add-architecture i386
if [ ! -d "$HOME/BYOND/i386_debs" ]; then
  # The runner's package mirror sometimes can't be reached for a minute, so this tries a few times
  for attempt in 1 2 3; do
    sudo apt-get update || true
    sudo apt-get clean
    if sudo apt-get install -y --download-only libcurl4:i386; then
      break
    fi
    if [ "$attempt" -eq 3 ]; then
      echo "::error title=apt-get failed::Could not download the 32-bit libcurl BYOND needs. The Ubuntu package mirror was probably down, re-running the job should fix it."
      exit 1
    fi
    echo "Downloading libcurl failed, trying again in 20 seconds"
    sleep 20
  done
  mkdir -p "$HOME/BYOND/i386_debs"
  cp /var/cache/apt/archives/*.deb "$HOME/BYOND/i386_debs/"
fi
sudo dpkg -i --force-unsafe-io "$HOME/BYOND/i386_debs/"*.deb
