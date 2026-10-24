from collections import defaultdict
from dataclasses import dataclass, field

from avulto import DME, Path as p, SourceLoc
import pytest

from conftest import Lint


@dataclass(frozen=True)
class ItemBOM:
    source_loc: SourceLoc
    build_costs: dict[str, set[int]] = field(default_factory=lambda: defaultdict(set))
    recycle_costs: dict[str, set[int]] = field(default_factory=lambda: defaultdict(set))


@pytest.mark.lint("Material Recycle Costs")
def test_material_recycle_costs(dme: DME, lint: Lint):
    designs = dme.subtypesof("/datum/design")

    costs: dict[p, ItemBOM] = {}
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
        result_type_materials = result_type.var_decl("materials")
        material_content = result_type_materials.const_val
        if build_path not in costs:
            costs[build_path] = ItemBOM(source_loc=result_type_materials.source_loc)

        bom = costs[build_path]
        if materials:
            for x in materials.keys():
                bom.build_costs[x].add(materials[x])
        if material_content:
            for x in material_content.keys():
                bom.recycle_costs[x].add(material_content[x])

    for pth in sorted(costs.keys()):
        bom = costs[pth]
        for matname, values in bom.build_costs.items():
            if matname not in bom.recycle_costs:
                continue
            recycle_cost = min(bom.recycle_costs[matname])
            if recycle_cost > max(values):
                lint.error_source(
                    f"{pth} has {matname} build cost {max(values)} and recycle cost {recycle_cost}",
                    bom.source_loc
                )
