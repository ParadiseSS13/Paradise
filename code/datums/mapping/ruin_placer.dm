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
	shuffle_inplace(z_levels)

	// Our goal is to maximize padding, so we'll perform some number of attempts
	// on one z-level, then the next, until we reach some limit, then reduce the
	// padding and start again.
	padding = DEFAULT_PADDING
	while(padding >= 0)
		var/width_border = base_padding + round(ruin.width / 2) + padding
		var/height_border = base_padding + round(ruin.height / 2) + padding

		for(var/z_level in z_levels)
			var/blocked_on_level = FALSE
			var/datum/space_level/current_level = GLOB.space_manager.get_zlev(z_level)
			for(var/blocked_ruin_id in ruin.never_spawn_on_the_same_level)
				if(blocked_on_level)
					break
				for(var/ruin_id in current_level.our_ruin_list)
					if(blocked_ruin_id == ruin_id)
						blocked_on_level = TRUE
						break
			if(blocked_on_level)
				continue

			var/placement_tries = PLACEMENT_TRIES
			while(placement_tries > 0)
				CHECK_TICK

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

				// One sanity check just in case
				if(!ruin.fits_in_map_bounds(central_turf, centered = TRUE))
					valid = FALSE

				for(var/turf/check in block(bottom_left.x_pos, bottom_left.y_pos, z_level, top_right.x_pos, top_right.y_pos, z_level))
					var/area/new_area = get_area(check)
					if(!(istype(new_area, area_whitelist)) || check.flags & NO_RUINS)
						valid = FALSE
						break

				if(!valid)
					continue

				var/loaded = ruin.load(central_turf, centered = TRUE)
				if(!loaded)
					stack_trace("ruin [ruin.suffix] failed to load at [COORD(central_turf)] after valid bounds check")
				for(var/turf/T in ruin.get_affected_turfs(central_turf, centered = TRUE)) // Just flag the actual ruin turfs!
					T.flags |= NO_RUINS
				new /obj/effect/landmark/ruin(central_turf, ruin)
				ruin.loaded++
				current_level.our_ruin_list += ruin.id

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

	var/list/forced_ruins = list() // ruins we are required to place
	var/list/ruins_available = list() // ruins we will attempt to place based on budget

	// Set up the starting ruin lists
	for(var/key in ruins)
		var/datum/map_template/ruin/R = ruins[key]
		if(R.always_place)
			forced_ruins += R
			continue
		if(R.unpickable)
			continue
		if(R.get_cost() > ruin_budget) // Why would you do that
			continue
		ruins_available[R] = R.placement_weight

	forced_ruins = sortTim(forced_ruins, GLOBAL_PROC_REF(cmp_ruin_placement_cost))
	while(length(forced_ruins))
		var/datum/map_template/ruin/ruin = forced_ruins[length(forced_ruins)]
		var/datum/ruin_placement/placement = new(ruin, base_padding_ = base_padding)
		var/placement_success = placement.try_to_place(z_levels, area_whitelist)
		if(placement_success)
			// this may push us into the negative but always_place means always_place
			ruin_budget -= ruin.get_cost()
		else
			stack_trace("failed to place required ruin [ruin.suffix]")

		forced_ruins.len--
		CHECK_TICK

	while(ruin_budget > 0 && length(ruins_available))
		var/datum/map_template/ruin/current_pick = pickweight(ruins_available)
		var/datum/ruin_placement/placement = new(current_pick, base_padding_ = base_padding)
		var/placement_success = placement.try_to_place(z_levels, area_whitelist)

		if(placement_success)
			ruin_budget -= current_pick.get_cost()
			if(!current_pick.allow_duplicates)
				for(var/datum/map_template/ruin/R in ruins_available)
					if(R.id == current_pick.id)
						ruins_available -= R
			if(current_pick.never_spawn_with)
				for(var/blacklisted_type in current_pick.never_spawn_with)
					for(var/possible_exclusion in ruins_available)
						if(istype(possible_exclusion,blacklisted_type))
							ruins_available -= possible_exclusion
		else
			for(var/datum/map_template/ruin/R in ruins_available)
				if(R.id == current_pick.id)
					ruins_available -= R
			log_debug("failed ruin placement `[current_pick.suffix]` length(z_levels)=[length(z_levels)] budget=[ruin_budget]")

		//Update the available list
		for(var/datum/map_template/ruin/R in ruins_available)
			if(R.get_cost() > ruin_budget)
				ruins_available -= R

		CHECK_TICK

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
