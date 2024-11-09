// DM API for Rust extension modules
// Current modules:
// - MILLA, an asynchronous replacement for BYOND atmos
// - Mapmanip, a parse-time DMM file reader and modifier

// Default automatic library detection.
// Look for it in the build location first, then in `.`, then in standard places.

/* This comment bypasses grep checks */ /var/__rustlib

/proc/__detect_rustlib()
	if(world.system_type == UNIX)
#ifdef CIBUILDING
		// CI override, use librustlibs_ci.so if possible.
		if(fexists("./tools/ci/librustlibs_ci.so"))
			return __rustlib = "tools/ci/librustlibs_ci.so"
#endif
		// First check if it's built in the usual place.
		if(fexists("./rust/target/i686-unknown-linux-gnu/release/librustlibs.so"))
			return __rustlib = "./rust/target/i686-unknown-linux-gnu/release/librustlibs.so"
		// Then check in the current directory.
		if(fexists("./librustlibs.so"))
			return __rustlib = "./librustlibs.so"
		// And elsewhere.
		return __rustlib = "librustlibs.so"
	else
		// First check if it's built in the usual place.
		if(fexists("./rust/target/i686-pc-windows-msvc/release/rustlibs.dll"))
			return __rustlib = "./rust/target/i686-pc-windows-msvc/release/rustlibs.dll"
		// Then check in the current directory.
		if(fexists("./rustlibs.dll"))
			return __rustlib = "./rustlibs.dll"
		// And elsewhere.
		return __rustlib = "rustlibs.dll"

#define RUSTLIB (__rustlib || __detect_rustlib())

#define RUSTLIB_CALL(func, args...) call_ext(RUSTLIB, "byond:[#func]_ffi")(args)

/proc/milla_init_z(z)
	return RUSTLIB_CALL(milla_initialize, z)

/proc/is_milla_synchronous(tick)
	return RUSTLIB_CALL(milla_is_synchronous, tick)

/proc/set_tile_atmos(turf/T, airtight_north, airtight_east, airtight_south, airtight_west, atmos_mode, environment_id, oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, temperature, innate_heat_capacity)
	return RUSTLIB_CALL(milla_set_tile, T, airtight_north, airtight_east, airtight_south, airtight_west, atmos_mode, environment_id, oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, temperature, innate_heat_capacity)

/proc/get_tile_atmos(turf/T, list/L)
	return RUSTLIB_CALL(milla_get_tile, T, L)

/proc/spawn_milla_tick_thread()
	return RUSTLIB_CALL(milla_spawn_tick_thread)

/proc/get_milla_tick_time()
	return RUSTLIB_CALL(milla_get_tick_time)

/proc/get_interesting_atmos_tiles()
	return RUSTLIB_CALL(milla_get_interesting_tiles)

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

/// The number of values per tile.
#define MILLA_TILE_SIZE						MILLA_INDEX_TEMPERATURE

// These are only for InterestingTiles.
#define MILLA_INDEX_TURF					16
#define MILLA_INDEX_INTERESTING_REASONS		17
#define MILLA_INDEX_AIRFLOW_X				18
#define MILLA_INDEX_AIRFLOW_Y				19

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
