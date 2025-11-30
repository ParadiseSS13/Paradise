/**
 * Generic Resist Subtree, resist if it makes sense to!
 *
 * Requires nothing beyond a living pawn, makes sense on a good amount of mobs since anything can get buckled.
 *
 * relevant blackboards:
 * * None!
 */
/datum/ai_planning_subtree/generic_resist/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	if(SHOULD_RESIST(living_pawn) && SPT_PROB(RESIST_SUBTREE_PROB, seconds_per_tick))
		controller.queue_behavior(/datum/ai_behavior/resist) // BRO IM ON FUCKING FIRE BRO
		return SUBTREE_RETURN_FINISH_PLANNING // IM NOT DOING ANYTHING ELSE BUT EXTINGUISH MYSELF, GOOD GOD HAVE MERCY.

/**
 * Generic Hunger Subtree,
 *
 * Requires at least a living mob that can hold items.
 *
 * relevant blackboards:
 * * BB_NEXT_HUNGRY - set by this subtree, is when the controller is next hungry
 */
/datum/ai_planning_subtree/generic_hunger/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.incapacitated()) // We're restrained or stunned - what are we gonna do?
		return SUBTREE_RETURN_FINISH_PLANNING

	var/next_eat = controller.blackboard[BB_NEXT_HUNGRY]
	if(!next_eat)
		// inits the blackboard timer
		next_eat = world.time + rand(0, 30 SECONDS)
		controller.set_blackboard_key(BB_NEXT_HUNGRY, next_eat)

	if(world.time < next_eat)
		return

	var/atom/food_target = controller.blackboard[BB_FOOD_TARGET]

	if(isnull(food_target))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/edible, BB_FOOD_TARGET, /obj/item, 2)
		return

	if(!length(living_pawn.get_empty_held_indexes())  && !(food_target in living_pawn.held_items()))
		controller.queue_behavior(/datum/ai_behavior/drop_item)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(istype(food_target, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/container = food_target
		if(!container.reagents.total_volume) // This thing empty.
			controller.queue_behavior(/datum/ai_behavior/drop_item)
			controller.clear_blackboard_key(BB_FOOD_TARGET)
			return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/consume, BB_FOOD_TARGET, BB_NEXT_HUNGRY)
	return SUBTREE_RETURN_FINISH_PLANNING
