/datum/emote/living/carbon
	mob_type_allowed_typecache = list(/mob/living/carbon)
	mob_type_blacklist_typecache = list(/mob/living/carbon/brain)

/datum/emote/living/carbon/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks."

/datum/emote/living/carbon/blink_r
	key = "blink_r"
	message = "blinks rapidly."

/datum/emote/living/carbon/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps."
	message_mime = "claps silently."
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	emote_type = EMOTE_SOUND
	audio_cooldown = 5 SECONDS
	vary = TRUE

/datum/emote/living/carbon/clap/run_emote(mob/user, params, type_override, intentional)

	if(!can_run_emote(user))
		return FALSE

	var/mob/living/carbon/human/H = user

	if(!H.bodyparts_by_name[BODY_ZONE_L_ARM] || !H.bodyparts_by_name[BODY_ZONE_R_ARM])
		if(!H.bodyparts_by_name[BODY_ZONE_L_ARM] && !H.bodyparts_by_name[BODY_ZONE_R_ARM])
			// no arms...
			to_chat(user, "<span class='warning'>You need arms to be able to clap.</span>")
		else
			// well, we've got at least one
			user.visible_message("[user] makes the sound of one hand clapping.")
		return TRUE

	. = ..()

/datum/emote/living/carbon/clap/get_sound(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H?.mind.miming)
			return
		else
			return pick('sound/misc/clap1.ogg',
						'sound/misc/clap2.ogg',
						'sound/misc/clap3.ogg',
						'sound/misc/clap4.ogg')

/datum/emote/living/carbon/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans!"
	message_mime = "appears to moan!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "giggles."
	message_mime = "giggles silently!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/gurgle
	key = "gurgle"
	key_third_person = "gurgles"
	message = "makes an uncomfortable gurgle."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/inhale
	key = "inhale"
	key_third_person = "inhales"
	message = "breathes in."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/inhale/sharp
	key = "inhale_s"
	key_third_person = "inhales sharply!"
	message = "takes a deep breath!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/kiss
	key = "kiss"
	key_third_person = "kisses"
	message = "blows a kiss."
	message_param = "blows a kiss at %t!"

/datum/emote/living/carbon/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves."
	message_param = "waves at %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/exhale
	key = "exhale"
	key_third_person = "exhales"
	message = "breathes out."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs."
	message_mime = "laughs silently!"
	message_param = "laughs at %t."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/scowl
	key = "scowl"
	key_third_person = "scowls"
	message = "scowls."

/datum/emote/living/groan
	key = "groan"
	key_third_person = "groans"
	message = "groans!"
	message_mime = "appears to groan!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs."
	message_param = "sighs at %t."
	muzzled_noises = list("dejected")
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/sigh/happy
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs contentedly."
	muzzled_noises = list("chill", "relaxed")
	message_param = "sighs contentedly at %t."

/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message = "signs."
	message_param = "signs the number %t."
	// Humans get their own proc since they have fingers
	mob_type_blacklist_typecache = list(/mob/living/carbon/human)
	hands_use_check = TRUE

/datum/emote/living/carbon/sign/select_param(mob/user, params)
	. = ..()
	if(!isnum(text2num(params)))
		return message

/datum/emote/living/carbon/faint
	key = "faint"
	key_third_person = "faints"
	message = "faints."

/datum/emote/living/carbon/faint/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.SetSleeping(2)


