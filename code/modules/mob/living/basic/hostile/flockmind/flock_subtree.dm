/datum/ai_planning_subtree/goap/flockdrone
	possible_behaviors = list(
		/datum/ai_behavior/flock/stare,
		/datum/ai_behavior/flock/wander,
		/datum/ai_behavior/flock/find_conversion_target,
		/datum/ai_behavior/flock/find_deconstruct_target,
		/datum/ai_behavior/flock/find_heal_target,
		/datum/ai_behavior/flock/find_existing_nest,
		/datum/ai_behavior/flock/find_harvest_target,
		/datum/ai_behavior/flock/find_closed_container,
		/datum/ai_behavior/flock/find_storage_item,
		/datum/ai_behavior/flock/find_conversion_target/nest,
		/datum/ai_behavior/flock/attack_target,
		/datum/ai_behavior/flock/find_capture_target,
		/datum/ai_behavior/flock/find_deposit_target,
	)

/datum/ai_planning_subtree/goap/flock
	possible_behaviors = list(
		/datum/ai_behavior/flock/stare,
		/datum/ai_behavior/flock/wander,
		/datum/ai_behavior/flock/find_conversion_target,
	)
