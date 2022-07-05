/datum/emote/living/carbon/human
	/// Custom messages that should be applied based on species
	/// Should be an associative list of species name: message
	var/species_custom_messages = list()
	/// Custom messages applied to mimes of a particular species
	var/species_custom_mime_messages = list()
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/select_message_type(mob/user, msg, intentional)
	. = ..()

	var/mob/living/carbon/human/human_user = user

	if(!species_custom_messages || (human_user.mind?.miming && !species_custom_mime_messages))
		return .

	var/custom_message
	if(user.mind?.miming)
		custom_message = species_custom_mime_messages[human_user.dna.species?.name]
	else
		custom_message = species_custom_messages[human_user.dna.species?.name]

	if(custom_message)
		return custom_message

/datum/emote/living/carbon/human/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/human/H = user
	if((emote_type & EMOTE_MOUTH) && !H.mind?.miming)
		if(H.getOxyLoss() > 10 || H.AmountLoseBreath() >= 8 SECONDS)		// no screaming if you don't have enough breath to scream
			H.emote("gasp")
			return TRUE
	return ..()

/datum/emote/living/carbon/human/airguitar
	key = "airguitar"
	message = "is strumming the air and headbanging like a safari chimp."
	emote_type = EMOTE_VISIBLE
	hands_use_check = TRUE

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
	muzzled_noises = list("weak", "pathetic", "sad")
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "give daps to %t."
	emote_target_type = EMOTE_TARGET_MOB
	hands_use_check = TRUE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."
	message_param = "raises an eyebrow at %t."

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles!"
	message_mime = "seems to grumble!"
	message_postfix = "at %t!"
	muzzled_noises = list("bothered")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themselves."
	message_param = "hugs %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles!"
	message_mime = "seems to be speaking sweet nothings!"
	message_postfix = "at %t!"
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/human/nod
	key = "nod"
	key_third_person = "nods"
	message = "nods their head."
	message_param = "nods their head at %t."

/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	message_mime = "acts out a scream!"
	message_postfix = "at %t!"
	muzzled_noises = list("very loud")
	emote_type = EMOTE_SOUND | EMOTE_MOUTH
	only_forced_audio = FALSE
	vary = TRUE
	age_based = TRUE
	cooldown = 5 SECONDS
	mob_type_blacklist_typecache = list(
		/mob/living/carbon/human/monkey, // screech instead
		/mob/living/silicon // Robot sounds
	)

/datum/emote/living/carbon/human/scream/select_message_type(mob/user, msg, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(H.dna.species?.scream_verb)
		if(H.mind?.miming)
			return "[H.dna.species?.scream_verb] silently!"
		else
			return "[H.dna.species?.scream_verb]!"

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	var/mob/living/carbon/human/human = user
	if(human.mind?.miming || !istype(human))
		return
	if(human.gender == FEMALE)
		return human.dna.species.female_scream_sound
	else
		return human.dna.species.male_scream_sound

/datum/emote/living/carbon/human/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps!"
	message_mime = "appears to be gasping!"
	emote_type = EMOTE_SOUND  // Don't make this one a mouth emote since we don't want it to be caught by nobreath
	age_based = TRUE
	unintentional_stat_allowed = UNCONSCIOUS
	volume = 100

/datum/emote/living/carbon/human/gasp/get_sound(mob/user)
	var/mob/living/carbon/human/H = user
	if(H.is_muzzled())
		// If you're muzzled you're not making noise
		return

	if(H.health > 0)
		return H.dna.species.gasp_sound

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_dying_gasp_sounds)
	else
		return pick(H.dna.species.male_dying_gasp_sounds)

/datum/emote/living/carbon/human/gasp/play_sound_effect(mob/user, intentional, sound_path, sound_volume)
	var/mob/living/carbon/human/H = user
	// special handling here: we don't want monkeys' gasps to sound through walls so you can actually walk past xenobio
	playsound(user.loc, sound_path, sound_volume, TRUE, frequency = H.get_age_pitch(), ignore_walls = !isnull(user.mind))

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
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/johnny
	key = "johnny"
	message = "takes a drag from a cigarette and blows their own name out in smoke."
	message_param = "dummy"  // Gets handled in select_param
	emote_type = EMOTE_AUDIBLE
	target_behavior = EMOTE_TARGET_BHVR_DEFAULT_TO_BASE
	emote_target_type = EMOTE_TARGET_MOB

