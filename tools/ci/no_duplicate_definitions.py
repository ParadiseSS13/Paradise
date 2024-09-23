import glob
import os
import re
import sys
import time
from collections import namedtuple, defaultdict

Failure = namedtuple("Failure", ["filename", "lineno", "message"])
Location = namedtuple("Location", ["filename", "lineno"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color

def print_error(message: str, filename: str, line_number: int):
    if os.getenv("GITHUB_ACTIONS") == "true": # We're on github, output in a special format.
        print(f"::error file={filename},line={line_number},title=Restricted Type in File::{filename}:{line_number}: {RED}{message}{NC}")
    else:
        print(f"{filename}:{line_number}: {RED}{message}{NC}")

if __name__ == "__main__":
    print("no_duplicate_definitions started")

    exit_code = 0
    start = time.time()

    dm_files = glob.glob("**/*.dm", recursive=True)

    if len(sys.argv) > 1:
        dm_files = sys.argv[1:]

    all_failures = []

    all_types = defaultdict(list)

    for code_filepath in dm_files:
        with open(code_filepath, encoding="UTF-8") as code:
            filename = code_filepath.split(os.path.sep)[-1]

            definition_matcher = re.compile(r'^(\/[\w][\w/]*?)(?: *\/[/*].*)?$')
            for idx, line in enumerate(code):
                if(rematch_result := re.search(definition_matcher, line)):
                    typepath = rematch_result.group(1)
                    if(not typepath):
                        print_error("Failed to find a type, despite matching regex. If this happens, this CI is probably broken.", code_filepath, idx + 1)
                        continue
                    all_types[typepath].append(Location(code_filepath, idx + 1))

    for key, value_list in all_types.items():
        if len(value_list) > 1:
            for location in value_list:
                print_error(f"Found a duplicate definition of {key}.", location.filename, location.lineno)
                exit_code = 1

    end = time.time()
    print(f"no_duplicate_definitions tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
