import glob
import re
import os
import sys
import time
from collections import namedtuple

Failure = namedtuple("Failure", ["lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color

IGNORE_515_PROC_MARKER_FILENAME = "__byond_version_compat.dm"
CHECK_515_PROC_MARKER_RE = re.compile(r"\.proc/")
def check_515_proc_syntax(lines):
    for idx, line in enumerate(lines):
        if CHECK_515_PROC_MARKER_RE.search(line):
            return Failure(idx + 1, "Outdated proc reference use detected in code. Please use proc reference helpers.")


CHECK_SPACE_INDENTATION_RE = re.compile(r"^ {2,}[^\*]")
def check_space_indentation(lines):
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
    for idx, line in enumerate(lines):
        if CHECK_SPACE_INDENTATION_RE.match(line):
            return Failure(idx + 1, "Space indentation detected, please use tab indentation.")


CHECK_MIXED_INDENTATION_RE = re.compile(r"^(\t+ | +\t)\s*[^\s\*]")
def check_mixed_indentation(lines):
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
    for idx, line in enumerate(lines):
        if CHECK_MIXED_INDENTATION_RE.match(line):
            return Failure(idx + 1, "Mixed <tab><space> indentation detected, please stick to tab indentation.")


def check_trailing_newlines(lines):
    lines = [x for x in lines]
    if lines and not lines[-1].endswith("\n"):
        return Failure(len(lines), "Missing a trailing newline")


GLOBAL_VARS_RE = re.compile(r"^/*var/")
def check_global_vars(lines):
    for idx, line in enumerate(lines):
        if GLOBAL_VARS_RE.match(line):
            return Failure(idx + 1, "Unmanaged global var use detected in code, please use the helpers.")


PROC_ARGS_WITH_VAR_PREFIX_RE = re.compile(r"^/[\w/]\S+\(.*(var/|, ?var/.*).*\)")
def check_proc_args_with_var_prefix(lines):
    for idx, line in enumerate(lines):
        if PROC_ARGS_WITH_VAR_PREFIX_RE.match(line):
            return Failure(idx + 1, "Changed files contains a proc argument starting with 'var'.")

NANOTRASEN_CAMEL_CASE = re.compile(r"NanoTrasen")
def check_for_nanotrasen_camel_case(lines):
    for idx, line in enumerate(lines):
        if NANOTRASEN_CAMEL_CASE.search(line):
            return Failure(idx + 1, "Nanotrasen should not be spelled in the camel case form.")

TO_CHAT_WITH_NO_USER_ARG_RE = re.compile(r"to_chat\(\"")
def check_to_chats_have_a_user_arguement(lines):
    for idx, line in enumerate(lines):
        if TO_CHAT_WITH_NO_USER_ARG_RE.search(line):
            return Failure(idx + 1, "Changed files contains a to_chat() procedure without a user argument.")

CONDITIONAL_LEADING_SPACE = re.compile(r"(if|for|while|switch)\s+(\(.*?\))") # checks for "if (thing)", replace with $1$2
CONDITIONAL_BEGINNING_SPACE = re.compile(r"(if|for|while|switch)(\(.+) \)") # checks for "if( thing)", replace with $1$2)
CONDITIONAL_ENDING_SPACE = re.compile(r"(if|for|while|switch)\( (.+\))") # checks for "if(thing )", replace with $1($2
CONDITIONAL_INFIX_NOT_SPACE = re.compile(r"(if)\(! (.+\))") # checks for "if(! thing)", replace with $1(!$2
# To fix any of these, run them as regex in VSCode, with the appropriate replacement
# It may be a good idea to turn the replacement into a script someday
def check_conditional_spacing(lines):
    for idx, line in enumerate(lines):
        if CONDITIONAL_LEADING_SPACE.search(line):
            return Failure(idx + 1, "Found a conditional statement matching the format \"if (thing)\", please use \"if(thing)\" instead.")
        if CONDITIONAL_BEGINNING_SPACE.search(line):
            return Failure(idx + 1, "Found a conditional statement matching the format \"if( thing)\", please use \"if(thing)\" instead.")
        if CONDITIONAL_ENDING_SPACE.search(line):
            return Failure(idx + 1, "Found a conditional statement matching the format \"if(thing )\", please use \"if(thing)\" instead.")
        if CONDITIONAL_INFIX_NOT_SPACE.search(line):
            return Failure(idx + 1, "Found a conditional statement matching the format \"if(! thing)\", please use \"if(!thing)\" instead.")

CODE_CHECKS = [
    check_space_indentation,
    check_mixed_indentation,
    check_trailing_newlines,
    check_global_vars,
    check_proc_args_with_var_prefix,
    check_for_nanotrasen_camel_case,
    check_to_chats_have_a_user_arguement,
    check_conditional_spacing,
]


if __name__ == "__main__":
    print("check_grep2 started")

    exit_code = 0
    start = time.time()

    for code_filepath in glob.glob("**/*.dm", recursive=True):
        with open(code_filepath, encoding="UTF-8") as code:
            filename = code_filepath.split(os.path.sep)[-1]
            # 515 proc syntax check is unique in running on all files but one,
            # but I'm not going to make some disproportionately generic "check"
            # that also validates that the test should be run, so it just goes
            # here.
            if filename != IGNORE_515_PROC_MARKER_FILENAME:
                if failure := check_515_proc_syntax(code):
                    exit_code = 1
                    print(f"{code_filepath}:{failure.lineno}: {RED}{failure.message}{NC}")

            for check in CODE_CHECKS:
                code.seek(0)
                if failure := check(code):
                    exit_code = 1
                    print(f"{code_filepath}:{failure.lineno}: {RED}{failure.message}{NC}")

    end = time.time()
    print(f"\ncheck_grep2 tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
