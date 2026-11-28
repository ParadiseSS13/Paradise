#[allow(dead_code)]
mod callsite_checker;
mod dmb;
mod opcode_checker;

use std::collections::{HashSet};
use std::io::Write;
use std::process::ExitCode;

use dmasm_bytecode::{disassembler::DisassembleEnv};

struct Names<'a>(&'a dmb::Dmb);

impl DisassembleEnv for Names<'_> {
    fn get_string_data(&mut self, index: u32) -> Option<Vec<u8>> {
        self.0.string(index).map(<[u8]>::to_vec)
    }

    fn get_variable_name(&mut self, index: u32) -> Option<Vec<u8>> {
        self.0.variable_name(index).map(<[u8]>::to_vec)
    }

    fn get_proc_name(&mut self, index: u32) -> Option<String> {
        let path = self.0.proc_path(self.0.procs.get(index as usize)?)?;
        Some(String::from_utf8_lossy(path).into_owned())
    }

    fn value_to_string_data(&mut self, tag: u32, data: u32) -> Option<Vec<u8>> {
        Some(format!("<{tag:#04x} {data}>").into_bytes())
    }
}


fn main() -> ExitCode {
    let allowed_locations_raw = include_str!("allowed_locations.txt");
    let allowed_locations_parsed: HashSet<&str> = allowed_locations_raw.lines().collect();


    let mut arguments = std::env::args().skip(1);
    let (Some(path), None) = (arguments.next(), arguments.next()) else {
        let mut stderr = std::io::stderr().lock();
        writeln!(stderr, "usage: dmb-inputs paradise.dmb").ok();
        return ExitCode::FAILURE;
    };

    let data = std::fs::read(&path).map_err(|why| format!("cannot read {path}: {why}")).unwrap();
    let dmb = dmb::Dmb::load(&data).map_err(|why| format!("cannot read {path} as a .dmb: {why}")).unwrap();

    let mut exit_code = ExitCode::SUCCESS;

    let mut out = std::io::stdout().lock();
    writeln!(out, ">>> Calls to input()").ok();
    match opcode_checker::check_inputs(&dmb, allowed_locations_parsed.clone(), &mut out) {
        Ok(_) => {},
        Err(_) => {
            exit_code = ExitCode::FAILURE;
        }
    }

    writeln!(out, ">>> Calls to tgui_input_text() with decode=FALSE").ok();
    match callsite_checker::check_tgui_input_calls(&dmb, allowed_locations_parsed.clone(), &mut out) {
        Ok(_) => {},
        Err(_) => {
            exit_code = ExitCode::FAILURE;
        }
    }

    exit_code
}
