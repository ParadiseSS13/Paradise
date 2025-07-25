from avulto import DME
from collections import namedtuple
import glob
import os
import re
import sys
import time

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color

def print_error(message: str, filename: str, line_number: int):
    if os.getenv("GITHUB_ACTIONS") == "true": # We're on github, output in a special format.
        print(f"::error file={filename},line={line_number},title=Check Grep::{filename}:{line_number}: {message}")
    else:
        print(f"{filename}:{line_number}: {message}")



def main():
    print("identical_variables started")
    exit_code = 0
    start = time.time()

    dme = DME.from_file("paradise.dme", parse_procs=True)
    all_failures = []

    for path in dme.subtypesof("/"):
        typepath = dme.type_decl(path)

        for variable_name in typepath.var_names(modified=True):
            modded = typepath.var_decl(variable_name, False)
            if(modded == None):
                print("Something went wrong!!!")
                sys.exit(1)
                return
            if path.parent == "/":
                continue
            parent_typepath = dme.type_decl(path.parent)
            original = parent_typepath.var_decl(variable_name, True)
            if(modded.const_val == original.const_val):
                if(modded.const_val == None): # Both proc calls (like sound() or icon()) and nulls are treated as "None", this sucks.
                    continue
                all_failures.append(Failure(typepath.source_loc.file_path, typepath.source_loc.line, f"{RED}{path}{NC} has a identical variable to its parents: {RED}{variable_name}{NC} = {modded.const_val}"))

    if all_failures:
        exit_code = 1
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)

    end = time.time()
    if(exit_code):
        print(f"identical_variables tests failed in {end - start:.2f}s with {len(all_failures)} failures.\n")
    else:
        print(f"identical_variables tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)

if __name__ == "__main__":
    main()
