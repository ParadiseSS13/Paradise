
#!/usr/bin/env python3

import glob

all_dm_files = glob.glob(r"**/*.dm", recursive=True)

file_name_map = {}

def main():
    for file in all_dm_files:
        newname = file.replace("\\", "/") # OS normalisation
        end_name = newname.split("/")[-1] # Get last split

        if end_name not in file_name_map:
            file_name_map[end_name] = []

        file_name_map[end_name].append(newname) # Take the full thing

    alert_sent = False
    for filename in file_name_map:
        if len(file_name_map[filename]) > 2:
            if not alert_sent:
                print("The following files have the same name in multiple places in the codebase. Please fix!")
                alert_sent = True

            print(f">>> {filename}")
            for fullpath in file_name_map[filename]:
                print(fullpath)

    if alert_sent:
        exit(1)
    else:
        exit(0)

if __name__ == "__main__":
    main()
