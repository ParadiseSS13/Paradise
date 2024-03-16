import os

import pygit2

try:
    from .dmm import *
    from .merge_driver import three_way_merge
    from .mapmerge import merge_map
except:
    from dmm import *
    from merge_driver import three_way_merge
    from mapmerge import merge_map

CHECK_SUCCESS = 0
CHECK_FAILURE = 1

STATUS_WT = (pygit2.GIT_STATUS_WT_NEW
    | pygit2.GIT_STATUS_WT_MODIFIED
    | pygit2.GIT_STATUS_WT_DELETED
    | pygit2.GIT_STATUS_WT_RENAMED
    | pygit2.GIT_STATUS_WT_TYPECHANGE
)

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
BRIGHT_BLUE = "\033[0;94m"
NC = "\033[0m"  # No Color


# Runs three-way merge on a clean tree against the HEAD's parent and their
# common ancestor. Different from merge_frontend.py in that its _posthoc merge
# driver assumes that we are conflicted, and different from fixup.py in that we
# are doing full conflict detection, not just sanity checks like TGM format.
def main(repo: pygit2.Repository):
    exit_code = CHECK_SUCCESS
    head_object = repo[repo.head.target]
    if len(head_object.parents) > 1:
        print("HEAD has multiple parents unexpectedly")
        return CHECK_FAILURE

    base_object = head_object.parents[0]
    tree_diff = head_object.tree.diff_to_tree(base_object.tree)

    merge_base = repo.merge_base(head_object.oid, base_object.parents[0].oid)
    if not merge_base:
        print("Unable to find common ancestor between commits")
        return CHECK_FAILURE
    merge_object = repo[merge_base]

    changed_map_files = set()
    for patch in tree_diff:
        # TODO: not dealing with renames right now, eff that
        if patch.delta.old_file.path.endswith('.dmm'):
            changed_map_files.add(patch.delta.old_file.path)

    if not changed_map_files:
        print("No changed map files detected.")
        return CHECK_SUCCESS

    print(f"re-merging maps from")
    print(f"parent   {base_object.oid}")
    print(f"to head  {head_object.oid}")
    print(f"off base {merge_object.oid}")

    failures = set()
    for map_file in changed_map_files:
        base_map = DMM.from_bytes(merge_object.tree[map_file].read_raw())
        left_map = DMM.from_bytes(base_object.tree[map_file].read_raw())
        right_map = DMM.from_bytes(head_object.tree[map_file].read_raw())
        failure, result = three_way_merge(base_map, left_map, right_map)
        if failure:
            failures.add(map_file)
            print(f"{RED}{map_file}{NC} failed to merge")
        elif result:
            fname = repo.workdir + map_file
            result.to_file(fname)
            print(f"{BRIGHT_BLUE}{map_file}{NC} rewritten")

    if failures:
        exit_code = CHECK_FAILURE

    maps_in_working_tree = []
    for path, status in repo.status().items():
        if path in changed_map_files and status & STATUS_WT:
            maps_in_working_tree.append(path)

    if maps_in_working_tree:
        for wt_map in maps_in_working_tree:
            print(f"map file {wt_map} found in working tree")
    else:
        print(f"{GREEN}no modified map files found{NC}")

    return exit_code

if __name__ == '__main__':
    exit(main(pygit2.Repository(pygit2.discover_repository(os.getcwd()))))
