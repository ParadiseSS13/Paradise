/datum/ai_controller/basic_controller/bee
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/bee,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_valid_home,
		/datum/ai_planning_subtree/enter_exit_home,
		/datum/ai_planning_subtree/find_and_hunt_target/pollinate,
		/datum/ai_planning_subtree/simple_find_target/bee,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/queen_bee
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/bee,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_valid_home,
		/datum/ai_planning_subtree/enter_exit_home/queen,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/syndibee
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/simple_find_target/bee/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/hydro_target = controller.blackboard[BB_TARGET_HYDRO]
	if(hydro_target)
		return SUBTREE_RETURN_FINISH_PLANNING
	return ..()

/datum/ai_planning_subtree/find_valid_home

/datum/ai_planning_subtree/find_valid_home/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/work_bee = controller.pawn

	var/obj/structure/beebox/current_home = controller.blackboard[BB_CURRENT_HOME]

	if(QDELETED(current_home))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/bee_hive, BB_CURRENT_HOME, /obj/structure/beebox)
		return

	if(work_bee in current_home.bees)
		return

	controller.queue_behavior(/datum/ai_behavior/inhabit_hive, BB_CURRENT_HOME)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/enter_exit_home
	/// chance we go back home
	var/flyback_chance = 15
	/// chance we exit the home
	var/exit_chance = 35

/datum/ai_planning_subtree/enter_exit_home/select_behaviors(datum/ai_controller/controller, seconds_per_tick)

	var/obj/structure/beebox/current_home = controller.blackboard[BB_CURRENT_HOME]

	if(QDELETED(current_home))
		return

	var/mob/living/bee_pawn = controller.pawn
	var/action_prob =  (bee_pawn.loc == current_home) ? exit_chance : flyback_chance

	if(!SPT_PROB(action_prob, seconds_per_tick))
		return

	controller.queue_behavior(/datum/ai_behavior/enter_exit_hive, BB_CURRENT_HOME, BB_BASIC_MOB_CURRENT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

// the queen spends more time in the hive
/datum/ai_planning_subtree/enter_exit_home/queen
	flyback_chance = 85
	exit_chance = 5

/datum/ai_planning_subtree/find_and_hunt_target/pollinate
	target_key = BB_TARGET_HYDRO
	hunting_behavior = /datum/ai_behavior/hunt_target/pollinate
	finding_behavior = /datum/ai_behavior/find_hunt_target/pollinate
	hunt_targets = list(/obj/machinery/hydroponics)
	hunt_range = 10
	hunt_chance = 85

/datum/ai_planning_subtree/find_and_hunt_target/pollinate/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/atom_pawn = controller.pawn
	if(!isturf(atom_pawn.loc))
		return
	return ..()
