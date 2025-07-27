import re
from collections import defaultdict
from pathlib import Path

import sys
import time
import glob
import os

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
	print("check_duplicate_procs started")

	exit_code = 0
	start = time.time()
	
	proc_definitions = defaultdict(list)
	
	dm_files = glob.glob("**/*.dm", recursive=True)

	for file in dm_files:
		with open(file, 'r', encoding='utf-8', errors='ignore') as f:
			for line_num, line in enumerate(f, 1):
				if match := re.match(r"^(/[\w/]+/[\w]+)\(\)$", line.strip()):
					proc_path = match.group(1)
					proc_definitions[proc_path].append((file, line_num))

	for proc_path, locations in proc_definitions.items():
		if len(locations) > 1:
			exit_code = 1

			for file, line_num in locations:
				print_error(f"Duplicate proc definition of {proc_path}", file, line_num)

	end = time.time()
	print(f"\ncheck_duplicate_procs tests completed in {end - start:.2f}s\n")

	sys.exit(exit_code)  

if __name__ == "__main__":
    main()
