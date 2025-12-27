from functools import cache
from pathlib import Path

from avulto import DME, DMI, DMM, Dir
import click

@click.command()
@click.argument("dme_file", type=click.Path(exists=True, dir_okay=False, path_type=Path))
def fix_icon_states(dme_file: Path):
    dme = DME.from_file(dme_file)
    root = dme_file.parent

    # Simple cache so we don't load icon files repeatedly
    dmi_files = dict()
    def get_iconstate_dirs(turf_path, icon=None, icon_state=None):
        typedecl = dme.types[turf_path]
        if icon is None:
            icon = typedecl.var_decl('icon').const_val
        if icon_state is None:
            icon_state = typedecl.var_decl('icon_state').const_val or ""
        if icon.endswith('.png'):
            return [Dir.SOUTH]

        if icon not in dmi_files:
            dmi_files[icon] = DMI.from_file(root / icon)
        dmi = dmi_files[icon]
        if icon_state not in dmi.states(): # horrible hack fix for shit like the sand in holodeck
            return [Dir.SOUTH]             # which i'm not dealing with right now
        state = dmi.state(icon_state)
        return state.dirs

    for mapfile in (root / "_maps/").glob("**/*.dmm"):
        dmm = DMM.from_file(mapfile)
        modified = False
        for tile in dmm.tiles():
            turf = tile.only('/turf')
            turf_dir = tile.get_prefab_var(turf, 'dir', Dir.SOUTH)
            varedit_icon = tile.get_prefab_var(turf, 'icon', None)
            varedit_icon_state = tile.get_prefab_var(turf, 'icon_state', None)
            if turf_dir not in get_iconstate_dirs(tile.turf_path, varedit_icon, varedit_icon_state):
                print(tile.convert())
                modified = True
                tile.del_prefab_var(turf, 'dir')
        if modified:
            try:
                dmm.save_to(dmm.filepath)
                print(dmm.filepath)
            except:
                print(f"couldn't fix {dmm.filepath}")

if __name__ == '__main__':
    fix_icon_states()