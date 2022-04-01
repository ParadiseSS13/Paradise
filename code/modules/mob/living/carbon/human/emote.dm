/datum/emote/living/carbon/human
	/// Custom messages that should be applied based on species
	/// Should be an associative list of species name: message
	var/species_custom_messages = list()
	/// Whether or not the mob should gasp instead of emoting.
	var/needs_breath = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/select_message_type(mob/user, msg, intentional)
	. = ..()

	if(!species_custom_messages)
		return .

	var/custom_message = species_custom_messages[user.dna.species?.name]
	if(custom_message)
		return custom_message

/datum/emote/living/carbon/human/run_emote(mob/user, params, type_override, intentional)
	if(!can_run_emote(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(needs_breath && !H.mind?.miming)
		if(H.getOxyLoss() > 35)		// no screaming if you don't have enough breath to scream
			H.emote("gasp")
			return FALSE
	. = ..()

/datum/emote/living/carbon/human/airguitar
	key = "airguitar"
	message = "is strumming the air and headbanging like a safari chimp."
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "give daps to %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles!"
	message_mime = "seems to grumble!"
	emote_type = EMOTE_AUDIBLE
	needs_breath = TRUE

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hands."
	message_param = "shakes hands with %t."
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself."
	message_param = "hugs %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles!"
	message_mime = "seems to be speaking sweet nothings!"
	emote_type = EMOTE_AUDIBLE
	needs_breath = TRUE

/datum/emote/living/carbon/human/nod
	key = "nod"
	key_third_person = "nod"
	message = "nods their head."
	message_param = "nods their head at %t."

/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	message_mime = "acts out a scream!"
	emote_type = EMOTE_SOUND
	only_forced_audio = FALSE
	vary = TRUE
	age_based = TRUE
	cooldown = 5 SECONDS
	needs_breath = TRUE

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	if(human.mind?.miming)
		return
	if(human.gender == FEMALE)
		return human.dna.species.female_scream_sound
	else
		return human.dna.species.male_scream_sound

/datum/emote/living/carbon/human/scream/screech //If a human tries to screech it'll just scream.
	key = "screech"
	key_third_person = "screeches"
	message = "screeches."
	emote_type = EMOTE_SOUND
	vary = FALSE
	needs_breath = TRUE

/datum/emote/living/carbon/human/scream/screech/should_play_sound(mob/user, intentional)
	if(ismonkeybasic(user))
		return TRUE
	return ..()

/datum/emote/living/carbon/human/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps!"
	message_mime = "appears to be gasping!"
	emote_type = EMOTE_SOUND
	age_based = TRUE

/datum/emote/living/carbon/human/gasp/get_sound(mob/user)

	var/mob/living/carbon/human/H = user

	if(H.health > 0)
		return H.dna.species.gasp_sound

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_dying_gasp_sounds)
	else
		return pick(H.dna.species.male_dying_gasp_sounds)

/datum/emote/living/carbon/human/shake
	key = "shake"
	key_third_person = "shakes"
	message = "shakes their head."
	message_param = "shakes their head at %t."
/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second."

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs."

/datum/emote/living/carbon/human/sniff
	key = "sniff"
	key_third_person = "sniff"
	message = "sniffs."
	needs_breath = TRUE

/datum/emote/living/carbon/human/johnny
	key = "johnny"
	key_third_person = "johnnys"  // ?????
	message = "takes a drag from a cigarette and blows their own name out in smoke."

/datum/emote/living/carbon/human/johnny/select_param(mob/user, params)
	if(!params)
		return
	var/target = params
	var/msg
	for(var/mob/A in oview(5, user))
		if(target == A.name)
			if(user.mind?.miming)
				msg = "takes a drag from a cigarette and blows \"[A.name]\" out in smoke."
			else
				msg = "says, \"[A.name], please. They had a family.\" [user] takes a drag from a cigarette and blows [user.p_their()] name out in smoke."
			return msg
	return message

/datum/emote/living/carbon/human/johnny/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/human/H = user
	if(!istype(H.wear_mask, /obj/item/clothing/mask/cigarette))
		to_chat(user, "<span class='warning'>You can't be that cool without a cigarette between your lips.</span>")
		return FALSE

	if(H.getOxyLoss() > 30)
		var/obj/item/clothing/mask/cigarette/cig = H.wear_mask
		to_chat(user, "<span class='warning'>You gasp for air and swallow your [cig]!</span>")
		if(cig.lit)
			to_chat(user, "<span class='userdanger'>The lit [cig] burns on the way down!")
			H.wear_mask = null
			H.wear_mask_update()
			qdel(cig)
			H.adjustFireLoss(5)
		return FALSE
	if(!select_param(user, params))
		return FALSE
	. = ..()

/datum/emote/living/carbon/human/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes."
	muzzled_noises = list("strange", "sharp")
	needs_breath = TRUE
	emote_type = EMOTE_SOUND

/datum/emote/living/carbon/human/sneeze/get_sound(mob/user)

	var/mob/living/carbon/human/H = user

	if(H.is_muzzled())
		// TODO DEAL WITH NO BREATH CAUSING GASPING FOR EMOTES
		return FALSE

	if(H.gender == FEMALE)
		playsound(src, H.dna.species.female_sneeze_sound, 70, 1, frequency = H.get_age_pitch())
	else
		playsound(src, H.dna.species.male_sneeze_sound, 70, 1, frequency = H.get_age_pitch())


/datum/emote/living/carbon/human/slap
	key = "slap"
	key_third_person = "slaps"
	hands_use_check = TRUE
	cooldown = 3 SECONDS // to prevent endless table slamming

/datum/emote/living/carbon/human/slap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/obj/item/slapper/N  = new(user)
	if(user.put_in_hands(N))
		to_chat(user, "<span class='notice'>You ready your slapping hand.</span>")
	else
		qdel(N)
		to_chat(user, "<span class='warning'>You're incapable of slapping in your current state.</span>")

/datum/emote/living/carbon/human/wink
	key = "wink"
	key_third_person = "winks"
	message = "winks."

/datum/emote/living/carbon/human/highfive
	key = "highfive"
	key_third_person = "highfives"
	message = "requests a highfive."
	hands_use_check = TRUE
	cooldown = 3 SECONDS

/datum/emote/living/carbon/human/highfive/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	var/mob/living/carbon/user_carbon = user
	if(user_carbon.restrained())
		return FALSE

/datum/emote/living/carbon/human/highfive/run_emote(mob/user, params, type_override, intentional)
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
				user.visible_message("<span class='danger'><b>[user.name]</b> and <b>[L.name]</b> high-five EPICALLY!</span>")
				user_carbon.status_flags |= (GODMODE)
				L.status_flags |= GODMODE
				explosion(user.loc,5,2,1,3)
				user_carbon.status_flags &= ~GODMODE
				L.status_flags &= ~GODMODE
				return
			user.visible_message("<b>[user.name]</b> and <b>[L.name]</b> high-five!")
			playsound('sound/effects/snap.ogg', 50)
			user_carbon.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
			L.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
			return
	. = ..()

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "holds out their hand."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/handshake/run_emote(mob/user, params, type_override, intentional)
	if(!can_run_emote(user))
		return FALSE

	var/mob/living/target
	for(var/mob/living/A in oview(5, user))
		if(params == A.name)
			target = A

	if(!target)
		user.visible_message(
			"[user] seems to shake hands with empty space.",
			"You shake the air's hand."
		)
		return FALSE

	if(target.canmove && !target.r_hand && !target.restrained())
		message_param = "shakes hands with %t."
	else
		message_param = "holds out [user.p_their()] hand to %t."

	. = ..()

/datum/emote/living/carbon/human/snap
	key = "snap"
	key_third_person = "snaps"
	hands_use_check = TRUE
	message = "snaps their fingers."
	message_param = "snaps their fingers at %t."
	sound = "sound/effects/fingersnap.ogg"
	emote_type = EMOTE_SOUND

/datum/emote/living/carbon/human/snap/run_emote(mob/user, params, type_override, intentional)
	if(prob(5))
		user.visible_message("<span class='danger'><b>[user]</b> snaps [p_their()] fingers right off!</span>")
		playsound(user.loc, 'sound/effects/snap.ogg', 50, 1)
		return FALSE
	. = ..()


/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"
	message = "farts."
	message_param = "farts in %t's general direction."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	for(var/atom/A in get_turf(src))
		A.fart_act(src)

/////////
// Species-specific emotes

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "starts wagging their tail."
	species_whitelist = list("Unathi", "Vulpkanin", "Tajaran", "Vox")

/datum/emote/living/carbon/human/proc/can_wag(mob/user)
	var/mob/living/carbon/human/H = user
	var/obscured = H.wear_suit && (H.wear_suit.flags_inv & HIDETAIL)
	if(!istype(H))
		return FALSE
	if(istype(H.body_accessory, /datum/body_accessory/tail))
		if(!H.body_accessory.try_restrictions(user))
			return FALSE

	if(H.dna.species.bodyflags & TAIL_WAGGING && obscured)
		return FALSE

	return TRUE

/datum/emote/living/carbon/human/wag/run_emote(mob/user, params, type_override, intentional)
	if(!can_run_emote(user))
		return FALSE
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = user
	H.start_tail_wagging()


/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE

	if(!can_wag(user))
		return FALSE

	return TRUE

/datum/emote/living/carbon/human/wag/stop
	key = "swag"
	key_third_person = "swags"
	message = "stops wagging their tail."

/datum/emote/living/carbon/human/wag/stop/run_emote(mob/user, params, type_override, intentional)

	if(!can_run_emote(user))
		return FALSE
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = user
	H.stop_tail_wagging()


/datum/emote/living/carbon/human/wag/select_message_type(mob/user, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!H.dna || !H.dna.species)
		return
	if(H.dna.species.bodyflags & TAIL_WAGGING)
		. = null

///Snowflake emotes only for le epic chimp
/datum/emote/living/carbon/human/monkey

/datum/emote/living/carbon/human/monkey/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(ismonkeybasic(user))
		return ..()
	return FALSE

/datum/emote/living/carbon/human/monkey/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows their teeth..."

/datum/emote/living/carbon/human/monkey/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/monkey/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "scratches."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/monkey/screech/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars."
	emote_type = EMOTE_AUDIBLE
	needs_breath = TRUE

/datum/emote/living/carbon/human/monkey/tail
	key = "tail"
	message = "waves their tail."

/datum/emote/living/carbon/human/monkeysign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t."
	hands_use_check = TRUE


/datum/emote/living/carbon/human/flap
	key = "flap"
	key_third_person = "flaps"
	message = "flaps their wings."
	species_whitelist = list("Nian")
	// TODO Maybe add custom species messages based on the user species?
	hands_use_check = TRUE

/datum/emote/living/carbon/human/flap/aflap
	key = "aflap"
	key_third_person = "aflaps"
	message = "flaps their wings ANGRILY!"

/datum/emote/living/carbon/human/flutter
	key = "flutter"
	key_third_person = "flutters"
	message = "flutters their wings."
	species_whitelist = list("Nian")


/datum/emote/living/carbon/human/quill
	key = "quill"
	key_third_person = "quills"
	message = "rustles their quills."
	message_param = "rustles their quills at %t."
	emote_type = EMOTE_SOUND
	age_based = TRUE
	// Credit to sound-ideas (freesfx.co.uk) for the sound.
	sound = "sound/effects/voxrustle.ogg"
	species_whitelist = list("Vox")

/datum/emote/living/carbon/human/warble
	key = "warble"
	key_third_person = "warbles"
	message = "warbles."
	message_param = "warbles at %t."
	emote_type = EMOTE_SOUND
	age_based = TRUE
	// Copyright CC BY 3.0 alienistcog (freesound.org) for the sound.
	sound = "sound/effects/warble.ogg"
	species_whitelist = list("Skrell")

/datum/emote/living/carbon/human/clack
	key = "clack"
	key_third_person = "clacks"
	message = "clacks their mandibles."
	message_param = "clacks their mandibles at %t."
	species_whitelist = list("Kidan")
	emote_type = EMOTE_SOUND
	age_based = TRUE
	// Credit to DrMinky (freesound.org) for the sound.
	sound = "sound/effects/Kidanclack.ogg"

/datum/emote/living/carbon/human/clack/run_emote(mob/user, params, type_override, intentional)
	if(!can_run_emote(user))
		return FALSE
	. = ..()
	mineral_scan_pulse(get_turf(src), range = world.view)

/datum/emote/living/carbon/human/clack/click
	key = "click"
	key_third_person = "clicks"
	message = "clicks their mandibles."
	message_param = "clicks their mandibles at %t."
	// Credit to DrMinky (freesound.org) for the sound.
	sound = "sound/effects/Kidanclack2.ogg"

/datum/emote/living/carbon/human/drone
	key = "drone"
	key_third_person = "drones"
	species_whitelist = list("Drask")
	emote_type = EMOTE_SOUND
	age_based = TRUE
	sound = "sound/voice/drasktalk.ogg"

/datum/emote/living/carbon/human/drone/New()
	message = "[key_third_person]."
	message_param = "[key_third_person] at %t."

/datum/emote/living/carbon/human/drone/hum
	key = "hum"
	key_third_person = "hums"


/datum/emote/living/carbon/human/drone/rumble
	key = "rumble"
	key_third_person = "rumbles"

/datum/emote/living/carbon/human/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses."
	message_param = "hisses at %t."
	species_whitelist = list("Unathi")
	emote_type = EMOTE_SOUND
	age_based = TRUE
	// Credit to Jamius (freesound.org) for the sound.
	sound = "sound/effects/unathihiss.ogg"
	muzzled_noises = list("weak hissing")
	needs_breath = TRUE

/datum/emote/living/carbon/human/creak
	key = "creak"
	key_third_person = "creaks"
	message = "creaks."
	message_param = "creaks at %t."
	emote_type = EMOTE_SOUND
	age_based = TRUE
	sound = "sound/voice/dionatalk1.ogg"
	species_whitelist = list("Diona")

/datum/emote/living/carbon/human/squish
	key = "squish"
	key_third_person = "squishes"
	message = "squishes."
	message_param = "squishes at %t."
	emote_type = EMOTE_SOUND
	age_based = TRUE
	// Credit to DrMinky (freesound.org) for the sound.
	sound = "sound/effects/slime_squish.ogg"

/datum/emote/living/carbon/human/squish/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	if(!.)
		return FALSE
	if(isslimeperson(src))	//Only Slime People can squish
		return TRUE
	else
		var/mob/living/carbon/human/H = user
		for(var/obj/item/organ/external/L in H.bodyparts) // if your limbs are squishy you can squish too!
			if(istype(L.dna.species, /datum/species/slime))
				return TRUE
	return FALSE

/datum/emote/living/carbon/human/howl
	key = "howl"
	key_third_person = "howls"
	message = "howls."
	message_mime = "acts out a howl."
	message_param = "howls at %t."
	species_whitelist = list("Vulpkanin")
	emote_type = EMOTE_SOUND
	age_based = TRUE
	sound = "sound/goonstation/voice/howl.ogg"
	muzzled_noises = list("very loud")
	needs_breath = TRUE

/datum/emote/living/carbon/human/growl
	key = "growl"
	key_third_person = "growls"
	message = "growls."
	message_param = "growls at %t."
	species_whitelist = list("Vulpkanin")
	sound = "growls"  // what the fuck
	muzzled_noises = list("annoyed")
	emote_type = EMOTE_SOUND
	needs_breath = TRUE

/datum/emote/living/carbon/human/rattle
	key = "rattle"
	key_third_person = "rattles"
	message = "rattles their bones."
	message_param = "rattles their bones at %t."
	species_whitelist = list("Plasmaman", "Skeleton")
