from dataclasses import dataclass
from collections import defaultdict

from avulto import DME, Path as p, ProcDecl, SourceLoc, TypeDecl
from avulto.ast import Node, Expression
import pytest

from conftest import Lint


@dataclass(frozen=True)
class AttackChainCall:
    proc_decl: ProcDecl
    var_name: str
    var_type: p | None
    call_name: str
    source_loc: SourceLoc
    legacy: bool

    def make_error_message(self):
        return f"{self.proc_decl.type_path}/{self.proc_decl.name}(...) calls {self.call_name}(...) on var {self.var_type}/{self.var_name}"


CALLS: dict[p, set[AttackChainCall]] = defaultdict(set)

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
        self.local_vars: dict[str, p | None] = dict()

    def get_var_type(self, name: str) -> p | None:
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

    def add_attack_call(self, var_name: str, chain_call: str, source_loc: SourceLoc, legacy: bool):
        var_type = self.get_var_type(var_name)
        if var_type:
            CALLS[var_type].add(
                AttackChainCall(
                    self.proc_decl,
                    var_name,
                    self.get_var_type(var_name),
                    chain_call,
                    source_loc,
                    legacy=legacy,
                )
            )

    def visit_Var(self, node: Node.Var, source_loc: SourceLoc):
        self.local_vars[str(node.name)] = node.declared_type
        if node.value:
            self.visit_Expr(node.value, source_loc)

    def visit_Expr(self, node: Expression, source_loc: SourceLoc):
        if isinstance(node, Expression.Call):
            legacy = False
            record = False
            if isinstance(node.name, Expression.Identifier):
                if "__legacy__attackchain" in node.name.name:
                    legacy = True
                    record = True
                elif node.name.name in NEW_PROCS:
                    legacy = False
                    record = True
                if record and node.expr:
                    if isinstance(node.expr, Expression.Identifier):
                        self.add_attack_call(str(node.expr), node.name.name, source_loc, legacy)
                    elif isinstance(node.expr, Expression.Constant):
                        if not node.expr.constant.val:
                            self.add_attack_call("src", node.name.name, source_loc, legacy)


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
    p("/mob/living"),
    p("/obj"),
    p("/obj/item"),
]

NEW_PROCS = [
    "activate_self",
    "after_attack",
    "attack_by",
    "attack",
    "attacked",
    "interact_with_atom",
    "item_interaction",
]


@pytest.mark.lint("Legacy Attack Chain")
def test_legacy_attack_chain(dme: DME, lint: Lint):
    LEGACY_PROCS: dict[p, list[ProcDecl]] = defaultdict(list)
    MODERN_PROCS: dict[p, list[ProcDecl]] = defaultdict(list)
    SETTING_CACHE: dict[p, bool] = dict()

    for pth in dme.subtypesof("/"):
        if pth in IGNORED_TYPES:
            continue

        td = dme.types[pth]
        if any([pth.child_of(assisted_type, strict=True) for assisted_type in ASSISTED_TYPES]):
            try:
                SETTING_CACHE[pth] = bool(td.var_decl("new_attack_chain", parents=True).const_val)
            except:
                SETTING_CACHE[pth] = False
        for proc_name in td.proc_names(modified=True):
            if "__legacy__attackchain" in proc_name:
                for proc_decl in td.proc_decls(proc_name):
                    LEGACY_PROCS[pth].append(proc_decl)
            elif proc_name in NEW_PROCS:
                for proc_decl in td.proc_decls(proc_name):
                    MODERN_PROCS[pth].append(proc_decl)
        for proc_decl in td.proc_decls():
            walker = AttackChainCallWalker(td, proc_decl)
            proc_decl.walk(walker)

    for pth in sorted(SETTING_CACHE.keys()):
        new_attack_chain = SETTING_CACHE[pth]
        cursor = pth
        if new_attack_chain:
            for proc_decl in sorted(LEGACY_PROCS[pth], key=lambda x: x.name):
                lint.error_source(
                    f"migrated type with legacy proc {pth}/{proc_decl.name}(...)",
                    proc_decl.source_loc,
                )

            while cursor not in ASSISTED_TYPES and not cursor.is_root:
                if LEGACY_PROCS[cursor] and not SETTING_CACHE[cursor]:
                    lint.error(f"new_attack_chain on {pth} but related type {cursor} is not")
                cursor = cursor.parent
            if pth in CALLS and any([x.legacy for x in CALLS[pth]]):
                for call in CALLS[pth]:
                    if call.legacy:
                        lint.error_source(call.make_error_message(), call.source_loc)

        elif pth not in ASSISTED_TYPES:
            if MODERN_PROCS[pth]:
                for proc_decl in sorted(MODERN_PROCS[pth], key=lambda x: x.name):
                    lint.error_source(
                        f"legacy type with migrated proc {pth}/{proc_decl.name}(...)",
                        proc_decl.source_loc
                    )
            if pth in CALLS and any([not x.legacy for x in CALLS[pth]]):
                for call in CALLS[pth]:
                    if not call.legacy:
                        lint.error_source(call.make_error_message(), call.source_loc)
