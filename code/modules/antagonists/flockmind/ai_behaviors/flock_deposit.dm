/datum/ai_behavior/flock/find_deposit_target
	name = "depositing"
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_DEPOSIT

/datum/ai_behavior/flock/find_deposit_target/setup(datum/ai_controller/controller, obj/structure/flock/overmind_target)
	. = ..()
	if(overmind_target)
		var/mob/living/basic/flock/drone/bird = controller.pawn
		if(goap_is_valid_target(controller, overmind_target))
			controller.set_blackboard_key(BB_FLOCK_OVERMIND_CONTROL, TRUE)
			controller.set_blackboard_key(BB_PATH_MAX_LENGTH, 200)
			bird.say("instruction confirmed: deposit substrate", forced = TRUE)
		else
			bird.say("invalid deposit target provided by sentient-level instruction", forced = TRUE)
			return FALSE

/datum/ai_behavior/flock/find_deposit_target/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/bird = controller.pawn
	return bird.substrate.has_points(FLOCK_SUBSTRATE_COST_DEPOST_TEALPRINT)

/datum/ai_behavior/flock/find_deposit_target/goap_get_potential_targets(datum/ai_controller/controller)
	var/list/options = ..()
	for(var/obj/structure/flock/tealprint in range(controller.target_search_radius, controller.pawn))
		options += tealprint
	return options

/datum/ai_behavior/flock/find_deposit_target/goap_is_valid_target(datum/ai_controller/controller, atom/target)
	var/obj/structure/flock/tealprint/tealprint = target
	if(!istype(tealprint))
		return FALSE

	var/mob/living/basic/flock/bird = controller.pawn
	return (tealprint.flock == bird.flock) && !tealprint.substrate.is_full()

/datum/ai_behavior/flock/find_deposit_target/perform(seconds_per_tick, datum/ai_controller/controller, overmind_target)
	..()
	var/atom/target = overmind_target || goap_get_ideal_target(controller, set_path = TRUE)
	if(!target)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_FLOCK_DEPOSIT_TARGET, target)
	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/find_deposit_target/finish_action(datum/ai_controller/controller, succeeded, overmind_target)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_TO_USE)

	if(!succeeded && overmind_target)
		controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
		controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)

/datum/ai_behavior/flock/find_deposit_target/next_behavior(datum/ai_controller/controller, success)
	if(success)
		controller.queue_behavior(/datum/ai_behavior/flock/perform_deposit)

/datum/ai_behavior/flock/perform_deposit
	name = "depositing"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/flock/perform_deposit/setup(datum/ai_controller/controller, ...)
	var/turf/target_turf = controller.blackboard[BB_FLOCK_DEPOSIT_TARGET]
	set_movement_target(controller, target_turf)
	return ..()

/datum/ai_behavior/flock/perform_deposit/goap_is_valid_target(datum/ai_controller/controller, atom/target)
	var/obj/structure/flock/tealprint/tealprint = target
	if(!istype(tealprint))
		return FALSE

	var/mob/living/basic/flock/bird = controller.pawn
	return (tealprint.flock == bird.flock) && !tealprint.substrate.is_full()

/datum/ai_behavior/flock/perform_deposit/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	..()
	var/mob/living/basic/flock/drone/bird = controller.pawn
	var/obj/structure/flock/tealprint/target = controller.blackboard[BB_FLOCK_DEPOSIT_TARGET]
	if(target)
		if(!goap_is_valid_target(controller, target))
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

		controller.clear_blackboard_key(BB_FLOCK_DEPOSIT_TARGET)

		var/datum/action/cooldown/flock/deposit/deposit_action = locate() in bird.actions
		spawn(-1)
			deposit_action.Trigger(target = target)

	if(DOING_INTERACTION(bird, "flock_cage"))
		return AI_BEHAVIOR_DELAY

	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/perform_deposit/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_FLOCK_DEPOSIT_TARGET)

	if(!succeeded && controller.blackboard[BB_FLOCK_OVERMIND_CONTROL] && !QDELETED(controller.pawn))
		var/mob/living/basic/flock/bird = controller.pawn
		bird.say("unable to reach target provided by sentient level instruction, aborting subroutine", forced = TRUE)

	controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
	controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)
