from pathlib import Path
import subprocess

from avulto import DMM, DME

RENDERER = Path("tools/github-actions/nanomap-renderer")
SCALE = 8


if __name__ == "__main__":
    commands = []

    print("parsing DME...")
    dme = DME.from_file("paradise.dme")
    dmm_files = [str(x) for x in Path("_maps/map_files").glob("**/*.dmm")]

    print("inspecting station maps...")
    for pth in dme.subtypesof("/datum/map"):
        td = dme.types[pth]
        map_path = td.var_decl("map_path").const_val
        technical_name = td.var_decl("technical_name").const_val
        dmm = DMM.from_file(map_path)
        width = dmm.size.x * SCALE
        height = dmm.size.y * SCALE
        commands.append([str(RENDERER), "minimap", "-w", str(width), "-h", str(height), str(map_path)])
        commands.append(["mv", f"data/nanomaps/{dmm.filepath.stem}_nanomap_z1.png", f"icons/_nanomaps/stations/{technical_name}_nanomap_z1.png"])

    print("inspecting ruins...")
    for pth in dme.subtypesof("/datum/map_template/ruin"):
        td = dme.types[pth]
        ruin_id = td.var_decl("id").const_val
        if not ruin_id:
            continue

        prefix = td.var_decl("prefix").const_val
        suffix = td.var_decl("suffix").const_val
        map_path = Path(prefix) / suffix
        dmm = DMM.from_file(map_path)
        width = dmm.size.x * SCALE
        height = dmm.size.y * SCALE
        commands.append([str(RENDERER), "minimap", "-w", str(width), "-h", str(height), str(map_path)])
        commands.append(["mv", f"data/nanomaps/{dmm.filepath.stem}_nanomap_z1.png", f"icons/_nanomaps/ruins/{ruin_id}_nanomap_z1.png"])

    print("executing...")
    for command in commands:
        subprocess.run(command, check=True)

    print("complete.")
