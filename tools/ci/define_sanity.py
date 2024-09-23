import fnmatch
import glob
import os
import re
import sys

parent_directory = "code/**/*.dm"

how_to_fix_message = "Please #undef the above defines or remake them as global defines in the code/__DEFINES directory."

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def blue(text):
    return "\033[34m" + str(text) + "\033[0m"

def post_error(define_name, file, github_error_style):
    if github_error_style:
        print(f"::error file={file},title=Define Sanity::{define_name} is defined locally in {file} but not undefined locally!")
    else:
        directory, filename = os.path.split(file)
        print(f"- Failure: {red(define_name)} is defined locally in {directory}\{red(filename)} but not undefined locally!")

def main():

    # simple way to check if we're running on github actions, or on a local machine
    on_github = os.getenv("GITHUB_ACTIONS") == "true"

    # This files/directories are expected to have "global" defines, so they must be exempt from this check.
    # Add directories as string here to automatically be exempt in case you have a non-complaint file name.
    excluded_files = [
        #  Wildcard directories, all files are expected to be exempt.
        "code/__DEFINES/*.dm",
        "code/__HELPERS/*.dm",
        "code/_globalvars/*.dm",
        # TGS files come from another repository so lets not worry about them.
        "code/modules/tgs/**/*.dm",
    ]

    define_regex = re.compile(r"^(\s+)?#define\s?([A-Z0-9_]+)\(?(.+)\)?", re.MULTILINE)

    files_to_scan = []

    number_of_defines = 0

    for code_file in glob.glob(parent_directory, recursive=True):
        exempt_file = False
        for exempt_directory in excluded_files:
            if fnmatch.fnmatch(code_file, exempt_directory):
                exempt_file = True
                break

        if exempt_file:
            continue

        # If the "base path" of the file starts with an underscore, it's assumed to be an encapsulated file holding references to the other files in its folder and is exempt from the checks.
        if os.path.basename(code_file)[0] == "_":
            continue

        files_to_scan.append(code_file)

    located_error_tuples = []

    for applicable_file in files_to_scan:
        with open(applicable_file, encoding="utf8") as file:
            file_contents = file.read()
            for define in define_regex.finditer(file_contents):
                number_of_defines += 1
                define_name = define.group(2)
                if not re.search("#undef\s" + define_name, file_contents):
                    located_error_tuples.append((define_name, applicable_file))

    if number_of_defines == 0:
        print(red("No defines found! This is likely an error."))
        sys.exit(1)

    if number_of_defines <= 1000:
        print(red(f"Only found {number_of_defines} defines! Something has likely gone wrong as the number of local defines should not be this low."))
        sys.exit(1)

    if len(located_error_tuples):
        fix_errors = False
        for error in located_error_tuples:
            post_error(error[0], error[1], on_github)

        print(red(how_to_fix_message))

        if(not on_github):
            fix_errors = input(red(f"We found {len(located_error_tuples)} defines missing #undef\'s at the end of their file. Would you like to fix these errors?") + " [y/n]: ").lower()[0] == "y" # Check if the answer is "Yes", "y", "Y", etc
            if(fix_errors):
                for error in located_error_tuples:
                    with open(error[1], "a") as write_file:
                        write_file.write(f"#undef {error[0]}\n") # We append at the \n because files end with \n

        sys.exit(1)

    else:
        print(green(f"No unhandled local defines found (found {number_of_defines} defines)."))

if __name__ == "__main__":
    main()
