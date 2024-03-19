import glob
import re
import os
import sys
import time
from collections import namedtuple

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

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
    print("restrict_file_types started")

    exit_code = 0
    start = time.time()

    dm_files = glob.glob("**/*.dm", recursive=True)

    if len(sys.argv) > 1:
        dm_files = [sys.argv[1]]

    all_failures = []

    for code_filepath in dm_files:
        with open(code_filepath, encoding="UTF-8") as code:
            filename = code_filepath.split(os.path.sep)[-1]

            restrict_regex = re.match(r"RESTRICT_TYPE\((.+)\)", code.read())
            if(not restrict_regex):
                continue

            type_path = restrict_regex.group(1)

            # These regexes could probably usee some refinement, but they're the best I could come up with.
            proc_search = re.compile(r'^(/[\w/]{3,}?)\/(?:proc\/)?\w+\(') # Search for any procs that are not of this type
            def_search = re.compile(r'(^(?:/(?:\w+))+)') # Search for any definition that are not of this type
            code.seek(0)
            for idx, line in enumerate(code):
                if(rematch_result := re.search(proc_search, line)):
                    rematch_result = rematch_result.group(1)
                    if(type_path != rematch_result):
                        all_failures += [Failure(code_filepath, idx + 1, f"'{rematch_result}' proc found in a file restricted to '{type_path}'")]
                elif(rematch_result := re.search(def_search, line)):
                    rematch_result = rematch_result.group(1)
                    if(type_path != rematch_result):
                        all_failures += [Failure(code_filepath, idx + 1, f"'{rematch_result}' type definition found in a file restricted to '{type_path}'")]


    if all_failures:
        exit_code = 1
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)

    end = time.time()
    print(f"restrict_file_types tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
