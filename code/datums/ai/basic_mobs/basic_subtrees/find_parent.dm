/datum/ai_planning_subtree/look_for_adult
	/// how far we must be from the mom
	var/minimum_distance = 1

/datum/ai_planning_subtree/look_for_adult/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/mob/target = controller.blackboard[BB_FOUND_MOM]
	var/mob/baby = controller.pawn

	if(QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/find_mom, BB_FIND_MOM_TYPES, BB_IGNORE_MOM_TYPES, BB_FOUND_MOM)
		return

	if(get_dist(target, baby) > minimum_distance)
		controller.queue_behavior(/datum/ai_behavior/travel_towards/stop_on_arrival, BB_FOUND_MOM)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!SPT_PROB(15, seconds_per_tick))
		return

	if(target.stat == DEAD)
		controller.queue_behavior(/datum/ai_behavior/perform_emote, "cries for their parent!")
	else
		controller.queue_behavior(/datum/ai_behavior/perform_emote, "dances around their parent!")

	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/find_mom
	/// range to look for the mom
	var/look_range = 7

/datum/ai_behavior/find_mom/perform(seconds_per_tick, datum/ai_controller/controller, mom_key, ignore_mom_key, found_mom)
	var/mob/living_pawn = controller.pawn
	var/list/mom_types = controller.blackboard[mom_key]
	var/list/all_moms = list()
	var/list/ignore_types = controller.blackboard[ignore_mom_key]

	if(!length(mom_types))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	for(var/mob/mother in oview(look_range, living_pawn))
		if(!is_type_in_list(mother, mom_types))
			continue
		if(is_type_in_list(mother, ignore_types)) // so the not permanent baby and the permanent baby subtype don't follow each other
			continue
		all_moms += mother

	if(length(all_moms))
		controller.set_blackboard_key(found_mom, pick(all_moms))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
