from collections import defaultdict
from glob import glob
from time import time
from concurrent.futures import ProcessPoolExecutor
from ..dmi import Dmi


def check_state(dmi_path: str) -> str:
    names = []
    dmi = Dmi.from_file(dmi_path)
    for state in dmi.states:
        if '!CONFLICT!' in state.name:
            names.append(state.name)
    return dmi_path, names

if __name__ == "__main__":
    print("check_icon_conflicts started")

    count = 0
    exit_code = 0
    start = time()

    findings = defaultdict(list)

    files = glob("**/*.dmi", recursive=True)
    with ProcessPoolExecutor() as executor:
        for dmi_path, names in executor.map(check_state, glob("**/*.dmi", recursive=True)):
            if names:
                findings[dmi_path] += names
            count += 1
    if findings:
        exit_code = 1
        for filename in sorted(findings.keys()):
            states = findings[filename]
            for state in sorted(states):
                print(f"{filename}: conflicted state {state}")


    end = time()
    print(f"\ncheck_icon_conflicts checked {count} files in {end - start:.2f}s\n")

    exit(exit_code)
