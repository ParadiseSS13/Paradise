#define DEFAULT_PADDING 32

/datum/ruin_placement
	var/datum/map_template/ruin/ruin
	var/base_padding
	var/padding

/datum/ruin_placement/New(datum/map_template/ruin/ruin_, padding_ = DEFAULT_PADDING, base_padding_ = 0)
	. = ..()
	ruin = ruin_
	base_padding = base_padding_
	padding = padding_

/datum/ruin_placement/proc/reduce_padding()
	padding = max(floor(padding / 2) - 1, -1)

/datum/ruin_placement/proc/try_to_place(zlist_or_zlevel, area_whitelist)
	var/list/z_levels = islist(zlist_or_zlevel) ? zlist_or_zlevel : list(zlist_or_zlevel)

	// Our goal is to maximize padding, so we'll perform some number of attempts
	// on one z-level, then the next, until we reach some limit, then reduce the
	// padding and start again.
	padding = DEFAULT_PADDING
	while(padding >= 0)
		var/width_border = base_padding + round(ruin.width / 2) + padding
		var/height_border = base_padding + round(ruin.height / 2) + padding

		for(var/z_level in z_levels)
			var/placement_tries = PLACEMENT_TRIES
			while(placement_tries > 0)
				placement_tries--

				var/turf/central_turf = locate(
					rand(width_border, world.maxx - width_border),
					rand(height_border, world.maxy - height_border),
					z_level
				)
				var/valid = TRUE

				if(!central_turf)
					continue

				// Expand the original bounds of the ruin with our padding and call
				// that our list of affected turfs.
				var/list/bounds = ruin.get_coordinate_bounds(central_turf, centered = TRUE)
				var/datum/coords/bottom_left = bounds["bottom_left"]
				var/datum/coords/top_right = bounds["top_right"]
				bottom_left.x_pos -= padding
				bottom_left.y_pos -= padding
				top_right.x_pos += padding
				top_right.y_pos += padding
				var/list/affected_turfs = block(bottom_left.x_pos, bottom_left.y_pos, z_level, top_right.x_pos, top_right.y_pos, z_level)

				// One sanity check just in case
				if(!ruin.fits_in_map_bounds(central_turf, centered = TRUE))
					valid = FALSE

				for(var/turf/check in affected_turfs)
					var/area/new_area = get_area(check)
					if(!(istype(new_area, area_whitelist)) || check.flags & NO_RUINS)
						valid = FALSE
						break

				if(!valid)
					continue

				for(var/turf/T in affected_turfs)
					for(var/obj/structure/spawner/nest in T)
						qdel(nest)
					for(var/mob/living/simple_animal/monster in T)
						qdel(monster)
					for(var/obj/structure/flora/ash/plant in T)
						qdel(plant)

				ruin.load(central_turf, centered = TRUE)
				for(var/turf/T in ruin.get_affected_turfs(central_turf, centered = TRUE)) // Just flag the actual ruin turfs!
					T.flags |= NO_RUINS
				new /obj/effect/landmark/ruin(central_turf, ruin)
				ruin.loaded++

				log_world("Ruin \"[ruin.name]\" placed at ([central_turf.x], [central_turf.y], [central_turf.z])")

				var/map_filename = splittext(ruin.mappath, "/")
				map_filename = map_filename[length(map_filename)]
				SSblackbox.record_feedback("associative", "ruin_placement", 1, list(
					"map" = map_filename,
					"coords" = "[central_turf.x],[central_turf.y],[central_turf.z]"
				))

				return TRUE

			// Ran out of placement tries for this z-level/padding, move to the next z-level

		// Ran out of z-levels to try with this padding, cut it and start again
		reduce_padding()

	// Ran out of z-levels, we got nowhere to place it
	return FALSE

/datum/ruin_placer
	var/ruin_budget
	var/area_whitelist
	var/list/templates
	var/base_padding

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

		var/datum/ruin_placement/placement = new(current_pick, base_padding_ = base_padding)
		var/placement_success = placement.try_to_place(forced_z ? forced_z : z_levels, area_whitelist)

		//That's done remove from priority even if it failed
		if(forced)
			//TODO : handle forced ruins with multiple variants
			forced_ruins -= current_pick
			forced = FALSE

		if(placement_success)
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
		else
			for(var/datum/map_template/ruin/R in ruins_availible)
				if(R.id == current_pick.id)
					ruins_availible -= R
			log_world("Failed to place [current_pick.name] ruin.")

		forced_z = 0

		//Update the availible list
		for(var/datum/map_template/ruin/R in ruins_availible)
			if(R.get_cost() > ruin_budget)
				ruins_availible -= R

	log_world("Ruin loader finished with [ruin_budget] left to spend.")

#undef DEFAULT_PADDING

/datum/ruin_placer/space
	area_whitelist = /area/space
	base_padding = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD

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
