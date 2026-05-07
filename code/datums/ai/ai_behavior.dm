/// Abstract class for an action an AI can take. Can range from movement to grabbing a nearby weapon.
/datum/ai_behavior
	/// What distance you need to be from the target to perform the action.
	var/required_distance = 1
	/// If >0, overrides controller.target_search_radius
	var/search_radius_override = null
	/// Flags for extra behavior
	var/behavior_flags = NONE
	/// Cooldown between actions performances, defaults to the value of
	/// CLICK_CD_MELEE because that seemed like a nice standard for the speed of
	/// AI behavior
	var/action_cooldown = CLICK_CD_MELEE
	/// A multiplier applied to the behavior's goap_score().
	var/goap_weight = 1

	/// Behaviors to add upon a successful setup
	var/list/sub_behaviors

/// Called by the AI controller when first being added. Additional arguments
/// depend on the behavior type. For example, if the behavior involves attacking
/// a mob, you may require an argument naming the blackboard key which points to
/// the target. Return FALSE to cancel.
/datum/ai_behavior/proc/setup(datum/ai_controller/controller, ...)
	return TRUE

/// Returns the delay to use for this behavior in the moment. The default
/// behavior cooldown is `CLICK_CD_MELEE`, but can be customized; for example,
/// you may want a mob crawling through vents to move slowly and at a random
/// pace between pipes.
/datum/ai_behavior/proc/get_cooldown(datum/ai_controller/cooldown_for)
	return action_cooldown

/// Called by the AI controller when this action is performed. This will
/// typically require consulting the blackboard for information on the specific
/// actions desired from this behavior, by passing the relevant blackboard data
/// keys to this proc. Returns a combination of [AI_BEHAVIOR_DELAY] or
/// [AI_BEHAVIOR_INSTANT], determining whether or not a cooldown occurs, and
/// [AI_BEHAVIOR_SUCCEEDED] or [AI_BEHAVIOR_FAILED]. The behavior's
/// `finish_action` proc is given TRUE or FALSE depending on whether or not the
/// return value of `perform` is marked as successful or unsuccessful.
/datum/ai_behavior/proc/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	SHOULD_CALL_PARENT(TRUE)
	controller.behavior_cooldowns[src] = world.time + action_cooldown

/// Called when the action is finished. This needs the same args as `perform`
/// besides the default ones. This should be used to clear up the blackboard of
/// any unnecessary or obsolete data, and update the state of the pawn if
/// necessary once we know whether or not the AI action was successful.
/// `succeeded` is `TRUE` or `FALSE` depending on whether
/// [/datum/ai_behavior/proc/perform] returns [AI_BEHAVIOR_SUCCEEDED] or
/// [AI_BEHAVIOR_FAILED].
/datum/ai_behavior/proc/finish_action(datum/ai_controller/controller, succeeded, ...)
	SHOULD_CALL_PARENT(TRUE)
	controller.dequeue_behavior(src)
	controller.behavior_args -= type
	// If this was a movement task, reset our movement target if necessary
	if(!(behavior_flags & AI_BEHAVIOR_REQUIRE_MOVEMENT))
		return
	if(behavior_flags & AI_BEHAVIOR_KEEP_MOVE_TARGET_ON_FINISH)
		return
	clear_movement_target(controller)
	controller.ai_movement.stop_moving_towards(controller)

/// Helper proc to ensure consistency in setting the source of the movement target
/datum/ai_behavior/proc/set_movement_target(datum/ai_controller/controller, atom/target, datum/ai_movement/new_movement)
	controller.set_movement_target(type, target, new_movement)

/// Clear the controller's movement target only if it was us who last set it
/datum/ai_behavior/proc/clear_movement_target(datum/ai_controller/controller)
	if(controller.movement_target_source != type)
		return
	controller.set_movement_target(type, null)

/// Returns a behavior to perform after this one, or null if continuing this one
/datum/ai_behavior/proc/next_behavior(datum/ai_controller/controller, success)
	return null

/// Executed before goap_score(), to see if the behavior should even be considered.
/datum/ai_behavior/proc/goap_precondition(datum/ai_controller/controller)
	return TRUE

/// Returns a numerical value that is essentially a priority for planner behaviors.
/datum/ai_behavior/proc/goap_score(datum/ai_controller/controller)
	return score_distance(controller, goap_get_ideal_target(controller))

