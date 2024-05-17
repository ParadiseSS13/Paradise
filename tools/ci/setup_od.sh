#!/bin/bash
set -eo pipefail

git clone https://github.com/OpenDreamProject/OpenDream.git OpenDream
cd OpenDream
git submodule update --init --recursive
# Below is temp until OD is fixed
cp ../tools/ci/global.json .
# end temp
dotnet restore
dotnet build -c Release