/datum/emote/living/carbon/human/johnny/select_param(mob/user, params)
	if(!params)
		return message
	var/mob/target = find_target(user, params, EMOTE_TARGET_MOB)
	if(!target)
		return message
	var/msg = message
	if(user.mind?.miming)
		msg = "takes a drag from a cigarette and blows \"[target.name]\" out in smoke."
	else
		msg = "says, \"[target.name], please. They had a family.\" [user] takes a drag from a cigarette and blows [user.p_their()] name out in smoke."
	return msg

/datum/emote/living/carbon/human/johnny/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/human/H = user
	if(!istype(H.wear_mask, /obj/item/clothing/mask/cigarette))
		to_chat(user, "<span class='warning'>You can't be that cool without a cigarette between your lips.</span>")
		return TRUE

	var/obj/item/clothing/mask/cigarette/cig = H.wear_mask

	if(!cig.lit)
		to_chat(user, "<span class='warning'>You have to light that [cig] first, cool cat.</span>")
		return TRUE

	if(H.getOxyLoss() > 30)
		user.visible_message(
			"<span class='warning'>[user] gasps for air and swallows their cigarette!</span>",
			"<span class='warning'>You gasp for air and accidentally swallow your [cig]!</span>"
		)
		if(cig.lit)
			to_chat(user, "<span class='userdanger'>The lit [cig] burns on the way down!")
			user.unEquip(cig)
			qdel(cig)
			H.adjustFireLoss(5)
		return TRUE
	return ..()

/datum/emote/living/carbon/human/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes."
	muzzled_noises = list("strange", "sharp")
	emote_type = EMOTE_SOUND | EMOTE_MOUTH
	volume = 70

/datum/emote/living/carbon/human/sneeze/get_sound(mob/user)
	var/mob/living/carbon/human/H = user
	if(H.gender == FEMALE)
		return H.dna.species.female_sneeze_sound
	else
		return H.dna.species.male_sneeze_sound

/datum/emote/living/carbon/human/slap
	key = "slap"
	key_third_person = "slaps"
	hands_use_check = TRUE
	cooldown = 3 SECONDS // to prevent endless table slamming

/datum/emote/living/carbon/human/slap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/slapper/N = new(user)
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

/datum/emote/living/carbon/human/highfive/proc/wiz_cleanup(mob/user, mob/highfived)
	user.status_flags &= ~GODMODE
	highfived.status_flags &= ~GODMODE

/datum/emote/living/carbon/human/highfive/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/user_carbon = user
	if(user_carbon.has_status_effect(STATUS_EFFECT_HIGHFIVE))
		user.visible_message("[user.name] shakes [user.p_their()] hand around slightly, impatiently waiting for someone to high-five them.")
		return TRUE
	user_carbon.apply_status_effect(STATUS_EFFECT_HIGHFIVE)
	for(var/mob/living/L in orange(1))
		if(L.has_status_effect(STATUS_EFFECT_HIGHFIVE) && L != user)
			if(iswizard(user) && iswizard(L))
				user.visible_message("<span class='biggerdanger'><b>[user.name]</b> and <b>[L.name]</b> high-five EPICALLY!</span>")
				user_carbon.status_flags |= GODMODE
				L.status_flags |= GODMODE
				explosion(get_turf(user), 5, 2, 1, 3)
				// explosions have a spawn so this makes sure that we don't get gibbed
				addtimer(CALLBACK(src, .proc/wiz_cleanup, user_carbon, L), 1)
				user_carbon.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
				L.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
				return TRUE
			user.visible_message("<b>[user.name]</b> and <b>[L.name]</b> high-five!")
			playsound(user, 'sound/effects/snap.ogg', 50)
			user_carbon.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
			L.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
			return TRUE
	return ..()

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "holds out their hand."
	hands_use_check = TRUE
	emote_target_type = EMOTE_TARGET_MOB
	target_behavior = EMOTE_TARGET_BHVR_DEFAULT_TO_BASE

/datum/emote/living/carbon/human/handshake/act_on_target(mob/user, target)
	. = ..()
	if(!target)
		user.visible_message(
			"[user] seems to shake hands with empty space.",
			"You shake the air's hand."
		)
		return EMOTE_ACT_STOP_EXECUTION

	if(!user.Adjacent(target) || !ishuman(target))
		message_param = "extends a hand towards %t."
		return TRUE

	var/mob/living/carbon/human/human_target = target

	if(human_target.canmove && !human_target.r_hand && !human_target.restrained())
		message_param = "shakes hands with %t."
	else
		message_param = "holds out [user.p_their()] hand to %t."

