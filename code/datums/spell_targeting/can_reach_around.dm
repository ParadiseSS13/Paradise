/datum/spell_targeting/can_reach_around/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	var/list/turf/locs = list()
	for(var/direction in GLOB.alldirs)
		if(length(locs) == max_targets) //we found 2 locations and thats all we need
			break
		var/turf/T = get_step(user, direction) //getting a loc in that direction
		if(AStar(user, T, /turf/proc/Distance, 1, simulated_only = FALSE)) // if a path exists, so no dense objects in the way its valid salid
			locs += T

	// pad with player location
	for(var/i = length(locs) + 1 to max_targets)
		locs += user.loc
	return locs
