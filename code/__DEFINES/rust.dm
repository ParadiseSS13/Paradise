// DM API for Rust extension modules
// Current modules:
// - MILLA, an asynchronous replacement for BYOND atmos
// - Mapmanip, a parse-time DMM file reader and modifier

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
		if(fexists("./rust/target/i686-unknown-linux-gnu/release/librustlibs[RUSTLIBS_SUFFIX].so"))
			return __rustlib = "./rust/target/i686-unknown-linux-gnu/release/librustlibs[RUSTLIBS_SUFFIX].so"
		// Then check in the current directory.
		if(fexists("./librustlibs[RUSTLIBS_SUFFIX].so"))
			return __rustlib = "./librustlibs[RUSTLIBS_SUFFIX].so"
		// And elsewhere.
		return __rustlib = "librustlibs[RUSTLIBS_SUFFIX].so"
	else
		// First check if it's built in the usual place.
		if(fexists("./rust/target/i686-pc-windows-msvc/release/rustlibs[RUSTLIBS_SUFFIX].dll"))
			return __rustlib = "./rust/target/i686-pc-windows-msvc/release/rustlibs[RUSTLIBS_SUFFIX].dll"
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

/proc/milla_init_z(z)
	return RUSTLIB_CALL(milla_initialize, z)

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

/proc/mapmanip_read_dmm(mapname)
	return RUSTLIB_CALL(mapmanip_read_dmm_file, mapname)

#undef RUSTLIB
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
