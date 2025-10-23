/**
 * Attached to a mob, explodes on death.
 */
/datum/component/mob_explode_on_death
	/// Devastation range
	var/exp_devastate
	/// Heavy range
	var/exp_heavy
	/// Light range
	var/exp_light
	/// Flash range
	var/exp_flash
	/// Fire range
	var/exp_fire

/datum/component/mob_explode_on_death/Initialize(
	exp_devastate = 0,
	exp_heavy = 0,
	exp_light = 2,
	exp_flash = 4,
	exp_fire = 3)

/datum/component/mob_explode_on_death/RegisterWithParent()
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_mob_death))

/datum/component/mob_explode_on_death/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOB_DEATH)

/// Add an attacking atom to a blackboard list of things which attacked us
/datum/component/mob_explode_on_death/proc/on_mob_death(mob/living/source)
	SIGNAL_HANDLER

	explosion(get_turf(source), exp_devastate, exp_heavy, exp_light, exp_flash, 0, flame_range = exp_fire, cause = source.name)
