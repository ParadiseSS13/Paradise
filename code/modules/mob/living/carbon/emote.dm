/datum/emote/living/carbon
	/// Types of species that are allowed to use the emote.
	var/list/species_allowed_typecache
	mob_type_allowed_typecache = list(/mob/living/carbon)

/datum/emote/living/carbon/New()
	. = ..()
	species_allowed_typecache = typecacheof(species_allowed_typecache)


/datum/emote/living/carbon/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna && is_type_in_typecache(H.dna.species, species_allowed_typecache))
			return TRUE


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
	emote_type = EMOTE_AUDIBLE
	audio_cooldown = 5 SECONDS
	vary = TRUE

/datum/emote/living/carbon/clap/get_sound(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H?.mind.miming)
			return
		if(!H.bodyparts_by_name[BODY_ZONE_L_ARM] || !H.bodyparts_by_name[BODY_ZONE_R_ARM])
			// we will never know the sound of one hand clapping...
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


/datum/emote/living/carbon/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs."
	message_param = "sighs at %t."
	muzzled_noises = list("dejected")

/datum/emote/living/carbon/sigh/happy
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs contentedly."
	muzzled_noises = list("chill", "relaxed")
	message_param = ""

/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t."
	mob_type_allowed_typecache = list(/mob/living/carbon/alien)
	hands_use_check = TRUE

/datum/emote/living/carbon/sign/select_param(mob/user, params)
	. = ..()
	if(!isnum(text2num(params)))
		return message

/datum/emote/living/carbon/sign/signal
	key = "signal"
	key_third_person = "signals"
	message_param = "raises %t fingers."
	param_desc = "number(0-10)"
	mob_type_allowed_typecache = list(/mob/living/carbon/human)
	hands_use_check = TRUE




