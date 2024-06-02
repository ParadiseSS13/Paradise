/**
 * A spell targeting system which is able to select 1 to many targets in range/view of the caster. Has a random mode, distance from user based mode or a user input mode.
 */
/datum/spell_targeting/targeted
	/// Only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast
	var/can_hit_target_more_than_once = FALSE
	/// Chooses random viable target instead of asking the caster
	var/random_target = FALSE
	/// Who to target when too many targets are found. Only matters when max_targets = 1
	var/target_priority = SPELL_TARGET_CLOSEST

/datum/spell_targeting/targeted/choose_targets(mob/user, datum/spell/spell, params, atom/clicked_atom)
	var/list/targets = list()
	var/list/possible_targets = list()
	var/atom/spell_location = use_turf_of_user ? get_turf(user) : user
	for(var/atom/target in view_or_range(range, spell_location, selection_type))
		if(valid_target(target, user, spell, FALSE))
			possible_targets += target

	if(!length(possible_targets))
		return null

	if(max_targets == INFINITY) // Unlimited
		targets = possible_targets
	else if(max_targets == 1) // Only one target
		var/atom/target
		if(!random_target)
			target = tgui_input_list(user, "Choose the target for the spell", "Targeting", possible_targets)
			//Adds a safety check post-input to make sure those targets are actually in range.
			if(target in view_or_range(range, spell_location, selection_type))
				targets += target
		else
			switch(target_priority)
				if(SPELL_TARGET_RANDOM)
					target = pick(possible_targets)
				if(SPELL_TARGET_CLOSEST)
					for(var/atom/A as anything in possible_targets)
						if(target)
							if(get_dist(spell_location, A) < get_dist(spell_location, target))
								target = A
						else
							target = A
			targets += target
	else if(max_targets > 1)
		do
			if(can_hit_target_more_than_once)
				targets += pick(possible_targets)
			else
				targets += pick_n_take(possible_targets)
		while(length(possible_targets) && length(targets) < max_targets)

	return targets
