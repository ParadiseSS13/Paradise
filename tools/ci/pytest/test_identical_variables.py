from avulto import DME
from conftest import Lint

def test_identical_variables(lint: Lint, dme: DME):
    for path in dme.subtypesof("/"):
        typepath = dme.types[path]

        for variable_name in typepath.var_names(modified=True):
            modded = typepath.var_decl(variable_name, False)
            if(not modded):
                lint.error_source(f"Avulto failed to read {path.rel}::{variable_name}. This is probably not your fault.", typepath.source_loc)
                continue
            if path.parent.is_root:
                continue
            parent_typepath = dme.types[path.parent]
            original = parent_typepath.var_decl(variable_name, True)
            if(modded.const_val == original.const_val):
                if(modded.const_val == None): # Both proc calls (like sound() or icon()) and nulls are treated as "None", this sucks.
                    continue
                # Make an exception for directional helpers, where you cant guarantee.
                if(modded.name in ["dir", "pixel_x", "pixel_y"] and path.parent.stem in ["directional", "offset"]):
                    continue
                # Make an exception for subsystems, as they are much less OOP dependent.
                if(path.child_of("/datum/controller/subsystem")):
                    continue
                # And make an exception for this fucked up edge case. wtf.
                if(path.rel == "/obj" and variable_name == "layer"):
                    continue
                lint.error_source(f"{path.rel} has a identical variable to its parents: {variable_name} = {modded.const_val}", typepath.source_loc)


