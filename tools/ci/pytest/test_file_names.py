from collections import defaultdict
from pathlib import Path
from ci_common import ErrorReporter

reporter = ErrorReporter("Same File Name")

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
        for paths in duplicate_files.values():
            for path in paths:
                other_paths = ", ".join([str(other) for other in paths if other != path])
                reporter.print(f"Identical name to {other_paths}", path)

    reporter.END_TEST()

