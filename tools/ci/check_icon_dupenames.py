from collections import defaultdict
from glob import glob
from time import time
from concurrent.futures import ProcessPoolExecutor
from ..dmi import Dmi

def check_states(dmi_path: str):
    dmi = Dmi.from_file(dmi_path)
    names = []
    states = set()
    for state in dmi.states:
        # Movement states have the same name as their non-movement counterparts
        if (state.name, state.movement) in states:
            names.append(state.name)
        states.add((state.name, state.movement))
    return dmi_path, names

if __name__ == "__main__":
    print("check_icon_dupenames started")

    count = 0
    exit_code = 0
    start = time()

    findings = defaultdict(list)

    with ProcessPoolExecutor() as executor:
        for dmi_path, names in executor.map(check_states, glob("**/*.dmi", recursive=True)):
            if names:
                findings[dmi_path] += names
            count += 1

    if findings:
        exit_code = 1

        for filename in sorted(findings.keys()):
            states = findings[filename]
            for state in sorted(states):
                print(f"{filename}: duplicate state name `{state}`")


    end = time()
    print(f"\ncheck_icon_dupenames checked {count} files in {end - start:.2f}s\n")

    exit(exit_code)
