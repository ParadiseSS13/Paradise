from collections import defaultdict
import glob
import sys
import time

from ..dmi import Dmi


if __name__ == "__main__":
    print("check_icon_dupenames started")

    count = 0
    exit_code = 0
    start = time.time()

    findings = defaultdict(list)

    for dmi_path in glob.glob("**/*.dmi", recursive=True):
        dmi = Dmi.from_file(dmi_path)
        states = set()
        for state in dmi.states:
            # Movement states have the same name as their non-movement counterparts
            if (state.name, state.movement) in states:
                findings[dmi_path].append(state.name)
            states.add((state.name, state.movement))
        count += 1

    if findings:
        exit_code = 1

        for filename in sorted(findings.keys()):
            states = findings[filename]
            for state in sorted(states):
                print(f"{filename}: duplicate state name `{state}`")


    end = time.time()
    print(f"\ncheck_icon_dupenames checked {count} files in {end - start:.2f}s\n")

    sys.exit(exit_code)
