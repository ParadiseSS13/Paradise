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
		return

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
	hands_use_check = TRUE

/datum/emote/living/carbon/human/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps."
	message_mime = "claps silently."
	message_param = "claps at %t."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/carbon/human/clap/run_emote(mob/user, params, type_override, intentional)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(!H.bodyparts_by_name[BODY_ZONE_L_ARM] || !H.bodyparts_by_name[BODY_ZONE_R_ARM])
		if(!H.bodyparts_by_name[BODY_ZONE_L_ARM] && !H.bodyparts_by_name[BODY_ZONE_R_ARM])
			// no arms...
			to_chat(user, "<span class='warning'>You need arms to be able to clap.</span>")
		else
			// well, we've got at least one
			user.visible_message("[user] makes the sound of one hand clapping.")
		return TRUE

	return ..()

/datum/emote/living/carbon/human/clap/get_sound(mob/living/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(!H.mind?.miming)
		return pick(
			'sound/misc/clap1.ogg',
			'sound/misc/clap2.ogg',
			'sound/misc/clap3.ogg',
			'sound/misc/clap4.ogg')

/datum/emote/living/carbon/human/crack
	key = "crack"
	key_third_person = "cracks"
	message = "cracks their knuckles."
	emote_type = EMOTE_AUDIBLE
	// knuckles.ogg by CGEffex. Shortened and cut.
	// https://freesound.org/people/CGEffex/sounds/93981/
	sound = "sound/effects/mob_effects/knuckles.ogg"
	// These species all have overrides, see below
	species_type_blacklist_typecache = list(/datum/species/slime, /datum/species/machine, /datum/species/plasmaman, /datum/species/skeleton, /datum/species/diona)

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
	muzzled_noises = list("weak", "pathetic", "sad")
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."
	message_param = "raises an eyebrow at %t."

/datum/emote/living/carbon/human/wince
	key = "wince"
	key_third_person = "winces"
	message = "winces."
	message_param = "winces at %t."

/datum/emote/living/carbon/human/squint
	key = "squint"
	key_third_person = "squints"
	message = "squints."
	message_param = "squints at %t."

/datum/emote/living/carbon/human/facepalm
	key = "facepalm"
	key_third_person = "facepalms"
	message = "facepalms."
	hands_use_check = TRUE
	sound = 'sound/weapons/slap.ogg'
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/palm
	key = "palm"
	message = "extends their palm expectingly."
	message_param = "extends their palm expectingly towards %t."

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
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	vary = TRUE
	age_based = TRUE
	cooldown = 5 SECONDS
	unintentional_audio_cooldown = 3.5 SECONDS
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
	if(HAS_TRAIT(human, TRAIT_I_WANT_BRAINS))
		return 'sound/voice/zombie_scream.ogg'
	if(human.gender == FEMALE)
		return human.dna.species.female_scream_sound
	else
		return human.dna.species.male_scream_sound

/datum/emote/living/carbon/human/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps!"
	message_mime = "appears to be gasping!"
	emote_type = EMOTE_AUDIBLE  // Don't make this one a mouth emote since we don't want it to be caught by nobreath
	age_based = TRUE
	unintentional_stat_allowed = UNCONSCIOUS
	volume = 100

/datum/emote/living/carbon/human/gasp/get_sound(mob/user)
	if(!ishuman(user))
		return
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
	var/oxy = H.getOxyLoss()
	var/volume_decrease = 0
	switch(oxy)
		if(0 to 50)
			volume_decrease = 0
		if(51 to 100)
			volume_decrease = 50
		if(101 to 150)
			volume_decrease = 65
		if(151 to 200)
			volume_decrease = 80
		else
			volume_decrease = 95
	sound_volume -= volume_decrease
	// special handling here: we don't want monkeys' gasps to sound through walls so you can actually walk past xenobio
	playsound(user.loc, sound_path, sound_volume, TRUE, -10, frequency = H.get_age_pitch(H.dna.species.max_age) * alter_emote_pitch(user), ignore_walls = !isnull(user.mind))

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
	audio_cooldown = 3 SECONDS
	var/list/serious_shoes = list(/obj/item/clothing/shoes/jackboots, /obj/item/clothing/shoes/combat,
								/obj/item/clothing/shoes/centcom, /obj/item/clothing/shoes/laceup)
	var/list/funny_shoes = list(/obj/item/clothing/shoes/magboots/clown, /obj/item/clothing/shoes/clown_shoes,
								/obj/item/clothing/shoes/cursedclown, /obj/item/clothing/shoes/ducky)

/datum/emote/living/carbon/human/salute/get_sound(mob/living/user)
	var/mob/living/carbon/human/H = user
	if(is_type_in_list(H.shoes, serious_shoes))
		return 'sound/effects/salute.ogg'
	if(is_type_in_list(H.shoes, funny_shoes))
		return 'sound/items/toysqueak1.ogg'

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
			user.unequip(cig)
			qdel(cig)
			H.adjustFireLoss(5)
		return TRUE
	return ..()

/datum/emote/living/carbon/human/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes."
	muzzled_noises = list("strange", "sharp")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
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
	var/obj/item/slapper/smacking_hand
	if(user.mind && user.mind.martial_art?.can_parry)
		smacking_hand = new /obj/item/slapper/parry(user)
	else
		smacking_hand = new /obj/item/slapper(user)
	if(user.put_in_hands(smacking_hand))
		to_chat(user, "<span class='notice'>You ready your slapping hand.</span>")
	else
		to_chat(user, "<span class='warning'>You're incapable of slapping in your current state.</span>")

/datum/emote/living/carbon/human/wink
	key = "wink"
	key_third_person = "winks"
	message = "winks."

/datum/emote/living/carbon/human/highfive
	key = "highfive"
	key_third_person = "highfives"
	hands_use_check = TRUE
	cooldown = 5 SECONDS
	/// Status effect to apply when this emote is used. Should be a subtype
	var/status = STATUS_EFFECT_HIGHFIVE
	/// title override, used for the re-use message.
	var/action_name

/datum/emote/living/carbon/human/highfive/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	var/mob/living/carbon/user_carbon = user
	if(user_carbon.restrained())
		return FALSE

/datum/emote/living/carbon/human/highfive/proc/set_status(mob/living/carbon/user)
	return user.apply_status_effect(status)

/datum/emote/living/carbon/human/highfive/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/user_carbon = user
	if(user_carbon.has_status_effect(status))
		user.visible_message("[user.name] shakes [user.p_their()] hand around slightly, impatiently waiting for someone to [!isnull(action_name) ? action_name : key].")
		return TRUE
	var/datum/result = set_status(user)
	if(QDELETED(result))
		return TRUE

	return ..()

/datum/emote/living/carbon/human/highfive/dap
	key = "dap"
	status = STATUS_EFFECT_DAP
	key_third_person = "daps"

/datum/emote/living/carbon/human/highfive/payme
	key = "payme"
	status = STATUS_EFFECT_OFFERING_EFTPOS

/datum/emote/living/carbon/human/highfive/payme/run_emote(mob/living/user, params, type_override, intentional)
	var/obj/item/eftpos/eftpos = user.is_holding_item_of_type(/obj/item/eftpos)
	if(!eftpos)
		to_chat(user, "<span class='warning'>You must be holding an EFTPOS to do that!</span>")
		return TRUE
	if(!eftpos.can_offer)
		to_chat(user, "<span class='warning'>[eftpos] is too bulky to hold out to someone!</span>")
		return TRUE
	if(!eftpos.transaction_locked)
		to_chat(user, "<span class='warning'>You must lock [eftpos] before it can accept payments.</span>")
		return TRUE
	if(user.has_status_effect(status))
		user.visible_message("<span class='notice'>[user.name] shakes [eftpos] around slightly, impatiently waiting for someone to scan their card.</span>")
		return TRUE

	var/datum/result = set_status(user)
	if(QDELETED(result))
		return TRUE

	return TRUE

/datum/emote/living/carbon/human/highfive/handshake
	key = "handshake"
	key_third_person = "handshakes"
	status = STATUS_EFFECT_HANDSHAKE

/datum/emote/living/carbon/human/highfive/rps
	key = "rps"
	param_desc = "r,p,s"
	status = STATUS_EFFECT_RPS
	action_name = "play rock-paper-scissors with"
	target_behavior = EMOTE_TARGET_BHVR_IGNORE
	/// If the user used parameters, the move that will be made.
	var/move

/datum/emote/living/carbon/human/highfive/rps/run_emote(mob/user, emote_arg, type_override, intentional)
	switch(lowertext(emote_arg))
		if("r", "rock")
			move = RPS_EMOTE_ROCK
		if("p", "paper")
			move = RPS_EMOTE_PAPER
		if("s", "scissors")
			move = RPS_EMOTE_SCISSORS

		// if it's an invalid emote param, just fall through and let them select

	return ..()

/datum/emote/living/carbon/human/highfive/rps/set_status(mob/living/carbon/user)
	if(!isnull(move))
		// if they supplied a valid parameter, use that for the move
		return user.apply_status_effect(status, move)
	return user.apply_status_effect(status)

/datum/emote/living/carbon/human/highfive/rps/reset_emote()
	..()
	move = initial(move)

/datum/emote/living/carbon/human/snap
	key = "snap"
	key_third_person = "snaps"
	message = "snaps their fingers."
	message_param = "snaps their fingers at %t."
	sound = "sound/effects/fingersnap.ogg"
	emote_type = EMOTE_AUDIBLE

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
		user.visible_message("<span class='danger'><b>[user]</b> snaps [user.p_their()] fingers right off!</span>")
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
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/sign/signal/run_emote(mob/user, params, type_override, intentional)
	var/fingers = round(text2num(params), 1)

	if(fingers > 10)
		to_chat(user, "<span class='warning'>You don't have enough fingers!</span>")
		return TRUE
	else if(fingers < 0)
		to_chat(user, "<span class='warning'>You're not entirely sure how to raise negative fingers.</span>")
		return TRUE

	params = fingers
	return ..()

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
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	// Credit to sound-ideas (freesfx.co.uk) for the sound.
	sound = "sound/effects/voxrustle.ogg"
	species_type_whitelist_typecache = list(/datum/species/vox)

/datum/emote/living/carbon/human/caw
	key = "caw"
	key_third_person = "caws"
	message = "cawws!"
	message_param = "cawws at %t!"
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	// Credit to zeroisnotnull (opengameart.org) for the original sound.
	species_type_whitelist_typecache = list(/datum/species/vox)
	muzzled_noises = list("frustrated")
	vary = TRUE

/datum/emote/living/carbon/human/caw/get_sound(mob/living/user)
	return pick("sound/effects/voxfcaw.ogg", "sound/effects/voxrcaw.ogg")

/datum/emote/living/carbon/human/warble
	key = "warble"
	key_third_person = "warbles"
	message = "warbles."
	message_param = "warbles at %t."
	emote_type = EMOTE_AUDIBLE
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
	emote_type = EMOTE_AUDIBLE
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
	sound = "sound/effects/kidanclack2.ogg"

/datum/emote/living/carbon/human/drask_talk
	species_type_whitelist_typecache = list(/datum/species/drask)
	emote_type = EMOTE_AUDIBLE
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
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	age_based = TRUE
	// Credit to Jamius (freesound.org) for the sound.
	sound = "sound/effects/unathihiss.ogg"
	muzzled_noises = list("weak hissing")

/datum/emote/living/carbon/human/thump
	key = "thump"
	key_third_person = "thumps"
	message = "thumps their tail."
	message_param = "thumps their tail at %t."
	species_type_whitelist_typecache = list(/datum/species/unathi)
	emote_type = EMOTE_AUDIBLE
	// Credit to TylerAM (freesound.org) for the sound.
	sound = "sound/effects/unathitailthump.ogg"

/datum/emote/living/carbon/human/creak
	key = "creak"
	key_third_person = "creaks"
	message = "creaks."
	message_param = "creaks at %t."
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	species_type_whitelist_typecache = list(/datum/species/diona)
	sound = "sound/voice/dionatalk1.ogg"

/datum/emote/living/carbon/human/diona_chirp
	key = "chirp"
	key_third_person = "chirps"
	message = "chirps!"
	message_param = "chirps at %t."
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	species_type_whitelist_typecache = list(/datum/species/diona)
	sound = "sound/creatures/nymphchirp.ogg"

/datum/emote/living/carbon/human/slime


/datum/emote/living/carbon/human/slime/can_run_emote(mob/user, status_check, intentional)
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

/datum/emote/living/carbon/human/slime/squish
	key = "squish"
	key_third_person = "squishes"
	message = "squishes."
	message_param = "squishes at %t."
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	// Credit to DrMinky (freesound.org) for the sound.
	sound = "sound/effects/slime_squish.ogg"

/datum/emote/living/carbon/human/slime/bubble
	key = "bubble"
	key_third_person = "bubbles"
	message = "bubbles."
	message_param = "bubbles at %t."
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	// Sound is CC-4.0 by Audiolarx
	// Effect is cut out of original clip
	// https://freesound.org/people/audiolarx/sounds/263945/
	sound = 'sound/effects/mob_effects/slime_bubble.ogg'

/datum/emote/living/carbon/human/slime/pop
	key = "pop"
	key_third_person = "pops"
	message = "makes a popping sound."
	message_param = "makes a popping sound at %t."
	message_mime = "makes a silent pop."
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	// CC0
	// https://freesound.org/people/greenvwbeetle/sounds/244653/
	sound = 'sound/effects/mob_effects/slime_pop.ogg'

/datum/emote/living/carbon/human/howl
	key = "howl"
	key_third_person = "howls"
	message = "howls."
	message_mime = "acts out a howl."
	message_param = "howls at %t."
	species_type_whitelist_typecache = list(/datum/species/vulpkanin)
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
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
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/human/hiss/tajaran
	message_mime = "hisses silently."
	species_type_whitelist_typecache = list(/datum/species/tajaran)
	sound = "sound/effects/tajaranhiss.ogg"
	volume = 80
	muzzled_noises = list("irritated")
	// catHisses1.wav by Zabuhailo. Edited.
	// https://freesound.org/people/Zabuhailo/sounds/146963/

/datum/emote/living/carbon/human/rattle
	key = "rattle"
	key_third_person = "rattles"
	message = "rattles their bones."
	message_param = "rattles their bones at %t."
	sound = "sound/voice/plas_rattle.ogg"
	volume = 80
	species_type_whitelist_typecache = list(/datum/species/skeleton, /datum/species/plasmaman)

/datum/emote/living/carbon/human/crack/slime
	message = "squishes their knuckles!"
	sound = "sound/effects/slime_squish.ogg"
	species_type_whitelist_typecache = list(/datum/species/slime)
	species_type_blacklist_typecache = null

/datum/emote/living/carbon/human/crack/machine
	message = "cracks their actuators!"
	sound = "sound/effects/mob_effects/ipc_crunch.ogg"
	species_type_whitelist_typecache = list(/datum/species/machine)
	species_type_blacklist_typecache = null

/datum/emote/living/carbon/human/crack/diona
	message = "cracks a twig!"
	sound = "sound/effects/mob_effects/diona_crunch.ogg"
	species_type_whitelist_typecache = list(/datum/species/diona)
	species_type_blacklist_typecache = null
	volume = 85  // the sound effect is a bit quiet

/datum/emote/living/carbon/human/crack/skelly
	message = "cracks something!"  // placeholder
	species_type_whitelist_typecache = list(/datum/species/skeleton, /datum/species/plasmaman)
	species_type_blacklist_typecache = null

/datum/emote/living/carbon/human/crack/skelly/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/bodypart = pick(H.bodyparts)
	message = "cracks their [bodypart.name]!"
	. = ..()
