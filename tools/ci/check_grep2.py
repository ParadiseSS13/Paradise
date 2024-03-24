import glob
import re
import os
import sys
import time
from collections import namedtuple

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color

def print_error(message: str, filename: str, line_number: int):
    if os.getenv("GITHUB_ACTIONS") == "true": # We're on github, output in a special format.
        print(f"::error file={filename},line={line_number},title=Check Grep::{filename}:{line_number}: {RED}{message}{NC}")
    else:
        print(f"{filename}:{line_number}: {RED}{message}{NC}")

IGNORE_515_PROC_MARKER_FILENAME = "__byond_version_compat.dm"
CHECK_515_PROC_MARKER_RE = re.compile(r"\.proc/")
def check_515_proc_syntax(idx, line):
    if CHECK_515_PROC_MARKER_RE.search(line):
        return [(idx + 1, "Outdated proc reference use detected in code. Please use proc reference helpers.")]


CHECK_SPACE_INDENTATION_RE = re.compile(r"^ {2,}[^\*]")
def check_space_indentation(idx, line):
    """
    Check specifically for space-significant indentation. Excludes dmdoc
    block comment lines so long as there is an asterisk immediately after the
    leading spaces.

    >>> bool(check_space_indentation(["  foo"]))
    True

    >>> bool(check_space_indentation(["\\tfoo"]))
    False
    >>> bool(check_space_indentation(["  * foo"]))
    False
    """
    if CHECK_SPACE_INDENTATION_RE.match(line):
        return [(idx + 1, "Space indentation detected, please use tab indentation.")]


CHECK_MIXED_INDENTATION_RE = re.compile(r"^(\t+ | +\t)\s*[^\s\*]")
def check_mixed_indentation(idx, line):
    """
    Check specifically for leading whitespace which contains a mix of tab and
    space characters. Excludes dmdoc block comment lines so long as there is an
    asterisk immediately after the leading whitespace.

    >>> bool(check_mixed_indentation(["\\t\\t foo"]))
    True
    >>> bool(check_mixed_indentation(["\\t \\t foo"]))
    True
    >>> bool(check_mixed_indentation(["\\t // foo"]))
    True
    >>> bool(check_mixed_indentation([" \\tfoo"]))
    True
    >>> bool(check_mixed_indentation(["  \\t  foo"]))
    True

    >>> bool(check_mixed_indentation(["\\t  * foo"]))
    False
    >>> bool(check_mixed_indentation(["\\t\\t* foo"]))
    False
    >>> bool(check_mixed_indentation(["\\t \\t  * foo"]))
    False
    """
    if CHECK_MIXED_INDENTATION_RE.match(line):
        return [(idx + 1, "Mixed <tab><space> indentation detected, please stick to tab indentation.")]


GLOBAL_VARS_RE = re.compile(r"^/*var/")
def check_global_vars(idx, line):
    if GLOBAL_VARS_RE.match(line):
        return [(idx + 1, "Unmanaged global var use detected in code, please use the helpers.")]


TOPLEVEL_VARDECLS_RE = re.compile(r"^(/[^\*(\/\/)].*/var/(list/)?\w+)")
def check_toplevel_vardecls(idx, line):
    if match := TOPLEVEL_VARDECLS_RE.match(line):
        return [(idx + 1, f"Top-level var {match.group(0)} found, please move to type declaration.")]


PROC_ARGS_WITH_VAR_PREFIX_RE = re.compile(r"^/[\w/]\S+\(.*(var/|, ?var/.*).*\)")
def check_proc_args_with_var_prefix(idx, line):
    if PROC_ARGS_WITH_VAR_PREFIX_RE.match(line):
        return [(idx + 1, "Changed files contains a proc argument starting with 'var'.")]

NANOTRASEN_CAMEL_CASE = re.compile(r"NanoTrasen")
def check_for_nanotrasen_camel_case(idx, line):
    if NANOTRASEN_CAMEL_CASE.search(line):
        return [(idx + 1, "Nanotrasen should not be spelled in the camel case form.")]

TO_CHAT_WITH_NO_USER_ARG_RE = re.compile(r"to_chat\(\"")
def check_to_chats_have_a_user_arguement(idx, line):
    if TO_CHAT_WITH_NO_USER_ARG_RE.search(line):
        return [(idx + 1, "Changed files contains a to_chat() procedure without a user argument.")]

