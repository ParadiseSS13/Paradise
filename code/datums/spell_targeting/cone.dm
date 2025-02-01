/datum/spell_targeting/cone
	max_targets = INFINITY
	use_intercept_click = TRUE
	/// This controls how many levels the cone has. Increase this value to make a bigger cone.
	var/cone_levels = 3
	/// This value determines if the cone penetrates walls.
	var/respect_density = FALSE

/datum/spell_targeting/cone/choose_targets(mob/user, datum/spell/spell, params, atom/clicked_atom)
	var/list/turfs_to_return = list()
	var/turf/turf_to_use = get_turf(user)
	var/turf/left_turf
	var/turf/right_turf
	var/dir_to_use = user.dir
	var/right_dir
	var/left_dir
	switch(dir_to_use)
		if(NORTH)
			left_dir = WEST
			right_dir = EAST
		if(SOUTH)
			left_dir = EAST
			right_dir = WEST
		if(EAST)
			left_dir = NORTH
			right_dir = SOUTH
		if(WEST)
			left_dir = SOUTH
			right_dir = NORTH

	// Go though every level of the cone levels and generate the cone.
	for(var/level in 1 to cone_levels)
		var/list/level_turfs = list()
		// Our center turf always exists, it's straight ahead of the caster.
		turf_to_use = get_step(turf_to_use, dir_to_use)
		level_turfs += turf_to_use
		// Level 1 only ever has 1 turf, it's a cone.
		if(level != 1)
			var/level_width_in_each_direction = round((calculate_cone_shape(level) - 1) / 2)
			left_turf = turf_to_use
			right_turf = turf_to_use
			// Check turfs to the left...
			for(var/left_of_center in 1 to level_width_in_each_direction)
				if(respect_density && left_turf.density)
					break
				left_turf = get_step(left_turf, left_dir)
				level_turfs += left_turf
			// And turfs to the right.
			for(var/right_of_enter in 1 to level_width_in_each_direction)
				if(respect_density && right_turf.density)
					break
				right_turf = get_step(right_turf, right_dir)
				level_turfs += right_turf
		// Add the list of all turfs on this level to the turfs to return
		turfs_to_return += list(level_turfs)

		// If we're at the last level, we're done
		if(level == cone_levels)
			break
		// But if we're not at the last level, we should check that we can keep going
		if(respect_density && turf_to_use.density)
			break

	return turfs_to_return

/**
 * Adjusts the width of the cone at the passed level.
 * This is never called on the first level of the cone (level 1 is always 1 width)
 *
 * Return a number - the TOTAL width of the cone at the passed level.
 */
/datum/spell_targeting/cone/proc/calculate_cone_shape(current_level)
	// Default formula: (1 (innate) -> 3 -> 5 -> 5 -> 7 -> 7 -> 9 -> 9 -> ...)
	return current_level + (current_level % 2) + 1
