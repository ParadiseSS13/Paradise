import os
import re
import tomllib
from typing import Tuple, Union
from pathlib import Path


import pytest
from conftest import Lint

def get_config_sql(lint: Lint, config_path: str):
    if os.path.exists(config_path):
        with open(config_path, "rb") as config:
            config_data = tomllib.load(config)
        if not ("database_configuration" in config_data):
            lint.error(f"File containing config doesn't have a database_configuration section.", config_path)
        elif "sql_version" in config_data["database_configuration"]:
            return config_data["database_configuration"]["sql_version"]
        else:
            lint.error(f"No default SQL version set in {config_path}.", config_path)
    else:
        lint.error(f"File containing config the SQL version does not exist ({config_path}).")

def get_define_sql(lint: Lint, define_path: str):
    if os.path.exists(define_path):
        with open(define_path, "r") as define:
            define_data = define.read()
        if search_result := re.search(r"#define SQL_VERSION (\d+)", define_data):
            return int(search_result.group(1))
        else:
            lint.error(f"No byond define for SQL found in {define_path}.", define_path)
    else:
        lint.error(f"File containing the byond define for the SQL version does not exist ({define_path}).")

def get_sql_folder_version(lint: Lint) -> int:
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
                lint.error(f"Missing SQL version update detected, {old_version}-{new_version}.sql should be {old_version}-{old_version+1}.sql")
            if new_version > highest_version:
                highest_version = new_version
                highest_file = filename
            all_versions.append(new_version)

    for num in range(highest_version):
        if num not in all_versions:
            lint.error(f"Missing SQL update for version {num}")

    if highest_file == None:
        lint.error("Failed to find a proper updates folder SQL version.")

    return highest_version

@pytest.mark.lint("SQL Version")
def test_config_sql(lint: Lint):
    assert get_config_sql

@pytest.mark.lint("SQL Version")
def test_define_sql(lint: Lint):

@pytest.mark.lint("SQL Version")
def test_sql_updates(lint: Lint):

@pytest.mark.lint("SQL Version")
def test_verify_sql_version(lint: Lint):
    config_path = "./config/example/config.toml"
    define_path = "./code/__DEFINES/misc_defines.dm"
    
    config_sql = get_config_sql(lint, config_path)
    define_sql = get_define_sql(lint, define_path)

    updates_folder_sql = get_sql_folder_version(lint)

    if updates_folder_sql <= 0 or not isinstance(updates_folder_sql, int):
        lint.error("Failed to find a proper updates folder SQL version.")
        return
    if config_sql != updates_folder_sql:
        lint.error(f"Updates file SQL version ({updates_folder_sql}) does not match the config SQL version ({config_sql}).", config_path)
    if define_sql != updates_folder_sql:
        lint.error(f"Updates file SQL version ({updates_folder_sql}) does not match the byond define SQL version ({define_sql}).", define_path)
