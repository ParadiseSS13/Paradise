/datum/emote/living/carbon/human
	/// Custom messages that should be applied based on species
	/// Should be an associative list of species name: message
	var/species_custom_messages = list()

/datum/emote/living/carbon/human/select_message_type(mob/user, msg, intentional)
	. = ..()

	if(!species_custom_messages)
		return .

	var/custom_message = species_custom_messages[user.dna.species?.name]
	if(custom_message)
		return custom_message

/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

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

/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	message_mime = "acts out a scream!"
	emote_type = EMOTE_AUDIBLE
	only_forced_audio = FALSE
	vary = TRUE
	age_based = TRUE

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
	// TODO Update this for all basic mobs
	emote_type = EMOTE_AUDIBLE
	vary = FALSE

/datum/emote/living/carbon/human/scream/screech/should_play_sound(mob/user, intentional)
	if(ismonkeybasic(user))
		return TRUE
	return ..()

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

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "starts wagging their tail."
	species_allowed_typecache =

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
	if(!.)
		return FALSE
	if(!can_run_emote(user))
		return FALSE
	. = ..()
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
	if(!.)
		return FALSE
	if(!can_run_emote(user))
		return FALSE
	. = ..()
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
	message = "gnarls and shows its teeth..."

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

/datum/emote/living/carbon/human/monkey/tail
	key = "tail"
	message = "waves their tail."

/datum/emote/living/carbon/human/monkeysign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t."
	hands_use_check = TRUE
