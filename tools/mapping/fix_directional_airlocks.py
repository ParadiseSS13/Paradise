from pathlib import Path

from avulto import DMM

MULTI_TILE_AIRLOCK_PATH = "/obj/machinery/door/airlock/multi_tile"
AIRLOCK_PATH = "/obj/machinery/door/airlock"
FIREDOOR_PATH = "/obj/machinery/door/firedoor"


def has_joiner(dmm: DMM, coord: tuple[int, int, int]):
    tile = dmm.tiledef(*coord)
    if tile.find("/turf/simulated/wall"):
        return True
    if tile.find("/turf/simulated/mineral"):
        return True
    if tile.find("/obj/structure/falsewall"):
        return True

    if tile.find(AIRLOCK_PATH):
        return True
    if tile.find(FIREDOOR_PATH):
        return True

    if tile.find("/obj/effect/spawner/window"):
        return True

    return False


def get_single_tile_airlock_direction(dmm: DMM, coord: tuple[int, int, int]):
    x, y, z = coord

    if y + 1 <= dmm.size.y and y - 1 >= 1:
        north = (x, y + 1, z)
        south = (x, y - 1, z)

        if has_joiner(dmm, north) and has_joiner(dmm, south):
            return 2

    if x + 1 <= dmm.size.x and x - 1 >= 1:
        east = (x + 1, y, z)
        west = (x - 1, y, z)

        if has_joiner(dmm, east) and has_joiner(dmm, west):
            return 4

    return 2


def get_multi_tile_airlock_direction(dmm: DMM, coord: tuple[int, int, int]):
    x, y, z = coord

    if y - 1 >= 1:
        south = (x, y - 1, z)

        if has_joiner(dmm, south):
            return 2

    if x - 1 >= 1:
        west = (x - 1, y, z)

        if has_joiner(dmm, west):
            return 4

    return 2


def fix_map(dmm: DMM):
    modified = False
    for coord in dmm.coords():
        tile = dmm.tiledef(*coord)

        for pth in (AIRLOCK_PATH, FIREDOOR_PATH):
            if tile.only(pth) is not None:
                idx = tile.only(pth)
                curdir = tile.get_prefab_var(idx, "dir", 2)
                newdir = get_single_tile_airlock_direction(dmm, coord)
                if curdir != newdir:
                    modified = True
                    tile.make_unique()
                    if newdir == 2:
                        tile.del_prefab_var(idx, "dir")
                    else:
                        tile.set_prefab_var(idx, "dir", newdir)

        if tile.only(MULTI_TILE_AIRLOCK_PATH) is not None:
            idx = tile.only(MULTI_TILE_AIRLOCK_PATH)
            curdir = tile.get_prefab_var(idx, "dir", 2)
            newdir = get_multi_tile_airlock_direction(dmm, coord)
            if curdir != newdir:
                modified = True
                tile.make_unique()
                if newdir == 2:
                    tile.del_prefab_var(idx, "dir")
                else:
                    tile.set_prefab_var(idx, "dir", newdir)

    if modified:
        dmm.save_to(dmm.filepath)


def fix_all_maps():
    root = Path("_maps/map_files")
    for dmm_file in root.glob("**/*.dmm"):
        print(dmm_file)
        dmm = DMM.from_file(dmm_file)
        fix_map(dmm)


if __name__ == "__main__":
    fix_all_maps()
