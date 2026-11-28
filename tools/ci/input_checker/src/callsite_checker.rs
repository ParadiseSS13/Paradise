use crate::dmb;
use crate::Names;
use dmasm_bytecode::operands::Value;
use dmasm_bytecode::{Instruction, Node};
use std::collections::{BTreeSet, HashSet};
use std::io::StdoutLock;
use std::io::{ErrorKind, Write};

struct FoundCallsite {
    calls: BTreeSet<(String, u32, String, BTreeSet<String>, u32)>,
    procs: usize,
    unread: Vec<String>,
    target_exists: bool,
}

struct Arguments {
    named: Vec<String>,
    unread: u32,
}


impl std::fmt::Display for Arguments {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let plural = if self.unread == 1 { "" } else { "s" };
        match (self.named.is_empty(), self.unread) {
            (_, 0) => write!(f, "{}", self.named.join(", ")),
            (true, unread) => write!(f, "({unread} argument{plural} not read)"),
            (false, unread) => write!(
                f,
                "{} ({unread} earlier argument{plural} not read)",
                self.named.join(", ")
            ),
        }
    }
}

fn calls_with_names(dmb: &dmb::Dmb, target: &str) -> FoundCallsite {
    let mut found = FoundCallsite {
        calls: BTreeSet::new(),
        procs: dmb.procs.len(),
        unread: Vec::new(),
        target_exists: dmb
            .procs
            .iter()
            .any(|proc| dmb.proc_path(proc) == Some(target.as_bytes())),
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
        for (at, node) in nodes.iter().enumerate() {
            match node {
                Node::Instruction(Instruction::DbgFile(name), _) => {
                    file = String::from_utf8_lossy(&name.0).into_owned()
                }
                Node::Instruction(Instruction::DbgLine(here), _) => line = *here,
                Node::Instruction(Instruction::CallGlobalArgList(called), _)
                    if called.0 == target =>
                {
                    let list = nodes[..at]
                        .iter()
                        .rposition(|node| matches!(node, Node::Instruction(..)));
                    let Some((list, Node::Instruction(Instruction::NewAssocList(pairs), _))) =
                        list.map(|list| (list, &nodes[list]))
                    else {
                        continue;
                    };
                    let a1 = arguments_of(&nodes, list, *pairs);
                    let arguments: BTreeSet<String> = a1.named.into_iter().collect();
                    found
                        .calls
                        .insert((file.clone(), line, name.clone(), arguments, a1.unread));
                }
                _ => {}
            }
        }
    }
    found
}

fn arguments_of<D>(nodes: &[Node<D>], list: usize, pairs: u32) -> Arguments {
    let mut named = vec![];
    let mut end = list.checked_sub(1);
    let mut read = 0;
    while read < pairs {
        let key = end
            .and_then(|end| one_value_ending_at(nodes, end))
            .and_then(|value| one_value_ending_at(nodes, value.checked_sub(1)?));
        let Some(key) = key else { break };
        match &nodes[key] {
            Node::Instruction(Instruction::PushVal(Value::DMString(name)), _) => {
                named.push(String::from_utf8_lossy(&name.0).into_owned());
            }
            Node::Instruction(Instruction::PushInt(_), _) => {}
            _ => break,
        }
        read += 1;
        end = key.checked_sub(1);
    }
    named.reverse();
    Arguments {
        named,
        unread: pairs - read,
    }
}

fn one_value_ending_at<D>(nodes: &[Node<D>], end: usize) -> Option<usize> {
    let mut wanted = 1usize;
    let mut at = end;
    loop {
        match &nodes[at] {
            Node::Instruction(Instruction::DbgLine(_) | Instruction::DbgFile(_), _)
            | Node::Comment(_) => {}
            Node::Instruction(instruction, _) => {
                wanted = wanted - 1 + values_taken(instruction)?;
                if wanted == 0 {
                    return Some(at);
                }
            }
            Node::Label(_) => return None,
        }
        at = at.checked_sub(1)?;
    }
}

fn values_taken(instruction: &Instruction) -> Option<usize> {
    use Instruction::*;
    Some(match instruction {
        PushInt(_) | PushVal(_) | GetVar(_) | EmptyList => 0,
        Not | UnaryNeg | Bnot | Abs | Sqrt | Length | LengthChar | UpperText | LowerText
        | Text2Num | Num2Text | CKey | CKeyEx | HtmlEncode | HtmlDecode | UrlEncode | UrlDecode
        | IsNull | IsNum | IsText | IsList | IsPath | Round | Ceil | Trunc | Md5 | Sha1
        | Text2Path | JsonEncode | JsonDecode | TrimText | Ref | CallGlobalArgList(_) => 1,
        Add | Sub | Mul | Div | Mod | Pow | Teq | Tne | Tl | Tg | Tle | Tge | Band | Bor | Bxor
        | LShift | RShift | ListGet => 2,
        Format(_, count)
        | CallGlob(count, _)
        | Call(_, count)
        | NewList(count)
        | AddText(count)
        | Min(count)
        | Max(count) => *count as usize,
        NewAssocList(count) => *count as usize * 2,
        _ => return None,
    })
}



pub fn check_tgui_input_calls(dmb: &dmb::Dmb, allowed_locations: HashSet<&str>, out: &mut StdoutLock) -> Result<(), String> {
    let target = "/proc/tgui_input_text";
    let found = calls_with_names(&dmb, &target);

    let mut issues: u32 = 0;

    for (file, line, caller, names, pargs) in &found.calls {
        if !file.is_empty() && line > &0 {
            // See if its a saved location
            let this_loc = format!("{file}|{line}");
            if allowed_locations.contains(this_loc.as_str()) {
                continue;
            }
        }

        if names.contains("decode") || pargs > &1u32 {
            let names_joined = names.iter().cloned().collect::<Vec<_>>().join(",");
            issues += 1;
            let written = if file.is_empty() {
                writeln!(out, "(no line information): {caller}: {names_joined}")
            } else {
                writeln!(out, "{file}:{line}: {caller}: {names_joined}")
            };
            match written {
                Ok(()) => {}
                Err(closed) if closed.kind() == ErrorKind::BrokenPipe => return Ok(()),
                Err(why) => return Err(format!("cannot write the list: {why}")),
            }
        }

    }
    eprintln!(
        "{} calls pass named arguments to {}, in {} procs read",
        found.calls.len(),
        target,
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
