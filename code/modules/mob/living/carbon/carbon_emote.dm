/datum/emote/living/carbon
	mob_type_allowed_typecache = list(/mob/living/carbon)

/datum/emote/living/carbon/blink
	key = "blink"
	key_third_person = "blinks"
	message = "моргает."

/datum/emote/living/carbon/blink_r
	key = "blink_r"
	message = "быстро моргает."

/datum/emote/living/carbon/cross
	key = "cross"
	key_third_person = "crosses"
	message = "скрещивает руки."
	hands_use_check = TRUE

/datum/emote/living/carbon/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "усмехается."
	message_mime = "беззвучно усмехается."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	muzzled_noises = list("радостный", "оптимистичный")

/datum/emote/living/carbon/cough
	key = "cough"
	key_third_person = "coughs"
	message = "кашляет!"
	message_mime = "бесшумно кашляет!"
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	vary = TRUE
	age_based = TRUE
	volume = 120
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/carbon/cough/get_sound(mob/living/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.gender == FEMALE)
			if(H.dna.species.female_cough_sounds)
				return pick(H.dna.species.female_cough_sounds)
		else
			if(H.dna.species.male_cough_sounds)
				return pick(H.dna.species.male_cough_sounds)

/datum/emote/living/carbon/moan
	key = "moan"
	key_third_person = "moans"
	message = "стонет!"
	message_mime = "как будто стонет!"
	muzzled_noises = list("страдальческий")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/carbon/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "хихикает."
	message_mime = "бесшумно хихикает!"
	muzzled_noises = list("шипучий")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/gurgle
	key = "gurgle"
	key_third_person = "gurgles"
	message = "издает неприятное булькание."
	muzzled_noises = list("недовольный", "гортанный")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/carbon/inhale
	key = "inhale"
	key_third_person = "inhales"
	message = "вдыхает."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	muzzled_noises = list("хриплый")

/datum/emote/living/carbon/inhale/sharp
	key = "inhale_s"
	key_third_person = "inhales sharply!"
	message = "делает глубокий вдох!"

/datum/emote/living/carbon/kiss
	key = "kiss"
	key_third_person = "kisses"
	message = "посылает воздушный поцелуй."
	message_param = "посылает воздушный поцелуй %t!"
	muzzled_noises = list("чмокающий")

/datum/emote/living/carbon/wave
	key = "wave"
	key_third_person = "waves"
	message = "машет."
	message_param = "машет %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "зевает."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	muzzled_noises = list("усталый", "ленивый", "сонный")

/datum/emote/living/carbon/exhale
	key = "exhale"
	key_third_person = "exhales"
	message = "выдыхает."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "смеётся."
	message_mime = "бесшумно смеётся!"
	message_param = "смеется над %t."
	muzzled_noises = list("счастливый", "веселый")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/scowl
	key = "scowl"
	key_third_person = "scowls"
	message = "хмурится."

/datum/emote/living/groan
	key = "groan"
	key_third_person = "groans"
	message = "болезненно вздыхает!"
	message_mime = "как будто болезненно вздыхает!"
	message_param = "болезненно вздыхает на %t."
	muzzled_noises = list("страдальческий")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message = "показывает число."
	message_param = "показывает число: %t."
	param_desc = "number(0-10)"
	// Humans get their own proc since they have fingers
	mob_type_blacklist_typecache = list(/mob/living/carbon/human)
	hands_use_check = TRUE
	target_behavior = EMOTE_TARGET_BHVR_NUM

/datum/emote/living/carbon/faint
	key = "faint"
	key_third_person = "faints"
	message = "теряет сознание."

/datum/emote/living/carbon/faint/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.Paralyse(2 SECONDS)

/datum/emote/living/carbon/twirl
	key = "twirl"
	key_third_person = "twirls"
	message = "вертит что-то в руке."
	hands_use_check = TRUE

/datum/emote/living/carbon/twirl/run_emote(mob/user, params, type_override, intentional)

	if(!(user.get_active_hand() || user.get_inactive_hand()))
		to_chat(user, "<span class='warning'>Вы должны держать что-то в руках, чтобы использовать эту эмоцию!</span>")
		return TRUE

	var/obj/item/thing

	if(user.get_active_hand())
		thing = user.get_active_hand()
	else
		thing = user.get_inactive_hand()

	if(istype(thing, /obj/item/grab))
		var/obj/item/grab/grabbed = thing
		message = "вертит [grabbed.affecting.name] туда-сюда!"
		grabbed.affecting.emote("spin")
	else if(!(thing.flags & ABSTRACT))
		message = "вертит [thing] в руке!"
	else
		to_chat(user, "<span class='warning'>У вас не получится повертеть [thing]!</span>")
		return TRUE

	. = ..()
	message = initial(message)
