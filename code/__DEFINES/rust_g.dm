// rust_g.dm - DM API for rust_g extension library
//
// To configure, create a `rust_g.config.dm` and set what you care about from
// the following options:
//
// #define RUST_G "path/to/rust_g"
// Override the .dll/.so detection logic with a fixed path or with detection
// logic of your own.
//
// #define RUSTG_OVERRIDE_BUILTINS
// Enable replacement rust-g functions for certain builtins. Off by default.

#ifndef RUST_G
// Default automatic RUST_G detection.
// On Windows, looks in the standard places for `rust_g.dll`.
// On Linux, looks in `.`, `$LD_LIBRARY_PATH`, and `~/.byond/bin` for either of
// `librust_g.so` (preferred) or `rust_g` (old).

/* This comment bypasses grep checks */ /var/__rust_g

/proc/__detect_rust_g()
	if(world.system_type == UNIX)
		if(fexists("./librust_g.so"))
			// No need for LD_LIBRARY_PATH badness.
			return __rust_g = "./librust_g.so"
		else if(fexists("./rust_g"))
			// Old dumb filename.
			return __rust_g = "./rust_g"
		else if(fexists("[world.GetConfig("env", "HOME")]/.byond/bin/rust_g"))
			// Old dumb filename in `~/.byond/bin`.
			return __rust_g = "rust_g"
		else
			// It's not in the current directory, so try others
			return __rust_g = "librust_g.so"
	else
		return __rust_g = "rust_g.dll"

#define RUST_G (__rust_g || __detect_rust_g())
#endif

// Handle 515 call() -> call_ext() changes
#if DM_VERSION >= 515
#define RUSTG_CALL call_ext
#else
#define RUSTG_CALL call
#endif

/// Gets the version of rust_g
/proc/rustg_get_version() return RUSTG_CALL(RUST_G, "get_version")()

// Grid Perlin Noise //

/**
 * This proc generates a grid of perlin-like noise
 *
 * Returns a single string that goes row by row, with values of 1 representing an turned on cell, and a value of 0 representing a turned off cell.
 *
 * Arguments:
 * * seed: seed for the function
 * * accuracy: how close this is to the original perlin noise, as accuracy approaches infinity, the noise becomes more and more perlin-like
 * * stamp_size: Size of a singular stamp used by the algorithm, think of this as the same stuff as frequency in perlin noise
 * * world_size: size of the returned grid.
 * * lower_range: lower bound of values selected for. (inclusive)
 * * upper_range: upper bound of values selected for. (exclusive)
 */
#define rustg_dbp_generate(seed, accuracy, stamp_size, world_size, lower_range, upper_range) \
	RUSTG_CALL(RUST_G, "dbp_generate")(seed, accuracy, stamp_size, world_size, lower_range, upper_range)

// DMI Operations //

#define rustg_dmi_strip_metadata(fname) RUSTG_CALL(RUST_G, "dmi_strip_metadata")(fname)


// Git Operations //

/// Returns the git hash of the given revision, ex. "HEAD".
#define rustg_git_revparse(rev) RUSTG_CALL(RUST_G, "rg_git_revparse")(rev)

/**
 * Returns the date of the given revision using the provided format.
 * Defaults to returning %F which is YYYY-MM-DD.
 */
/proc/rustg_git_commit_date(rev, format = "%F")
	return RUSTG_CALL(RUST_G, "rg_git_commit_date")(rev, format)

/**
 * Returns the formatted datetime string of HEAD using the provided format.
 * Defaults to returning %F which is YYYY-MM-DD.
 * This is different to rustg_git_commit_date because it only needs the logs directory.
 */
/proc/rustg_git_commit_date_head(format = "%F")
	return RUSTG_CALL(RUST_G, "rg_git_commit_date_head")(format)

// HTTP Operations //

#define RUSTG_HTTP_METHOD_GET "get"
#define RUSTG_HTTP_METHOD_PUT "put"
#define RUSTG_HTTP_METHOD_DELETE "delete"
#define RUSTG_HTTP_METHOD_PATCH "patch"
#define RUSTG_HTTP_METHOD_HEAD "head"
#define RUSTG_HTTP_METHOD_POST "post"
#define rustg_http_request_blocking(method, url, body, headers, options) RUSTG_CALL(RUST_G, "http_request_blocking")(method, url, body, headers, options)
#define rustg_http_request_async(method, url, body, headers, options) RUSTG_CALL(RUST_G, "http_request_async")(method, url, body, headers, options)
#define rustg_http_check_request(req_id) RUSTG_CALL(RUST_G, "http_check_request")(req_id)
/proc/rustg_create_async_http_client() return RUSTG_CALL(RUST_G, "start_http_client")()
/proc/rustg_close_async_http_client() return RUSTG_CALL(RUST_G, "shutdown_http_client")()

// Jobs Defines //

#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

// JSON Operations //

#define rustg_json_is_valid(text) (RUSTG_CALL(RUST_G, "json_is_valid")(text) == "true")

// Logging Operations //

#define rustg_log_write(fname, text) RUSTG_CALL(RUST_G, "log_write")(fname, text)
/proc/rustg_log_close_all() return RUSTG_CALL(RUST_G, "log_close_all")()

// SQL Operations //

#define rustg_sql_connect_pool(options) RUSTG_CALL(RUST_G, "sql_connect_pool")(options)
#define rustg_sql_query_async(handle, query, params) RUSTG_CALL(RUST_G, "sql_query_async")(handle, query, params)
#define rustg_sql_query_blocking(handle, query, params) RUSTG_CALL(RUST_G, "sql_query_blocking")(handle, query, params)
#define rustg_sql_connected(handle) RUSTG_CALL(RUST_G, "sql_connected")(handle)
#define rustg_sql_disconnect_pool(handle) RUSTG_CALL(RUST_G, "sql_disconnect_pool")(handle)
#define rustg_sql_check_query(job_id) RUSTG_CALL(RUST_G, "sql_check_query")("[job_id]")

// Toast Operations //

#define rustg_create_toast(title, body) RUSTG_CALL(RUST_G, "create_toast")(title, body)

// TOML Operations //

#define rustg_raw_read_toml_file(path) json_decode(RUSTG_CALL(RUST_G, "toml_file_to_json")(path) || "null")

/proc/rustg_read_toml_file(path)
	var/list/output = rustg_raw_read_toml_file(path)
	if(output["success"])
		return json_decode(output["content"])
	else
		CRASH(output["content"])
