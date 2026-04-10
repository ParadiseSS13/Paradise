/obj/item/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	inhand_icon_state = "radio"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT

	/// How long to wait when using it as normal
	var/normal_cooldown = 2 SECONDS
	/// How long to wait between insults
	var/modified_cooldown = 20 SECONDS
	/// If it's on cooldown.
	var/on_cooldown = FALSE
	/// Span to use by default for the message.
	var/span = "reallybig"
	/// List of insults to be sent when the megaphone is cmagged.
	var/list/insultmsg = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")

/obj/item/megaphone/suicide_act(mob/user)
	user.visible_message(SPAN_SUICIDE("[user] is uttering [user.p_their()] last words into [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	on_cooldown = FALSE
	user.emote("scream")
	say_msg(user, "AAAAAAAAAAAARGHHHHH")
	return OXYLOSS

/obj/item/megaphone/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		. += SPAN_WARNING("Yellow ooze seems to be seeping from the speaker...")

/obj/item/megaphone/attack_self__legacy__attackchain(mob/living/user)
	if(check_mute(user.ckey, MUTE_IC))
		to_chat(src, SPAN_WARNING("You cannot speak in IC (muted)."))
		return
	if(!ishuman(user))
		to_chat(user, SPAN_WARNING("You don't know how to use this!"))
		return
	if(!user.can_speak())
		to_chat(user, SPAN_WARNING("You find yourself unable to speak at all."))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/abductor/H = user
		if(isabductor(H))
			to_chat(user, SPAN_WARNING("Megaphones can't project psionic communication!"))
			return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H && H.mind && H.mind.miming)
			to_chat(user, SPAN_WARNING("Your vow of silence prevents you from speaking."))
			return
		if(HAS_TRAIT(H, TRAIT_COMIC_SANS))
			span = "sans"
	if(on_cooldown)
		to_chat(user, SPAN_WARNING("[src] needs to recharge!"))
		return

	var/message = tgui_input_text(user, "Shout a message:", "Megaphone")
	if(!message)
		return
	message = capitalize(message)
	var/list/message_pieces = message_to_multilingual(message)
	user.handle_speech_problems(message_pieces)
	message = multilingual_to_message(message_pieces)
	if((loc == user && !user.incapacitated()))
		if(HAS_TRAIT(src, TRAIT_CMAGGED))
			message = pick(insultmsg)
		say_msg(user, message)

		on_cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, on_cooldown, FALSE), (HAS_TRAIT(src, TRAIT_CMAGGED) || emagged) ? modified_cooldown : normal_cooldown)

/obj/item/megaphone/proc/say_msg(mob/living/user, message)
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		playsound(src, "sound/items/bikehorn.ogg", 50, TRUE)
	else
		playsound(src, "sound/items/megaphone.ogg", 100, FALSE, 5)

	audible_message("<span class='game say'>[SPAN_NAME("[user.GetVoice()]")] [user.GetAltName()] broadcasts, <span class='[span]'>\"[message]\"</span></span>", hearing_distance = 14)
	log_say("(MEGAPHONE) [message]", user)
	user.create_log(SAY_LOG, "(megaphone) '[message]'")
	for(var/obj/O in view(14, get_turf(src)))
		O.hear_talk(user, message_to_multilingual("<span class='[span]'>[message]</span>"))

	for(var/mob/M as anything in get_mobs_in_view(7, src, ai_eyes = AI_EYE_REQUIRE_HEAR))
		if((M.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) && M.can_hear())
			M.create_chat_message(user, message, FALSE, "big")

/obj/item/megaphone/cmag_act(mob/user)
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		return FALSE
	if(user)
		to_chat(user, SPAN_WARNING("You drip some yellow ooze into [src]'s voice synthesizer, gunking it up."))
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
	return TRUE

/obj/item/megaphone/emag_act(mob/user)
	if(emagged)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_CMAGGED))  // one at a time
		to_chat(user, SPAN_WARNING("You go to short out [src], but it's covered in yellow ooze! You don't want to gunk up your emag!"))
		return FALSE
	to_chat(user, SPAN_DANGER("You short out [src]'s dampener circuits."))
	emagged = TRUE
	span = "reallybig userdanger"  // really obvious, but also really loud
	return TRUE

