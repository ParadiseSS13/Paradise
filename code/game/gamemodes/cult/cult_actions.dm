/datum/action/innate/cult
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	buttontooltipstyle = "cult"

/datum/action/innate/cult/IsAvailable(show_message = TRUE)
	if(!IS_CULTIST(owner))
		return FALSE
	return ..()


//Comms
/datum/action/innate/cult/comm
	name = "Communion"
	desc = "Whispered words that all cultists can hear.<br><b>Warning:</b>Nearby non-cultists can still hear you."
	button_icon_state = "cult_comms"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/cult/comm/Activate()
	var/input = tgui_input_text(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", encode = FALSE)
	if(!input || !IsAvailable())
		return
	cultist_commune(usr, input)
	return

/datum/action/innate/cult/comm/proc/cultist_commune(mob/living/user, message)
	if(!user || !message)
		return

	if(user.holy_check())
		return

	if(!user.can_speak())
		to_chat(user, "<span class='warning'>You can't speak!</span>")
		return

	if(HAS_TRAIT(user, TRAIT_MUTE) || user.mind.miming) //Under vow of silence/mute?
		user.visible_message("<span class='notice'>[user] appears to whisper to themselves.</span>",
		"<span class='notice'>You begin to whisper to yourself.</span>") //Make them do *something* abnormal.
		sleep(10)
	else
		user.whisper("O bidai nabora se[pick("'","`")]sma!") // Otherwise book club sayings.
		sleep(10)
		user.whisper(message) // And whisper the actual message

	var/title
	var/large = FALSE
	var/living_message
	if(istype(user, /mob/living/simple_animal/demon/slaughter/cult)) //Harbringers of the Slaughter
		title = "<b>Harbringer of the Slaughter</b>"
		large = TRUE
	else
		title = "<b>[(isconstruct(user) ? "Construct" : isshade(user) ? "" : "Acolyte")] [user.real_name]</b>"

	living_message = "<span class='cult[(large ? "large" : "speech")]'>[title]: [message]</span>"
	for(var/mob/M in GLOB.player_list)
		if(IS_CULTIST(M))
			to_chat(M, living_message)
		else if((M in GLOB.dead_mob_list) && !isnewplayer(M))
			to_chat(M, "<span class='cult[(large ? "large" : "speech")]'>[title] ([ghost_follow_link(user, ghost=M)]): [message]</span>")

	log_say("(CULT) [message]", user)

/datum/action/innate/cult/comm/spirit
	name = "Spiritual Communion"
	desc = "Conveys a message from the spirit realm that all cultists can hear."

/datum/action/innate/cult/comm/spirit/IsAvailable(show_message = TRUE)
	return TRUE

/datum/action/innate/cult/comm/spirit/cultist_commune(mob/living/user, message)

	var/living_message
	if(!message)
		return
	var/title = "The [user.name]"
	living_message = "<span class='cultlarge'>[title]: [message]</span>"

	for(var/mob/M in GLOB.player_list)
		if(IS_CULTIST(M))
			to_chat(M, living_message)
		else if((M in GLOB.dead_mob_list) && !isnewplayer(M))
			to_chat(M, "<span class='cultlarge'>[title] ([ghost_follow_link(user, ghost=M)]): [message]</span>")


//Objectives
/datum/action/innate/cult/check_progress
	name = "Study the Veil"
	button_icon_state = "tome"
	desc = "Check your cult's current progress and objective."
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/cult/check_progress/New()
	button_icon_state = GET_CULT_DATA(tome_icon, "tome")
	..()

/datum/action/innate/cult/check_progress/IsAvailable(show_message = TRUE)
	return IS_CULTIST(owner) || isobserver(owner)

/datum/action/innate/cult/check_progress/Activate()
	if(!IsAvailable())
		return
	if(SSticker?.mode?.cult_team)
		SSticker.mode.cult_team.study_objectives(usr, TRUE)
	else
		to_chat(usr, "<span class='cultitalic'>You fail to study the Veil. (This should never happen, adminhelp and/or yell at a coder)</span>")


//Draw rune
/datum/action/innate/cult/use_dagger
	name = "Draw Blood Rune"
	desc = "Use the ritual dagger to create a powerful blood rune."
	button_icon_state = "blood_dagger"
	default_button_position = "10:29,4:-2"

/datum/action/innate/cult/use_dagger/Grant()
	button_icon_state = GET_CULT_DATA(dagger_icon, "blood_dagger")
	..()

/datum/action/innate/cult/use_dagger/Activate()
	var/obj/item/melee/cultblade/dagger/D = owner.find_item(/obj/item/melee/cultblade/dagger)
	if(D)
		owner.unequip(D)
		owner.put_in_hands(D)
		D.activate_self(owner)
	else
		to_chat(usr, "<span class='cultitalic'>You do not seem to carry a ritual dagger to draw a rune with. If you need a new one, prepare and use the Summon Dagger spell.</span>")
