// DM API for Rust extension modules
// Current modules:
// - MILLA, an asynchronous replacement for BYOND atmos
// - Mapmanip, a parse-time DMM file reader and modifier
// - A bunch of imports from rustg

// Default automatic library detection.
// Look for it in the build location first, then in `.`, then in standard places.

/* This comment bypasses grep checks */ /var/__rustlib

// IF we are on the production box, use a dll that has 0 compatibility of working with normal people's CPUs
// This works by allowing rust to compile with modern x86 instructionns, instead of compiling for a pentium 4
// This has the potential for significant speed upgrades with SIMD and similar
#ifdef PARADISE_PRODUCTION_HARDWARE
#define RUSTLIBS_SUFFIX "_prod"
#else
#define RUSTLIBS_SUFFIX ""
#endif

/proc/__detect_rustlib()
	if(world.system_type == UNIX)
#ifdef CIBUILDING
		// CI override, use librustlibs_ci.so if possible.
		if(fexists("./tools/ci/librustlibs_ci.so"))
			return __rustlib = "tools/ci/librustlibs_ci.so"
#endif
		// First check if it's built in the usual place.
		// Linx doesnt get the version suffix because if youre using linux you can figure out what server version youre running for
		if(fexists("./rust/target/i686-unknown-linux-gnu/release/librustlibs[RUSTLIBS_SUFFIX].so"))
			return __rustlib = "./rust/target/i686-unknown-linux-gnu/release/librustlibs[RUSTLIBS_SUFFIX].so"
		// Then check in the current directory.
		if(fexists("./librustlibs[RUSTLIBS_SUFFIX].so"))
			return __rustlib = "./librustlibs[RUSTLIBS_SUFFIX].so"
		// And elsewhere.
		return __rustlib = "librustlibs[RUSTLIBS_SUFFIX].so"
	else
		// First check if it's built in the usual place.
		if(fexists("./rust/target/i686-pc-windows-msvc/debug/rustlibs.dll"))
			return __rustlib = "./rust/target/i686-pc-windows-msvc/debug/rustlibs.dll"
		if(fexists("./rust/target/i686-pc-windows-msvc/release/rustlibs.dll"))
			return __rustlib = "./rust/target/i686-pc-windows-msvc/release/rustlibs.dll"
		// Then check in the current directory.
		if(fexists("./rustlibs[RUSTLIBS_SUFFIX].dll"))
			return __rustlib = "./rustlibs[RUSTLIBS_SUFFIX].dll"

		// And elsewhere.
		var/assignment_confirmed = (__rustlib = "rustlibs[RUSTLIBS_SUFFIX].dll")
		// This being spanned over multiple lines is kinda scuffed, but its needed because of https://www.byond.com/forum/post/2072419
		return assignment_confirmed


#define RUSTLIB (__rustlib || __detect_rustlib())

#define RUSTLIB_CALL(func, args...) call_ext(RUSTLIB, "byond:[#func]_ffi")(args)

// This needs to go BELOW the above define, otherwise the BYOND compiler can make the above immediate call disappear
#undef RUSTLIBS_SUFFIX

/// Exists by default in 516, but needs to be defined for 515 or byondapi-rs doesn't like it.
/proc/byondapi_stack_trace(err)
	CRASH(err)

// MARK: MILLA

/proc/milla_init_z(z)
	return RUSTLIB_CALL(milla_initialize, z)

/proc/milla_load_turfs(turf/low_corner, turf/high_corner)
	ASSERT(istype(low_corner))
	ASSERT(istype(high_corner))
	return RUSTLIB_CALL(milla_load_turfs, "milla_data", low_corner, high_corner)

/proc/set_tile_atmos(turf/T, airtight_north, airtight_east, airtight_south, airtight_west, atmos_mode, environment_id, oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, temperature, innate_heat_capacity, hotspot_temperature, hotspot_volume)
	return RUSTLIB_CALL(milla_set_tile, T, airtight_north, airtight_east, airtight_south, airtight_west, atmos_mode, environment_id, oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, temperature, innate_heat_capacity, hotspot_temperature, hotspot_volume)

