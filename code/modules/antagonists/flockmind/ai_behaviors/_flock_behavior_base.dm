/datum/ai_behavior/flock
	/// The name of the behavior in the UI for flock drones.
	var/name = ""

/datum/ai_behavior/flock/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	var/mob/living/basic/flock/drone/bird = controller.pawn
	bird.set_task_desc(name)

/datum/ai_behavior/flock/finish_action(datum/ai_controller/controller, succeeded, ...)
	var/mob/living/basic/flock/drone/bird = controller.pawn
	if(HAS_TRAIT(controller.pawn, TRAIT_FLOCKPHASE))
		bird.stop_flockphase(FALSE)

	. = ..()

	bird.set_task_desc("")

