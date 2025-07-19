import os
import re
import sys
import time
from collections import namedtuple
import tomllib
from typing import Tuple, Union
from pathlib import Path

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color

def print_error(message: str, filename: str = None):
    if os.getenv("GITHUB_ACTIONS") == "true": # We're on github, output in a special format.
        if filename != None:
            print(f"::error file={filename},title=SQL Version mismatch::{filename}: {RED}{message}{NC}")
        else:
            print(f"::error title=SQL Version mismatch:: {RED}{message}{NC}")
    else:
        if filename != None:
            print(f"{filename}: {RED}{message}{NC}")
        else:
            print(f"ERROR: {RED}{message}{NC}")

def get_sql_folder_version() -> Tuple[Union[str, None], int]:
    folder_path = Path("SQL/updates")
    highest_file = None
    highest_version = 0
    all_versions = [0]

    for file_path in folder_path.iterdir():
        if file_path.is_file():
            filename = file_path.name
            search_result = re.search(r"(\d+)-(\d+)\.", filename)
            if search_result is None:
                continue
            old_version = int(search_result.group(1))
            new_version = int(search_result.group(2))
            if (old_version + 1) != new_version:
                print_error(f"Missing SQL version update detected, {old_version}-{new_version}.sql should be {old_version}-{old_version+1}.sql")
            if new_version > highest_version:
                highest_version = new_version
                highest_file = filename
            all_versions.append(new_version)

    for num in range(highest_version):
        if num not in all_versions:
            print_error(f"Missing SQL update for version {num}")

    return highest_file, highest_version

def get_sql_folder_version_220() -> Tuple[Union[str, None], int]:
    folder_path = Path("SQL/updates220")
    highest_file_220 = None
    highest_version_220 = 0
    all_versions_220 = [0]

    for file_path in folder_path.iterdir():
        if file_path.is_file():
            filename = file_path.name
            search_result = re.search(r"(?P<old>\d+)(\.220\.(?P<old220>\d+))?-(?P<new>\d+)\.220\.(?P<new220>\d+)\.", filename)
            if search_result is None:
                continue
            old_version = int(search_result.group("old"))
            new_version = int(search_result.group("new"))
            old_version_220 = int(search_result.group("old220") or 0)
            new_version_220 = int(search_result.group("new220"))
            if (old_version_220 + 1) != new_version_220:
                print_error((
                    "Missing SQL version update detected,"
                    f" {filename} should be"
                    f" {old_version}.220.{old_version_220}-{new_version}.220.{old_version_220 + 1}.sql"
                    f" or {old_version}.220.{new_version_220 - 1}-{new_version}.220.{new_version_220}.sql"
                ))
            if new_version_220 > highest_version_220:
                highest_version_220 = new_version_220
                highest_file_220 = filename
            all_versions_220.append(new_version_220)

    for num in range(highest_version_220):
        if num not in all_versions_220:
            print_error(f"Missing SQL update for version 220.{num}")

    _, highest_version = get_sql_folder_version()

    return highest_file_220, f"{highest_version}220{highest_version_220}"

if __name__ == "__main__":
    print("verify_sql_version started")

    exit_code = 0
    start = time.time()

    config_path = "./config/example/config.toml"
    define_path = "./code/__DEFINES/misc_defines.dm"
    if os.path.exists(config_path):
        with open(config_path, "rb") as config:
            config_data = tomllib.load(config)
        if not ("database_configuration" in config_data):
            print_error(f"File containing config doesn't have a database_configuration section.", config_path)
            exit_code = 1
        elif "sql_version" in config_data["database_configuration"]:
            config_sql = str(config_data["database_configuration"]["sql_version"])
        else:
            print_error(f"No default SQL version set in {config_path}.", config_path)
            exit_code = 1
    else:
        print_error(f"File containing config the SQL version does not exist ({config_path}).")
        exit_code = 1

    if os.path.exists(define_path):
        with open(define_path, "r") as define:
            define_data = define.read()
        if search_result := re.search(r"#define SQL_VERSION (\d+)", define_data):
            define_sql = search_result.group(1)
        else:
            print_error(f"No byond define for SQL found in {define_path}.", define_path)
            exit_code = 1
    else:
        print_error(f"File containing the byond define for the SQL version does not exist ({define_path}).")
        exit_code = 1

    updates_file, updates_folder_sql = get_sql_folder_version_220()

    if(exit_code == 0):
        if config_sql != updates_folder_sql:
            print_error(f"Updates file SQL version ({updates_folder_sql}) does not match the config SQL version ({config_sql}).", config_path)
            exit_code = 1
        if define_sql != updates_folder_sql:
            print_error(f"Updates file SQL version ({updates_folder_sql}) does not match the byond define SQL version ({define_sql}).", define_path)
            exit_code = 1

    end = time.time()
    print(f"verify_sql_version tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)

