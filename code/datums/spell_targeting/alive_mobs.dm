/**
 * Will find targets in the GLOB.alive_mob_list. The result will be in a random order
 */
/datum/spell_targeting/alive_mob_list
	allowed_type = /mob/living

/datum/spell_targeting/alive_mob_list/choose_targets(mob/user, datum/spell/spell, params, atom/clicked_atom)
	var/list/possible_targets = list()
	for(var/mob/living/possible_target as anything in GLOB.alive_mob_list)
		if(valid_target(possible_target, user, spell, FALSE))
			possible_targets += possible_target

	var/list/targets = pick_multiple_unique(possible_targets, max_targets)

	return targets
