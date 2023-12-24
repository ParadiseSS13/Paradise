/datum/asset/simple/mob_hunt/register()
	for(var/state in icon_states('icons/effects/mob_hunt.dmi'))
		if(state == "Placeholder")
			continue
		assets["[state].png"] = icon('icons/effects/mob_hunt.dmi', state)

	return ..()
