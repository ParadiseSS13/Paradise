/turf/proc/CanAtmosPass(direction, consider_objects = TRUE)
	if(blocks_air)
		return FALSE

	if(!consider_objects)
		return TRUE

	for(var/obj/O in contents)
		if(istype(O, /obj/item))
			// Items can't block atmos.
			continue

		if(!O.CanAtmosPass(direction))
			return FALSE

	return TRUE

/atom/movable/proc/CanAtmosPass()
	return TRUE

/atom/proc/CanPass(atom/movable/mover, border_dir)
	return !density

/turf/CanPass(atom/movable/mover, border_dir)
	var/turf/target = get_step(src, border_dir)
	if(!target)
		return FALSE

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(!obstacle.CanPass(mover, border_dir))
				return 0
		for(var/obj/obstacle in target)
			if(!obstacle.CanPass(mover, src))
				return 0

		return 1

/atom/movable/proc/get_superconductivity(direction)
	return OPEN_HEAT_TRANSFER_COEFFICIENT

/atom/movable/proc/recalculate_atmos_connectivity()
	for(var/turf/T in locs) // used by double wide doors and other nonexistant multitile structures
		T.recalculate_atmos_connectivity()

/atom/movable/proc/move_update_air(turf/T)
	if(isturf(T))
		T.recalculate_atmos_connectivity()
	recalculate_atmos_connectivity()

//returns a list of adjacent turfs that can share air with this one.
//alldir includes adjacent diagonal tiles that can share
//	air with both of the related adjacent cardinal tiles
/turf/proc/GetAtmosAdjacentTurfs(alldir = 0)
	if(!issimulatedturf(src))
		return list()

	var/adjacent_turfs = list()
	for(var/turf/T in RANGE_EDGE_TURFS(1, src))
		var/direction = get_dir(src, T)
		if(!CanAtmosPass(direction))
			continue
		if(!T.CanAtmosPass(turn(direction, 180)))
			continue
		adjacent_turfs += T

	if(!alldir)
		return adjacent_turfs

	for(var/turf/T in RANGE_TURFS(1, src))
		var/direction = get_dir(src, T)
		if(IS_DIR_CARDINAL(direction))
			continue
		// check_direction is the first way we move, from src
		for(var/check_direction in GLOB.cardinal)
			if(!(check_direction & direction))
				// Wrong way.
				continue

			var/turf/intermediate = get_step(src, check_direction)
			if(!(intermediate in adjacent_turfs))
				continue

			// other_direction is the second way we move, from intermediate.
			var/other_direction = direction & ~check_direction

			// We already know we can reach intermediate, so now we just need to check the second step.
			if(!intermediate.CanAtmosPass(other_direction))
				continue
			if(!T.CanAtmosPass(turn(other_direction, 180)))
				continue

			adjacent_turfs += T
			break

	return adjacent_turfs

/atom/movable/proc/atmos_spawn_air(flag, amount) //because a lot of people loves to copy paste awful code lets just make a easy proc to spawn your plasma fires
	var/turf/simulated/T = get_turf(src)
	if(!istype(T))
		return
	T.atmos_spawn_air(flag, amount)

/turf/simulated/proc/atmos_spawn_air(flag, amount)
	if(!flag || !amount || blocks_air)
		return

	var/datum/gas_mixture/G = new()

	if(flag & LINDA_SPAWN_20C)
		G.set_temperature(T20C)

	if(flag & LINDA_SPAWN_HEAT)
		G.set_temperature(G.temperature() + 1000)

	if(flag & LINDA_SPAWN_COLD)
		G.set_temperature(TCMB)

	if(flag & LINDA_SPAWN_TOXINS)
		G.set_toxins(G.toxins() + amount)

	if(flag & LINDA_SPAWN_OXYGEN)
		G.set_oxygen(G.oxygen() + amount)

	if(flag & LINDA_SPAWN_CO2)
		G.set_carbon_dioxide(G.carbon_dioxide() + amount)

	if(flag & LINDA_SPAWN_NITROGEN)
		G.set_nitrogen(G.nitrogen() + amount)

	if(flag & LINDA_SPAWN_N2O)
		G.set_sleeping_agent(G.sleeping_agent() + amount)

	if(flag & LINDA_SPAWN_AGENT_B)
		G.set_agent_b(G.agent_b() + amount)

	if(flag & LINDA_SPAWN_AIR)
		G.set_oxygen(G.oxygen() + MOLES_O2STANDARD * amount)
		G.set_nitrogen(G.nitrogen() + MOLES_N2STANDARD * amount)

	blind_release_air(G)
