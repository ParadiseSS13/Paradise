// milla.dm - DM API for milla extension library

// Default automatic MILLA detection.
// Look for it in the build location first, then in `.`, then in standard places.

/* This comment bypasses grep checks */ /var/__milla

/proc/__detect_milla()
	if(world.system_type == UNIX)
#ifdef CIBUILDING
		// CI override, use libmilla_ci.so if possible.
		if(fexists("./tools/ci/libmilla_ci.so"))
			return __milla = "tools/ci/libmilla_ci.so"
#endif
		// First check if it's built in the usual place.
		if(fexists("./milla/target/i686-unknown-linux-gnu/release/libmilla.so"))
			return __milla = "./milla/target/i686-unknown-linux-gnu/release/libmilla.so"
		// Then check in the current directory.
		if(fexists("./libmilla.so"))
			return __milla = "./libmilla.so"
		// And elsewhere.
		return __milla = "libmilla.so"
	else
		// First check if it's built in the usual place.
		if(fexists("./milla/target/i686-pc-windows-msvc/release/milla.dll"))
			return __milla = "./milla/target/i686-pc-windows-msvc/release/milla.dll"
		// Then check in the current directory.
		if(fexists("./milla.dll"))
			return __milla = "./milla.dll"
		// And elsewhere.
		return __milla = "milla.dll"

#define MILLA (__milla || __detect_milla())

#define MILLA_CALL(func, args...) call_ext(MILLA, "byond:[#func]_ffi")(args)

/proc/milla_init_z(z)
	return MILLA_CALL(initialize, z)

/proc/is_milla_synchronous()
	return MILLA_CALL(is_synchronous)

/proc/set_tile_atmos(x, y, z, blocked_north, blocked_east, blocked_south, blocked_west, atmos_mode, external_temperature, oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, temperature, innate_heat_capacity)
	return MILLA_CALL(set_tile_atmos, x, y, z, blocked_north, blocked_east, blocked_south, blocked_west, atmos_mode, external_temperature, oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, temperature, innate_heat_capacity)

/proc/get_tile_atmos(x, y, z)
	return MILLA_CALL(get_tile_atmos, x, y, z)

/proc/spawn_milla_tick_thread()
	return MILLA_CALL(spawn_tick_thread)

/proc/get_milla_tick_time()
	return MILLA_CALL(get_tick_time)

/proc/get_interesting_atmos_tiles()
	return MILLA_CALL(get_interesting_tiles)

/proc/reduce_superconductivity(x, y, z, list/superconductivity)
	var/north = superconductivity[1]
	var/east = superconductivity[2]
	var/south = superconductivity[3]
	var/west = superconductivity[4]

	return MILLA_CALL(reduce_superconductivity, x, y, z, north, east, south, west)

/proc/reset_superconductivity(x, y, z)
	return MILLA_CALL(reset_superconductivity, x, y, z)

/proc/set_tile_atmos_blocking(x, y, z, list/blocking)
	var/north = blocking[1]
	var/east = blocking[2]
	var/south = blocking[3]
	var/west = blocking[4]

	return MILLA_CALL(set_tile_atmos_blocking, x, y, z, north, east, south, west)

/proc/get_random_interesting_tile()
	return MILLA_CALL(get_random_interesting_tile)

#undef MILLA
#undef MILLA_CALL
