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

/// Panic handler that appends to ./milla_panic.txt if we crash.
pub(crate) fn setup_panic_handler() {
    std::panic::set_hook(Box::new(|info| {
        let backtrace = Backtrace::force_capture();
        let mut f = File::options()
            .create(true)
            .append(true)
            .open("./milla_panic.txt")
            .unwrap();
        writeln!(&mut f, "Panic {:#?}\n{:#?}", info, backtrace).unwrap();
    }))
}
