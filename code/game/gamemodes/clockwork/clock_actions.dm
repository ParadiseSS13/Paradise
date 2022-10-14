/datum/action/innate/clockwork
	icon_icon = 'icons/mob/actions/actions_clockwork.dmi'
	background_icon_state = "bg_clockwork"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND
	// buttontooltipstyle = "cult"

/datum/action/innate/clockwork/IsAvailable()
	if(!isclocker(owner))
		return FALSE
	return ..()

//Comms
/datum/action/innate/clockwork/comm
	name = "Hierophant's Network"
	desc = "Whispered words that all clockers can hear.<br><b>Warning:</b>Nearby non-clockers can still hear you."
	button_icon_state = "hierophant"
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/clockwork/comm/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other workmates.", "Voice of Clockwork", "")
	if(!input || !IsAvailable())
		return
	clockwork_commune(usr, input)
	return

/datum/action/innate/clockwork/comm/proc/clockwork_commune(mob/living/user, message)
	if(!user || !message)
		return

	var/prefix = ""
	if((MUTE in user.mutations) || user.mind.miming) //Under vow of silence/mute?
		user.visible_message("<span class='notice'>[user] appears to whisper to themselves.</span>",
		"<span class='notice'>You begin to whisper to yourself.</span>") //Make them do *something* abnormal.
		sleep(10)
	else if(!issilicon(user))
		user.whisper("N`i th`e le-ing roc-cus!") // Otherwise book club sayings.
		sleep(10)
		user.whisper(message) // And whisper the actual message
		prefix = "Workmate"
	else
		prefix = "Automaton"


	var/my_message = "<span class='clockspeech'><b>[prefix] [user.real_name]:</b> [message]</span>"
	for(var/mob/M in GLOB.player_list)
		if(isclocker(M))
			to_chat(M, my_message)
		else if((M in GLOB.dead_mob_list) && !isnewplayer(M))
			to_chat(M, "<span class='clockspeech'> <a href='?src=[M.UID()];follow=[user.UID()]'>(F)</a> [my_message] </span>")

	add_say_logs(user, message, language = "CLOCKCULT")

//Objectives
/datum/action/innate/clockwork/check_progress
	name = "Study the Veil"
	button_icon_state = "tome"
	desc = "Check your cult's current progress and objective."
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/clockwork/check_progress/IsAvailable()
	if(isclocker(owner) || isobserver(owner))
		return TRUE
	return FALSE

/datum/action/innate/clockwork/check_progress/Activate()
	if(!IsAvailable())
		return
	if(SSticker?.mode)
		SSticker.mode.clocker_objs.study(usr, TRUE)
	else
		to_chat(usr, "<span class='clockitalic'>You fail to study the Veil. (This should never happen, adminhelp and/or yell at a coder)</span>")
