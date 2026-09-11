/datum/spell/big_voice
	name = "Speak with Authority"
	desc = "Speak with a COMMANDING AUTHORITY against those you govern."
	base_cooldown = 1 MINUTES
	action_background_icon_state = "bg_default"
	action_icon = 'icons/obj/clothing/accessories.dmi'
	action_icon_state = "gold"
	sound = null
	invocation = null
	clothes_req = FALSE

/datum/spell/big_voice/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/big_voice/cast(list/targets, mob/living/user)
	var/say_message = tgui_input_text(user, "Message:", "Speak With Authority", encode = FALSE)
	if(isnull(say_message))
		revert_cast()
	else
		if(user.big_voice != 2)
			user.big_voice = 1
			user.say(say_message)
			user.big_voice = 0
		else
			user.say(say_message)
			cooldown_handler.start_recharge()
