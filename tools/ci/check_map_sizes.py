import os
import sys
from pathlib import Path
import time

from avulto import DMM

CODE_ROOT = Path(".")

MAX_X_SIZE = 255
MAX_Y_SIZE = 255
MAX_Z_SIZE = 1
FIX_MESSAGE = f"Please make sure maps are <= {MAX_X_SIZE}x{MAX_Y_SIZE}x{MAX_Z_SIZE}."


def red(text):
    return "\033[31m" + str(text) + "\033[0m"


def post_error(filepath: str, size, github_error_style: bool):
    msg = f" is >{MAX_X_SIZE}x{MAX_Y_SIZE}x{MAX_Z_SIZE} (Found: {size.x},{size.y},{size.z})"
    if github_error_style:
        print(f"::error file={filepath},title=Map Size::{filepath}{msg}")
    else:
        print(f"- Failure: {red(filepath)}{msg}")


def main():
    print("check_map_sizes started")
    exit_code = 0
    start = time.time()
    # simple way to check if we're running on github actions, or on a local machine
    on_github = os.getenv("GITHUB_ACTIONS") == "true"

    failures = []
    map_count = 0

    for map_file in (CODE_ROOT / "_maps/map_files").glob("**/*.dmm"):
        map_count += 1
        dmm = DMM.from_file(map_file)

        if (
            dmm.size.x > MAX_X_SIZE
            or dmm.size.y > MAX_Y_SIZE
            or dmm.size.z > MAX_Z_SIZE
        ):
            failures.append((map_file.relative_to(CODE_ROOT), dmm.size))

    if failures:
        exit_code = 1

        for error in failures:
            post_error(error[0], error[1], on_github)

        print(red(FIX_MESSAGE))

    end = time.time()
    print(f"check_map_sizes.py checked {map_count} maps in {(end - start):.2f}s")

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
