import os
import re
import tomllib
from pathlib import Path
from typing import Optional

import pytest
from conftest import Lint

def get_config_sql(lint: Lint, config_path: Path) -> Optional[int]:
    if not os.path.exists(config_path):
        lint.error(f"File containing config the SQL version does not exist ({config_path}).")
        return

    with open(config_path, "rb") as config:
        config_data = tomllib.load(config)

    if not ("database_configuration" in config_data):
        lint.error(f"File containing config doesn't have a database_configuration section.", config_path)
        return
    if "sql_version" in config_data["database_configuration"]:
        return config_data["database_configuration"]["sql_version"]

    lint.error(f"No default SQL version set in {config_path}.", config_path)

def get_define_sql(lint: Lint, define_path: Path) -> Optional[int]:
    if not os.path.exists(define_path):
        lint.error(f"File containing the byond define for the SQL version does not exist ({define_path}).")
        return

    with open(define_path, "r") as define:
        define_data = define.read()

    if search_result := re.search(r"#define SQL_VERSION (\d+)", define_data):
        return int(search_result.group(1))

    lint.error(f"No byond define for SQL found in {define_path}.", define_path)

def get_sql_folder_version(lint: Lint, folder_path: Path) -> Optional[int]:
    all_versions: list[int] = []

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
            all_versions.append(new_version)

    if len(all_versions) == 0:
        lint.error(f"No updates exist in {folder_path}")
        return None

    highest_version = max(all_versions)
    for num in range(1, highest_version):
        if num not in all_versions:
            lint.error(f"Missing SQL update for version {num}")

    return highest_version

@pytest.mark.lint("SQL Version")
def test_verify_sql_version(lint: Lint, repo_root: Path):
    config_path = repo_root / "config/example/config.toml"
    define_path = repo_root / "code/__DEFINES/misc_defines.dm"
    sql_updates_path = repo_root / "SQL/updates"

    config_sql = get_config_sql(lint, config_path)
    define_sql = get_define_sql(lint, define_path)
    updates_folder_sql = get_sql_folder_version(lint, sql_updates_path)

    if config_sql is None or define_sql is None or updates_folder_sql is None:
        return

    if config_sql != updates_folder_sql:
        lint.error(f"Updates file SQL version ({updates_folder_sql}) does not match the config SQL version ({config_sql}).", config_path)
    if define_sql != updates_folder_sql:
        lint.error(f"Updates file SQL version ({updates_folder_sql}) does not match the byond define SQL version ({define_sql}).", define_path)
