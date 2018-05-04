/datum/emote/brain
	stat_allowed = UNCONSCIOUS
	emote_type = EMOTE_AUDIBLE

/datum/emote/brain/can_run_emote(mob/living/carbon/brain/user, status_check = TRUE)
	//No MMI, no emotes
	if(!user.container && !istype(user.container, /obj/item/mmi))
		return FALSE
	return TRUE

/datum/emote/brain/alarm
	key = "alarm"
	key_third_person = "alarms"
	message = "sounds an alarm"

/datum/emote/brain/alert
	key = "alert"
	key_third_person = "alerts"
	message = "lets out a distressed noise"

/datum/emote/brain/notice
	key = "notice"
	key_third_person = "notices"
	message = "plays a loud tone"

/datum/emote/brain/flash
	key = "flash"
	key_third_person = "flashes"
	message = "flashes their lights quickly"
	emote_type = EMOTE_VISIBLE

/datum/emote/brain/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks"
	emote_type = EMOTE_VISIBLE

/datum/emote/brain/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "whistles"

/datum/emote/brain/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps"

/datum/emote/brain/boop
	key = "boop"
	key_third_person = "boops"
	message = "boops"
