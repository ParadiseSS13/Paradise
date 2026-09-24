from collections import defaultdict
from pathlib import Path
import pytest
from ci_common import Color

def test_file_names():
    file_name_map: dict[str, list[Path]] = defaultdict(list)

    for file in Path(".").glob("**/*.dm"):
        file_name_map[file.name].append(file)

    duplicate_files = {
        filename: paths
        for filename, paths in file_name_map.items()
        if len(paths) > 1
    }

    if duplicate_files:
        message = [
            "The following files have the same name in multiple places "
            "in the codebase. Please fix!",
            "",
        ]

        for filename, paths in duplicate_files.items():
            message.append(f">>> {Color.RED}{filename}{Color.NO_COLOR}")
            message.extend(f"    {path}" for path in paths)
            message.append("")

        pytest.fail("\n".join(message), pytrace=False)