/datum/emote/living/carbon/human/handshake/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/target
	for(var/mob/living/A in oview(5, user))
		if(params == A.name)
			target = A

	if(!target)
		user.visible_message(
			"[user] seems to shake hands with empty space.",
			"You shake the air's hand."
		)
		return TRUE

	if(target.canmove && !target.r_hand && !target.restrained())
		message_param = "shakes hands with %t."
	else
		message_param = "holds out [user.p_their()] hand to %t."

	return ..()

/datum/emote/living/carbon/human/snap
	key = "snap"
	key_third_person = "snaps"
	message = "snaps their fingers."
	message_param = "snaps their fingers at %t."
	sound = "sound/effects/fingersnap.ogg"
	emote_type = EMOTE_SOUND

/datum/emote/living/carbon/human/snap/run_emote(mob/user, params, type_override, intentional)

	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/LH = H.get_organ("l_hand")
	var/obj/item/organ/external/RH = H.get_organ("r_hand")
	var/left_hand_good = FALSE
	var/right_hand_good = FALSE
	if(LH && !(LH.status & ORGAN_SPLINTED) && !(LH.status & ORGAN_BROKEN))
		left_hand_good = TRUE
	if(RH && !(RH.status & ORGAN_SPLINTED) && !(RH.status & ORGAN_BROKEN))
		right_hand_good = TRUE

	if(!left_hand_good && !right_hand_good)
		to_chat(user, "You need at least one hand in good working order to snap your fingers.")
		return TRUE

	if(prob(5))
		user.visible_message("<span class='danger'><b>[user]</b> snaps [p_their()] fingers right off!</span>")
		playsound(user.loc, 'sound/effects/snap.ogg', 50, 1)
		return TRUE
	return ..()

/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"
	message = "farts."
	message_param = "farts in %t's general direction."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, intentional)
	var/farted_on_something = FALSE
	for(var/atom/A in get_turf(user))
		farted_on_something = A.fart_act(user) || farted_on_something
	if(!farted_on_something)
		return ..()

/datum/emote/living/carbon/sign/signal
	key = "signal"
	key_third_person = "signals"
	message_param = "raises %t fingers."
	param_desc = "number(0-10)"
	mob_type_allowed_typecache = list(/mob/living/carbon/human)
	hands_use_check = TRUE


/////////
// Species-specific emotes

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "starts wagging their tail."
	emote_type = EMOTE_VISIBLE | EMOTE_FORCE_NO_RUNECHAT
	species_type_whitelist_typecache = list(
		/datum/species/unathi,
		/datum/species/vulpkanin,
		/datum/species/tajaran,
		/datum/species/vox
	)

/datum/emote/living/carbon/human/proc/can_wag(mob/user)
	var/mob/living/carbon/human/H = user
	if(!(H.dna.species.bodyflags & TAIL_WAGGING))
		return FALSE
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
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = user
	H.start_tail_wagging()


/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE

	if(!can_wag(user))
		return FALSE

	return TRUE

/datum/emote/living/carbon/human/wag/stop
	key = "swag"  // B)
	key_third_person = "swags"
	message = "stops wagging their tail."

/datum/emote/living/carbon/human/wag/stop/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = user
	H.stop_tail_wagging()

///Snowflake emotes only for le epic chimp
/datum/emote/living/carbon/human/monkey
	species_type_whitelist_typecache = list(/datum/species/monkey)


// Note: subtype of human scream, not monkey, so we need the overrides.
/datum/emote/living/carbon/human/scream/screech
	key = "screech"
	key_third_person = "screeches"
	message = "screeches!"
	message_param = "screeches at %t!"
	vary = FALSE
	mob_type_blacklist_typecache = list()
	mob_type_allowed_typecache = list(/mob/living/carbon/human/monkey)
	species_type_whitelist_typecache = list(/datum/species/monkey)

/datum/emote/living/carbon/human/scream/screech/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars!"
	message_param = "roars at %t!"

/datum/emote/living/carbon/human/monkey/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows their teeth!"
	message_param = "gnarls and shows their teeth at %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/human/monkey/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/monkey/roll/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		user.SpinAnimation(10, 1)

/datum/emote/living/carbon/human/monkey/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "scratches."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/monkey/tail
	key = "tail"
	message = "waves their tail."

///////
// More specific human species emotes

/datum/emote/living/carbon/human/flap
	key = "flap"
	key_third_person = "flaps"
	message = "flaps their wings."
	species_type_whitelist_typecache = list(/datum/species/moth)

/datum/emote/living/carbon/human/flap/angry
	key = "aflap"
	key_third_person = "aflaps"
	message = "flaps their wings ANGRILY!"

