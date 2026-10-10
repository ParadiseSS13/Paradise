# This is basically a slightly edited verison of unticked_files.py.
# Look there for precise documentation on the methods used here.
import bisect
import re
from pathlib import Path

import pytest
from conftest import Lint

INCLUDED_FILES = [
    'paradise.dme'
]

ILLEGAL_FILES = [
    '.dmm'
]

extensions = '|'.join(re.escape(ext) for ext in ILLEGAL_FILES)
pattern = re.compile(r'#include "(.+(?:' + extensions + r'))"')

@pytest.mark.lint("Illegal DME file")
def test_illegal_files(lint: Lint, repo_root: Path):
    for includer in INCLUDED_FILES:
        with open(repo_root / includer, 'r') as f:
            content = f.read()

        # This is kinda overkill to get the line number, but it works
        newlines = [i for i, char in enumerate(content) if char == '\n']

        for result in pattern.finditer(content):
            path = Path(result.group(1))

            # use bisect to count newlines before the match
            line_number = bisect.bisect_right(newlines, result.start()) + 1

            lint.error(f"Illegal file included in dme: {path}", includer, line_number)
