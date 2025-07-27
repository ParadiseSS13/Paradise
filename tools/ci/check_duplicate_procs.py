import re
from collections import defaultdict
from pathlib import Path

proc_definitions = defaultdict(list)

for file in Path(".").glob("**/*.dm"):
    with open(file, 'r', encoding='utf-8', errors='ignore') as f:
        for line_num, line in enumerate(f, 1):
            if match := re.match(r"^(/[\w/]+/[\w]+)\(\)$", line.strip()):
                proc_path = match.group(1)
                proc_definitions[proc_path].append((file, line_num))

def main():
    alert_sent = False
    for proc_path, locations in proc_definitions.items():
        if len(locations) > 1:
            if not alert_sent:
                print("The following proc definitions are duplicated. Please fix!\n")
                alert_sent = True

            print(f">>> {proc_path}()")
            for file, line_num in locations:
                print(f"{file}:{line_num}")
            print()

    if alert_sent:
        exit(1)
    else:
        exit(0)

if __name__ == "__main__":
    main()
