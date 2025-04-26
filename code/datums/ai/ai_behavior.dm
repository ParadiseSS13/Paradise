/// Abstract class for an action an AI can take. Can range from movement to grabbing a nearby weapon.
/datum/ai_behavior
	/// What distance you need to be from the target to perform the action.
	var/required_distance = 1
	/// Flags for extra behavior
	var/behavior_flags = NONE
	/// Cooldown between actions performances, defaults to the value of
	/// CLICK_CD_MELEE because that seemed like a nice standard for the speed of
	/// AI behavior
	var/action_cooldown = CLICK_CD_MELEE

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
	controller.behavior_cooldowns[src] = world.time + action_cooldown

/// Called when the action is finished. This needs the same args as `perform`
/// besides the default ones. This should be used to clear up the blackboard of
/// any unnecessary or obsolete data, and update the state of the pawn if
/// necessary once we know whether or not the AI action was successful.
/// `succeeded` is `TRUE` or `FALSE` depending on whether
/// [/datum/ai_behavior/proc/perform] returns [AI_BEHAVIOR_SUCCEEDED] or
/// [AI_BEHAVIOR_FAILED].
/datum/ai_behavior/proc/finish_action(datum/ai_controller/controller, succeeded, ...)
	LAZYREMOVE(controller.current_behaviors, src)
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
