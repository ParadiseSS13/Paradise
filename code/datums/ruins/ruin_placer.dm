/datum/ruin_placer
	var/ruin_budget
	var/area_whitelist
	var/list/templates

/datum/ruin_placer/proc/place_ruins(z_levels)
	if(!z_levels || !length(z_levels))
		WARNING("No Z levels provided - Not generating ruins")
		return

	for(var/zl in z_levels)
		var/turf/T = locate(1, 1, zl)
		if(!T)
			WARNING("Z level [zl] does not exist - Not generating ruins")
			return

	var/list/ruins = templates.Copy()

	var/list/forced_ruins = list()		//These go first on the z level associated (same random one by default)
	var/list/ruins_availible = list()	//we can try these in the current pass
	var/forced_z	//If set we won't pick z level and use this one instead.

	//Set up the starting ruin list
	for(var/key in ruins)
		var/datum/map_template/ruin/R = ruins[key]
		if(R.get_cost() > ruin_budget) //Why would you do that
			continue
		if(R.always_place)
			forced_ruins[R] = -1
		if(R.unpickable)
			continue
		ruins_availible[R] = R.placement_weight

	while(ruin_budget > 0 && (length(ruins_availible) || length(forced_ruins)))
		var/datum/map_template/ruin/current_pick
		var/forced = FALSE
		if(length(forced_ruins)) //We have something we need to load right now, so just pick it
			for(var/ruin in forced_ruins)
				current_pick = ruin
				if(forced_ruins[ruin] > 0) //Load into designated z
					forced_z = forced_ruins[ruin]
				forced = TRUE
				break
		else //Otherwise just pick random one
			current_pick = pickweight(ruins_availible)

		var/placement_tries = PLACEMENT_TRIES
		var/failed_to_place = TRUE
		var/z_placed = 0
		while(placement_tries > 0)
			placement_tries--
			z_placed = pick(z_levels)
			if(!current_pick.try_to_place(forced_z ? forced_z : z_placed, area_whitelist))
				continue
			else
				failed_to_place = FALSE
				break

		//That's done remove from priority even if it failed
		if(forced)
			//TODO : handle forced ruins with multiple variants
			forced_ruins -= current_pick
			forced = FALSE

		if(failed_to_place)
			for(var/datum/map_template/ruin/R in ruins_availible)
				if(R.id == current_pick.id)
					ruins_availible -= R
			log_world("Failed to place [current_pick.name] ruin.")
		else
			ruin_budget -= current_pick.get_cost()
			if(!current_pick.allow_duplicates)
				for(var/datum/map_template/ruin/R in ruins_availible)
					if(R.id == current_pick.id)
						ruins_availible -= R
			if(current_pick.never_spawn_with)
				for(var/blacklisted_type in current_pick.never_spawn_with)
					for(var/possible_exclusion in ruins_availible)
						if(istype(possible_exclusion,blacklisted_type))
							ruins_availible -= possible_exclusion
		forced_z = 0

		//Update the availible list
		for(var/datum/map_template/ruin/R in ruins_availible)
			if(R.get_cost() > ruin_budget)
				ruins_availible -= R

	log_world("Ruin loader finished with [ruin_budget] left to spend.")

/datum/ruin_placer/space
	area_whitelist = /area/space

/datum/ruin_placer/space/New()
	ruin_budget = rand(
		GLOB.configuration.ruins.space_ruin_budget_min,
		GLOB.configuration.ruins.space_ruin_budget_max
	)
	templates = GLOB.space_ruins_templates

/datum/ruin_placer/lavaland
	area_whitelist = /area/lavaland/surface/outdoors/unexplored

/datum/ruin_placer/lavaland/New()
	ruin_budget = rand(
		GLOB.configuration.ruins.lavaland_ruin_budget_min,
		GLOB.configuration.ruins.lavaland_ruin_budget_max
	)
	templates = GLOB.lava_ruins_templates
