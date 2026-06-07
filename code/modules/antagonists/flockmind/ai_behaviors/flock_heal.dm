/datum/ai_behavior/flock/find_heal_target
	name = "repairing"
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_REPAIR

/datum/ai_behavior/flock/find_heal_target/setup(datum/ai_controller/controller, mob/living/basic/flock/overmind_target)
	. = ..()
	if(overmind_target)
		var/mob/living/basic/flock/drone/bird = controller.pawn
		if(goap_is_valid_target(controller, overmind_target))
			controller.set_blackboard_key(BB_FLOCK_OVERMIND_CONTROL, TRUE)
			controller.set_blackboard_key(BB_PATH_MAX_LENGTH, 200)
			bird.say("instruction confirmed: repair construct", forced = TRUE)
		else
			bird.say("invalid repair target provided by sentient-level instruction", forced = TRUE)
			return FALSE

/datum/ai_behavior/flock/find_heal_target/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/drone/bird = controller.pawn
	return bird.flock && bird.substrate.has_points(FLOCK_SUBSTRATE_COST_REPAIR)

/datum/ai_behavior/flock/find_heal_target/goap_get_potential_targets(datum/ai_controller/controller)
	var/list/options = ..()
	for(var/mob/living/basic/flock/drone/bird in oview(controller.target_search_radius, controller.pawn))
		options += bird
	return options

/datum/ai_behavior/flock/find_heal_target/goap_is_valid_target(datum/ai_controller/controller, atom/target)
	var/mob/living/basic/flock/drone/this_bird = controller.pawn
	var/mob/living/basic/flock/drone/other_bird = target
	if(this_bird.flock != other_bird.flock)
		return FALSE
	if(other_bird.stat == DEAD)
		return FALSE

	// Birds at or below 60% health
	if((other_bird.getBruteLoss() + other_bird.getFireLoss()) / other_bird.maxHealth >= 0.4)
		return TRUE

/datum/ai_behavior/flock/find_heal_target/perform(seconds_per_tick, datum/ai_controller/controller, mob/living/basic/flock/overmind_target)
	..()
	var/atom/target = overmind_target || goap_get_ideal_target(controller, set_path = TRUE)
	if(!target)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_FLOCK_HEAL_TARGET, target)
	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/find_heal_target/finish_action(datum/ai_controller/controller, succeeded, overmind_target)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_TO_USE)
	if(!succeeded && overmind_target)
		controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
		controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)

/datum/ai_behavior/flock/find_heal_target/next_behavior(datum/ai_controller/controller, success)
	if(success)
		controller.queue_behavior(/datum/ai_behavior/flock/heal)

/datum/ai_behavior/flock/heal
	name = "repairing"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/flock/heal/setup(datum/ai_controller/controller, ...)
	var/atom/target = controller.blackboard[BB_FLOCK_HEAL_TARGET]
	set_movement_target(controller, target)
	return ..()

/datum/ai_behavior/flock/heal/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	..()
	var/mob/living/basic/flock/drone/bird = controller.pawn

	if(isnull(controller.blackboard[BB_FLOCK_HEAL_FRUSTRATION]))
		controller.set_blackboard_key(BB_FLOCK_HEAL_FRUSTRATION, world.time + 3 SECONDS)

	if(DOING_INTERACTION(bird, "flock_repair"))
		return AI_BEHAVIOR_DELAY

	var/datum/action/cooldown/flock/flock_heal/repair = locate() in bird.actions
	spawn(-1)
		repair.Trigger(target = controller.blackboard[BB_FLOCK_HEAL_TARGET])

	if(controller.blackboard[BB_FLOCK_HEAL_FRUSTRATION] >= world.time)
		return AI_BEHAVIOR_DELAY

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/datum/ai_behavior/flock/heal/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_FLOCK_HEAL_FRUSTRATION)
	controller.clear_blackboard_key(BB_FLOCK_HEAL_TARGET)