/proc/get_tile_atmos(turf/T, list/L)
	return RUSTLIB_CALL(milla_get_tile, T, L)

/proc/spawn_milla_tick_thread()
	return RUSTLIB_CALL(milla_spawn_tick_thread)

/proc/get_milla_tick_time()
	return RUSTLIB_CALL(milla_get_tick_time)

/proc/get_interesting_atmos_tiles()
	return RUSTLIB_CALL(milla_get_interesting_tiles)

/proc/get_tracked_pressure_tiles()
	return RUSTLIB_CALL(milla_get_tracked_pressure_tiles)

/proc/reduce_superconductivity(turf/T, list/superconductivity)
	var/north = superconductivity[1]
	var/east = superconductivity[2]
	var/south = superconductivity[3]
	var/west = superconductivity[4]

	return RUSTLIB_CALL(milla_reduce_superconductivity, T, north, east, south, west)

/proc/reset_superconductivity(turf/T)
	return RUSTLIB_CALL(milla_reset_superconductivity, T)

/proc/set_tile_airtight(turf/T, list/airtight)
	var/north = airtight[1]
	var/east = airtight[2]
	var/south = airtight[3]
	var/west = airtight[4]

	return RUSTLIB_CALL(milla_set_tile_airtight, T, north, east, south, west)

/proc/create_hotspot(turf/T, hotspot_temperature, hotspot_volume)
	return RUSTLIB_CALL(milla_create_hotspot, T, hotspot_temperature, hotspot_volume)

/proc/track_pressure_tiles(atom/A, radius)
	var/turf/T = get_turf(A)
	if(istype(T))
		return RUSTLIB_CALL(milla_track_pressure_tiles, T, radius)

/proc/get_random_interesting_tile()
	return RUSTLIB_CALL(milla_get_random_interesting_tile)

/proc/create_environment(oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, temperature)
	return RUSTLIB_CALL(milla_create_environment, oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, temperature)

/proc/set_zlevel_freeze(z, bool_frozen)
	return RUSTLIB_CALL(milla_set_zlevel_frozen, z, bool_frozen)

// MARK: MapManip

/proc/mapmanip_read_dmm(mapname)
	return RUSTLIB_CALL(mapmanip_read_dmm_file, mapname)

// MARK: TOML
/proc/rustlibs_read_toml_file(path)
	var/list/output = json_decode(RUSTLIB_CALL(toml_file_to_json, path) || "null")
	if(output["success"])
		return json_decode(output["content"])
	else
		CRASH(output["content"])

// MARK: Git
/proc/rustlibs_git_revparse(rev)
	return RUSTLIB_CALL(git_revparse, rev)

/proc/rustlibs_git_commit_date(rev, format = "%F")
	return RUSTLIB_CALL(git_commit_date, rev, format)

// MARK: Logging
/proc/rustlibs_log_write(fname, text)
	return RUSTLIB_CALL(log_write, fname, text)

/proc/rustlibs_log_close_all()
	return RUSTLIB_CALL(log_close_all)

// MARK: DMI
/proc/rustlibs_dmi_strip_metadata(fname)
	return RUSTLIB_CALL(dmi_strip_metadata, fname)

// MARK: JSON
/proc/rustlibs_json_is_valid(text)
	return (RUSTLIB_CALL(json_is_valid, text) == "true")


// MARK: Grid Perlin Noise
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
/proc/rustlibs_dbp_generate(seed, accuracy, stamp_size, world_size, lower_range, upper_range)
	return RUSTLIB_CALL(dbp_generate, seed, accuracy, stamp_size, world_size, lower_range, upper_range)

// MARK: Redis
#define RUSTLIBS_REDIS_ERROR_CHANNEL "RUSTG_REDIS_ERROR_CHANNEL"

/proc/rustlibs_redis_connect(addr)
	return RUSTLIB_CALL(redis_connect, addr)

/proc/rustlibs_redis_disconnect()
	return RUSTLIB_CALL(redis_disconnect)

/proc/rustlibs_redis_subscribe(channel)
	return RUSTLIB_CALL(redis_subscribe, channel)

