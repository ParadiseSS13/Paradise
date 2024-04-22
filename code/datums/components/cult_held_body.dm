/**
 * A component for tracking and manipulating bodies held inside constructs/shades
 * Will drop the body/brain when the parent dies or is deleted.
 */
/datum/component/construct_held_body
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// A reference to either a mob, or a brain organ that is held inside our parent. Will drop when parent dies/is deleted
	var/atom/movable/held_body

/datum/component/construct_held_body/Initialize(atom/movable/new_body)
	. = ..()
	add_body(new_body)

/datum/component/construct_held_body/Destroy(force, silent)
	if(held_body)
		stack_trace("/datum/component/construct_held_body had a held body still despite being destroyed. Body is [held_body] ([held_body.type])")
		held_body = null
	return ..()

/datum/component/construct_held_body/PostTransfer()
	held_body.forceMove(parent) // forcemove them to the new parent

/datum/component/construct_held_body/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(drop_body))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(drop_body))
	RegisterSignal(parent, COMSIG_SHADE_TO_CONSTRUCT_TRANSFER, PROC_REF(transfer_held_body))

/datum/component/construct_held_body/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_DEATH)
	UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	UnregisterSignal(parent, COMSIG_SHADE_TO_CONSTRUCT_TRANSFER)

/datum/component/construct_held_body/proc/add_body(atom/movable/new_body)
	held_body = new_body
	RegisterSignal(new_body, COMSIG_PARENT_QDELETING, PROC_REF(_null_held_body))
	new_body.forceMove(parent)

/datum/component/construct_held_body/proc/_null_held_body()
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING
	UnregisterSignal(held_body, COMSIG_PARENT_QDELETING)
	held_body = null

/datum/component/construct_held_body/proc/transfer_held_body(mob/living/current_parent, mob/living/new_body_holder)
	SIGNAL_HANDLER // COMSIG_SHADE_TO_CONSTRUCT_TRANSFER
	new_body_holder.TakeComponent(src)

/datum/component/construct_held_body/proc/drop_body()
	SIGNAL_HANDLER // COMSIG_MOB_DEATH + COMSIG_PARENT_QDELETING
	INVOKE_ASYNC(src, PROC_REF(_drop_body))

/datum/component/construct_held_body/proc/_drop_body() // call me lazy ig
	if(!held_body) // Null check for empty bodies
		return
	var/mob/living/parent_mob = parent
	held_body.forceMove(get_turf(parent))
	SSticker.mode?.cult_team?.add_cult_immunity(held_body)

	var/mob/living/held_mob = held_body
	if(ismob(held_body)) // Check if the held_body is a mob
		held_mob.key = parent_mob.key
		held_mob.cancel_camera()
	else if(istype(held_body, /obj/item/organ/internal/brain)) // Check if the held_body is a brain
		var/obj/item/organ/internal/brain/brain = held_body
		if(brain.brainmob) // Check if the brain has a brainmob
			brain.brainmob.key = parent_mob.key // Set the key to the brainmob
			held_mob = brain.brainmob

	if(!istype(held_mob) || QDELETED(held_mob))
		CRASH("/datum/component/construct_held_body/proc/_drop_body attempted to drop a body despite having no body, or a qdeleted body")

	parent_mob.mind.transfer_to(held_mob) // Transfer the mind to the original mob
	// goodbye construct antag datums!
	held_mob.mind.remove_antag_datum(/datum/antagonist/cultist, silent_removal = TRUE)
	held_mob.mind.remove_antag_datum(/datum/antagonist/wizard/construct, silent_removal = TRUE)
	held_body = null
	qdel(src) // our job here is done
