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

/atom/proc/CanPass(atom/movable/mover, turf/target, height=1.5)
	return (!density || !height)

/turf/CanPass(atom/movable/mover, turf/target, height=1.5)
	if(!target) return 0

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(!obstacle.CanPass(mover, target, height))
				return 0
		for(var/obj/obstacle in target)
			if(!obstacle.CanPass(mover, src, height))
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
		G.temperature = T20C

	if(flag & LINDA_SPAWN_HEAT)
		G.temperature += 1000

	if(flag & LINDA_SPAWN_COLD)
		G.temperature = TCMB

	if(flag & LINDA_SPAWN_TOXINS)
		G.toxins += amount

	if(flag & LINDA_SPAWN_OXYGEN)
		G.oxygen += amount

	if(flag & LINDA_SPAWN_CO2)
		G.carbon_dioxide += amount

	if(flag & LINDA_SPAWN_NITROGEN)
		G.nitrogen += amount

	if(flag & LINDA_SPAWN_N2O)
		G.sleeping_agent += amount

	if(flag & LINDA_SPAWN_AGENT_B)
		G.agent_b += amount

	if(flag & LINDA_SPAWN_AIR)
		G.oxygen += MOLES_O2STANDARD * amount
		G.nitrogen += MOLES_N2STANDARD * amount

	var/datum/gas_mixture/full_air = get_air()
	full_air.merge(G)
	write_air(full_air)

// From milla/src/lib.rs
// Increased by 1 due to the difference in array indexing.
#define GAS_OFFSET 7
// Rust deals in thermal energy, but converts when talking to DM.
#define ATMOS_TEMPERATURE 13
#define ATMOS_INNATE_HEAT_CAPACITY 18
/proc/milla_to_gas_mixture(list/raw_atmos)
	var/datum/gas_mixture/air = new()
	// Numbers from milla/src/lib.rs, plus one due to array indexing.
	air.oxygen = raw_atmos[GAS_OFFSET + 0]
	air.carbon_dioxide = raw_atmos[GAS_OFFSET + 1]
	air.nitrogen = raw_atmos[GAS_OFFSET + 2]
	air.toxins = raw_atmos[GAS_OFFSET + 3]
	air.sleeping_agent = raw_atmos[GAS_OFFSET + 4]
	air.agent_b = raw_atmos[GAS_OFFSET + 5]
	air.temperature = raw_atmos[ATMOS_TEMPERATURE]
	air.innate_heat_capacity = raw_atmos[ATMOS_INNATE_HEAT_CAPACITY]
	return air
#undef GAS_OFFSET
#undef ATMOS_TEMPERATURE
#undef ATMOS_INNATE_HEAT_CAPACITY
