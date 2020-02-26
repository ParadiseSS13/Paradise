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
	desc = "Whispered words that all cultists can hear.<br><b>Warning:</b>Nearby non-cultists can still hear you."
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
		user.visible_message("<span class='notice'>[user] appears to whisper to themselves.</span>","<span class='notice'>You begin to whisper to yourself.</span>") //Make them do *something* abnormal.
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

/datum/action/innate/cult/comm/spirit
	name = "Spiritual Communion"
	desc = "Conveys a message from the spirit realm that all cultists can hear."

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

//Draw rune


/datum/action/innate/cult/use_dagger
	name = "Draw Blood Rune"
	desc = "Use the ritual dagger to create a powerful blood rune"
	button_icon_state = "cult_dagger"

/datum/action/innate/cult/use_dagger/Grant()
	if(SSticker.mode)
		button_icon_state = SSticker.cultdat.dagger_icon
	..()
	button.ordered = FALSE
	button.screen_loc = "6:157,4:-2"
	button.moved = "6:157,4:-2"

/datum/action/innate/cult/use_dagger/Activate()
	var/obj/item/I
	I = usr.get_active_hand()
	if(istype(I, /obj/item/melee/cultblade/dagger))
		I.attack_self(usr)
		return
	I = owner.get_inactive_hand()
	if(istype(I, /obj/item/melee/cultblade/dagger))
		I.attack_self(usr)
		return
	var/obj/item/melee/cultblade/dagger/D = locate() in usr
	if(!D)
		D = locate() in usr.get_item_by_slot(slot_back)
	if(!D)
		to_chat(usr, "<span class='cultitalic'>You do not seem to carry a ritual dagger to draw a rune with. If you need a new one, scribe and use the Summon Dagger spell.</span>")
		return FALSE
	usr.remove_from_mob(D)
	usr.put_in_hands(D)
	D.attack_self(usr)

/datum/action/item_action/cult_dagger
	name = "Draw Blood Rune"
	desc = "Use the ritual dagger to create a powerful blood rune"
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "draw"
	background_icon_state = "bg_cult"
	buttontooltipstyle = "cult"

/datum/action/item_action/cult_dagger/Grant(mob/M)
	if(iscultist(M))
		..()
		button.ordered = FALSE
		button.screen_loc = "6:157,4:-2"
		button.moved = "6:157,4:-2"
	else
		Remove(owner)

/datum/action/item_action/cult_dagger/Trigger()
	var/obj/item/I
	I = owner.get_active_hand()
	if(istype(I, /obj/item/melee/cultblade/dagger))
		I.attack_self(owner)
		return
	I = owner.get_inactive_hand()
	if(istype(I, /obj/item/melee/cultblade/dagger))
		I.attack_self(owner)
		return
	var/obj/item/T = target
	owner.remove_from_mob(T)
	owner.put_in_hands(T)
	T.attack_self(owner)