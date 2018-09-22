from tempfile import NamedTemporaryFile
import sys
import os
import time
import subprocess

dmitool_path = "tools/dmitool/dmitool.jar"

def run_shell_command(command):
    return subprocess.run(command, shell=True, stdout=subprocess.PIPE, universal_newlines=True).stdout

def run_shell_command_binary(command):
    return subprocess.run(command, shell=True, stdout=subprocess.PIPE).stdout

def string_to_num(s):
    try:
        return int(s)
    except ValueError:
        return -1

def main(relative_root):
    git_version = run_shell_command("git version")
    if not git_version:
        print("ERROR: Failed to run git. Make sure it is installed and in your PATH.")
        return False

    file_conflicts = run_shell_command("git diff --name-only --diff-filter=U").split("\n")
    icon_conflicts = [path for path in file_conflicts if path[len(path)-3::] == "dmi"]

    for i in range(0, len(icon_conflicts)):
        print("[{}]: {}".format(i, icon_conflicts[i]))
    selection = input("Choose icon files you want to fix (example: 1,3-5,12):\n")
    selection = selection.replace(" ", "")
    selection = selection.split(",")

    #shamelessly copied from mapmerger cli
    valid_indices = list()
    for m in selection:
        index_range = m.split("-")
        if len(index_range) == 1:
            index = string_to_num(index_range[0])
            if index >= 0 and index < len(icon_conflicts):
                valid_indices.append(index)
        elif len(index_range) == 2:
            index0 = string_to_num(index_range[0])
            index1 = string_to_num(index_range[1])
            if index0 >= 0 and index0 <= index1 and index1 < len(icon_conflicts):
                valid_indices.extend(range(index0, index1 + 1))

    if not len(valid_indices):
        print("No icons selected, exiting.")
        sys.exit()

    print("Attempting to fix the following icon files:")
    for i in valid_indices:
        print(icon_conflicts[i])
    input("Press Enter to start.")

    for i in valid_indices:
        path = icon_conflicts[i]
        print("{}: {}".format("Merging", path))

        common_ancestor_hash = run_shell_command("git merge-base MERGE_HEAD HEAD").strip()

        ours_icon = NamedTemporaryFile(delete=False)
        theirs_icon = NamedTemporaryFile(delete=False)
        base_icon = NamedTemporaryFile(delete=False)

        ours_icon.write(run_shell_command_binary("git show ORIG_HEAD:{}".format(path)))
        theirs_icon.write(run_shell_command_binary("git show master:{}".format(path)))
        base_icon.write(run_shell_command_binary("git show {}:{}".format(common_ancestor_hash, path)))

        # So it being "open" doesn't prevent other programs from using it
        ours_icon.close()
        theirs_icon.close()
        base_icon.close()

        merge_command = "java -jar {} merge {} {} {} {}".format(relative_root + dmitool_path, base_icon.name, ours_icon.name, theirs_icon.name, relative_root + path + ".fixed")

        print(merge_command)
        print(run_shell_command(merge_command))
        os.remove(ours_icon.name)
        os.remove(theirs_icon.name)
        os.remove(base_icon.name)
        print(".")

main(sys.argv[1])
