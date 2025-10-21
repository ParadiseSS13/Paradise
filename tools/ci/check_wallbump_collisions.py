from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path
import sys
import time

from avulto import DMM, DME, Dir, Path as p


@dataclass(frozen=True)
class ResultRow:
    map_path: Path
    coords: tuple[int, int, int]
    bumps: list[p]

    def format_bumps(self):
        return ", ".join([str(pth) for pth in sorted(self.bumps)])

    def format_coords(self):
        # z-index is basically always one digit so no justify for it
        return f"({self.coords[0]:>3}, {self.coords[1]:>3}, {self.coords[2]})"


@dataclass(frozen=True)
class BumpCheck:
    pth: p
    exact: bool = False
    allowed: list[p] = field(default_factory=list)


BUMPS: list[BumpCheck] = [
    BumpCheck(p("/obj/item/radio/intercom")),
    BumpCheck(p("/obj/machinery/alarm")),
    BumpCheck(p("/obj/machinery/camera")),
    BumpCheck(p("/obj/machinery/door/airlock")),
    BumpCheck(p("/obj/machinery/door/firedoor")),
    BumpCheck(p("/obj/machinery/economy/vending/wallmed")),
    BumpCheck(p("/obj/machinery/firealarm")),
    BumpCheck(p("/obj/machinery/light_switch")),
    BumpCheck(p("/obj/machinery/light"), exact=True),
    BumpCheck(p("/obj/machinery/light/small"), exact=True),
    BumpCheck(p("/obj/machinery/newscaster")),
    BumpCheck(p("/obj/machinery/power/apc")),
    BumpCheck(p("/obj/machinery/recharger/wallcharger")),
    BumpCheck(p("/obj/machinery/requests_console")),
    BumpCheck(p("/obj/structure/closet/walllocker/emerglocker")),
    BumpCheck(p("/obj/structure/extinguisher_cabinet")),
    BumpCheck(p("/obj/structure/reagent_dispensers/peppertank")),
    BumpCheck(p("/obj/structure/reagent_dispensers/spacecleanertank")),
    BumpCheck(p("/obj/structure/reagent_dispensers/virusfood")),
    BumpCheck(p("/obj/machinery/status_display")),
    BumpCheck(p("/obj/machinery/ai_status_display")),
]


def find_colliding_bumps(dmm: DMM, dme: DME) -> list[ResultRow]:
    results = []
    for coord in dmm.coords():
        tile = dmm.tiledef(*coord)
        bumps_per_dir = defaultdict(list)
        for bump in BUMPS:
            for found_bump in tile.find(bump.pth, exact=bump.exact):
                apparent_dir = tile.get_prefab_var(found_bump, "dir", Dir.SOUTH)

                prefab_path = tile.prefab_path(found_bump)
                typedecl = dme.types[prefab_path]
                pixel_x = typedecl.var_decl("pixel_x").const_val
                pixel_y = typedecl.var_decl("pixel_y").const_val
                if "pixel_x" in tile.prefab_vars(found_bump):
                    pixel_x = tile.prefab_var(found_bump, "pixel_x")
                if "pixel_y" in tile.prefab_vars(found_bump):
                    pixel_y = tile.prefab_var(found_bump, "pixel_y")
                if pixel_x > 0:
                    apparent_dir = Dir.EAST
                elif pixel_x < 0:
                    apparent_dir = Dir.WEST
                elif pixel_y > 0:
                    apparent_dir = Dir.NORTH
                elif pixel_y < 0:
                    apparent_dir = Dir.SOUTH

                # fucking cameras
                if bump.pth.child_of(p("/obj/machinery/camera")):
                    if apparent_dir == Dir.EAST:
                        apparent_dir = Dir.WEST
                    elif apparent_dir == Dir.WEST:
                        apparent_dir = Dir.EAST
                    elif apparent_dir == Dir.SOUTH:
                        apparent_dir = Dir.NORTH
                    elif apparent_dir == Dir.NORTH:
                        apparent_dir = Dir.SOUTH

                bumps_per_dir[apparent_dir].append(prefab_path)

        for apparent_dir, bumps in bumps_per_dir.items():
            if len(bumps) > 1:
                # airlocks and firelocks on the same tile is fine
                if all(bump.child_of(p("/obj/machinery/door")) for bump in bumps):
                    continue

                results.append(
                    ResultRow(
                        dmm.filepath,
                        coord,
                        sorted(bumps),
                    )
                )

    return results


CODE_ROOT = Path(".")
MAP_ROOT = CODE_ROOT / "_maps/map_files"


def green(text):
    return "\033[32m" + str(text) + "\033[0m"


def red(text):
    return "\033[31m" + str(text) + "\033[0m"


def test_map(mapfile: Path, dme: DME):
    dmm = DMM.from_file(mapfile)

    results = sorted(
        find_colliding_bumps(dmm, dme), key=lambda c: c.coords, reverse=True
    )
    filename = dmm.filepath.relative_to(CODE_ROOT)
    for result in results:
        print(
            red(
                f"{filename}: {result.format_coords()} contains collision: {result.format_bumps()}"
            )
        )
    if len(results):
        return 1
    else:
        print(f"{filename} {green('OK')}")

    return 0


def main():
    print("check_wallbump_collisions started")
    start = time.time()

    dme = DME.from_file(CODE_ROOT / "paradise.dme")

    exit_code = 0
    for mappath in MAP_ROOT.glob("**/*.dmm"):
        if "mapmanipout" in mappath.stem:
            continue
        result = test_map(mappath, dme)
        if result:
            exit_code = 1

    end = time.time()
    print(f"check_legacy_attack_chain tests completed in {end - start:.2f}s")
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
