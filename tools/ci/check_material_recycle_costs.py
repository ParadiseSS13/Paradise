import sys
import time
from collections import namedtuple, defaultdict

from avulto import DME


RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color

ItemBOM = namedtuple("ItemBOM", ["build_costs", "recycle_costs"])


if __name__ == "__main__":
    print("check_material_recycle_costs started")

    exit_code = 0
    start = time.time()

    dme = DME.from_file("paradise.dme")
    designs = dme.subtypesof("/datum/design")

    costs = {}
    for design in designs:
        td = dme.types[design]
        build_type = td.var_decl("build_type").const_val
        build_path = td.var_decl("build_path").const_val
        materials = td.var_decl("materials").const_val
        if not build_type or not build_path or not build_path.child_of("/obj/item"):
            continue
        # ammo boxes update their materials dynamically based on contained ammo contents
        if build_path.child_of("/obj/item/ammo_box"):
            continue
        result_type = dme.types[build_path]
        material_content = result_type.var_decl("materials").const_val
        if result_type not in costs:
            costs[build_path] = ItemBOM(defaultdict(set), defaultdict(set))

        bom = costs[build_path]
        for x in materials.keys():
            bom.build_costs[x].add(materials[x])
        for x in material_content.keys():
            bom.recycle_costs[x].add(material_content[x])

    for pth in sorted(costs.keys()):
        bom = costs[pth]
        for matname, values in bom.build_costs.items():
            if matname not in bom.recycle_costs:
                continue
            recycle_cost = min(bom.recycle_costs[matname])
            if recycle_cost > max(values):
                exit_code = 1
                msg = f"{pth} has {matname} build cost {max(values)} and recycle cost {recycle_cost}"
                print(msg)

    end = time.time()
    print(f"check_material_recycle_costs tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
