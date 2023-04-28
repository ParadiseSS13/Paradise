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
	if (world.system_type == UNIX)
		if (fexists("./librust_g.so"))
			// No need for LD_LIBRARY_PATH badness.
			return __rust_g = "./librust_g.so"
		else if (fexists("./rust_g"))
			// Old dumb filename.
			return __rust_g = "./rust_g"
		else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/rust_g"))
			// Old dumb filename in `~/.byond/bin`.
			return __rust_g = "rust_g"
		else
			// It's not in the current directory, so try others
			return __rust_g = "librust_g.so"
	else
		return __rust_g = "rust_g.dll"

#define RUST_G (__rust_g || __detect_rust_g())
#endif

/// Gets the version of rust_g
/proc/rustg_get_version() return CALL_EXT(RUST_G, "get_version")()


/**
 * Sets up the Aho-Corasick automaton with its default options.
 *
 * The search patterns list and the replacements must be of the same length when replace is run, but an empty replacements list is allowed if replacements are supplied with the replace call
 * Arguments:
 * * key - The key for the automaton, to be used with subsequent rustg_acreplace/rustg_acreplace_with_replacements calls
 * * patterns - A non-associative list of strings to search for
 * * replacements - Default replacements for this automaton, used with rustg_acreplace
 */
#define rustg_setup_acreplace(key, patterns, replacements) CALL_EXT(RUST_G, "setup_acreplace")(key, json_encode(patterns), json_encode(replacements))

/**
 * Sets up the Aho-Corasick automaton using supplied options.
 *
 * The search patterns list and the replacements must be of the same length when replace is run, but an empty replacements list is allowed if replacements are supplied with the replace call
 * Arguments:
 * * key - The key for the automaton, to be used with subsequent rustg_acreplace/rustg_acreplace_with_replacements calls
 * * options - An associative list like list("anchored" = 0, "ascii_case_insensitive" = 0, "match_kind" = "Standard"). The values shown on the example are the defaults, and default values may be omitted. See the identically named methods at https://docs.rs/aho-corasick/latest/aho_corasick/struct.AhoCorasickBuilder.html to see what the options do.
 * * patterns - A non-associative list of strings to search for
 * * replacements - Default replacements for this automaton, used with rustg_acreplace
 */
#define rustg_setup_acreplace_with_options(key, options, patterns, replacements) CALL_EXT(RUST_G, "setup_acreplace")(key, json_encode(options), json_encode(patterns), json_encode(replacements))

/**
 * Run the specified replacement engine with the provided haystack text to replace, returning replaced text.
 *
 * Arguments:
 * * key - The key for the automaton
 * * text - Text to run replacements on
 */
#define rustg_acreplace(key, text) CALL_EXT(RUST_G, "acreplace")(key, text)

/**
 * Run the specified replacement engine with the provided haystack text to replace, returning replaced text.
 *
 * Arguments:
 * * key - The key for the automaton
 * * text - Text to run replacements on
 * * replacements - Replacements for this call. Must be the same length as the set-up patterns
 */
#define rustg_acreplace_with_replacements(key, text, replacements) CALL_EXT(RUST_G, "acreplace_with_replacements")(key, text, json_encode(replacements))

// Cellular Noise Operations //

/**
 * This proc generates a cellular automata noise grid which can be used in procedural generation methods.
 *
 * Returns a single string that goes row by row, with values of 1 representing an alive cell, and a value of 0 representing a dead cell.
 *
 * Arguments:
 * * percentage: The chance of a turf starting closed
 * * smoothing_iterations: The amount of iterations the cellular automata simulates before returning the results
 * * birth_limit: If the number of neighboring cells is higher than this amount, a cell is born
 * * death_limit: If the number of neighboring cells is lower than this amount, a cell dies
 * * width: The width of the grid.
 * * height: The height of the grid.
 */
#define rustg_cnoise_generate(percentage, smoothing_iterations, birth_limit, death_limit, width, height) \
	CALL_EXT(RUST_G, "cnoise_generate")(percentage, smoothing_iterations, birth_limit, death_limit, width, height)

// DMI Operations //
#define rustg_dmi_strip_metadata(fname) CALL_EXT(RUST_G, "dmi_strip_metadata")(fname)
#define rustg_dmi_create_png(path, width, height, data) CALL_EXT(RUST_G, "dmi_create_png")(path, width, height, data)
#define rustg_dmi_resize_png(path, width, height, resizetype) CALL_EXT(RUST_G, "dmi_resize_png")(path, width, height, resizetype)

// File Operations //
#define rustg_file_read(fname) CALL_EXT(RUST_G, "file_read")(fname)
#define rustg_file_exists(fname) CALL_EXT(RUST_G, "file_exists")(fname)
#define rustg_file_write(text, fname, b64decode) CALL_EXT(RUST_G, "file_write")(text, fname, b64decode)
#define rustg_file_append(text, fname) CALL_EXT(RUST_G, "file_append")(text, fname)

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define file2text(fname) rustg_file_read("[fname]")
	#define text2file(text, fname) rustg_file_append(text, "[fname]")
#endif

// Git Operations //
#define rustg_git_revparse(rev) CALL_EXT(RUST_G, "rg_git_revparse")(rev)
#define rustg_git_commit_date(rev) CALL_EXT(RUST_G, "rg_git_commit_date")(rev)

