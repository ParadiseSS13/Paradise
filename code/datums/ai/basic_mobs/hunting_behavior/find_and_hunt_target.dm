/**
 * Tells the AI to find a certain target nearby to hunt.
 * If a target has been found, we will start to move towards it, and eventually attack it.
 */
/datum/ai_planning_subtree/find_and_hunt_target
	/// What key in the blacbkboard do we store our hunting target?
	/// If you want to have multiple hunting behaviors on a controller be sure that this is unique
	var/target_key = BB_CURRENT_HUNTING_TARGET
	/// What behavior to execute if we have no target
	var/finding_behavior = /datum/ai_behavior/find_hunt_target
	/// What behavior to execute if we do have a target
	var/hunting_behavior = /datum/ai_behavior/hunt_target
	/// What targets we're hunting for
	var/list/hunt_targets
	/// In what radius will we hunt
	var/hunt_range = 2
	/// What are the chances we hunt something at any given moment
	var/hunt_chance = 100
	///do we finish planning subtree
	var/finish_planning = TRUE

/datum/ai_planning_subtree/find_and_hunt_target/New()
	. = ..()
	hunt_targets = typecacheof(hunt_targets)

/datum/ai_planning_subtree/find_and_hunt_target/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!SPT_PROB(hunt_chance, seconds_per_tick))
		return

	if(controller.blackboard[BB_HUNTING_COOLDOWN(type)] >= world.time)
		return

	if(!controller.blackboard_key_exists(target_key))
		controller.queue_behavior(finding_behavior, target_key, hunt_targets, hunt_range)
		return

	// We ARE hunting something, execute the hunt.
	// Note that if our AI controller has multiple hunting subtrees set,
	// we may accidentally be executing another tree's hunt - not ideal,
	// try to set a unique target key if you have multiple

	controller.queue_behavior(hunting_behavior, target_key, BB_HUNTING_COOLDOWN(type))
	if(finish_planning)
		return SUBTREE_RETURN_FINISH_PLANNING //If we're hunting we're too busy for anything else

/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores
	target_key = BB_ORE_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/hunt_ores
	finding_behavior = /datum/ai_behavior/find_hunt_target/hunt_ores
	hunt_targets = list(/obj/item/stack/ore)
	hunt_chance = 90
	hunt_range = 9

/// Find and clean things
/datum/ai_planning_subtree/find_and_hunt_target/clean
	target_key = BB_CLEAN_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/clean
	hunt_targets = list(/obj/effect/decal/cleanable)
	hunt_range = 4
