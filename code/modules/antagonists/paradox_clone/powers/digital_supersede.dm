/datum/spell/paradox_spell/self/digital_supersede
	name = "Digital Supersede"
	desc = "With the help of the paradox, you cloak yourself from any camera feeds, leaving only interference in your place..."
	action_icon_state = "digital_supersede"
	base_cooldown = 1 SECONDS

/datum/spell/paradox_spell/self/digital_supersede/cast(list/targets, mob/user = usr)
	if(HAS_TRAIT_FROM(user, TRAIT_AI_UNTRACKABLE, PARADOX_CLONE_TRAIT))
		REMOVE_TRAIT(user, TRAIT_AI_UNTRACKABLE, PARADOX_CLONE_TRAIT)
		user.set_invisible(INVISIBILITY_MINIMUM)
		to_chat(user, "<span class='notice'>You've become more connected with this world, making you slightly more visible to machines.</span>")
	else
		ADD_TRAIT(user, TRAIT_AI_UNTRACKABLE, PARADOX_CLONE_TRAIT)
		to_chat(user, "<span class='notice'>The connection with this world has decreased. You're nothing but a bit of noise on cameras, and no machine will track you.</span>")
		user.set_invisible(SEE_INVISIBLE_LIVING)

	add_attack_logs(user, user, "(Paradox Clone) Digital Superseded")
