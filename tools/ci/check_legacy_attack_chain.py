import sys
import time
from dataclasses import dataclass
from collections import namedtuple, defaultdict

from avulto import DMM, DME, DMI, Dir, Path as p, paths, ProcDecl, TypeDecl
from avulto.ast import NodeKind
from avulto import exceptions


@dataclass(frozen=True)
class AttackChainCall:
    proc_decl: ProcDecl
    var_name: str
    var_type: p | None
    call_name: str

    def __str__(self):
        return f"AttackChainCall\n\t- called in {self.proc_decl}\n\t- called proc {self.call_name}\n\t- on var {self.var_type}/{self.var_name}"

    def __repr__(self):
        return self.__str__()


# Walker for determining if a proc contains any calls to a legacy attack chain
# proc on an object that is in the type tree of our migrating type.
#
# We check local, proc-argument, and type-declaration scope to find variables of
# matching names for when an attack chain proc is called, and attempt to find
# that variable's matching type. If the type matches, then the call site is
# calling a legacy proc on that type.
class AttackChainCallWalker:
    def __init__(self, type_decl: TypeDecl, proc_decl: ProcDecl):
        self.type_decl = type_decl
        self.proc_decl = proc_decl
        self.local_vars = dict()
        self.attack_chain_calls = list()

    def get_var_type(self, name):
        if name == "src":
            return self.type_decl.path
        if name in self.local_vars:
            return self.local_vars[name]
        for arg in self.proc_decl.args:
            if arg.arg_name == name:
                return arg.arg_type

        try:
            vd = self.type_decl.var_decl(name, parents=True)
            if vd.declared_type:
                return vd.declared_type
        except:
            pass

        return None

    def add_attack_call(self, var_name, chain_call):
        var_type = self.get_var_type(var_name)
        CALLS[var_type].add(
            AttackChainCall(
                self.proc_decl,
                var_name,
                self.get_var_type(var_name),
                chain_call,
            )
        )

    def visit_Var(self, node, source_info):
        self.local_vars[str(node.name)] = node.declared_type

    def visit_Expr(self, node, source_info):
        if node.kind == NodeKind.CALL:
            if "__legacy__attackchain" in node.name.name:
                if node.expr:
                    if node.expr.kind == NodeKind.IDENTIFIER:
                        self.add_attack_call(str(node.expr), node.name.name)
                    elif node.expr.kind == NodeKind.CONSTANT:
                        if not node.expr.constant.val:
                            self.add_attack_call("src", node.name.name)


# Ignored types will never be part of the attack chain.
IGNORED_TYPES = [
    p("/area"),
    p("/client"),
    p("/database"),
    p("/datum"),
    p("/dm_filter"),
    p("/exception"),
    p("/generator"),
    p("/icon"),
    p("/image"),
    p("/matrix"),
    p("/mutable_appearance"),
    p("/particles"),
    p("/regex"),
    p("/sound"),
]

# Assisted types are the ones which actually perform negotiation between old/new
# attack chains, and will not be migrated until everything else is.
ASSISTED_TYPES = [
    p("/atom"),
    p("/mob"),
    p("/obj"),
    p("/obj/item"),
]


if __name__ == "__main__":
    print("check_legacy_attack_chain started")

    exit_code = 0
    start = time.time()

    CALLS = defaultdict(set)
    SETTING_CACHE = dict()
    LEGACY_PROCS = dict()
    BAD_TREES = dict()
    PROCS = dict()

    dme = DME.from_file("paradise.dme", parse_procs=True)

    for pth in dme.subtypesof("/"):
        td = dme.types[pth]
        if any(
            [
                pth.child_of(assisted_type, strict=True)
                for assisted_type in ASSISTED_TYPES
            ]
        ):
            try:
                SETTING_CACHE[pth] = bool(
                    td.var_decl("new_attack_chain", parents=True).const_val
                )
            except:
                SETTING_CACHE[pth] = False
        LEGACY_PROCS[pth] = {
            x for x in td.proc_names(modified=True) if "__legacy__attackchain" in x
        }
        for proc_decl in td.proc_decls():
            walker = AttackChainCallWalker(td, proc_decl)
            proc_decl.walk(walker)

    for pth, new_attack_chain in SETTING_CACHE.items():
        cursor = pth
        if new_attack_chain:
            if LEGACY_PROCS[pth]:
                exit_code = 1
                print(
                    f"new_attack_chain on {pth} still has legacy procs {LEGACY_PROCS[pth]}"
                )
            while cursor not in ASSISTED_TYPES and not cursor.is_root:
                if LEGACY_PROCS[cursor] and not SETTING_CACHE[cursor]:
                    exit_code = 1
                    print(
                        f"new_attack_chain on {pth} but type {cursor} has legacy procs {LEGACY_PROCS[cursor]}"
                    )
                cursor = cursor.parent
            if pth in CALLS:
                exit_code = 1
                print("Call sites requiring migration:")
                for call in CALLS[pth]:
                    print(call)

    end = time.time()
    print(f"check_legacy_attack_chain tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
