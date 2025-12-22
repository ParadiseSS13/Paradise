/datum/emote/living/silicon
	// Humans are allowed for the sake of IPCs
	mob_type_allowed_typecache = list(/mob/living/silicon, /mob/living/simple_animal/bot, /mob/living/carbon/human)
	mob_type_blacklist_typecache = list()

/datum/emote/living/silicon/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	// Let IPCs (and people with robo-heads) make beep-boop noises
	if(!.)
		return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/head/head = H.get_organ(BODY_ZONE_HEAD)
		if(head && !head.is_robotic())
			return FALSE

/datum/emote/living/silicon/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	message_param = "screams at %t!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = "sound/goonstation/voice/robot_scream.ogg"
	volume = 80

/datum/emote/living/silicon/ping
	key = "ping"
	key_third_person = "pings"
	message = "pings."
	message_param = "pings at %t."
	emote_type = EMOTE_AUDIBLE
	sound = "sound/machines/ping.ogg"

/datum/emote/living/silicon/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "buzzes."
	message_param = "buzzes at %t."
	emote_type = EMOTE_AUDIBLE
	sound = "sound/machines/buzz-sigh.ogg"

/datum/emote/living/silicon/buzz2
	key = "buzz2"
	message = "emits an irritated buzzing sound."
	message_param = "emits an irritated buzzing sound at %t."
	emote_type = EMOTE_AUDIBLE
	sound = "sound/machines/buzz-two.ogg"

/datum/emote/living/silicon/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps."
	message_param = "beeps at %t."
	emote_type = EMOTE_AUDIBLE
	sound = "sound/machines/twobeep.ogg"

/datum/emote/living/silicon/boop
	key = "boop"
	key_third_person = "boops"
	message = "boops."
	message_param = "boops at %t."
	emote_type = EMOTE_AUDIBLE
	sound = "sound/machines/boop.ogg"

/datum/emote/living/silicon/yes
	key = "yes"
	message = "emits an affirmative blip."
	message_param = "emits an affirmative blip at %t."
	emote_type = EMOTE_AUDIBLE
	sound = "sound/machines/synth_yes.ogg"

/datum/emote/living/silicon/no
	key = "no"
	message = "emits a negative blip."
	message_param = "emits a negative blip at %t."
	emote_type = EMOTE_AUDIBLE
	sound = "sound/machines/synth_no.ogg"

/datum/emote/living/silicon/law
	key = "law"
	message = "shows its legal authorization barcode."
	message_param = "shows %t its legal authorization barcode."
	emote_type = EMOTE_AUDIBLE
	sound = "sound/voice/biamthelaw.ogg"

/datum/emote/living/silicon/law/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	var/mob/living/silicon/robot/bot = user
	if(!istype(bot) || !istype(bot.module, /obj/item/robot_module/security))
		return FALSE

/datum/emote/living/silicon/halt
	key = "halt"
	message = "screeches \"HALT! SECURITY!\" from its speakers."
	message_param = "instructs %t to HALT."
	emote_type = EMOTE_AUDIBLE
	sound = "sound/voice/halt.ogg"

/datum/emote/living/silicon/halt/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	var/mob/living/silicon/robot/bot = user
	if(!istype(bot) || !istype(bot.module, /obj/item/robot_module/security))
		return FALSE

/datum/emote/living/silicon/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	emote_type = EMOTE_AUDIBLE
	sound = "sound/effects/tong_pickup.ogg" // Either the tink of a foot stepping down or an arm hitting their head when they salute.

/datum/emote/living/silicon/salute/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	if(is_ai(user)) // AI has no moving parts to salute with, sadly.
		return FALSE
