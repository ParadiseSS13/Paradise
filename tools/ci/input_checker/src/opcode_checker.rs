use crate::dmb;
use crate::Names;
use dmasm_bytecode::{Instruction, Node};
use std::collections::{BTreeSet, HashSet};
use std::io::StdoutLock;
use std::io::{ErrorKind, Write};


struct FoundInput {
    places: BTreeSet<(String, u32, String)>,
    procs: usize,
    unread: Vec<String>,
}

fn inputs_in(dmb: &dmb::Dmb) -> FoundInput {
    let mut found = FoundInput {
        places: BTreeSet::new(),
        procs: dmb.procs.len(),
        unread: Vec::new(),
    };
    for proc in &dmb.procs {
        let name = match dmb.proc_path(proc) {
            Some(path) => String::from_utf8_lossy(path).into_owned(),
            None => "(unnamed proc)".to_owned(),
        };
        let (nodes, failed) =
            dmasm_bytecode::disassembler::disassemble(dmb.bytecode(proc), &mut Names(dmb));
        if failed.is_some() {
            found.unread.push(name.clone());
        }
        let (mut file, mut line) = (String::new(), 0);
        for node in &nodes {
            match node {
                Node::Instruction(Instruction::DbgFile(name), _) => {
                    file = String::from_utf8_lossy(&name.0).into_owned()
                }
                Node::Instruction(Instruction::DbgLine(at), _) => line = *at,
                Node::Instruction(Instruction::Input(..) | Instruction::InputColor(..), _) => {
                    found.places.insert((file.clone(), line, name.clone()));
                }
                _ => {}
            }
        }
    }
    found
}

pub fn check_inputs(dmb: &dmb::Dmb, allowed_locations: HashSet<&str>, out: &mut StdoutLock) -> Result<(), String> {
    let found = inputs_in(&dmb);

    let mut issues: u32 = 0;

    for (file, line, proc) in &found.places {
        if !file.is_empty() && line > &0 {
            // See if its a saved location
            let this_loc = format!("{file}|{line}");
            if allowed_locations.contains(this_loc.as_str()) {
                continue;
            }
        }

        issues += 1;
        let written = if file.is_empty() {
            writeln!(out, "(no line information): {proc}")
        } else {
            writeln!(out, "{file}:{line}: {proc}")
        };
        match written {
            Ok(()) => {}
            Err(closed) if closed.kind() == ErrorKind::BrokenPipe => return Ok(()),
            Err(why) => return Err(format!("cannot write the list: {why}")),
        }
    }
    eprintln!(
        "{} places call input(), in {} procs read",
        found.places.len(),
        found.procs
    );
    for proc in &found.unread {
        eprintln!("not read to its end, so it may hide more: {proc}");
    }

    if issues == 0 {
        Ok(())
    } else {
        Err(format!("{issues} issues found"))
    }
}
