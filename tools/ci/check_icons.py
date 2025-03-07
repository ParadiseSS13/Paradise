from glob import glob
from time import time
from collections import defaultdict

from avulto import DMI

def check_duplicate_names(dmi: DMI) -> list[str]:
    states = set()
    failures = []
    for state in dmi.states():
        # Movement states have the same name as their non-movement counterparts
        if (state.name, state.movement) in states:
            duplicates.append(f"duplicate state name `{state.name}`")
        states.add((state.name, state.movement))
    return failures

def check_conflicted(dmi: DMI) -> list[str]:
    failures = []
    for state in dmi.state_names():
        if '!CONFLICT!' in state:
            failures.append(f"conflicted state {state}")
    return failures

ICON_CHECKS = [
    check_duplicate_names,
    check_conflicted,
]

if __name__ == "__main__":
    print("check_icons started")

    count = 0
    exit_code = 0
    start = time()

    findings = defaultdict(list)

    for dmi_path in glob("**/*.dmi", recursive=True):
        dmi = DMI.from_file(dmi_path)
        for check in ICON_CHECKS:
            if failures := check(dmi):
                findings[dmi_path].extend(failures)
        count += 1

    if findings:
        exit_code = 1

        for filename in sorted(findings.keys()):
            failures = findings[filename]
            for failure in sorted(failures):
                print(f"{filename}: {failure}")

    end = time()
    print(f"\ncheck_icons checked {count} files in {end - start:.2f}s")

    exit(exit_code)
