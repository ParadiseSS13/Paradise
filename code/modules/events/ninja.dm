/datum/event/space_ninja
	name = "Космический ниндзя"

/datum/event/space_ninja/proc/get_ninja()
	var/image/I = new('icons/mob/ninja_previews.dmi', "ninja_preview_new_hood_green")
	var/list/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for the position of a Spider Clan Assassin'?", ROLE_NINJA, source = I)
	if(candidates.len)
		var/mob/dead/observer/selected = pick(candidates)
		candidates -= selected
		var/mob/living/carbon/human/new_character = makeBody(selected)
		new_character.mind.make_Space_Ninja()
		return TRUE
	else
		return FALSE

/datum/event/space_ninja/start()
	processing = 0 //so it won't fire again in next tick
	if(!get_ninja())
		message_admins("Space Ninja event failed to find players. Retrying in 30s.")
		addtimer(CALLBACK(src, .proc/get_ninja), 5 SECONDS)
