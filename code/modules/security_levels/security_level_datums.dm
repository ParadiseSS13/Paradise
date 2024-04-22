/**
 * Security levels
 *
 * These are used by the security level subsystem. Each one of these represents a security level that a player can set.
 *
 * Base type is abstract
 */
/datum/security_level
	/// The name of this security level.
	var/name = "Not set."
	/// The numerical level of this security level, see defines for more information.
	var/number_level = -1
	/// The delay, after which the security level will be set
	var/set_delay = 0
	/// The sound that we will play when elevated to this security level
	var/elevating_to_sound
	/// The sound that we will play when lowered to this security level
	var/lowering_to_sound
	/// The AI announcement sound about code change, that will be played after main sound
	var/ai_announcement_sound
	/// Color of security level
	var/color
	/// The status display that will be posted to all status displays on security level set
	var/status_display_mode = STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME
	/// The status display data that will be posted to all status displays on security level set
	var/status_display_data = ""
	/// Our announcement title when lowering to this level
	var/lowering_to_announcement_title = "Not set."
	/// Our announcement when lowering to this level
	var/lowering_to_announcement_text = "Not set."
	/// Our announcement title when elevating to this level
	var/elevating_to_announcement_title = "Not set."
	/// Our announcement when elevating to this level
	var/elevating_to_announcement_text = "Not set."

/**
 * Should contain actions that must be completed before actual security level set
 */
/datum/security_level/proc/pre_change()
	return

/**
 * GREEN
 *
 * No threats
 */
/datum/security_level/green
	name = "green"
	number_level = SEC_LEVEL_GREEN
	ai_announcement_sound = 'sound/AI/green.ogg'
	color = "limegreen"
	lowering_to_announcement_title = "Attention! Security level lowered to Green."
	lowering_to_announcement_text = "All threats to the station have passed. All weapons need to be holstered and privacy laws are once again fully enforced."

/**
 * BLUE
 *
 * Caution advised
 */
/datum/security_level/blue
	name = "blue"
	number_level = SEC_LEVEL_BLUE
	elevating_to_sound = 'sound/misc/notice1.ogg'
	ai_announcement_sound = 'sound/AI/blue.ogg'
	color = "dodgerblue"
	lowering_to_announcement_title = "Attention! Security level lowered to Blue."
	lowering_to_announcement_text = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	elevating_to_announcement_title = "Attention! Security level elevated to Blue."
	elevating_to_announcement_text = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible and random searches are permitted."

/**
 * RED
 *
 * Hostile threats
 */
/datum/security_level/red
	name = "red"
	number_level = SEC_LEVEL_RED
	elevating_to_sound = 'sound/misc/notice1.ogg'
	ai_announcement_sound = 'sound/AI/red.ogg'
	color = "red"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "redalert"
	lowering_to_announcement_title = "Attention! Code Red!"
	lowering_to_announcement_text = "The station's self-destruct mechanism has been deactivated, but there is still an immediate and serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	elevating_to_announcement_title = "Attention! Code Red!"
	elevating_to_announcement_text = "There is an immediate and serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."

/**
 * Gamma
 *
 * Station major hostile threats
 */
/datum/security_level/gamma
	name = "gamma"
	number_level = SEC_LEVEL_GAMMA
	lowering_to_sound = 'sound/effects/new_siren.ogg'
	elevating_to_sound = 'sound/effects/new_siren.ogg'
	ai_announcement_sound = 'sound/AI/gamma.ogg'
	color = "gold"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "gammaalert"
	lowering_to_announcement_title = "Attention! Gamma security level activated!"
	lowering_to_announcement_text = "Central Command has ordered the Gamma security level on the station. Security is to have weapons equipped at all times, and all civilians are to immediately seek out command staff for instructions."
	elevating_to_announcement_text = "Central Command has ordered the Gamma security level on the station. Security is to have weapons equipped at all times, and all civilians are to immediately seek out command staff for instructions."
	elevating_to_announcement_title = "Attention! Gamma security level activated!"

/**
 * Epsilon
 *
 * Station is not longer under the Central Command and to be destroyed by Death Squad (Or maybe not)
 */
/datum/security_level/epsilon
	name = "epsilon"
	number_level = SEC_LEVEL_EPSILON
	set_delay = 15 SECONDS
	lowering_to_sound = 'sound/effects/purge_siren.ogg'
	elevating_to_sound = 'sound/effects/purge_siren.ogg'
	ai_announcement_sound = 'sound/AI/epsilon.ogg'
	color = "blueviolet"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "epsilonalert"
	lowering_to_announcement_title = "Attention! Epsilon security level activated!"
	lowering_to_announcement_text = "Central Command has ordered the Epsilon security level on the station."
	elevating_to_announcement_title = "Attention! Epsilon security level activated!"
	elevating_to_announcement_text = "Central Command has ordered the Epsilon security level on the station. Nanotrasen Representative, please prepare to abandon station. Consider all contracts terminated."

/datum/security_level/epsilon/pre_change()
	sound_to_playing_players_on_station_level(S = sound('sound/effects/powerloss.ogg'))

/**
 * DELTA
 *
 * Station self-destruiction mechanism has been engaged
 */
/datum/security_level/delta
	name = "delta"
	number_level = SEC_LEVEL_DELTA
	elevating_to_sound = 'sound/effects/delta_klaxon.ogg'
	ai_announcement_sound = 'sound/AI/delta.ogg'
	color = "orangered"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "deltaalert"
	elevating_to_announcement_title = "Attention! Delta security level reached!"
	elevating_to_announcement_text = "The station's self-destruct mechanism has been engaged. All crew are instructed to abandon the station immediately. This is not a drill."
