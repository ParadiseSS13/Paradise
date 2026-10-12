# When running in POSIX environments, the include paths in the codebase need to
# be munged into PureWindowsPaths before being spit back out. Otherwise, the
# checker will attempt to find files named e.g. /workspace/code\\foo.dm, which
# translates to the (completely legitimate) filename "code\foo.dm" in the
# /workspace directory.
#
# For more information, see the discussion of pure paths in the pathlib
# documentation.

import re
from pathlib import Path, PureWindowsPath

import pytest
from conftest import Lint

INCLUDER_FILES = [
    'paradise.dme',
    'code/modules/tgs/includes.dm',
    'code/tests/game_tests.dm',
]

IGNORE_FILES = [
    # Included directly in the function /datum/tgs_api/v5#ApiVersion
    'code/modules/tgs/v5/v5_interop_version.dm',
    # Included as part of OD lints
    'tools/ci/lints.dm'
]

pattern = re.compile(r'#include "(.+)"')

@pytest.mark.lint("Unticked file")
def test_unticked_files(lint: Lint, repo_root: Path, dm_files: list[Path]):
    ticked_files: set[Path] = set()
    for includer in INCLUDER_FILES:
        with open(repo_root / includer, 'r') as file:
            content = file.read()

        for result in pattern.finditer(content):
            ticked_files.add(Path(includer).parent / Path(PureWindowsPath(result.group(1))))

    unticked_files = set(dm_files) - ticked_files - {Path(ignore) for ignore in IGNORE_FILES}
    for unticked in unticked_files:
        lint.error("Unticked file", unticked)
