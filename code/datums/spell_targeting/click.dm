/datum/spell_targeting/click
	use_intercept_click = TRUE
	try_auto_target = TRUE
	/// How big the radius around the clicked atom is to find clicked_atom suitable target. -1 is only the selected atom is considered
	var/click_radius = 1
	var/random_target_priority = TARGET_CLOSEST


/datum/spell_targeting/click/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	var/list/targets = list()
	if(valid_target(clicked_atom, user))
		targets.Add(clicked_atom)

	if(max_targets <= length(targets) || click_radius < 0)
		return targets

	var/list/found_others = list()
	for(var/atom/target in range(click_radius, clicked_atom))
		if(clicked_atom != target && valid_target(target, user))
			found_others += target

	if(max_targets <= length(found_others) + length(targets))
		targets.Add(found_others)
	else
		switch(random_target_priority) //Add in the rest
			if(TARGET_RANDOM)
				while(length(targets) < max_targets && length(found_others)) // Add the others
					targets.Add(pick_n_take(found_others))
			if(TARGET_CLOSEST)
				var/list/distances = list()
				for(var/target in found_others) // maybe not needed TODO check
					distances[target] = get_dist(user, target)
				sortTim(distances, /proc/cmp_numeric_asc, TRUE) // Sort on distance
				for(var/target in distances)
					targets.Add(target)
					if(length(targets) >= max_targets)
						break

	return targets

