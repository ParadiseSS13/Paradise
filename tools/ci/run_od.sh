#!/bin/bash
set -eo pipefail
dotnet DMCompiler_linux-x64/DMCompiler.dll --suppress-unimplemented paradise.dme
