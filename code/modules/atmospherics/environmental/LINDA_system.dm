/turf/proc/CanAtmosPass(turf/T)
	if(!istype(T))
		return FALSE
	var/R = TRUE	// return
	if(blocks_air || T.blocks_air)
		R = FALSE

	for(var/obj/O in (contents + T.contents))
		if(!O.CanAtmosPass(src) || !O.CanAtmosPass(T))
			R = FALSE
			if(O.BlockSuperconductivity())
				var/D = get_dir(src, T)
				atmos_superconductivity |= D
				D = get_dir(T, src)
				T.atmos_superconductivity |= D
				return R

	var/D = get_dir(src, T)
	atmos_superconductivity &= ~D
	D = get_dir(T, src)
	T.atmos_superconductivity &= ~D

	return R

/atom/movable/proc/CanAtmosPass()
	return TRUE

/atom/proc/CanPass(atom/movable/mover, turf/target, height=1.5)
	return (!density || !height)

/turf/CanPass(atom/movable/mover, turf/target, height=1.5)
	if(!target)
		return FALSE

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return FALSE

		for(var/obj/obstacle in src)
			if(!obstacle.CanPass(mover, target, height))
				return FALSE
		for(var/obj/obstacle in target)
			if(!obstacle.CanPass(mover, src, height))
				return FALSE

		return TRUE

/atom/movable/proc/BlockSuperconductivity() // objects that block air and don't let superconductivity act. Only firelocks atm.
	return FALSE

/turf/proc/CalculateAdjacentTurfs()
	for(var/direction in GLOB.cardinal)
		var/turf/T = get_step(src, direction)
		if(!istype(T))
			continue
		if(CanAtmosPass(T))
			atmos_adjacent_turfs |= T
			T.atmos_adjacent_turfs |= src
		else
			atmos_adjacent_turfs -= T
			T.atmos_adjacent_turfs -= src

//returns a list of adjacent turfs that can share air with this one.
//alldir includes adjacent diagonal tiles that can share
//	air with both of the related adjacent cardinal tiles
/turf/proc/GetAtmosAdjacentTurfs(alldir = 0)
	if(!istype(src, /turf/simulated))
		return list()

	var/adjacent_turfs = atmos_adjacent_turfs.Copy()
	if(!alldir)
		return adjacent_turfs
	var/turf/simulated/curloc = src
	for(var/direction in GLOB.diagonals)
		var/matchingDirections = 0
		var/turf/simulated/S = get_step(curloc, direction)

		for(var/checkDirection in GLOB.cardinal)
			var/turf/simulated/checkTurf = get_step(S, checkDirection)
			if(!(checkTurf in S.atmos_adjacent_turfs))
				continue

			if(checkTurf in adjacent_turfs)
				matchingDirections++

			if(matchingDirections >= 2)
				adjacent_turfs += S
				break

	return adjacent_turfs

/atom/movable/proc/air_update_turf(command = 0)
	if(!istype(loc,/turf) && command)
		return
	for(var/turf/T in locs) // used by double wide doors and other nonexistant multitile structures
		T.air_update_turf(command)

/turf/proc/air_update_turf(command = 0)
	if(command)
		CalculateAdjacentTurfs()
	if(SSair)
		SSair.add_to_active(src,command)

/atom/movable/proc/move_update_air(turf/T)
    if(istype(T,/turf))
        T.air_update_turf(1)
    air_update_turf(1)



/atom/movable/proc/atmos_spawn_air(text, amount) //because a lot of people loves to copy paste awful code lets just make a easy proc to spawn your plasma fires
	var/turf/simulated/T = get_turf(src)
	if(!istype(T))
		return
	T.atmos_spawn_air(text, amount)

/turf/simulated/proc/atmos_spawn_air(flag, amount)
	if(!text || !amount || !air)
		return

	var/datum/gas_mixture/G = new

	if(flag & LINDA_SPAWN_20C)
		G.temperature = T20C

	if(flag & LINDA_SPAWN_HEAT)
		G.temperature += 1000

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

	air.merge(G)
	SSair.add_to_active(src, 0)
