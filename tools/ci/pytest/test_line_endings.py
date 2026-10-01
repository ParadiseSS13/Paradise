# TODO: This file reads the WHOLE codebase, this should be done at the same time as other operations that read the whole codebase, like check_grep2

import glob
import sys
from typing import Any

import pytest
from conftest import Lint

WINDOWS_NEWLINE = b'\r\n'

@pytest.fixture
def files_to_read():
    files_to_read: list[Any] = []
    files_to_read.extend(glob.glob(r"**/*.dm", recursive=True))
    files_to_read.extend(glob.glob(r"**/*.dmm", recursive=True))
    files_to_read.extend(glob.glob(r"*.dme"))

    yield files_to_read

def has_newlines(lines: list[bytes]) -> bool:
	for line in lines:
		if line.endswith(WINDOWS_NEWLINE):
			return True
	return False

# git's autocrlf may make this test fail locally for some windows developers, disabled for that reason
@pytest.mark.skipif(sys.platform == "win32", reason="Inconsistent for Windows developers")
@pytest.mark.lint("CRLF File")
def test_line_endings(files_to_read: list[Any], lint: Lint):
    filelist: list[Any] = []

    for file in files_to_read:
        with open(file, "rb") as data:
            if has_newlines(data.readlines()):
                filelist.append(file)

    for file in filelist:
        lint.error("suspected CRLF file.", file=file)
