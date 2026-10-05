/// Shapeshift when we have no target, until someone has been nearby for long enough
/datum/ai_planning_subtree/shapechange_ambush
	operational_datums = list(/datum/component/ai_target_timer)
	/// Key where we keep our ability
	var/ability_key = BB_SHAPESHIFT_ACTION
	/// Key where we keep our target
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// How long to lull our target into a false sense of security
	var/minimum_target_time = 8 SECONDS

/datum/ai_planning_subtree/shapechange_ambush/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	var/is_shifted = ismob(living_pawn.loc)
	var/has_target = controller.blackboard_key_exists(target_key)
	var/datum/action/cooldown/using_action = controller.blackboard[ability_key]

	if(!is_shifted)
		if(has_target)
			return // We're busy

		if(using_action?.IsAvailable())
			controller.queue_behavior(/datum/ai_behavior/use_mob_ability/shapeshift, BB_SHAPESHIFT_ACTION) // Shift
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!has_target || !using_action?.IsAvailable())
		return SUBTREE_RETURN_FINISH_PLANNING // Lie in wait
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if(time_on_target < minimum_target_time)
		return // Wait a bit longer
	controller.queue_behavior(/datum/ai_behavior/use_mob_ability/shapeshift, BB_SHAPESHIFT_ACTION) // Surprise!

/// Selects a random shapeshift ability before shifting
/datum/ai_behavior/use_mob_ability/shapeshift

/datum/ai_behavior/use_mob_ability/shapeshift/setup(datum/ai_controller/controller, ability_key)
	var/datum/spell/mimic/using_action = controller.blackboard[ability_key]
	if(using_action?.cooldown_handler.is_on_cooldown())
		return FALSE
	if(isnull(using_action.selected_form)) // If we don't have a shape then pick one, AI can't use context wheels
		var/list/things = list()
		for(var/atom/movable/A in oview(src))
			if(using_action.valid_target(A, src))
				things += A
		if(!length(things))
			return
		var/atom/movable/T = pick(things)
		using_action.take_form(new /datum/mimic_form(T, src), src)
	return ..()
