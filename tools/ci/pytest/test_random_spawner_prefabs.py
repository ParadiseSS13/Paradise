from avulto import DME, Dmlist
from avulto.ast import Prefab
import pytest

from conftest import Lint


def print_prefab(prefab: Prefab) -> str:
    if not prefab.vars:
        return prefab.path

    prefab_vars = []
    for kv in prefab.vars:
        nameval = list(kv.items())
        prefab_vars.append(f"{nameval[0][0]} = {nameval[0][1]}")

    return f"{prefab.path}{{{', '.join(prefab_vars)}}}"

def check_list_items(dmlist: Dmlist, invalid_items: list) -> list:
    for item in dmlist:
        if isinstance(item, Dmlist):
            return check_list_items(item, invalid_items)
        if isinstance(item, Prefab) and item.vars:
            invalid_items.append(item)

    return invalid_items


@pytest.mark.lint("Random Spawner Prefabs")
def test_random_spawner_prefabs(dme: DME, lint: Lint):
    prefabs_by_spawner = {}

    for pth in dme.subtypesof("/obj/effect/spawner/random"):
        invalid_items = []
        td = dme.types[pth]
        loot = td.var_decl("loot").const_val
        if not loot:
            continue
        if result := check_list_items(loot, invalid_items):
            prefabs_by_spawner[pth] = result

    for pth, items in prefabs_by_spawner.items():
        result_list = "\n".join(
            sorted(
                [
                    f"- {print_prefab(item)}"
                    for item in items
                    if isinstance(item, Prefab)
                ]
            )
        )
        lint.error(
            f"{pth} contains prefabs. Please convert these to subtypes:\n{result_list}"
        )
