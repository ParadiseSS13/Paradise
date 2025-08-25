/datum/controller/subsystem/security_level
	/// Whether advanced communication (common channel limitations) is enabled.
	var/advanced_communication_enabled = FALSE

/datum/controller/subsystem/security_level/Initialize()
	. = ..()
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_round_start))

/datum/controller/subsystem/security_level/proc/on_round_start()
	SIGNAL_HANDLER
	var/threshold = GLOB.configuration.ss220_misc.advanced_communication_threshold
	advanced_communication_enabled = length(GLOB.clients) >= threshold

/datum/controller/subsystem/security_level/announce_security_level(datum/security_level/selected_level)
	var/message
	var/title
	var/sound
	var/sound2 = selected_level.ai_announcement_sound

	if(selected_level.number_level > current_security_level.number_level)
		message = selected_level.elevating_to_announcement_text
		title =	selected_level.elevating_to_announcement_title
		sound =	selected_level.elevating_to_sound
	else
		message = selected_level.lowering_to_announcement_text
		title =	selected_level.lowering_to_announcement_title
		sound =	selected_level.lowering_to_sound
	
	if(advanced_communication_enabled)
		if(selected_level.grants_common_channel_access() && !current_security_level.grants_common_channel_access())
			message += " Ограничения на пользование общим каналом связи сняты."
		else if(!selected_level.grants_common_channel_access() && current_security_level.grants_common_channel_access())
			message += " Ограничения на пользование общим каналом связи восстановлены."

	GLOB.security_announcement.Announce(message, title, new_sound = sound, new_sound2 = sound2)

/datum/security_level
	/// Tells if every crew member will be allowed to talk on the common frequency.
	var/grants_common_channel_access = FALSE

/datum/security_level/proc/grants_common_channel_access()
	if(!SSsecurity_level.advanced_communication_enabled)
		return TRUE
	return grants_common_channel_access

/datum/security_level/gamma
	grants_common_channel_access = TRUE

/datum/security_level/epsilon
	grants_common_channel_access = TRUE

/datum/security_level/delta
	grants_common_channel_access = TRUE
