/**
 * A spell template that adds bounces to the charge_up spell template. The spell will bounce between targets once released.
 * Don't override cast and instead override apply_bounce_effect and the other procs
 */
/datum/spell/charge_up/bounce
	/// Sound we make when we hit a mob
	var/bounce_hit_sound
	/// How much time should be between each bounce?
	var/bounce_time = 0 SECONDS

/datum/spell/charge_up/bounce/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.allowed_type = /mob/living
	T.try_auto_target = FALSE
	T.use_obstacle_check = TRUE
	return T

/datum/spell/charge_up/bounce/cast(list/targets, mob/user = usr)
	var/mob/living/target = targets[1]

	bounce(user, target, get_bounce_energy(), get_bounce_amount(), user)

/**
 * How much energy should each bounce have?
 */
/datum/spell/charge_up/bounce/proc/get_bounce_energy()
	return

/**
 * How much bounces should there be in total?
 */
/datum/spell/charge_up/bounce/proc/get_bounce_amount()
	return

/**
 * Called when a bounce travels from one mob to another
 *
 * Arguments:
 * * origin - Where the bounce came from
 * * target - The mob that got hit
 */
/datum/spell/charge_up/bounce/proc/create_beam(mob/origin, mob/target)
	return

/**
 * The proc called when a bounce hits a target. Override this to add an effect
 * The user itself is never hit
 *
 * Arguments:
 * * origin - Where the bounce came from
 * * target - The mob that got hit
 * * energy - How much energy the bounce has
 * * user - The caster of the spell
 */
/datum/spell/charge_up/bounce/proc/apply_bounce_effect(mob/origin, mob/target, energy, mob/user)
	return

/datum/spell/charge_up/bounce/proc/bounce(mob/origin, mob/target, energy, bounces, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	create_beam(origin, target)
	apply_bounce_effect(origin, target, energy, user)
	add_attack_logs(user, target, "Bounce spell '[src]' bounced on")
	playsound(get_turf(target), bounce_hit_sound, 50, TRUE, -1)

	if(bounces >= 1)
		if(bounce_time)
			addtimer(CALLBACK(src, PROC_REF(continue_bounce), target, get_target(target, user), energy, bounces - 1, user), bounce_time, TIMER_DELETE_ME)
		else
			bounce(target, get_target(target, user), energy, bounces - 1, user)

/datum/spell/charge_up/bounce/proc/continue_bounce(mob/origin, mob/target, energy, bounces, mob/user)
	// We will only continue the chain if we exist
	if(QDELETED(target))
		return
	// We fulfilled the conditions, get the next target
	var/mob/living/carbon/to_beam_next = get_target(target, user)
	if(isnull(to_beam_next)) // No target = no chain
		return

	// Chain again! Recursively
	bounce(target, to_beam_next, energy, bounces - 1, user)

/datum/spell/charge_up/bounce/proc/get_target(mob/origin, mob/user)
	var/list/possible_targets = list()
	for(var/mob/living/M in view(targeting.range, origin))
		if(user == M || origin == M && targeting.obstacle_check(origin, M))
			continue
		possible_targets += M
	if(!length(possible_targets))
		return

	return pick(possible_targets)
