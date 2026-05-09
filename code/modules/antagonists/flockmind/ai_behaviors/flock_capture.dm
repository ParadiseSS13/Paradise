/datum/ai_behavior/flock/find_capture_target
	name = "capturing"
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_CAPTURE

/datum/ai_behavior/flock/find_capture_target/setup(datum/ai_controller/controller, mob/overmind_target)
	. = ..()
	if(overmind_target)
		var/mob/living/basic/flock/drone/bird = controller.pawn
		if(isturf(overmind_target.loc))
			controller.set_blackboard_key(BB_FLOCK_OVERMIND_CONTROL, TRUE)
			controller.set_blackboard_key(BB_PATH_MAX_LENGTH, 200)
			bird.say("instruction confirmed: capture biological lifeform", forced = TRUE)
		else
			bird.say("invalid capture target provided by sentient-level instruction", forced = TRUE)
			return FALSE

/datum/ai_behavior/flock/find_capture_target/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/drone/bird = controller.pawn
	return length(bird.flock?.enemies)

/datum/ai_behavior/flock/find_capture_target/goap_get_potential_targets(datum/ai_controller/controller)
	var/mob/living/basic/flock/bird = controller.pawn
	return bird.flock.enemies.Copy()

/datum/ai_behavior/flock/find_capture_target/goap_is_valid_target(datum/ai_controller/controller, atom/target)
	var/mob/living/target_mob = target
	return ismob(target_mob) && isturf(target_mob.loc) && (target_mob.incapacitated(ignore_restraints = TRUE, ignore_grab = TRUE) || target_mob.IsKnockedDown())

/datum/ai_behavior/flock/find_capture_target/perform(seconds_per_tick, datum/ai_controller/controller, mob/overmind_target)
	..()
	var/atom/target = overmind_target || goap_get_ideal_target(controller, set_path = TRUE)
	if(!target)
		return AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_FLOCK_CAPTURE_TARGET, target)
	set_movement_target(controller, target)
	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/find_capture_target/finish_action(datum/ai_controller/controller, succeeded, obj/item/overmind_target)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_TO_USE)

	if(!succeeded && overmind_target)
		controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
		controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)

/datum/ai_behavior/flock/find_capture_target/next_behavior(datum/ai_controller/controller, success)
	if(success)
		controller.queue_behavior(/datum/ai_behavior/flock/perform_capture)

/datum/ai_behavior/flock/perform_capture
	name = "capturing"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/flock/perform_capture/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	..()
	var/mob/living/basic/flock/drone/bird = controller.pawn
	var/mob/living/target = controller.blackboard[BB_FLOCK_CAPTURE_TARGET]
	if(target)
		if(!isturf(target?.loc) || !(target.incapacitated(ignore_restraints = TRUE, ignore_grab = TRUE)) || target.IsKnockedDown())
			return AI_BEHAVIOR_FAILED
		controller.clear_blackboard_key(BB_FLOCK_CAPTURE_TARGET)
		var/datum/action/cooldown/flock/cage_mob/cage_action = locate() in bird.actions
		spawn(-1)
			cage_action.Trigger(target = target)

	if(DOING_INTERACTION(bird, "flock_cage"))
		return AI_BEHAVIOR_DELAY

	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/perform_capture/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_FLOCK_CAPTURE_TARGET)


	if(!succeeded && controller.blackboard[BB_FLOCK_OVERMIND_CONTROL] && !QDELETED(controller.pawn))
		var/mob/living/basic/flock/bird = controller.pawn
		bird.say("unable to reach target provided by sentient level instruction, aborting subroutine", forced = TRUE)

	controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
	controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)
