/datum/emote/robot/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes"
	message_param = "salutes to %t"

/datum/emote/robot/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps"

/datum/emote/robot/law
	key = "law"
	key_third_person = "laws"
	cooldown = 20
	sound = 'sound/voice/biamthelaw.ogg'
	message = "shows their legal authorization barcode"
	emote_type = EMOTE_AUDIBLE

/datum/emote/robot/halt
	key = "halt"
	key_third_person = "halts"
	cooldown = 20
	sound = 'sound/voice/halt.ogg'
	message = "'s speakers screech, \"Halt! Security!\""
	emote_type = EMOTE_AUDIBLE

/datum/emote/robot/halt/can_run_emote(mob/living/silicon/robot/user, status_check = TRUE)
	if(!..())
		return FALSE
	if(!istype(user.module, /obj/item/robot_module/security))
		unusable_message(user, status_check, "<span class='notice'>You are not security.</span>")
		return FALSE
	return TRUE

/datum/emote/robot/powerwarn
	key = "powerwarn"
	key_third_person = "powerwarns"
	cooldown = 50
	sound = 'sound/machines/buzz-two.ogg'
	emote_type = EMOTE_AUDIBLE
	stat_allowed = DEAD

/datum/emote/robot/powerwarn/can_run_emote(mob/living/silicon/robot/user, status_check = TRUE)
	if(!..())
		return FALSE
	if(user.is_component_functioning("power cell") && user.cell && user.cell.charge)
		unusable_message(user, status_check, "<span class='warning'>You can only use this emote when you're out of charge.</span>")
		return FALSE
	return TRUE

/datum/emote/robot/powerwarn/create_emote_message(mob/user, params)
	to_chat(user, "You announce you are operating in low power mode.")
	return "The power warning light on <span class='name'>[user]</span> flashes urgently."

/mob/living/silicon/robot/verb/powerwarn()
	set category = "Robot Commands"
	set name = "Power Warning"

	emote("powerwarn")
