import os
import sys
import time
from dataclasses import dataclass
from typing import Any

from avulto import DME, Path as p, ProcDecl
from avulto.ast import NodeKind, SourceLoc


RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color


def make_error(source_loc: SourceLoc, msg) -> str:
    if os.getenv("GITHUB_ACTIONS") == "true":
        return f"::error file={source_loc.file_path},line={source_loc.line},title=User Verbs::{source_loc.file_path}:{source_loc.line}: {RED}{msg}{NC}"
    else:
        return f"{source_loc.file_path}:{source_loc.line}: {RED}{msg}{NC}"


PROCS_NEED_CLIENT = (
    "alert",
    "tgui_input_list",
    "tgui_input_number",
    "to_chat",
)

BAD_VARS = (
    "usr",
    "src",
)


class Walker:
    def __init__(self):
        self.bad_names = []
        self.bad_inputs = []
        self.bad_calls = []
        self.bad_clean_inputs = []

    def visit_Identifier(self, node, source_info):
        if node.name in BAD_VARS:
            self.bad_names.append((node, source_info))

    def visit_Input(self, node, source_info):
        if node.args[0].kind == NodeKind.CONSTANT:
            self.bad_inputs.append((node, source_info))
        elif str(node.args[0]) in BAD_VARS:
            self.bad_names.append((node.args[0], source_info))

    def visit_Call(self, node, source_info):
        if (
            str(node.name) in PROCS_NEED_CLIENT
            and node.args[0].kind == NodeKind.CONSTANT
        ):
            self.bad_calls.append((node, source_info))

        if str(node.name) == "clean_input":
            last_arg = node.args[-1]
            if last_arg.kind == NodeKind.ASSIGN_OP:
                if str(last_arg.lhs) != "user" or str(last_arg.rhs) != "client":
                    self.bad_clean_inputs.append((node, source_info))
            else:
                self.bad_clean_inputs.append((node, source_info))

        for arg in node.args:
            if arg.kind == NodeKind.IDENTIFIER:
                self.visit_Identifier(arg, source_info)
            elif arg.kind == NodeKind.CALL:
                self.visit_Call(arg, source_info)
            elif arg.kind == NodeKind.INTERP_STRING:
                # "[key_name(usr)] blah blah"
                #
                # hate we have to nest this so deeply but once we have a
                # visit_Node for any Node, its tree is not going to get
                # visited node by node unless we so do explicitly.
                for expr, _ in arg.token_pairs:
                    if expr.kind == NodeKind.CALL:
                        self.visit_Call(expr, source_info)
                    elif expr.kind == NodeKind.IDENTIFIER:
                        self.visit_Identifier(expr, source_info)


if __name__ == "__main__":
    print("check_user_verb_params started")

    exit_code = 0
    start = time.time()

    dme = DME.from_file("paradise.dme", parse_procs=True)
    errors = []

    for pth in dme.subtypesof("/datum/user_verb"):
        walker = Walker()
        td = dme.types[pth]
        proc = td.proc_decls("__avd_do_verb")[0]
        proc.walk(walker)

        if walker.bad_names:
            exit_code = 1
            for name, source_loc in walker.bad_names:
                errors.append(
                    make_error(
                        source_loc,
                        f"user verb {td.path} uses `{name}` instead of implicit client/client arg",
                    )
                )

        if walker.bad_inputs:
            exit_code = 1
            for node, source_loc in walker.bad_inputs:
                errors.append(
                    make_error(
                        source_loc,
                        f"input() call in {td.path} missing explicit recipient",
                    )
                )

        if walker.bad_calls:
            exit_code = 1
            for node, source_loc in walker.bad_calls:
                errors.append(
                    make_error(
                        source_loc,
                        f"call {node.name}() in {td.path} missing explicit recipient",
                    )
                )

        if walker.bad_clean_inputs:
            exit_code = 1
            for node, source_loc in walker.bad_clean_inputs:
                errors.append(
                    make_error(
                        source_loc,
                        f"call {node.name}() in {td.path} must have `user = client` as its last arg",
                    )
                )

    for error in sorted(errors):
        print(error)

    end = time.time()
    print(f"check_user_verb_params tests completed in {end - start:.2f}s\n")
    sys.exit(exit_code)
