//! The library itself, as BYOND loads it.

/// BYOND unloads the library when the world shuts down, and anything still running in it then crashes the server on its way out.
/// Code that leaves threads behind calls this first, so the library stays loaded until the process ends.
#[cfg(windows)]
pub(crate) fn keep_loaded() {
    use std::ffi::c_void;
    const GET_MODULE_HANDLE_EX_FLAG_PIN: u32 = 0x1;
    const GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS: u32 = 0x4;
    #[link(name = "kernel32")]
    extern "system" {
        fn GetModuleHandleExW(flags: u32, name: *const u16, module: *mut *mut c_void) -> i32;
    }
    let mut module = std::ptr::null_mut();
    // SAFETY: the address is a function in this library, which is all FROM_ADDRESS needs
    unsafe {
        GetModuleHandleExW(
            GET_MODULE_HANDLE_EX_FLAG_PIN | GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,
            keep_loaded as *const u16,
            &mut module,
        );
    }
}

#[cfg(unix)]
pub(crate) fn keep_loaded() {
    use std::ffi::{c_char, c_int, c_void};
    #[repr(C)]
    struct DlInfo {
        dli_fname: *const c_char,
        dli_fbase: *mut c_void,
        dli_sname: *const c_char,
        dli_saddr: *mut c_void,
    }
    const RTLD_NOW: c_int = 2;
    const RTLD_NODELETE: c_int = 0x1000;
    #[link(name = "dl")]
    extern "C" {
        fn dladdr(address: *const c_void, info: *mut DlInfo) -> c_int;
        fn dlopen(filename: *const c_char, flags: c_int) -> *mut c_void;
    }
    // SAFETY: dladdr fills in the struct for an address in this library, and dlopen of a library that's already loaded
    // only marks it to never be unloaded
    unsafe {
        let mut info: DlInfo = std::mem::zeroed();
        if dladdr(keep_loaded as *const c_void, &mut info) != 0 && !info.dli_fname.is_null() {
            dlopen(info.dli_fname, RTLD_NOW | RTLD_NODELETE);
        }
    }
}
