/datum/spell_targeting/telepathic

/datum/spell_targeting/telepathic/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
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
		return null

	var/target_name = input("Choose the target to listen to.", "Targeting") as null|anything in valid_targets

	var/mob/living/target = valid_targets[target_name]
	if(!target)
		return null

	return list(target)
