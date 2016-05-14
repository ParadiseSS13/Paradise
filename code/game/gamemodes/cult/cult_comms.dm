/datum/action/cultcomm
	name = "Communion"
	button_icon_state = "cult_comms"
	background_icon_state = "bg_cult"
	action_type = AB_INNATE
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING

/datum/action/cultcomm/IsAvailable()
	if(!iscultist(owner))
		return 0
	return ..()

/datum/action/cultcomm/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input || !IsAvailable())
		return

	cultist_commune(usr, input)
	return

/proc/cultist_commune(mob/living/user, message)
	if(!message)
		return
	if(!ishuman(user))
		user.say("O bidai nabora se[pick("'","`")]sma!")
	else
		user.whisper("O bidai nabora se[pick("'","`")]sma!")
	sleep(10)
	if(!user)
		return
	if(!ishuman(user))
		user.say(message)
	else
		user.whisper(message)
	var/my_message = "<span class='cultitalic'><b>[(ishuman(user) ? "Acolyte" : "Construct")] [user]:</b> [message]</span>"
	for(var/mob/M in mob_list)
		if(iscultist(M))
			to_chat(M, my_message)
		else if(M in dead_mob_list)
			to_chat(M, "<a href='?src=\ref[M];follow=\ref[user]'>(F)</a> [my_message]")

	log_say("[user.real_name]/[user.key] : [message]")