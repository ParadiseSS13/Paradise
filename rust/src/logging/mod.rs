/// Call stack trace dm method with message.
pub(crate) fn dm_call_stack_trace(msg: String) {
    let msg = byondapi::value::ByondValue::try_from(msg).unwrap();
    // this is really ugly, cause we want to get id/ref to a proc name string
    // that is already allocated, and don't want to allocate a new string entirely
    byondapi::global_call::call_global_id(
        {
            static STRING_ID: std::sync::OnceLock<u32> = std::sync::OnceLock::new();
            *STRING_ID.get_or_init(|| byondapi::byond_string::str_id_of("_stack_trace").unwrap())
        },
        &[msg],
    )
    .unwrap();
}

/// Panic handler, called on unhandled errors.
/// Writes panic info to a text file, and calls dm stack trace proc as well.
pub(crate) fn setup_panic_handler() {
    std::panic::set_hook(Box::new(|info| {
        let msg = format!("Panic \n {:#?}", info);
        let _ = std::fs::write("./rustlibs_panic.txt", msg.clone());
        dm_call_stack_trace(msg);
    }))
}
