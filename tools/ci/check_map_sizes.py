import glob
import os
import sys
import subprocess
import platform
import json
import time

parent_directory = "_maps/**/*.dmm"

MAX_X_SIZE = 255
MAX_Y_SIZE = 255
MAX_Z_SIZE = 1

how_to_fix_message = f"Please make sure maps are <= {MAX_X_SIZE}x{MAX_Y_SIZE}x{MAX_Z_SIZE}."

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def blue(text):
    return "\033[34m" + str(text) + "\033[0m"

def post_error(file, map_data, github_error_style):
    if github_error_style:
        print(f"::error file={file},title=Map Size::{file} is >{MAX_X_SIZE}x{MAX_Y_SIZE}x{MAX_Z_SIZE} (Found: {map_data['x']},{map_data['y']},{map_data['z']})!")
    else:
        print(f"- Failure: {red(file)} is is >{MAX_X_SIZE}x{MAX_Y_SIZE}x{MAX_Z_SIZE} (Found: {map_data['x']},{map_data['y']},{map_data['z']})")

def do_dmmtools_call(file):
    # Windows - hopefully local
    exec_path = None
    if platform.system() == 'Windows':
        exec_path = "dmm-tools.exe"
    # Linux - CI
    else:
        exec_path = "tools/github-actions/nanomap-renderer"

    exec_args = f"{exec_path} map-info \"{file}\""
    result = subprocess.run(exec_args, shell=True, capture_output=True, text=True)

    res_obj = json.loads(result.stdout)

    return_obj = {
        "x": res_obj[file]["size"][0],
        "y": res_obj[file]["size"][1],
        "z": res_obj[file]["size"][2]
    }

    return return_obj

def main():
    start = time.time()
    # simple way to check if we're running on github actions, or on a local machine
    on_github = os.getenv("GITHUB_ACTIONS") == "true"

    maps_greater_than_allowed = []

    map_count = 0

    for map_file in glob.glob(parent_directory, recursive=True):
        map_count += 1
        # Open the map in the nanomap dmm tools - it works
        map_data = do_dmmtools_call(map_file)

        if map_data["x"] > MAX_X_SIZE or map_data["y"] > MAX_Y_SIZE or map_data["z"] > MAX_Z_SIZE:
            maps_greater_than_allowed.append((map_file, map_data))

    if len(maps_greater_than_allowed):
        for error in maps_greater_than_allowed:
            post_error(error[0], error[1], on_github)

        print(red(how_to_fix_message))

        end = time.time()
        print(f"\ncheck_map_sizes.py completed in {(end - start):.2f}s\n")

        sys.exit(1)

    else:
        print(green(f"No oversized maps found (checked {map_count} maps)."))

    end = time.time()
    print(f"\ncheck_map_sizes.py completed in {(end - start):.2f}s\n")

if __name__ == "__main__":
    main()


