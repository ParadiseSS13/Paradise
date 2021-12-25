/**
 * A spell template that adds bounces to the charge_up spell template. The spell will bounce between targets once released.
 * Don't override cast and instead override apply_bounce_effect and the other procs
 */
/obj/effect/proc_holder/spell/charge_up/bounce
	var/bounce_hit_sound

/obj/effect/proc_holder/spell/charge_up/bounce/cast(list/targets, mob/user = usr)
	var/mob/living/target = targets[1]

	bounce(user, target, get_bounce_energy(), get_bounce_amount(), user)

/**
 * How much energy should each bounce have?
 */
/obj/effect/proc_holder/spell/charge_up/bounce/proc/get_bounce_energy()
	return

/**
 * How much bounces should there be in total?
 */
/obj/effect/proc_holder/spell/charge_up/bounce/proc/get_bounce_amount()
	return

/**
 * Called when a bounce travels from one mob to another
 *
 * Arguments:
 * * origin - Where the bounce came from
 * * target - The mob that got hit
 */
/obj/effect/proc_holder/spell/charge_up/bounce/proc/create_beam(mob/origin, mob/target)
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
/obj/effect/proc_holder/spell/charge_up/bounce/proc/apply_bounce_effect(mob/origin, mob/target, energy, mob/user)
	return

/obj/effect/proc_holder/spell/charge_up/bounce/proc/bounce(mob/origin, mob/target, energy, bounces, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	create_beam(origin, target)
	apply_bounce_effect(origin, target, energy, user)
	add_attack_logs(user, target, "Bounce spell '[src]' bounced on")
	playsound(get_turf(target), bounce_hit_sound, 50, 1, -1)

	if(bounces >= 1)
		var/list/possible_targets = list()
		for(var/mob/living/M in view(targeting.range, target))
			if(user == M || target == M && los_check(target, M))
				continue
			possible_targets += M
		if(!length(possible_targets))
			return
		var/mob/living/next = pick(possible_targets)
		bounce(target, next, energy, bounces - 1, user)
