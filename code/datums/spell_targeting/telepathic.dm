/**
 * A spell targeting system which will allow the user to select a target from nearby living mobs. The name will be "Unknown entity" if the user can not see them
 */
/datum/spell_targeting/telepathic

/datum/spell_targeting/telepathic/choose_targets(mob/user, datum/spell/spell, params, atom/clicked_atom)
	var/list/valid_targets = list()
	var/turf/T = get_turf(user)
	var/list/mobs_in_view = user.get_visible_mobs()

	for(var/mob/living/M in range(14, T))
		if(M && M.mind)
			if(M == user)
				continue
			var/mob_name
			if(M in mobs_in_view)
				mob_name = M.name
			else
				mob_name = "Unknown entity"
			var/i = 0
			var/result_name
			do
				result_name = mob_name
				if(i++)
					result_name += " ([i])" // Avoid dupes
			while(valid_targets[result_name])
			valid_targets[result_name] = M
	if(!length(valid_targets))
		return

	var/target_name = tgui_input_list(user, "Choose the target to listen to", "Targeting", valid_targets)

	var/mob/living/target = valid_targets[target_name]
	if(QDELETED(target))
		return

	return list(target)
