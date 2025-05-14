# Asset Server RS

Rust replacement of the asset server python script because that just didn't work well and froze all the time.

Use this to test the webroot asset sending or for debugging issues with it.

## How do I run this?

### First time setup

1. Install rust
2. Navigate to this directory in the shell
3. `cargo build --release`

### Subsequent launches

1. Set `asset_transport = "webroot"` in `config/config.toml`
2. Start the game server
3. Type `tools/asset_server_rs/target/release/asset_server_rs.exe` in your shell
  a. Yes thats a windows path. If you're doing this on Linux I trust that you are smart enough to launch a program from the shell.
