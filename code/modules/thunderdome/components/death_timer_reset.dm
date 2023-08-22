/*
*	death_timer_reset: component designed for resetting time of death for ghosts when they
*	spawn for short-temp role such as Thunderdome player
*
*	Side effects: ghostizing from dead body even without gibbing, inability to enter it again.
*
*/

/datum/component/death_timer_reset
	var/death_time_before

/datum/component/death_timer_reset/Initialize(death_time)
	death_time_before = death_time
	RegisterSignal(parent, list(COMSIG_MOB_GHOSTIZE), PROC_REF(reset_death_time))

/**
 * A bit of a trick with ghostized dead without possibility to return to left body. (Because it resets time of death to world.time)
 */
/datum/component/death_timer_reset/proc/reset_death_time(mob/living/creature, mob/dead/observer/ghost)
	ghost.timeofdeath = death_time_before
	ghost.can_reenter_corpse = FALSE
	UnregisterSignal(parent, list(COMSIG_MOB_GHOSTIZE))

