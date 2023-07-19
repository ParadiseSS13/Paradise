/mob/living/Life(seconds, times_fired)
	SEND_SIGNAL(src, COMSIG_LIVING_LIFE, seconds, times_fired)
	. = ..()

/mob/living/carbon/human/Initialize(mapload, datum/species/new_species)
	. = ..()
	//AddComponent(/datum/component/softcrit) //Disabled for now

/mob/living/carbon/human/handle_critical_condition()
	. = ..()
	if(status_flags & GODMODE)
		return 0
	if(health <= HEALTH_THRESHOLD_CRIT)
		if(!HAS_TRAIT(src, TRAIT_HEALTH_CRIT))
			ADD_TRAIT(src, TRAIT_HEALTH_CRIT, SOFTCRIT_REWORK_TRAIT)

/mob/living/carbon/human/check_death_method()
	return FALSE

// No messages when in Crit

/mob/living/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(HAS_TRAIT(src, TRAIT_HEALTH_CRIT))
		whisper_say(message_pieces)
		return TRUE
	. = ..()

/mob/living/carbon/human/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(HAS_TRAIT(src, TRAIT_HEALTH_CRIT))
		whisper_say(message_pieces)
		return TRUE
	. = ..()
