/**
  * # Hallucination - Xeno Pounce
  *
  * An imaginary alien hunter pounces towards the target.
  */
/datum/hallucination_manager/xeno_pounce
	trigger_time = 5 SECONDS
	initial_hallucination = /obj/effect/hallucination/no_delete/xeno_pouncer
	/// Typecasted reference to the xeno pouncer
	var/obj/effect/hallucination/no_delete/xeno_pouncer/xeno

/datum/hallucination_manager/xeno_pounce/get_spawn_location()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent in range(world.view / 2, owner))
		vents += vent
	if(!length(vents))
		qdel(src)
		return

	return get_turf(pick(vents))

/datum/hallucination_manager/xeno_pounce/on_spawn()
	initial_hallucination.dir = get_dir(initial_hallucination, owner)
	xeno = initial_hallucination

/datum/hallucination_manager/xeno_pounce/on_trigger()
	if(QDELETED(xeno) || QDELETED(owner))
		qdel(src)
		return

	xeno.leap_to(owner)
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(on_second_trigger)), trigger_time, TIMER_DELETE_ME)

/datum/hallucination_manager/xeno_pounce/proc/on_second_trigger()
	if(QDELETED(xeno) || QDELETED(owner))
		qdel(src)
		return

	xeno.leap_to(owner)
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(on_last_trigger)), trigger_time, TIMER_DELETE_ME)

/datum/hallucination_manager/xeno_pounce/proc/on_last_trigger()
	if(QDELETED(xeno) || QDELETED(owner))
		qdel(src)
		return

	xeno.leap_to(owner)
	qdel(src)

// MARK: The xeno pouncer hallucination

/obj/effect/hallucination/no_delete/xeno_pouncer
	hallucination_icon = 'icons/mob/alien.dmi'
	hallucination_icon_state = "alienh_pounce"
	hallucination_override = TRUE

/obj/effect/hallucination/no_delete/xeno_pouncer/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	name = "\proper alien hunter ([rand(100, 999)])"

/obj/effect/hallucination/no_delete/xeno_pouncer/throw_impact(A)
	if(A == target)
		forceMove(get_turf(target))
		target.Weaken(10 SECONDS)
		target.visible_message("<span class='danger'>[target] recoils backwards and falls flat!</span>",
							"<span class='userdanger'>[name] pounces on you!</span>")

		to_chat(target, "<span class='notice'>[name] begins climbing into the ventilation system...</span>")
	QDEL_IN(src, 2 SECONDS)

/**
  * Throws the xeno towards the given loc.
  *
  * Arguments:
  * * dest - The loc to leap to.
  */
/obj/effect/hallucination/no_delete/xeno_pouncer/proc/leap_to(dest)
	if(images && images[1])
		images[1].icon = 'icons/mob/alienleap.dmi'
		images[1].icon_state = "alienh_leap"
	dir = get_dir(get_turf(src), dest)
	throw_at(dest, 7, 1, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, PROC_REF(reset_icon)))

/**
  * Resets the xeno's icon to a resting state.
  */
/obj/effect/hallucination/no_delete/xeno_pouncer/proc/reset_icon()
	if(images && images[1])
		images[1].icon = 'icons/mob/alien.dmi'
		images[1].icon_state = "alienh_pounce"