// Hashing Operations //
#define rustg_hash_string(algorithm, text) CALL_EXT(RUST_G, "hash_string")(algorithm, text)
#define rustg_hash_file(algorithm, fname) CALL_EXT(RUST_G, "hash_file")(algorithm, fname)
#define rustg_hash_generate_totp(seed) CALL_EXT(RUST_G, "generate_totp")(seed)
#define rustg_hash_generate_totp_tolerance(seed, tolerance) CALL_EXT(RUST_G, "generate_totp_tolerance")(seed, tolerance)

#define RUSTG_HASH_MD5 "md5"
#define RUSTG_HASH_SHA1 "sha1"
#define RUSTG_HASH_SHA256 "sha256"
#define RUSTG_HASH_SHA512 "sha512"
#define RUSTG_HASH_XXH64 "xxh64"
#define RUSTG_HASH_BASE64 "base64"

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define md5(thing) (isfile(thing) ? rustg_hash_file(RUSTG_HASH_MD5, "[thing]") : rustg_hash_string(RUSTG_HASH_MD5, thing))
#endif

// HTTP Operations //
#define RUSTG_HTTP_METHOD_GET "get"
#define RUSTG_HTTP_METHOD_PUT "put"
#define RUSTG_HTTP_METHOD_DELETE "delete"
#define RUSTG_HTTP_METHOD_PATCH "patch"
#define RUSTG_HTTP_METHOD_HEAD "head"
#define RUSTG_HTTP_METHOD_POST "post"
// Commented out because this thing locks up the entire DD process when you use it
// DO NOT USE FOR THE LOVE OF GOD
// #define rustg_http_request_blocking(method, url, body, headers, options) CALL_EXT(RUST_G, "http_request_blocking")(method, url, body, headers, options)
#define rustg_http_request_async(method, url, body, headers, options) CALL_EXT(RUST_G, "http_request_async")(method, url, body, headers, options)
#define rustg_http_check_request(req_id) CALL_EXT(RUST_G, "http_check_request")(req_id)
/proc/rustg_create_async_http_client() return CALL_EXT(RUST_G, "start_http_client")()
/proc/rustg_close_async_http_client() return CALL_EXT(RUST_G, "shutdown_http_client")()

// Jobs Subsystem Operations //
#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

// JSON Operations //
#define rustg_json_is_valid(text) (CALL_EXT(RUST_G, "json_is_valid")(text) == "true")

// Logging Operations //
#define rustg_log_write(fname, text, format) CALL_EXT(RUST_G, "log_write")(fname, text, format)
/proc/rustg_log_close_all() return CALL_EXT(RUST_G, "log_close_all")()

// Noise Operations //
#define rustg_noise_get_at_coordinates(seed, x, y) CALL_EXT(RUST_G, "noise_get_at_coordinates")(seed, x, y)

// SQL Opeartions //
#define rustg_sql_connect_pool(options) CALL_EXT(RUST_G, "sql_connect_pool")(options)
#define rustg_sql_query_async(handle, query, params) CALL_EXT(RUST_G, "sql_query_async")(handle, query, params)
#define rustg_sql_query_blocking(handle, query, params) CALL_EXT(RUST_G, "sql_query_blocking")(handle, query, params)
#define rustg_sql_connected(handle) CALL_EXT(RUST_G, "sql_connected")(handle)
#define rustg_sql_disconnect_pool(handle) CALL_EXT(RUST_G, "sql_disconnect_pool")(handle)
#define rustg_sql_check_query(job_id) CALL_EXT(RUST_G, "sql_check_query")("[job_id]")

#define rustg_time_microseconds(id) text2num(CALL_EXT(RUST_G, "time_microseconds")(id))
#define rustg_time_milliseconds(id) text2num(CALL_EXT(RUST_G, "time_milliseconds")(id))
#define rustg_time_reset(id) CALL_EXT(RUST_G, "time_reset")(id)

// TOML Operations //
#define rustg_raw_read_toml_file(path) json_decode(CALL_EXT(RUST_G, "toml_file_to_json")(path) || "null")

/proc/rustg_read_toml_file(path)
	var/list/output = rustg_raw_read_toml_file(path)
	if (output["success"])
		return json_decode(output["content"])
	else
		CRASH(output["content"])

// Unzip Operations //
#define rustg_unzip_download_async(url, unzip_directory) CALL_EXT(RUST_G, "unzip_download_async")(url, unzip_directory)
#define rustg_unzip_check(job_id) CALL_EXT(RUST_G, "unzip_check")("[job_id]")

// URL Encoder/Decoder Operations //
#define rustg_url_encode(text) CALL_EXT(RUST_G, "url_encode")("[text]")
#define rustg_url_decode(text) CALL_EXT(RUST_G, "url_decode")(text)

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define url_encode(text) rustg_url_encode(text)
	#define url_decode(text) rustg_url_decode(text)
#endif

// Text Operations //
#define rustg_cyrillic_to_latin(text) CALL_EXT(RUST_G, "cyrillic_to_latin")("[text]")
#define rustg_latin_to_cyrillic(text) CALL_EXT(RUST_G, "latin_to_cyrillic")("[text]")
