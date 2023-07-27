/**
 * Gets a list of turfs around the center atom to scramble.
 *
 * Returns an assoc list of [turf] to [turf]. These pairs are what turfs are
 * swapped between one another when the cast is done.
 */
/datum/spell_targeting/spiral
	max_targets = INFINITY


/datum/spell_targeting/spiral/choose_targets(atom/center)
	// Get turfs around the center
	var/list/turfs = spiral_range_turfs(range, center)
	if(!length(turfs))
		return

	var/list/targets = list()

	// Go through the turfs we got and pair them up
	// This is where we determine what to swap where
	var/num_to_scramble = round(length(turfs) * 0.5)
	for(var/i in 1 to num_to_scramble)
		targets[pick_n_take(turfs)] = pick_n_take(turfs)

	// If there's any turfs unlinked with a friend,
	// just randomly swap it with any turf in the area
	if(length(turfs))
		var/turf/loner = pick(turfs)
		var/area/caster_area = get_area(center)
		targets[loner] = get_turf(pick(caster_area.contents))

	return targets

