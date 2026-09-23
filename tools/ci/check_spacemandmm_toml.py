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


def format_error(source_loc: SourceLoc | Path, message):
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

if __name__ == "__main__":
    print("check_spacemandmm_toml started")

    exit_code = 0
    start = time.time()

    errors = []

    config = tomllib.load(open("SpacemanDMM.toml", "rb"))
    dme = DME.from_file("paradise.dme")
    all_paths = set(dme.typesof("/"))

    for key_path in TOML_CHECK_KEYS:
        found_data = True
        data = config
        for name in key_path:
            data = data.get(name)
            if data is None:
                found_data = False
                print(f"no config keys at {key_path} exist")
                break
        if not found_data:
            continue

        missing_paths = set()
        paths = [p(path) for path in data]
        for path in paths:
            if path not in all_paths:
                exit_code = 1
                errors.append(
                    format_error(
                        "SpacemanDMM.toml", f"path {path} does not exist in DME"
                    )
                )

    end = time.time()

    for error in errors:
        print(error)

    print(f"check_spacemandmm_toml tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
