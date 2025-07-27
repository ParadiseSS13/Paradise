/**
  * # Hallucination - Tripper
  *
  * A generic hallucination that causes the target to trip if they cross it.
  */
/obj/effect/hallucination/tripper
	/// Chance to trip when crossing.
	var/trip_chance = 100
	/// Stun to add when crossed.
	var/stun = 4 SECONDS
	/// Weaken to add when crossed.
	var/weaken = 4 SECONDS

/obj/effect/hallucination/tripper/CanPass(atom/movable/mover, turf/T)
	. = TRUE
	if(isliving(mover) && mover == target)
		var/mob/living/M = mover
		if(!(M.mobility_flags & MOBILITY_MOVE) || !prob(trip_chance))
			return
		M.Weaken(weaken)
		on_crossed()

/**
  * Called when the target crosses this hallucination.
  */
/obj/effect/hallucination/tripper/proc/on_crossed()
	return

/**
  * # Hallucination - Chaser
  *
  * A generic hallucination that chases the target.
  */
/obj/effect/hallucination/chaser
	hallucination_icon = 'icons/mob/monkey.dmi'
	hallucination_icon_state = "monkey1"
	hallucination_override = TRUE
	// Settings
	// Minimum distance required between the target and us to keep chasing them.
	var/min_distance = 1
	/// Interval between two thinks in deciseconds. Shouldn't be too low to prevent lag.
	var/think_interval = 1 SECONDS
	// Variables
	/// Think timer handle.
	var/think_timer = null

/obj/effect/hallucination/chaser/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	name = "\proper monkey ([rand(100, 999)])"
	think_timer = addtimer(CALLBACK(src, PROC_REF(think)), think_interval, TIMER_LOOP | TIMER_STOPPABLE)

/obj/effect/hallucination/chaser/Destroy()
	deltimer(think_timer)
	return ..()

/**
  * Called at regular intervals to determine what to do.
  */
/obj/effect/hallucination/chaser/proc/think()
	if(QDELETED(src))
		return
	else if(QDELETED(target))
		qdel(src)
		return

	if(get_dist(src, target) > min_distance)
		chase()
	else
		within_range()

/**
  * Called every Think when we are not close enough to the target.
  */
/obj/effect/hallucination/chaser/proc/chase()
	step_towards(src, target)

/**
  * Called every Think when we are close enough to the target.
  */
/obj/effect/hallucination/chaser/proc/within_range()
	return

/**
  * # Hallucination - Attacker
  *
  * A generic hallucination based on the Chaser that attacks if close enough.
  */
/obj/effect/hallucination/chaser/attacker
	/// Chance to attack per Think spent in range.
	var/attack_chance = 100
	/// Stamina damage to heal on hit.
	var/damage = 25
	/// Whether to attack if the target is knocked down.
	var/should_attack_weakened = FALSE

/obj/effect/hallucination/chaser/attacker/within_range()
	if(!prob(attack_chance))
		return
	var/was_weakened = target.IsWeakened()
	if(was_weakened && !should_attack_weakened)
		return

	attacker_attack(was_weakened)

/**
  * Called every Think when we are attacking the target.
  *
  * Arguments:
  * * was_weakened - Whether the target was already knocked down prior to this attack.
  */
/obj/effect/hallucination/chaser/attacker/proc/attacker_attack(was_weakened)
	dir = get_dir(src, target)
	attack_effects()
	target.apply_damage(damage, STAMINA)
	if(!was_weakened && target.IsWeakened())
		on_knockdown()

/**
  * Called to handle the visual and audio effects of an attack.
  */
/obj/effect/hallucination/chaser/attacker/proc/attack_effects()
	do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	target.playsound_local(get_turf(src), get_sfx("punch"), 25, TRUE)
	to_chat(target, "<span class='userdanger'>[name] has punched [target]!</span>")

/**
  * Called when one of our attacks put the target in stamina crit.
  */
/obj/effect/hallucination/chaser/attacker/proc/on_knockdown()
	target.visible_message("<span class='warning'>[target] recoils as if hit by something, before suddenly collapsing!</span>",
						"<span class='userdanger'>[src]'s blow was too much for you, causing you to collapse!</span>")
