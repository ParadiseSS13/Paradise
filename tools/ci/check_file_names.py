#!/usr/bin/env python3
from collections import defaultdict
from pathlib import Path

file_name_map = defaultdict(list)

for file in Path(".").glob("**/*.dm"):
  if "modular_ss220" in str(file):
    continue
  file_name_map[file.name].append(file)

def main():
    alert_sent = False
    for filename, fullpaths in file_name_map.items():
        if len(fullpaths) > 1:
            if not alert_sent:
                print("The following files have the same name in multiple places in the codebase. Please fix!")
                alert_sent = True

            print(f">>> {filename}")
            for fullpath in fullpaths:
                print(fullpath)

    if alert_sent:
        exit(1)
    else:
        exit(0)

if __name__ == "__main__":
    main()
