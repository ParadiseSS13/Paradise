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
