/datum/spell_targeting/targeted
	/// Only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast
	var/can_hit_target_more_than_once = FALSE
	/// Chooses random viable target instead of asking the caster
	var/random_target = FALSE
	/// Who to target when too many targets are found. Only matters when max_targets = 1
	var/target_priority = SPELL_TARGET_CLOSEST

/datum/spell_targeting/targeted/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	var/list/targets = list()
	var/list/possible_targets = list()
	for(var/atom/target in view_or_range(range, user, selection_type))
		if(valid_target(target, user, spell))
			possible_targets += target

	if(!length(possible_targets))
		return null

	if(max_targets == 1) // Only one target
		var/mob/M
		if(!random_target)
			M = input("Choose the target for the spell.", "Targeting") as mob in possible_targets
			//Adds a safety check post-input to make sure those targets are actually in range.
			if(M in view_or_range(range, user, selection_type))
				targets += M
		else
			switch(target_priority)
				if(SPELL_TARGET_RANDOM)
					M = pick(possible_targets)
				if(SPELL_TARGET_CLOSEST)
					for(var/mob/living/L in possible_targets)
						if(M)
							if(get_dist(user,L) < get_dist(user,M))
								if(spell.los_check(user, L))
									M = L
						else
							if(spell.los_check(user, L))
								M = L
			targets += M
	else if(max_targets > 1)
		do
			if(can_hit_target_more_than_once)
				targets += pick(possible_targets)
			else
				targets += pick_n_take(possible_targets)
		while(length(possible_targets) && length(targets) < max_targets)
	else // Unlimited
		targets = possible_targets

	return targets