/// Returns the ideal target for this behavior.
/datum/ai_behavior/proc/goap_get_ideal_target(datum/ai_controller/controller, set_path = FALSE)
	var/list/options = goap_filter_targets(controller)
	return get_best_target_by_distance_score(controller, options, set_path)

/// Filter through potential targets to find real targets.
/datum/ai_behavior/proc/goap_filter_targets(datum/ai_controller/controller)
	var/list/options = list()
	for(var/atom/potential_target as anything in goap_get_potential_targets(controller))
		if(goap_is_valid_target(controller, potential_target))
			options += potential_target
	return options

/// Returns a list of potential targets to filter through.
/datum/ai_behavior/proc/goap_get_potential_targets(datum/ai_controller/controller)
	return list()

/// Returns TRUE if the given atom is a valid target for this behavior.
/datum/ai_behavior/proc/goap_is_valid_target(datum/ai_controller/controller, atom/target)
	return TRUE

#define BINARY_INSERT_TARGET(target_list, target, score) \
	do { \
		var/length = length(target_list); \
		if(!length) { \
			target_list[target] = score; \
		} else { \
			var/left = 1; \
			var/right = length; \
			var/middle = (left + right) >> 1; \
			while(left < right) { \
				if(target_list[target_list[middle]] <= score) { \
					left = middle + 1; \
				} else { \
					right = middle; \
				}; \
				middle = (left + right) >> 1; \
			}; \
			middle = target_list[target_list[middle]] > score ? middle : middle + 1; \
			target_list.Insert(middle, target); \
			target_list[target] = score; \
		}; \
	} while(FALSE)


/// Returns the best target by scoring the distance of each possible target.
/// Takes a list to insert the path into, so it can be handed back and re-used.
/datum/ai_behavior/proc/get_best_target_by_distance_score(datum/ai_controller/controller, list/targets, set_path = FALSE)
	if(!length(targets))
		return null

	var/atom/movable/pawn = controller.pawn
	var/list/access = controller.get_access()

	var/list/targets_by_score = list()
	var/list/reachable_targets = list()

	// Sort targets by their estimated score. The last element in the lists has the highest score.
	while(length(targets))
		var/index = rand(1, length(targets))
		var/atom/A = targets[index]
		targets.Cut(index, index + 1)

		var/score = score_distance(controller, A)

		BINARY_INSERT_TARGET(targets_by_score, A, score)

		// WEE WOO WEE WOO BEHAVIOR-CHANGING MICRO-OPT: we assume turfs further than 1 tile aren't reachable
		// Because this is true in 99.9999999999999999% of cases
		if(get_dist(pawn, A) <= 1 && A.Adjacent(pawn))
			BINARY_INSERT_TARGET(reachable_targets, A, score)

	// Go through our sorted target list until we find a path to one.
	// Note: This does mean that the found target might not be the ideal one, as it's operating on the estimate
	// This is a performance thing. We cannot actually use the true best target.
	var/atom/ideal_atom
	var/list/ideal_path
	if(length(reachable_targets))
		ideal_atom = reachable_targets[length(reachable_targets)]
	else
		while(length(targets_by_score))
			var/atom/candidate = targets_by_score[length(targets_by_score)]
			targets_by_score.len--

			var/list/path = SSpathfinder.astar_pathfind_now(
				controller.pawn,
				candidate,
				controller.max_target_distance,
				required_distance,
				access,
				HAS_TRAIT(controller.pawn, TRAIT_FLYING),
			)

			if(path)
				ideal_atom = candidate
				ideal_path = path
				break

	if(set_path && length(ideal_path))
		controller.set_blackboard_key(BB_PATH_TO_USE, ideal_path)
	return ideal_atom

#undef BINARY_INSERT_TARGET

/// Helper for scoring something based on the distance between it and the pawn.
/// By default, returns a value between 100 and -INFINITY, where 100 is a distance of 0 steps.
/// A distance equal to target_search_radius is zero.
/// A distance greater than target_search_radius is negative.
/datum/ai_behavior/proc/score_distance(datum/ai_controller/controller, atom/target)
	var/search_radius = search_radius_override || controller.target_search_radius
	if(isnull(target))
		return -INFINITY
	return 100 * (search_radius - get_dist_manhattan(get_turf(controller.pawn), get_turf(target))) / search_radius
