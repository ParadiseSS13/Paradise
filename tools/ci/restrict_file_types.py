import glob
import os
import re
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
        dm_files = sys.argv[1:]

    all_failures = []

    for code_filepath in dm_files:
        with open(code_filepath, encoding="UTF-8") as code:
            filename = code_filepath.split(os.path.sep)[-1]

            restrict_regex = re.match(r"RESTRICT_TYPE\((.+)\)", code.read())
            if(not restrict_regex):
                continue

            restrict_type_path = restrict_regex.group(1)

            # Matches a definition into two groups:
            # 1: The typepath or /proc (for global procs), required. First character is handled specially, to avoid picking up start-of-line comments.
            # 2: The name of the proc, if any.
            definition_matcher = re.compile(r'^(/[\w][\w/]*?)(?:/proc)?(?:/([\w]+)\(.*?)?(?: */[/*].*)?$')
            code.seek(0)
            for idx, line in enumerate(code):
                if(rematch_result := re.search(definition_matcher, line)):
                    if(restrict_type_path != rematch_result.group(1)):
                        type_path = rematch_result.group(1)
                        proc_name = rematch_result.group(2)
                        if(type_path == "/proc"):
                            all_failures += [Failure(code_filepath, idx + 1, f"'Global proc '/proc/{proc_name}' found in a file restricted to type '{restrict_type_path}'")]
                        else:
                            if(proc_name):
                                all_failures += [Failure(code_filepath, idx + 1, f"'Proc '{type_path}/proc/{proc_name}' found in a file restricted to type '{restrict_type_path}'")]
                            else:
                                all_failures += [Failure(code_filepath, idx + 1, f"'Definition for different type '{type_path}' found in a file restricted to '{restrict_type_path}'")]


    if all_failures:
        exit_code = 1
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)

    end = time.time()
    print(f"restrict_file_types tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
