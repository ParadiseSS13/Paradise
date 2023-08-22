/**
*	Thunderdome death signaler
*	Component designed for handling death of Thunderdome participants. Used for tracking.
*/
/datum/component/thunderdome_death_signaler
	var/datum/thunderdome_battle/thunderdome

/**
 * Death signaler initializing can also be done with custom thunderdome, but for now uses global datum instead.
 */
/datum/component/thunderdome_death_signaler/Initialize(datum/thunderdome_battle/thunderdome)
	src.thunderdome = thunderdome
	RegisterSignal(parent, list(COMSIG_MOB_DEATH), PROC_REF(signal_death))

/**
 * Sends signal to thunderdome datum for handling death situation of participant.
 */
/datum/component/thunderdome_death_signaler/proc/signal_death()
	thunderdome.handle_participant_death(parent)
	UnregisterSignal(parent, list(COMSIG_MOB_DEATH))
