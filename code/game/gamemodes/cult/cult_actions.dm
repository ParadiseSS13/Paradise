/datum/action/innate/cult
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND
	buttontooltipstyle = "cult"

/datum/action/innate/cult/IsAvailable()
	if(!iscultist(owner))
		return FALSE
	return ..()


//Comms
/datum/action/innate/cult/comm
	name = "Communion"
	desc = "Whispered words that all cultists can hear.<br><b>Warning:</b>Nearby non-cultists can still hear you."
	button_icon_state = "cult_comms"
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/cult/comm/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input || !IsAvailable())
		return
	cultist_commune(usr, input)
	return

/datum/action/innate/cult/comm/proc/cultist_commune(mob/living/user, message)
	if(!user || !message)
		return
	if(!user.can_speak())
		to_chat(user, "<span class='warning'>You can't speak!</span>")
		return

	if((MUTE in user.mutations) || user.mind.miming) //Under vow of silence/mute?
		user.visible_message("<span class='notice'>[user] appears to whisper to themselves.</span>",
		"<span class='notice'>You begin to whisper to yourself.</span>") //Make them do *something* abnormal.
		sleep(10)
	else
		user.whisper("O bidai nabora se[pick("'","`")]sma!") // Otherwise book club sayings.
		sleep(10)
		user.whisper(message) // And whisper the actual message

	var/my_message
	if(istype(user, /mob/living/simple_animal/slaughter/cult)) //Harbringers of the Slaughter
		my_message = "<span class='cultlarge'><b>Harbringer of the Slaughter:</b> [message]</span>"
	else
		my_message = "<span class='cultspeech'><b>[(isconstruct(user) ? "Construct" : isshade(user) ? "" : "Acolyte")] [user.real_name]:</b> [message]</span>"
	for(var/mob/M in GLOB.player_list)
		if(iscultist(M))
			to_chat(M, my_message)
		else if((M in GLOB.dead_mob_list) && !isnewplayer(M))
			to_chat(M, "<span class='cultspeech'> <a href='?src=[M.UID()];follow=[user.UID()]'>(F)</a> [my_message] </span>")

	add_say_logs(user, message, language = "CULT")

/datum/action/innate/cult/comm/spirit
	name = "Spiritual Communion"
	desc = "Conveys a message from the spirit realm that all cultists can hear."

/datum/action/innate/cult/comm/spirit/IsAvailable()
	return TRUE

/datum/action/innate/cult/comm/spirit/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	my_message = "<span class='cultlarge'>The [user.name]: [message]</span>"
	for(var/mob/M in GLOB.player_list)
		if(iscultist(M))
			to_chat(M, my_message)
		else if((M in GLOB.dead_mob_list) && !isnewplayer(M))
			to_chat(M, "<span class='cultspeech'> <a href='?src=[M.UID()];follow=[user.UID()]'>(F)</a> [my_message] </span>")


//Objectives
/datum/action/innate/cult/check_progress
	name = "Study the Veil"
	button_icon_state = "tome"
	desc = "Check your cult's current progress and objective."
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/cult/check_progress/New()
	if(SSticker.mode)
		button_icon_state = SSticker.cultdat.tome_icon
	..()

/datum/action/innate/cult/check_progress/IsAvailable()
	if(iscultist(owner) || isobserver(owner))
		return TRUE
	return FALSE

/datum/action/innate/cult/check_progress/Activate()
	if(!IsAvailable())
		return
	if(SSticker && SSticker.mode)
		SSticker.mode.cult_objs.study(usr, TRUE)
	else
		to_chat(usr, "<span class='cultitalic'>You fail to study the Veil. (This should never happen, adminhelp and/or yell at a coder)</span>")


//Draw rune
/datum/action/innate/cult/use_dagger
	name = "Draw Blood Rune"
	desc = "Use the ritual dagger to create a powerful blood rune"
	button_icon_state = "blood_dagger"

/datum/action/innate/cult/use_dagger/Grant()
	if(SSticker.mode)
		button_icon_state = SSticker.cultdat.dagger_icon
	..()

/datum/action/innate/cult/use_dagger/override_location()
	button.ordered = FALSE
	button.screen_loc = "6:157,4:-2"
	button.moved = "6:157,4:-2"

/datum/action/innate/cult/use_dagger/Activate()
	var/obj/item/melee/cultblade/dagger/D = owner.find_item(/obj/item/melee/cultblade/dagger)
	if(D)
		owner.remove_from_mob(D)
		owner.put_in_hands(D)
		D.attack_self(owner)
	else
		to_chat(usr, "<span class='cultitalic'>You do not seem to carry a ritual dagger to draw a rune with. If you need a new one, prepare and use the Summon Dagger spell.</span>")
