/**
 * A click based spell targeting system. The clicked atom will be used to determine who/what to target
 */
/datum/spell_targeting/click
	use_intercept_click = TRUE
	try_auto_target = TRUE
	/// How big the radius around the clicked atom is to find clicked_atom suitable target. -1 is only the selected atom is considered
	var/click_radius = 1
	var/random_target_priority = SPELL_TARGET_CLOSEST


/datum/spell_targeting/click/choose_targets(mob/user, datum/spell/spell, params, atom/clicked_atom)
	var/list/targets = list()
	if(valid_target(clicked_atom, user, spell))
		targets.Add(clicked_atom)

	if(length(targets) >= max_targets || click_radius < 0)
		return targets

	var/list/found_others = list()
	for(var/atom/target in range(click_radius, clicked_atom) - clicked_atom)
		if(valid_target(target, user, spell))
			found_others += target

	if(max_targets >= length(found_others) + length(targets))
		targets.Add(found_others)
	else
		switch(random_target_priority) //Add in the rest
			if(SPELL_TARGET_RANDOM)
				while(length(targets) < max_targets && length(found_others)) // Add the others
					targets.Add(pick_n_take(found_others))
			if(SPELL_TARGET_CLOSEST)
				// Take the first X. Byond's view/range procs already keep distance in mind. Will have a bias towards the left targets due to this
				targets += found_others.Copy(1, max_targets - length(targets) + 1)

	return targets

