/**
 * Reproduce with a similar mob.
 */
/datum/ai_planning_subtree/make_babies
	operational_datums = list(/datum/component/breed)
	/// chance to make babies
	var/chance = 5
	/// make babies behavior we will use
	var/datum/ai_behavior/reproduce_behavior = /datum/ai_behavior/make_babies

/datum/ai_planning_subtree/make_babies/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()

	if(!SPT_PROB(chance, seconds_per_tick) || controller.blackboard[BB_PARTNER_SEARCH_TIMEOUT] >= world.time)
		return

	if(controller.blackboard_key_exists(BB_BABIES_TARGET))
		controller.queue_behavior(reproduce_behavior, BB_BABIES_TARGET, BB_BABIES_CHILD_TYPES)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(controller.pawn.gender == FEMALE || !controller.blackboard[BB_BREED_READY])
		return

	if(!controller.blackboard[BB_BABIES_PARTNER_TYPES] || !controller.blackboard[BB_BABIES_CHILD_TYPES])
		return

	// Find target
	controller.queue_behavior(/datum/ai_behavior/find_partner, BB_BABIES_TARGET, BB_BABIES_PARTNER_TYPES, BB_BABIES_CHILD_TYPES)

#define FIND_PARTNER_COOLDOWN 1 MINUTES

/**
 * Find a compatible, living partner, if we're also alone.
 */
/datum/ai_behavior/find_partner
	action_cooldown = 5 SECONDS
	/// Range to look.
	var/range = 7
	/// Maximum number of nearby pop
	var/max_nearby_pop = 3

/datum/ai_behavior/find_partner/perform(seconds_per_tick, datum/ai_controller/controller, target_key, partner_types_key, child_types_key)
	var/maximum_pop = controller.blackboard[BB_MAX_CHILDREN] || max_nearby_pop
	var/mob/pawn_mob = controller.pawn
	var/list/similar_species_types = controller.blackboard[partner_types_key] + controller.blackboard[child_types_key]
	var/mob/living/living_pawn = controller.pawn
	var/list/possible_partners = list()

	var/nearby_pop = 0
	for(var/mob/living/other in oview(range, pawn_mob))
		if(!pawn_mob.faction_check_mob(other))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

		if(!is_type_in_list(other, similar_species_types))
			continue

		if(++nearby_pop >= maximum_pop)
			controller.set_blackboard_key(BB_PARTNER_SEARCH_TIMEOUT, world.time + FIND_PARTNER_COOLDOWN)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

		if(other.stat != CONSCIOUS) // Check if it's conscious FIRST.
			continue

		if(other.gender != living_pawn.gender)
			possible_partners += other

	if(!length(possible_partners))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(target_key, pick(possible_partners))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/**
 * Reproduce.
 */
/datum/ai_behavior/make_babies
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/make_babies/setup(datum/ai_controller/controller, target_key, child_types_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(!target)
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/make_babies/perform(seconds_per_tick, datum/ai_controller/controller, target_key, child_types_key)
	var/mob/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.stat != CONSCIOUS)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.ai_interact(target = target, intent = INTENT_HELP)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/make_babies/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

#undef FIND_PARTNER_COOLDOWN