/datum/emote/living/carbon/human/flutter
	key = "flutter"
	key_third_person = "flutters"
	message = "flutters their wings."
	species_type_whitelist_typecache = list(/datum/species/moth)

/datum/emote/living/carbon/human/quill
	key = "quill"
	key_third_person = "quills"
	message = "rustles their quills."
	message_param = "rustles their quills at %t."
	emote_type = EMOTE_SOUND
	age_based = TRUE
	// Credit to sound-ideas (freesfx.co.uk) for the sound.
	sound = "sound/effects/voxrustle.ogg"
	species_type_whitelist_typecache = list(/datum/species/vox)

/datum/emote/living/carbon/human/warble
	key = "warble"
	key_third_person = "warbles"
	message = "warbles."
	message_param = "warbles at %t."
	emote_type = EMOTE_SOUND
	age_based = TRUE
	// Copyright CC BY 3.0 alienistcog (freesound.org) for the sound.
	sound = "sound/effects/warble.ogg"
	species_type_whitelist_typecache = list(/datum/species/skrell)

/datum/emote/living/carbon/human/clack
	key = "clack"
	key_third_person = "clacks"
	message = "clacks their mandibles."
	message_param = "clacks their mandibles at %t."
	species_type_whitelist_typecache = list(/datum/species/kidan)
	emote_type = EMOTE_SOUND
	audio_cooldown = 3 SECONDS
	age_based = TRUE
	// Credit to DrMinky (freesound.org) for the sound.
	sound = "sound/effects/Kidanclack.ogg"

/datum/emote/living/carbon/human/clack/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	mineral_scan_pulse(get_turf(src), range = world.view)

/datum/emote/living/carbon/human/clack/click
	key = "click"
	key_third_person = "clicks"
	message = "clicks their mandibles."
	message_param = "clicks their mandibles at %t."
	// Credit to DrMinky (freesound.org) for the sound.
	sound = "sound/effects/Kidanclack2.ogg"

/datum/emote/living/carbon/human/drask_talk
	species_type_whitelist_typecache = list(/datum/species/drask)
	emote_type = EMOTE_SOUND
	age_based = TRUE
	sound = "sound/voice/drasktalk.ogg"

/datum/emote/living/carbon/human/drask_talk/drone
	key = "drone"
	key_third_person = "drones"
	message = "drones."
	message_param = "drones at %t."

/datum/emote/living/carbon/human/drask_talk/hum
	key = "hum"
	key_third_person = "hums"
	message = "hums."
	message_param = "hums at %t."

/datum/emote/living/carbon/human/drask_talk/rumble
	key = "rumble"
	key_third_person = "rumbles"
	message = "rumbles."
	message_param = "rumbles at %t."

/datum/emote/living/carbon/human/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses."
	message_param = "hisses at %t."
	species_type_whitelist_typecache = list(/datum/species/unathi)
	emote_type = EMOTE_SOUND | EMOTE_MOUTH
	age_based = TRUE
	// Credit to Jamius (freesound.org) for the sound.
	sound = "sound/effects/unathihiss.ogg"
	muzzled_noises = list("weak hissing")

/datum/emote/living/carbon/human/creak
	key = "creak"
	key_third_person = "creaks"
	message = "creaks."
	message_param = "creaks at %t."
	emote_type = EMOTE_SOUND
	age_based = TRUE
	species_type_whitelist_typecache = list(/datum/species/diona)
	sound = "sound/voice/dionatalk1.ogg"

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
	species_type_whitelist_typecache = list(/datum/species/vulpkanin)
	emote_type = EMOTE_SOUND | EMOTE_MOUTH
	age_based = TRUE
	sound = "sound/goonstation/voice/howl.ogg"
	muzzled_noises = list("very loud")
	volume = 100
	cooldown = 10 SECONDS

/datum/emote/living/carbon/human/growl
	key = "growl"
	key_third_person = "growls"
	message = "growls."
	message_mime = "growls silently."
	message_param = "growls at %t."
	species_type_whitelist_typecache = list(/datum/species/vulpkanin)
	sound = "growls"  // what the fuck why is this just top level
	volume = 80
	muzzled_noises = list("annoyed")
	emote_type = EMOTE_SOUND | EMOTE_MOUTH

/datum/emote/living/carbon/human/rattle
	key = "rattle"
	key_third_person = "rattles"
	message = "rattles their bones."
	message_param = "rattles their bones at %t."
	species_type_whitelist_typecache = list(/datum/species/skeleton, /datum/species/plasmaman)
