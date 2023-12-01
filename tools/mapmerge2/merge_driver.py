#!/usr/bin/env python3
import collections
from . import dmm
from hooks.merge_frontend import MergeDriver


debug_stats = collections.defaultdict(int)

SELECT_LEFT = 'left'
SELECT_RIGHT = 'right'


def make_conflict_marker(typ, name):
    # Note that if you do not have an object that matches this path in
    # your DME, the invalid path may be discarded when the map is loaded
    # into a map editor. To rectify this, either add an object with this
    # same path, or create a new object/denote an existing object in the
    # obj_path define.
    obj_path = f"{typ}/merge_conflict_marker"
    obj_name = f"Merge Conflict Marker{(': ' + name) if name else ''}"
    return f'{obj_path}{{name = "{obj_name}"}}'


def select(base, left, right, *, debug=None):
    if left == right:
        # whether or not it's in the base, both sides agree
        if debug:
            debug_stats[f"select {debug} both"] += 1
        return SELECT_LEFT
    elif base == left:
        # base == left, but right is different: accept right
        if debug:
            debug_stats[f"select {debug} right"] += 1
        return SELECT_RIGHT
    elif base == right:
        # base == right, but left is different: accept left
        if debug:
            debug_stats[f"select {debug} left"] += 1
        return SELECT_LEFT
    else:
        # all three versions are different
        if debug:
            debug_stats[f"select {debug} fail"] += 1
        return None


def three_way_merge(base: dmm.DMM, left: dmm.DMM, right: dmm.DMM):
    if base.size != left.size or base.size != right.size:
        print("Dimensions have changed:")
        print(f"    Base: {base.size}")
        print(f"    Ours: {left.size}")
        print(f"    Theirs: {right.size}")
        return True, None

    trouble = False
    merged = dmm.DMM(base.key_length, base.size)
    merged.dictionary = base.dictionary.copy()

    desired_keys = {}

    # For either left or right: Check to see if the tile already exists with a
    # key. If so, we clobber the key and reuse the one from the left/right to
    # reduce key changes that may cascade throughout the file, causing noisy
    # unrelated diffs.
    def swap_in_from_leftright(coord, leftright: dmm.DMM, tiledata: tuple):
        # If the exact tile data already exists, we reuse that tile's key. This
        # may cause more churn in the textual diff but the alternative is
        # attempting to reassign *that* key which would almost certainly end up
        # being noisier.
        #
        # Note that this is being done sequentially through the file; an
        # existence check passing here almost guarantees that what we're seeing
        # is a result of us, ourselves, wanting this key-value pair in the final
        # output. So I don't think ignoring the swap-in key here is disastrous.
        if tiledata in merged.dictionary.inv:
            merged.grid[coord] = merged.dictionary.inv[tiledata]
            return

        # Otherwise, we need to swap in the data.
        swap_in_key = leftright.dictionary.inv[tiledata]

        if swap_in_key in merged.dictionary:
            # If the key is already being used, we generate a new key but keep
            # track of the old one, because there's a pretty good chance the
            # reason there's a collision is because the old tile has it. So
            # later when we remove unused keys we have another chance to clean
            # up the text diff.

            # swap in key = tile data, new key
            desired_keys[swap_in_key] = (tiledata, merged.set_tile(coord, tiledata))
        else:
            merged.dictionary[swap_in_key] = tiledata
            merged.grid[coord] = swap_in_key

    for (z, y, x) in base.coords_zyx:
        coord = x, y, z
        base_tile = base.get_tile(coord)
        left_tile = left.get_tile(coord)
        right_tile = right.get_tile(coord)

        # try to merge the whole tiles
        whole_tile_merge = select(base_tile, left_tile, right_tile, debug='tile')
        if whole_tile_merge is not None:
            if whole_tile_merge == SELECT_LEFT:
                swap_in_from_leftright(coord, left, left_tile)
            elif whole_tile_merge == SELECT_RIGHT:
                swap_in_from_leftright(coord, right, right_tile)
            else:
                raise RuntimeError(f"unexpected select {whole_tile_merge}")

            continue

        # try to merge each group independently (movables, turfs, areas)
        base_movables, base_turfs, base_areas = dmm.split_atom_groups(base_tile)
        left_movables, left_turfs, left_areas = dmm.split_atom_groups(left_tile)
        right_movables, right_turfs, right_areas = dmm.split_atom_groups(right_tile)

        tile = []

        select_movable = select(base_movables, left_movables, right_movables, debug='movable')
        select_turf = select(base_turfs, left_turfs, right_turfs, debug='turf')
        select_area = select(base_areas, left_areas, right_areas, debug='area')

        if not all([select_movable, select_turf, select_area]):
            trouble = True
            print(f" C: Both sides touch the tile at {coord}")

        # fall back to requiring manual conflict resolution
        # TODO: more advanced strategies?

        if select_movable == SELECT_LEFT:
            tile += left_movables
        elif select_movable == SELECT_RIGHT:
            tile += right_movables
        else:
            tile += [make_conflict_marker("/obj", "<<<")] + left_movables + [make_conflict_marker("/obj", "---")] + right_movables + [make_conflict_marker("/obj", ">>>")]
            print(f"    Left and right movable groups are split by an object conflict marker.")

        if select_turf == SELECT_LEFT:
            tile += left_turfs
        elif select_turf == SELECT_RIGHT:
            tile += right_turfs
        else:
            tile += [make_conflict_marker("/turf", "<<<")] + left_turfs + [make_conflict_marker("/turf", "---")] + right_turfs + [make_conflict_marker("/turf", ">>>")]
            print(f"    Left and right turfs are split by an object conflict marker.")

        if select_area == SELECT_LEFT:
            tile += left_areas
        elif select_area == SELECT_RIGHT:
            tile += right_areas
        else:
            tile += [make_conflict_marker("/area", "<<<")] + left_areas + [make_conflict_marker("/area", "---")] + right_areas + [make_conflict_marker("/area", ">>>")]
            print(f"    Left and right areas are split by an object conflict marker.")

        merged.set_tile(coord, tile)

    merged.remove_unused_keys()

    swaps = {}

    for key, (tiledata, new_key) in desired_keys.items():
        if key not in merged.dictionary:
            # We got the key back after removing unused keys
            merged.dictionary.inv[tiledata] = key
            swaps[new_key] = key

    if swaps:
        for (z, y, x) in merged.coords_zyx:
            k = merged.grid[(x, y, z)]
            if k in swaps:
                merged.grid[(x, y, z)] = swaps[k]

    return trouble, merged


class DmmDriver(MergeDriver):
    driver_id = 'dmm'

    def merge(self, base, left, right):
        map_base = dmm.DMM.from_bytes(base.read())
        map_left = dmm.DMM.from_bytes(left.read())
        map_right = dmm.DMM.from_bytes(right.read())
        trouble, merge_result = three_way_merge(map_base, map_left, map_right)
        return not trouble, merge_result

    def to_file(self, outfile, merge_result):
        outfile.write(merge_result.to_bytes())

    def post_announce(self, success, merge_result):
        if not success:
            print("!!! Manual merge required!")
            if merge_result:
                print("    A best-effort merge was performed. You must edit the map and confirm")
                print("    that all coordinates mentioned above are as desired.")
            else:
                print("    The map was totally unable to be merged; you must start with one version")
                print("    or the other and manually resolve the conflict. Information about the")
                print("    conflicting tiles is listed above.")


if __name__ == '__main__':
    exit(DmmDriver().main())
