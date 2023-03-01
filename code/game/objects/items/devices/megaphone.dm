/obj/item/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	item_state = "radio"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0
	var/span = ""
	var/list/insultmsg = list("ИДИТЕ НАХУЙ!", "Я АГЕНТ СИНДИКАТА!", "СБ, ЗАСТРЕЛИТЕ МЕНЯ НЕМЕДЛЕННО!", "У МЕНЯ БОМБА!", "КАПИТАН ГАНДОН!", "ЗА СИНДИКАТ!")

/obj/item/megaphone/attack_self(mob/living/user as mob)
	if(user.client && (user.client.prefs.muted & MUTE_IC))
		to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
		return
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You don't know how to use this!</span>")
		return
	if(!user.can_speak())
		to_chat(user, "<span class='warning'>You find yourself unable to speak at all.</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/abductor/H = user
		if(isabductor(H))
			to_chat(user, "<span class='warning'>Megaphones can't project psionic communication!</span>")
			return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H && H.mind && H.mind.miming)
			to_chat(user, "<span class='warning'>Your vow of silence prevents you from speaking.</span>")
			return
		if((COMIC in H.mutations) || H.get_int_organ(/obj/item/organ/internal/cyberimp/brain/clown_voice))
			span = "sans"
	if(spamcheck)
		to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
		return

	var/message = input(user, "Shout a message:", "Megaphone") as text|null
	if(!message)
		return
	message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
	if(!message)
		return
	message = capitalize(message)
	var/list/message_pieces = message_to_multilingual(message)
	user.handle_speech_problems(message_pieces)
	message = multilingual_to_message(message_pieces)
	if((loc == user && !user.incapacitated()))
		if(emagged)
			if(insults)
				saymsg(user, pick(insultmsg))
				insults--
			else
				to_chat(user, "<span class='warning'>*BZZZZzzzzzt*</span>")
		else
			if(span)
				message = "<span class='[span]'>[message]</span>"
			saymsg(user, message)

		spamcheck = 1
		spawn(20)
			spamcheck = 0

/obj/item/megaphone/proc/saymsg(mob/living/user as mob, message)
	add_say_logs(user, message, language = "Megaphone")
	var/message_tts = message
	message = replace_characters(message, list("+"))
	audible_message("<span class='game say'><span class='name'>[user.GetVoice()]</span> [user.GetAltName()] broadcasts, <span class='reallybig'>\"[message]\"</span></span>", hearing_distance = 14)
	for(var/obj/O in range(14, get_turf(src)))
		O.hear_talk(user, message_to_multilingual("<span class='reallybig'>[message]</span>"))

	for(var/mob/M in get_mobs_in_view(7, src))
		if((M.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) && M.can_hear() && M.stat != UNCONSCIOUS)
			M.create_chat_message(user, message, FALSE, FALSE)
		var/effect = SOUND_EFFECT_MEGAPHONE
		if(isrobot(user))
			effect = SOUND_EFFECT_MEGAPHONE_ROBOT
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, user, M, message_tts, user.tts_seed, FALSE, effect)
		log_debug("megaphone.saymsg(): [message]")

/obj/item/megaphone/emag_act(user as mob)
	if(!emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
