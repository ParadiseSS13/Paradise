
/datum/spell/paradox/self/digital_supersede
	name = "Digital Supersede"
	desc = "With the help of the paradox, you completely remove the cameras from yourself, leaving only interference..."
	action_icon_state = "digital_supersede"
	base_cooldown = 1 SECONDS

/datum/spell/paradox/self/digital_supersede/cast(list/targets, mob/user = usr)
	if(HAS_TRAIT_FROM(user, TRAIT_AI_UNTRACKABLE, PARADOX_CLONE_TRAIT))
		REMOVE_TRAIT(user, TRAIT_AI_UNTRACKABLE, PARADOX_CLONE_TRAIT)
		user.set_invisible(INVISIBILITY_MINIMUM)
		to_chat(user, "<span class='notice'>You've reconnected with this world...</span>")
	else
		ADD_TRAIT(user, TRAIT_AI_UNTRACKABLE, PARADOX_CLONE_TRAIT)
		to_chat(user, "<span class='notice'>The connection with this world has decreased. There's only interference from you on the cameras, and no machine will track you.</span>")
		user.set_invisible(SEE_INVISIBLE_LIVING)

	add_attack_logs(user, user, "(Paradox Clone) Digital Superseded")