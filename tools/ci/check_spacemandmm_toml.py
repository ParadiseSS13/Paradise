import os
from pathlib import Path
import sys
import time
import tomllib

from avulto import DME, Path as p
from avulto.ast import SourceLoc

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color


def error(source_loc: SourceLoc | Path, message):
    if isinstance(source_loc, SourceLoc):
        if os.getenv("GITHUB_ACTIONS") == "true":
            return f"::error file={source_loc.file_path},line={source_loc.line},title=SpacemanDMM TOML::{source_loc.file_path}:{source_loc.line}: {RED}{message}{NC}"
        else:
            return f"{source_loc.file_path}:{source_loc.line}: {RED}{message}{NC}"
    else:
        if os.getenv("GITHUB_ACTIONS") == "true":
            return f"::error file={source_loc},title=SpacemanDMM TOML::{source_loc}: {RED}{message}{NC}"
        else:
            return f"{source_loc}: {RED}{message}{NC}"


TOML_CHECK_KEYS = (
    ("map_renderer", "hide_invisible"),
    ("map_renderer", "fancy_layers"),
)


# Descend into a nested dictionary based on the names in the given 'key_path'
# iterable. Return None if at any point, a nested key doesn't exist.
def get_nested_key(data, key_path):
    key = data
    for name in key_path:
        key = key.get(name)
        if key is None:
            return

    return key


# Check all known paths against the paths in a given nested key in the config.
def check_nested_key(config, key_path, all_paths):
    result = []
    data = get_nested_key(config, key_path)
    if data:
        paths = [p(path) for path in data]
        for path in paths:
            if path not in all_paths:
                result += [error("SpacemanDMM.toml", f"{path} doesn't exist in DME")]
    else:
        result += [error(__file__, f"invalid key-path {key_path}")]

    return result


if __name__ == "__main__":
    print("check_spacemandmm_toml started")

    start = time.time()

    errors = []

    with open("SpacemanDMM.toml", "rb") as f:
        config = tomllib.load(f)

    dme = DME.from_file("paradise.dme")
    all_paths = set(dme.typesof("/"))

    for key_path in TOML_CHECK_KEYS:
        errors.extend(check_nested_key(config, key_path, all_paths))

    end = time.time()

    for error in errors:
        print(error)

    print(f"check_spacemandmm_toml tests completed in {end - start:.2f}s\n")

    if errors:
        sys.exit(1)
