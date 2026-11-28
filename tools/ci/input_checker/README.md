
# Input Checker

This is based on stuff from auxtools, courtesy of Sophie Wallace <sophie@wiox.me> (claude), just embedded into the repo with source so I can tweak it to Paradise's needs. I (AA07) didn't write this. If you ask me to explain what the hell is going on, I am just going to direct you to coderbus.

Below is the original readme.

---

## dmb-inputs

`dmb-inputs` reads a compiled BYOND world (`.dmb`) from disk and lists every place that calls
`input()`. It needs no BYOND installation, source code, or running world.

The tool scans the bytecode of every proc in the `.dmb` for the two instructions DreamMaker compiles
`input()` to: `Input`, and `InputColor` for `input(...) as color`. Because it inspects compiled
bytecode, it finds calls made through macros and includes only code actually in the build (excluding
code left out by `#ifdef`).

## Usage

Pass a single `.dmb` path as the only argument:

```text
dmb-inputs WORLD.dmb
```

Build the binary from source first, on both Windows and Linux (see
[Building from source](#building-from-source)). After building, it is at `target/release/dmb-inputs`
(`target\release\dmb-inputs.exe` on Windows).

Standard output lists one place per line as `FILE:LINE: PROC`, sorted by file and line:

```text
code/__HELPERS/text.dm:91: /proc/stripped_input
```

Standard error prints a summary line at the end:

```text
251 places call input(), in 34849 procs read
```

- **Line numbers.** File paths and line numbers come from debug information in the `.dmb`, which
  DreamMaker writes only when the world is compiled with `#define DEBUG`. Without debug
  information, a place is listed as `(no line information): PROC`.
- **Deduplication.** A place is a file, a line, and a proc, so two calls on the same line of the
  same proc are listed once.
- **Unreadable procs.** If a proc's bytecode cannot be read to its end, standard error prints
  `not read to its end, so it may hide more: PROC`, and scanning continues for the rest of the
  file.
- **Exit codes.** `dmb-inputs` exits with `0` when the file was read, or `1` (with a message
  starting with `dmb-inputs:`) when the file could not be read or is not a `.dmb`.

## Limitations

- Finds `input()` calls only. `alert()`, `winset()`, and other ways of prompting the client use
  other instructions and are not listed.
- Reads worlds compiled by BYOND 515 and 516, with an instruction decoder covering builds
  515.1637–516.1689. Older and newer builds were not tried. It was tried on open-source SS13 worlds
  built with BYOND 516.1685 and 516.1687: cmss13, tgstation (where one unnamed proc could not be
  read to its end), and goonstation.

## Building from source

Building requires Rust 1.88 or later (rustup.rs). Run the following command in this directory:

```text
cargo build --release
```

The first build needs network access to download its two dependencies: `dmasm-bytecode` from the
auxtools repository on GitHub at the tag `v4.0.0`, and `bitflags` from crates.io. The compiled
binary is written to `target/release/dmb-inputs` (`target\release\dmb-inputs.exe` on Windows).

## Contents and license

The tool consists of:

- `src/`: Rust source (`src/main.rs` for the tool and `src/dmb.rs` for reading the `.dmb` format)
- `Cargo.toml`: Cargo manifest
- `LICENSE`: GNU General Public License, version 3
- `README.md`: this file

`dmb-inputs` is a standalone tool built on [auxtools](https://github.com/auxtools/auxtools) 4.0.0.
It uses the `dmasm-bytecode` crate to decode instructions, and `src/dmb.rs` is an unchanged copy of
`dmasm/compiler/examples/compare_dreammaker/dmb.rs` from auxtools (part of the `dmasm-compiler`
crate). Those two pieces of auxtools are licensed under the GNU General Public License, version 3,
and so is `dmb-inputs`. The `bitflags` dependency is licensed under MIT or Apache-2.0.
