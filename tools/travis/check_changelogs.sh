#!/bin/bash
set -euo pipefail

md5sum -c - <<< "6dc1b6bf583f3bd4176b6df494caa5f1 *html/changelogs/example.yml"
python tools/ss13_genchangelog.py html/changelog.html html/changelogs
