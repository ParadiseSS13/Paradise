/datum/ai_behavior/swirl_around_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 0
	/// chance to swirl
	var/swirl_chance = 60

/datum/ai_behavior/swirl_around_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/swirl_around_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn

	if(QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	if(get_dist(target, living_pawn) > 1)
		set_movement_target(controller, target)
		return AI_BEHAVIOR_DELAY

	if(!SPT_PROB(swirl_chance, seconds_per_tick))
		return AI_BEHAVIOR_DELAY

	var/list/possible_turfs = list()

	for(var/turf/possible_turf in oview(2, target))
		if(possible_turf.is_blocked_turf(source_atom = living_pawn))
			continue
		possible_turfs += possible_turf

	if(!length(possible_turfs))
		return AI_BEHAVIOR_DELAY

	if(isnull(controller.movement_target_source) || controller.movement_target_source == type)
		set_movement_target(controller, pick(possible_turfs))
	return AI_BEHAVIOR_DELAY