CONDITIONAL_LEADING_SPACE = re.compile(r"(if|for|while|switch)\s+(\(.*?\)?)") # checks for "if (thing)", replace with $1$2
CONDITIONAL_BEGINNING_SPACE = re.compile(r"(if|for|while|switch)\((!?) (.+\)?)") # checks for "if( thing)", replace with $1($2$3
CONDITIONAL_ENDING_SPACE = re.compile(r"(if|for|while|switch)(\(.+) \)") # checks for "if(thing )", replace with $1$2)
CONDITIONAL_DOUBLE_PARENTHESIS = re.compile(r"(if)\((\([^)]+\))\)$") # checks for if((thing)), replace with $1$2
# To fix any of these, run them as regex in VSCode, with the appropriate replacement
# It may be a good idea to turn the replacement into a script someday
def check_conditional_spacing(idx, line):
    failures = []
    if CONDITIONAL_LEADING_SPACE.search(line):
        failures.append((idx + 1, "Found a conditional statement matching the format \"if (thing)\" (irregular spacing), please use \"if(thing)\" instead."))
    if CONDITIONAL_BEGINNING_SPACE.search(line):
        failures.append((idx + 1, "Found a conditional statement matching the format \"if( thing)\" (irregular spacing), please use \"if(thing)\" instead."))
    if CONDITIONAL_ENDING_SPACE.search(line):
        failures.append((idx + 1, "Found a conditional statement matching the format \"if(thing )\" (irregular spacing), please use \"if(thing)\" instead."))
    if CONDITIONAL_DOUBLE_PARENTHESIS.search(line):
        failures.append((idx + 1, "Found a conditional statement matching the format \"if((thing))\" (unnecessary outer parentheses), please use \"if(thing)\" instead."))

    return failures

# makes sure that no global list inits have an empty list in them without using the helper
GLOBAL_LIST_EMPTY = re.compile(r"(?<!#define GLOBAL_LIST_EMPTY\(X\) )GLOBAL_LIST_INIT([^,]+),.{0,5}list\(\)")
# This uses a negative look behind to make sure its not the global list definition
# An easy regex replacement for this is GLOBAL_LIST_EMPTY$1
def check_global_list_empty(idx, line):
    if GLOBAL_LIST_EMPTY.search(line):
        failures.append((idx + 1, "Found a GLOBAL_LIST_INIT(_, list()), please use GLOBAL_LIST_EMPTY(_) instead."))

# makes sure arguments contained within "ui = new" are valid
TGUI_UI_NEW = re.compile(r"ui = new\(((?:(?!,\s*).)+,\s*){1,3}(?:(?!,\s*).)+\)")
def check_tgui_ui_new_argument(idx, line):
    if "\tui = new" in line and not TGUI_UI_NEW.search(line):
        return [(idx + 1, "Invalid argument within constructor, please make sure window sizing is in corresponding JavaScript file.")]

# checks for any (for var/type/x) loops that are not looping over bare datums: enforcing that the only case we will see this is if you genuinely want to loop over all datums in memory
FOR_ALL_DATUMS = re.compile(r"for\s*\(\s*var\/((\w+)(?:(?:\/\w+){2,})?)\)")
# double-checks that we don't have any attempts at looping like for(var/atom/a)
FOR_ALL_NOT_DATUMS = re.compile(r"for\s*\(\s*var\/((?:atom|area|turf|obj|mob)(?:\/\w+))\)")
def check_datum_loops(idx, line):
    if FOR_ALL_DATUMS.search(line) or FOR_ALL_NOT_DATUMS.search(line):
        return Failure(
            idx + 1,
            # yes this will concatenate the strings, don't look too hard
            "Found a for loop without explicit contents. If you're trying to loop over everything in the world, first double check that you truly need to, and if so specify \'in world\'.\n"
            "If you're trying to check bare datums, please ensure that your value is only cast to /datum, and please make sure you use \'as anything\', or use a global list instead."
        )

CODE_CHECKS = [
    check_space_indentation,
    check_mixed_indentation,
    check_global_vars,
    check_toplevel_vardecls,
    check_proc_args_with_var_prefix,
    check_for_nanotrasen_camel_case,
    check_to_chats_have_a_user_arguement,
    check_conditional_spacing,
    check_global_list_empty,
    check_tgui_ui_new_argument,
    check_datum_loops,
]


if __name__ == "__main__":
    print("check_grep2 started")

    exit_code = 0
    start = time.time()

    dm_files = glob.glob("**/*.dm", recursive=True)

    if len(sys.argv) > 1:
        dm_files = [sys.argv[1]]

    all_failures = []

    for code_filepath in dm_files:
        with open(code_filepath, encoding="UTF-8") as code:
            filename = code_filepath.split(os.path.sep)[-1]

            extra_checks = []
            if filename != IGNORE_515_PROC_MARKER_FILENAME:
                extra_checks.append(check_515_proc_syntax)

            last_line = None
            for idx, line in enumerate(code):
                for check in CODE_CHECKS + extra_checks:
                    if failures := check(idx, line):
                        all_failures += [Failure(code_filepath, lineno, message) for lineno, message in failures]
                last_line = line

            if last_line and last_line[-1] != '\n':
                all_failures.append(Failure(code_filepath, idx + 1, "Missing a trailing newline"))

    if all_failures:
        exit_code = 1
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)

    end = time.time()
    print(f"\ncheck_grep2 tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
