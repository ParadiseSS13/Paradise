GLOBAL_VAR_INIT(backrooms_occupied, FALSE)

/**
 * # Hallucination - Backrooms
 *
 * Temporarily sends the target to the backrooms. Their body's movement matches their movement in the backrooms.
 */

/datum/hallucination_manager/backrooms
	// this is the total length of the hallucination, if it's too short it cuts off the end
	trigger_time = 14 SECONDS
	// Human that will see the hallucination
	var/mob/living/carbon/human/human_owner
	// Item that will copy the owner's visible contents
	var/obj/item/clone_base

/datum/hallucination_manager/backrooms/on_spawn()
	if(!ishuman(owner))
		return
	human_owner = owner
	// One person at a time in the backrooms, no backroom brawls allowed.
	if(GLOB.backrooms_occupied)
		return
	GLOB.backrooms_occupied = TRUE
	fade_out_trigger()

/datum/hallucination_manager/backrooms/proc/fade_out_trigger()
	human_owner.overlay_fullscreen("sleepblind", /atom/movable/screen/fullscreen/center/blind/sleeping, animated = 1 SECONDS)
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(do_hallucination_trigger)), 1 SECONDS, TIMER_STOPPABLE)

/datum/hallucination_manager/backrooms/proc/do_hallucination_trigger()
	human_owner.clear_fullscreen("sleepblind")
	RegisterSignal(human_owner, COMSIG_MOVABLE_MOVED, PROC_REF(follow_movement))
	var/obj/spawn_location = pick(GLOB.backroomswarp)
	clone_base = new(spawn_location)
	clone_base.vis_contents += human_owner
	human_owner.reset_perspective(clone_base)
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(fade_in_trigger)), 12 SECONDS, TIMER_STOPPABLE)

/datum/hallucination_manager/backrooms/proc/fade_in_trigger()
	human_owner.overlay_fullscreen("sleepblind", /atom/movable/screen/fullscreen/center/blind/sleeping, animated = 1 SECONDS)
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(end_fade_trigger)), 1 SECONDS, TIMER_STOPPABLE)

/datum/hallucination_manager/backrooms/proc/end_fade_trigger()
	human_owner.clear_fullscreen("sleepblind")

/datum/hallucination_manager/backrooms/Destroy(force)
	GLOB.backrooms_occupied = FALSE
	UnregisterSignal(human_owner, COMSIG_MOVABLE_MOVED)
	human_owner.reset_perspective(human_owner)
	human_owner = null
	QDEL_NULL(clone_base)
	return ..()

/datum/hallucination_manager/backrooms/proc/follow_movement(source, atom/old_loc, dir, forced)
	// signal is called above in on_spawn so that whenever our human moves, we also move the clone
	SIGNAL_HANDLER  // COMSIG_MOVABLE_MOVED
	step_towards(clone_base, get_step(get_turf(clone_base), dir))
