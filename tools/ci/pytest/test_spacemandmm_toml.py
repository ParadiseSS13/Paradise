import tomllib

import pytest
from avulto import DME, Path as p
from conftest import Lint


TOML_CHECK_KEYS = (
    ("map_renderer", "hide_invisible"),
    ("map_renderer", "fancy_layers"),
)


# Descend into a nested dictionary based on the names in the given 'key_path'
# iterable. Return None if at any point, a nested key doesn't exist.
def get_nested_key(nested_data, keys):
    current = nested_data
    for layer in keys:
        current = current.get(layer)
        if current is None:
            return

    return current


# Check all known paths against the paths in a given nested key in the config.
def check_nested_key(config, key_path, all_paths):
    data = get_nested_key(config, key_path)

    if not data:
        return [(__file__, f"invalid key-path {key_path}")]

    result = []
    paths = [p(path) for path in data]
    for path in paths:
        if path not in all_paths:
            result += [("SpacemanDMM.toml", f"{path} doesn't exist in DME")]

    return result

@pytest.mark.lint("SpacemanDMM TOML")
def test_spacemandmm_toml(dme: DME, lint: Lint):
    with open("SpacemanDMM.toml", "rb") as f:
        config = tomllib.load(f)

    all_paths = set(dme.typesof("/"))

    for key_path in TOML_CHECK_KEYS:
        for file, message in check_nested_key(config, key_path, all_paths):
            lint.error(message, file)
