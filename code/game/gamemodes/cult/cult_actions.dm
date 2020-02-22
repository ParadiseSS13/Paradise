/datum/action/innate/cult
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	buttontooltipstyle = "cult"

/datum/action/innate/cult/IsAvailable()
	if(!iscultist(owner))
		return FALSE
	return ..()

//Comms

/datum/action/innate/cult/comm
	name = "Communion"
	button_icon_state = "cult_comms"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/cult/comm/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input || !IsAvailable())
		return

	cultist_commune(usr, input)
	return

/proc/cultist_commune(mob/living/user, message)
	if(!message)
		return

	if((user.disabilities & MUTE) || user.mind.miming) //Under vow of silence/mute?
		user.visible_message("[user] appears to whisper to themselves.","You begin to whisper to yourself.") //Make them do *something* abnormal.
	else
		user.whisper("O bidai nabora se[pick("'","`")]sma!") // Otherwise book club sayings.
	sleep(10)

	if(!user)
		return

	if(!((user.disabilities & MUTE) || user.mind.miming)) // If they aren't mute/miming, commence the whisperting
		user.whisper(message)
	var/my_message
	if(istype(user, /mob/living/simple_animal/slaughter/cult)) //Harbringers of the Slaughter
		my_message = "<span class='cultlarge'><b>Harbringer of the Slaughter:</b> [message]</span>"
	else
		my_message = "<span class='cultspeech'><b>[(ishuman(user) ? "Acolyte" : "Construct")] [user.real_name]:</b> [message]</span>"
	for(var/mob/M in GLOB.player_list)
		if(iscultist(M))
			to_chat(M, my_message)
		else if((M in GLOB.dead_mob_list) && !isnewplayer(M))
			to_chat(M, "<span class='cultspeech'> <a href='?src=[M.UID()];follow=[user.UID()]'>(F)</a> [my_message] </span>")

	log_say("(CULT) [message]", user)


//Objectives

/datum/action/innate/cult/check_progress
	name = "Study the Veil"
	button_icon_state = "cult_mark"
	desc = "Check your cult's current progress and objective."
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/cult/check_progress/Activate()
	if(!IsAvailable())
		return

	if(SSticker && SSticker.mode)
		SSticker.mode.cult_objs.study(usr)
	else
		to_chat(usr, "<span class='cultitalic'>You fail to study the Veil. (This should never happen, adminhelp and/or yell at a coder)</span>")