/proc/rustlibs_redis_get_messages()
	return RUSTLIB_CALL(redis_get_messages)

/proc/rustlibs_redis_publish(channel, message)
	return RUSTLIB_CALL(redis_publish, channel, message)


// MARK: Toast
/// (Windows only) Triggers a desktop notification with the specified title and body
/proc/rustlibs_create_toast(title, body) 
	return RUSTLIB_CALL(create_toast, title, body)


// MARK: HTTP
#define RUSTLIBS_HTTP_METHOD_GET "get"
#define RUSTLIBS_HTTP_METHOD_PUT "put"
#define RUSTLIBS_HTTP_METHOD_DELETE "delete"
#define RUSTLIBS_HTTP_METHOD_PATCH "patch"
#define RUSTLIBS_HTTP_METHOD_HEAD "head"
#define RUSTLIBS_HTTP_METHOD_POST "post"

/proc/rustlibs_http_send_request(datum/http_request/request)
	return RUSTLIB_CALL(http_submit_async_request, request)

/proc/rustlibs_http_check_request(datum/http_request/request)
	return RUSTLIB_CALL(http_check_job, request)

/proc/rustlibs_http_start_client(datum/http_request)
	return RUSTLIB_CALL(http_start_client)

/proc/rustlibs_http_shutdown_client(datum/http_request)
	return RUSTLIB_CALL(http_shutdown_client)

// MARK: Jobs
#define RUSTLIBS_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTLIBS_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTLIBS_JOB_ERROR "JOB PANICKED"

#undef RUSTLIB_CALL

// Indexes for Tiles and InterestingTiles
// Must match the order in milla/src/model.rs
#define MILLA_INDEX_AIRTIGHT_DIRECTIONS 	1
#define MILLA_INDEX_OXYGEN					2
#define MILLA_INDEX_CARBON_DIOXIDE			3
#define MILLA_INDEX_NITROGEN				4
#define MILLA_INDEX_TOXINS					5
#define MILLA_INDEX_SLEEPING_AGENT			6
#define MILLA_INDEX_AGENT_B					7
#define MILLA_INDEX_ATMOS_MODE				8
#define MILLA_INDEX_ENVIRONMENT_ID			9
#define MILLA_INDEX_SUPERCONDUCTIVITY_NORTH	10
#define MILLA_INDEX_SUPERCONDUCTIVITY_EAST	11
#define MILLA_INDEX_SUPERCONDUCTIVITY_SOUTH	12
#define MILLA_INDEX_SUPERCONDUCTIVITY_WEST	13
#define MILLA_INDEX_INNATE_HEAT_CAPACITY	14
#define MILLA_INDEX_TEMPERATURE				15
#define MILLA_INDEX_HOTSPOT_TEMPERATURE		16
#define MILLA_INDEX_HOTSPOT_VOLUME			17
#define MILLA_INDEX_WIND_X					18
#define MILLA_INDEX_WIND_Y					19
#define MILLA_INDEX_FUEL_BURNT				20

/// The number of values per tile.
#define MILLA_TILE_SIZE						MILLA_INDEX_FUEL_BURNT

// These are only for InterestingTiles.
#define MILLA_INDEX_TURF					21
#define MILLA_INDEX_INTERESTING_REASONS		22
#define MILLA_INDEX_AIRFLOW_X				23
#define MILLA_INDEX_AIRFLOW_Y				24

/// The number of values per interesting tile.
#define MILLA_INTERESTING_TILE_SIZE			MILLA_INDEX_AIRFLOW_Y

/// Interesting because it needs a display update.
#define MILLA_INTERESTING_REASON_DISPLAY	(1 << 0)
/// Interesting because it's hot enough to start a fire. Excludes normal-temperature Lavaland tiles without an active fire.
#define MILLA_INTERESTING_REASON_HOT		(1 << 1)
/// Interesting because it has wind that can push stuff around.
#define MILLA_INTERESTING_REASON_WIND		(1 << 2)

#define MILLA_NORTH	(1 << 0)
#define MILLA_EAST	(1 << 1)
#define MILLA_SOUTH	(1 << 2)
#define MILLA_WEST	(1 << 3)
