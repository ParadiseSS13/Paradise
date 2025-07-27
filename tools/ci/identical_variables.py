from avulto import DME
from collections import namedtuple
import os
import sys
import time

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color

def print_error(message: str, filename: str, line_number: int):
    if os.getenv("GITHUB_ACTIONS") == "true": # We're on github, output in a special format.
        print(f"::error file={filename},line={line_number},title=Identical Variables::{filename}:{line_number}: {message}")
    else:
        print(f"{filename}:{line_number}: {message}")

def main():
    print("identical_variables started")
    exit_code = 0
    start = time.time()

    dme = DME.from_file("paradise.dme")
    all_failures = []

    for path in dme.subtypesof("/"):
        typepath = dme.type_decl(path)

        for variable_name in typepath.var_names(modified=True):
            modded = typepath.var_decl(variable_name, False)
            if(not modded):
                all_failures.append(Failure(typepath.source_loc.file_path, typepath.source_loc.line, f"{RED}Avulto failed to read {path.rel}::{variable_name}.{NC} This is probably not your fault."))
                continue
            if path.parent.is_root:
                continue
            parent_typepath = dme.type_decl(path.parent)
            original = parent_typepath.var_decl(variable_name, True)
            if(modded.const_val == original.const_val):
                if(modded.const_val == None): # Both proc calls (like sound() or icon()) and nulls are treated as "None", this sucks.
                    continue
                # Make an exception for directional helpers, where you cant guarantee.
                if(modded.name in ["dir", "pixel_x", "pixel_y"] and path.parent.stem in ["directional", "offset"]):
                    continue
                # Make an exception for subsystems, as they are much less OOP dependent.
                if(path.child_of("/datum/controller/subsystem")):
                    continue
                # And make an exception for this fucked up edge case. wtf.
                if(path.rel == "/obj" and variable_name == "layer"):
                    continue
                all_failures.append(Failure(typepath.source_loc.file_path, typepath.source_loc.line, f"{RED}{path.rel}{NC} has a identical variable to its parents: {RED}{variable_name}{NC} = {modded.const_val}"))

    if all_failures:
        exit_code = 1
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)

    end = time.time()
    print(f"identical_variables tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)

if __name__ == "__main__":
    main()
