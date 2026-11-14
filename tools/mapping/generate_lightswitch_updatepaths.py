from pathlib import Path

from avulto import DMM, Dir


LIGHT_SWITCH_PATH = "/obj/machinery/light_switch"
ELECTRO_SWITCH_PATH = "/obj/machinery/button/windowtint"

KNOWN_VARS = {"id", "name", "dir", "pixel_x", "pixel_y", "req_access", "req_one_access", "range"}

if __name__ == "__main__":
    updatepaths_rules = {}

    root_path = Path("_maps/map_files")

    for filepath in root_path.glob("**/*.dmm"):
        dmm = DMM.from_file(filepath)
        for coord in dmm.coords():
            tile = dmm.tiledef(*coord)

            for atom_path in [LIGHT_SWITCH_PATH, ELECTRO_SWITCH_PATH]:
                for idx in tile.find(atom_path):
                    unknown_vars = set(tile.prefab_vars(idx)) - KNOWN_VARS
                    if unknown_vars:
                        print(f"unexpected vars {unknown_vars} for {atom_path} (on {filepath.stem}@{coord})")

                    pixel_x = tile.get_prefab_var(idx, "pixel_x", None)
                    pixel_y = tile.get_prefab_var(idx, "pixel_y", None)

                    attr_list = []
                    new_attrs = []

                    if pixel_x is None:
                        pixel_x = 0
                    else:
                        attr_list.append(f"pixel_x={pixel_x}")

                    if pixel_y is None:
                        pixel_y = 0
                    else:
                        attr_list.append(f"pixel_y={pixel_y}")

                    if "id" in tile.prefab_vars(idx):
                        attr_list.append(f"id=\"{tile.prefab_var(idx, 'id')}\"")
                        new_attrs.append(f"id=\"{tile.prefab_var(idx, 'id')}\"")

                    if "range" in tile.prefab_vars(idx):
                        attr_list.append(f"range=\"{tile.prefab_var(idx, 'range')}\"")
                        new_attrs.append(f"range=\"{tile.prefab_var(idx, 'range')}\"")

                    if "req_access" in tile.prefab_vars(idx):
                        key_list = [str(x) for x in tile.prefab_var(idx, 'req_access').keys()]
                        attr_list.append(f"req_access=list({','.join(key_list)})")
                        new_attrs.append(f"req_access=list({','.join(key_list)})")

                    if "req_one_access" in tile.prefab_vars(idx):
                        key_list = [str(x) for x in tile.prefab_var(idx, 'req_one_access').keys()]
                        attr_list.append(f"req_one_access=list({','.join(key_list)})")
                        new_attrs.append(f"req_one_access=list({','.join(key_list)})")

                    if "name" in tile.prefab_vars(idx):
                        name = tile.prefab_var(idx, "name")
                        if not name.endswith("bump") and not name.endswith("placement"):
                            attr_list.append(f"name=\"{name}\"")
                            new_attrs.append(f"name=\"{name}\"")


                    attrs = ";".join(sorted(attr_list))

                    # light switches have no standardized pixel_x/pixel_ys, they
                    # range anywhere from [-10, 10] for offsets and [-35, 35] for
                    # directions. if a switch is clearly the only one on the wall
                    # (little to no offsets) we want to use a /directional/ mapper.
                    # otherwise we want to use an /offset/ mapper biased in the
                    # direction that the pixel_x/pixel_y suggests.
                    subpath = None

                    if -50 < pixel_x < -10:
                        if 0 < pixel_y <= 10:
                            subpath = "/offset/west"
                        elif -10 <= pixel_y < 0:
                            subpath = "/offset/southwest"
                        elif pixel_y == 0:
                            subpath = "/directional/west"
                    elif 10 < pixel_x < 50:
                        if 0 < pixel_y <= 10:
                            subpath = "/offset/northeast"
                        elif -10 <= pixel_y < 0:
                            subpath = "/offset/east"
                        elif pixel_y == 0:
                            subpath = "/directional/east"

                    if -50 < pixel_y < -10:
                        if 0 < pixel_x <= 10:
                            subpath = "/offset/southeast"
                        elif -10 <= pixel_x < 0:
                            subpath = "/offset/south"
                        elif pixel_x == 0:
                            subpath = "/directional/south"
                    elif 10 < pixel_y < 50:
                        if 0 < pixel_x <= 10:
                            subpath = "/offset/north"
                        elif -10 <= pixel_x < 0:
                            subpath = "/offset/northwest"
                        elif pixel_x == 0:
                            subpath = "/directional/north"

                    if subpath is None:
                        print(f"Could not find subpath {atom_path} for {pixel_x=},{pixel_y=} (on {filepath.stem}@{coord})")
                    else:
                        result_path = f"{atom_path}{subpath}"
                        if new_attrs:
                            result_path = f"{result_path}{{{';'.join(sorted(new_attrs))}}}"
                        updatepaths_rules[f"{atom_path}{{{attrs}}}"] = result_path


    with open("tools/UpdatePaths/scripts/XXXXX_lightswitch_offsets.txt", "w") as f:
        for key in sorted(updatepaths_rules):
            f.write(f"{key} : {updatepaths_rules[key]}\n")
