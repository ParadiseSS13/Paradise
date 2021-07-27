#ifndef RUST_G
/// Locator for the RUSTG DLL or SO depending on system type. Override if needed.
#define RUST_G (world.system_type == UNIX ? "./librust_g.so" : "./rust_g.dll")
#endif

// Gets the version of RUSTG
/proc/rustg_get_version() return call(RUST_G, "get_version")()

// Defines for internal job subsystem //
#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

// DMI related operations //
#define rustg_dmi_strip_metadata(fname) call(RUST_G, "dmi_strip_metadata")(fname)
#define rustg_dmi_create_png(path, width, height, data) call(RUST_G, "dmi_create_png")(path, width, height, data)

// Noise related operations //
#define rustg_noise_get_at_coordinates(seed, x, y) call(RUST_G, "noise_get_at_coordinates")(seed, x, y)

// File related operations //
#define rustg_file_read(fname) call(RUST_G, "file_read")(fname)
#define rustg_file_write(text, fname) call(RUST_G, "file_write")(text, fname)
#define rustg_file_append(text, fname) call(RUST_G, "file_append")(text, fname)

#ifdef RUSTG_OVERRIDE_BUILTINS
#define file2text(fname) rustg_file_read(fname)
#define text2file(text, fname) rustg_file_append(text, fname)
#endif

// Git related operations //
#define rustg_git_revparse(rev) call(RUST_G, "rg_git_revparse")(rev)
#define rustg_git_commit_date(rev) call(RUST_G, "rg_git_commit_date")(rev)

// Hash related operations //
#define rustg_hash_string(algorithm, text) call(RUST_G, "hash_string")(algorithm, text)
#define rustg_hash_file(algorithm, fname) call(RUST_G, "hash_file")(algorithm, fname)

#define RUSTG_HASH_MD5 "md5"
#define RUSTG_HASH_SHA1 "sha1"
#define RUSTG_HASH_SHA256 "sha256"
#define RUSTG_HASH_SHA512 "sha512"

#ifdef RUSTG_OVERRIDE_BUILTINS
#define md5(thing) (isfile(thing) ? rustg_hash_file(RUSTG_HASH_MD5, "[thing]") : rustg_hash_string(RUSTG_HASH_MD5, thing))
#endif

// Logging stuff //
#define rustg_log_write(fname, text) call(RUST_G, "log_write")(fname, text)
/proc/rustg_log_close_all() return call(RUST_G, "log_close_all")()

// URL encoding stuff
#define rustg_url_encode(text) call(RUST_G, "url_encode")(text)
#define rustg_url_decode(text) call(RUST_G, "url_decode")(text)

#ifdef RUSTG_OVERRIDE_BUILTINS
#define url_encode(text) rustg_url_encode(text)
#define url_decode(text) rustg_url_decode(text)
#endif

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

// toml2json stuff //
#define rustg_toml2json(tomlfile) call(RUST_G, "toml2json")(tomlfile)

// RUSTG Version //
#define RUST_G_VERSION "0.4.5-P3"
