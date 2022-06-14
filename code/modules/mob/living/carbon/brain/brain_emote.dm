/**
 * Emotes usable by brains, but only while they're in MMIs.
 */
/datum/emote/living/carbon/brain
	mob_type_allowed_typecache = list(/mob/living/carbon/brain)
	mob_type_blacklist_typecache = null
	/// The message that will be displayed to themselves, since brains can't really see their own emotes
	var/self_message

/datum/emote/living/carbon/brain/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE

	if(self_message)
		to_chat(user, self_message)

/datum/emote/living/carbon/brain/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/brain/B = user

	if(!(B.container && istype(B.container, /obj/item/mmi)))  // No MMI, no emotes
		return FALSE

// So, brains can't really see their own emotes so we'll probably just want to send an extra message

/datum/emote/living/carbon/brain/alarm
	key = "alarm"
	key_third_person = "alarms"
	message = "sounds an alarm."
	self_message = "You sound an alarm."

/datum/emote/living/carbon/brain/alert
	key = "alert"
	key_third_person = "alerts"
	message = "lets out a distressed noise."
	self_message = "You let out a distressed noise."

/datum/emote/living/carbon/brain/notice
	key = "notice"
	message = "plays a loud tone."
	self_message = "You play a loud tone."

/datum/emote/living/carbon/brain/flash
	key = "flash"
	message = "starts flashing its lights quickly!"

/datum/emote/living/carbon/brain/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "whistles."
	self_message = "You whistle."

/datum/emote/living/carbon/brain/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps."
	self_message = "You beep."

/datum/emote/living/carbon/brain/boop
	key = "boop"
	key_third_person = "boops"
	message = "boops."
	self_message = "You boop."
