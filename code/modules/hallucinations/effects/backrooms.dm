GLOBAL_VAR_INIT(backrooms_occupied, FALSE)

/**
 * # Hallucination - Backrooms
 *
 * Temporarily sends the target to the backrooms. Their body's movement matches their movement in the backrooms.
 */

/obj/effect/hallucination/no_delete/backrooms
	hallucination_icon = 'icons/effects/effects.dmi'
	hallucination_icon_state = "anom"

/datum/hallucination_manager/backrooms
    var/mob/living/carbon/human/human_owner
    var/obj/item/clone_base
    initial_hallucination = /obj/effect/hallucination/no_delete/backrooms

/datum/hallucination_manager/backrooms/Destroy(force, ...)
    GLOB.backrooms_occupied = FALSE
    UnregisterSignal(human_owner, COMSIG_MOVABLE_MOVED)
    human_owner.reset_perspective(human_owner)
    QDEL_NULL(clone_base)
    human_owner = null
    . = ..()

/datum/hallucination_manager/backrooms/on_spawn()
    if(!ishuman(owner))
        return
    human_owner = owner

    // One person at a time in the backrooms, no backroom brawls allowed.
    if(GLOB.backrooms_occupied)
        return
    GLOB.backrooms_occupied = TRUE

    var/obj/spawn_location = pick(GLOB.backroomswarp)

    RegisterSignal(human_owner, COMSIG_MOVABLE_MOVED, PROC_REF(follow_movement))
    clone_base = new(spawn_location)
    clone_base.vis_contents += human_owner
    human_owner.reset_perspective(clone_base)

/datum/hallucination_manager/backrooms/proc/follow_movement(source, atom/old_loc, dir, forced)
    SIGNAL_HANDLER
    step_towards(clone_base, get_step(get_turf(clone_base), dir))
