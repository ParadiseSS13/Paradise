# Paradise Rust Libraries

## Info

These libraries allow rust code for things that are incredibly slow or outright impossible in DM.
Think of it like a ParadiseSS13 specifiy version of [rust-g](https://github.com/tgstation/rust-g).

It currently handles:

- Atmospherics (`milla`)
- DMM manipulation stuff (`mapmanip`)

It also imports and tweaks the following [rust-g](https://github.com/tgstation/rust-g) features:

- DMI
- File
- HTTP
- JSON
- Logging
- MySQL
- Noisegen
- Redis PubSub
- TOML

If you're adding anything to this, **please** use the BYONDAPI stuff instead of `json_encode` and `json_decode` everywhere.

## Building

Just running `cargo build --release` should be enough if you're on Windows. If you are on Linux, you should be familiar with figuring stuff out yourself and consulting 300 pieces of documentation for a single command.
