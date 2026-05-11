/datum/ai_behavior/flock/attack_target
	name = "incapacitating"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_SHOOT

	search_radius_override = 12

/datum/ai_behavior/flock/attack_target/setup(datum/ai_controller/controller, mob/overmind_target)
	. = ..()
	if(overmind_target)
		var/mob/living/basic/flock/drone/bird = controller.pawn
		if(!goap_is_valid_target(controller, overmind_target))
			controller.set_blackboard_key(BB_FLOCK_OVERMIND_CONTROL, TRUE)
			controller.set_blackboard_key(BB_PATH_MAX_LENGTH, 200)
			bird.say("instruction confirmed: incapacitate lifeform", forced = TRUE)
		else
			bird.say("invalid attack target provided by sentient-level instruction", forced = TRUE)
			return FALSE

	var/atom/target = overmind_target || goap_get_ideal_target(controller, set_path = TRUE)
	if(!target)
		return FALSE

	controller.set_blackboard_key(BB_FLOCK_ATTACK_TARGET, target)
	set_movement_target(controller, target)
	//controller.queue_behavior(/datum/ai_behavior/frustration, BB_FLOCK_ATTACK_FRUSTRATION, 10 SECONDS)

/datum/ai_behavior/flock/attack_target/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/drone/bird = controller.pawn
	return length(bird.flock?.enemies)

/datum/ai_behavior/flock/attack_target/goap_get_potential_targets(datum/ai_controller/controller)
	var/mob/living/basic/flock/bird = controller.pawn
	return bird.flock.enemies.Copy()

/datum/ai_behavior/flock/attack_target/goap_is_valid_target(datum/ai_controller/controller, atom/target)
	var/mob/living/target_mob = target
	return ismob(target_mob) && isturf(target_mob.loc) && !target_mob.incapacitated(ignore_restraints = TRUE, ignore_grab = TRUE) && !target_mob.IsKnockedDown()

/datum/ai_behavior/flock/attack_target/perform(seconds_per_tick, datum/ai_controller/controller, mob/overmind_target)
	..()
	var/atom/target = controller.blackboard[BB_FLOCK_ATTACK_TARGET]
	if(!target)
		return AI_BEHAVIOR_FAILED

	if(!goap_is_valid_target(controller, target))
		return AI_BEHAVIOR_FAILED

	if(!COOLDOWN_FINISHED(controller, blackboard[BB_FLOCK_ATTACK_COOLDOWN]))
		controller.set_blackboard_key(BB_FLOCK_ATTACK_FRUSTRATION, world.time) // Reset frustration if we're on cooldown.
		return AI_BEHAVIOR_DELAY

	var/mob/living/basic/flock/drone/bird = controller.pawn
	if(!can_see(bird, target))
		return AI_BEHAVIOR_DELAY

	if(get_dist(bird, target) > 6) // Too far to shoot!
		return AI_BEHAVIOR_DELAY

	// Run away!
	if(SPT_PROB(40, seconds_per_tick) && COOLDOWN_FINISHED(controller, blackboard[BB_FLOCK_ATTACK_RUN_COOLDOWN]) && get_dist(bird, target) < 3)
		controller.set_blackboard_key(BB_FLOCK_ATTACK_RUN_COOLDOWN, world.time + 5 SECONDS)
		controller.queue_behavior(/datum/ai_behavior/run_away_from_target, target)

	// Strafe!
	else if(SPT_PROB(60, seconds_per_tick) && COOLDOWN_FINISHED(controller, blackboard[BB_FLOCK_ATTACK_STRAFE_COOLDOWN]))
		controller.set_blackboard_key(BB_FLOCK_ATTACK_STRAFE_COOLDOWN, controller.movement_delay * 3)
		var/step_dir = turn(get_dir(bird, target), prob(50) ? 90 : -90)
		step(bird, step_dir)

	if(!istype(bird.active_part, /datum/flockdrone_part/incapacitator))
		var/datum/flockdrone_part/incapacitator/weapon = locate() in bird.parts
		bird.set_active_part(weapon)

	controller.set_blackboard_key(BB_FLOCK_ATTACK_COOLDOWN, world.time + 1.2 SECONDS)
	controller.set_blackboard_key(BB_FLOCK_ATTACK_FRUSTRATION, world.time) // Reset frustration

	bird.RangedAttack(target)
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/flock/attack_target/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_FLOCK_ATTACK_TARGET)
	controller.clear_blackboard_key(BB_FLOCK_ATTACK_FRUSTRATION)
