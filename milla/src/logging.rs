use std::backtrace::Backtrace;
use std::fs::File;
use std::io::Write;

/// Simple logging function, appends to ./milla_log.txt
#[allow(dead_code)]
pub(crate) fn write_log<T: AsRef<[u8]>>(x: T) {
    let mut f = File::options()
        .create(true)
        .append(true)
        .open("./milla_log.txt")
        .unwrap();
    writeln!(&mut f, "{}", String::from_utf8_lossy(x.as_ref())).unwrap();
}

/// Panic handler that dumps info out to ./milla_panic.txt (overwriting) if we crash.
pub(crate) fn setup_panic_handler() {
    std::panic::set_hook(Box::new(|info| {
        let backtrace = Backtrace::force_capture();
        std::fs::write(
            "./milla_panic.txt",
            format!("Panic {:#?}\n{:#?}", info, backtrace),
        )
        .unwrap();
    }))
}
