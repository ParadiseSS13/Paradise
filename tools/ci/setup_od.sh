#!/bin/bash
set -eo pipefail

git clone https://github.com/OpenDreamProject/OpenDream.git OpenDream
cd OpenDream
git submodule update --init --recursive
dotnet restore
dotnet build -c Release
