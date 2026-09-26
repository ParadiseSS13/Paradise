from collections import defaultdict
from pathlib import Path

import pytest
from conftest import Lint


@pytest.mark.lint("Same File Name")
def test_file_names(lint: Lint):
    file_name_map: dict[str, list[Path]] = defaultdict(list)

    for file in Path(".").glob("**/*.dm"):
        file_name_map[file.name].append(file)

    duplicate_files = {
        filename: paths
        for filename, paths in file_name_map.items()
        if len(paths) > 1
    }

    if duplicate_files:
        for paths in duplicate_files.values():
            for path in paths:
                other_paths = ", ".join([str(other) for other in paths if other != path])
                lint.error(f"Identical name to {other_paths}", path)
    # assert False
