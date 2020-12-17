/// Locator for the RUSTG DLL or SO depending on system type
#define RUST_G (world.system_type == UNIX ? "./librust_g.so" : "./rust_g.dll")

// Defines for internal job subsystem //
#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

// DMI related operations //
#define rustg_dmi_strip_metadata(fname) call(RUST_G, "dmi_strip_metadata")(fname)
#define rustg_dmi_create_png(path, width, height, data) call(RUST_G, "dmi_create_png")(path, width, height, data)

#define rustg_noise_get_at_coordinates(seed, x, y) call(RUST_G, "noise_get_at_coordinates")(seed, x, y)

// Git related operations //
#define rustg_git_revparse(rev) call(RUST_G, "rg_git_revparse")(rev)
#define rustg_git_commit_date(rev) call(RUST_G, "rg_git_commit_date")(rev)

// Logging stuff //
#define rustg_log_write(fname, text) call(RUST_G, "log_write")(fname, text)
/proc/rustg_log_close_all() return call(RUST_G, "log_close_all")()

// HTTP library stuff //
#define RUSTG_HTTP_METHOD_GET "get"
#define RUSTG_HTTP_METHOD_PUT "put"
#define RUSTG_HTTP_METHOD_DELETE "delete"
#define RUSTG_HTTP_METHOD_PATCH "patch"
#define RUSTG_HTTP_METHOD_HEAD "head"
#define RUSTG_HTTP_METHOD_POST "post"

// Commented out because this thing locks up the entire DD process when you use it
// DO NOT USE FOR THE LOVE OF GOD
// #define rustg_http_request_blocking(method, url, body, headers) call(RUST_G, "http_request_blocking")(method, url, body, headers)
#define rustg_http_request_async(method, url, body, headers) call(RUST_G, "http_request_async")(method, url, body, headers)
#define rustg_http_check_request(req_id) call(RUST_G, "http_check_request")(req_id)
/proc/rustg_create_async_http_client() return call(RUST_G, "start_http_client")()
/proc/rustg_close_async_http_client() return call(RUST_G, "shutdown_http_client")()

// SQL stuff //
#define rustg_sql_connect_pool(options) call(RUST_G, "sql_connect_pool")(options)
#define rustg_sql_query_async(handle, query, params) call(RUST_G, "sql_query_async")(handle, query, params)
#define rustg_sql_query_blocking(handle, query, params) call(RUST_G, "sql_query_blocking")(handle, query, params)
#define rustg_sql_connected(handle) call(RUST_G, "sql_connected")(handle)
#define rustg_sql_disconnect_pool(handle) call(RUST_G, "sql_disconnect_pool")(handle)
#define rustg_sql_check_query(job_id) call(RUST_G, "sql_check_query")("[job_id]")
