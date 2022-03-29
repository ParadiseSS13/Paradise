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
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE
	audio_cooldown = 5 SECONDS
	vary = TRUE

/datum/emote/living/carbon/clap/get_sound(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
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


/datum/emote/living/carbon/slap
	key = "slap"
	key_third_person = "slaps"
	hands_use_check = TRUE
	cooldown = 3 SECONDS // to prevent endless table slamming

/datum/emote/living/carbon/slap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/obj/item/slapper/N  = new(user)
	if(user.put_in_hands(N))
		to_chat(user, "<span class='notice'>You ready your slapping hand.</span>")
	else
		qdel(N)
		to_chat(user, "<span class='warning'>You're incapable of slapping in your current state.</span>")

/datum/emote/living/carbon/wink
	key = "wink"
	key_third_person = "winks"
	message = "winks."

/datum/emote/living/carbon/highfive
	key = "highfive"
	key_third_person = "highfives"
	message = "requests a highfive."
	hands_use_check = TRUE
	cooldown = 3 SECONDS

/datum/emote/living/carbon/highfive/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	var/mob/living/carbon/user_carbon = user
	if(user_carbon.restrained())
		return FALSE

/datum/emote/living/carbon/highfive/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/user_carbon = user
	if(!can_run_emote(user))
		return FALSE
	if(user_carbon.has_status_effect(STATUS_EFFECT_HIGHFIVE))
		user.visible_message("[src] drops his raised hand, frowning.", "You were left hanging...")
		user_carbon.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
		return
	message = "requests a highfive."
	user_carbon.apply_status_effect(STATUS_EFFECT_HIGHFIVE)
	for(var/mob/living/L in orange(1))
		if(L.has_status_effect(STATUS_EFFECT_HIGHFIVE))
			if((user_carbon.mind && user_carbon.mind.special_role == SPECIAL_ROLE_WIZARD) && (L.mind && L.mind.special_role == SPECIAL_ROLE_WIZARD))
				user.visible_message("<span class='danger'><b>[name]</b> and <b>[L.name]</b> high-five EPICALLY!</span>")
				user_carbon.status_flags |= (GODMODE)
				L.status_flags |= GODMODE
				explosion(user.loc,5,2,1,3)
				user_carbon.status_flags &= ~GODMODE
				L.status_flags &= ~GODMODE
				return
			user.visible_message("<b>[name]</b> and <b>[L.name]</b> high-five!")
			playsound('sound/effects/snap.ogg', 50)
			user_carbon.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
			L.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
			return
	. = ..()

