/**
 * A spell targeting system which will return nearby turfs which are reachable from the users location. Will pad the targets with the user's location if needed
 */
/datum/spell_targeting/reachable_turfs

/datum/spell_targeting/reachable_turfs/choose_targets(mob/user, datum/spell/spell, params, atom/clicked_atom)
	var/list/turf/locs = list()
	for(var/direction in GLOB.alldirs)
		if(length(locs) == max_targets) //we found 2 locations and thats all we need
			break
		var/turf/T = get_step(user, direction) //getting a loc in that direction
		if(length(get_path_to(user, T, max_distance = 1, simulated_only = FALSE))) // if a path exists, so no dense objects in the way its valid salid
			locs += T

	// pad with player location
	for(var/i = length(locs) + 1 to max_targets)
		locs += user.loc
	return locs
