from collections import defaultdict
import glob
import sys
import time

from ..dmi import Dmi


if __name__ == "__main__":
    print("check_icon_conflicts started")

    count = 0
    exit_code = 0
    start = time.time()

    findings = defaultdict(list)

    for dmi_path in glob.glob("**/*.dmi", recursive=True):
        dmi = Dmi.from_file(dmi_path)
        for state in dmi.states:
            if '!CONFLICT!' in state.name:
                findings[dmi_path].append(state.name)
        count += 1

    if findings:
        exit_code = 1

        for filename in sorted(findings.keys()):
            states = findings[filename]
            for state in sorted(states):
                print(f"{filename}: conflicted state {state}")


    end = time.time()
    print(f"\ncheck_icon_conflicts checked {count} files in {end - start:.2f}s\n")

    sys.exit(exit_code)
