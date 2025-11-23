/// Attacks people it can see, disintegrates things based on priority.
/datum/ai_controller/basic_controller/swarmer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 4,
	)
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	movement_delay = 0.2 SECONDS
	ai_traits = AI_FLAG_PAUSE_DURING_DO_AFTER

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/ranged_skirmish/avoid_friendly,
		/datum/ai_planning_subtree/attack_obstacle_in_path/avoid_breaches/walls,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/swarmer_replicate,
		/datum/ai_planning_subtree/swarmer_find_construction_target,
		/datum/ai_planning_subtree/swarmer_create_trap,
		/datum/ai_planning_subtree/swarmer_create_barricade,
		/datum/ai_planning_subtree/attack_obstacle_in_path/avoid_breaches/walls/swarmer_hunting,
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/swarmer,
		/datum/ai_planning_subtree/find_and_hunt_target/swarmer_objects,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
	)

/// Attacks people it can see, disintegrates things based on priority. More aggressive.
/datum/ai_controller/basic_controller/swarmer/lesser
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 8,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/ranged_skirmish/avoid_friendly,
		/datum/ai_planning_subtree/attack_obstacle_in_path/avoid_breaches/walls,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/swarmer_find_construction_target,
		/datum/ai_planning_subtree/swarmer_create_trap,
		/datum/ai_planning_subtree/swarmer_create_barricade,
		/datum/ai_planning_subtree/attack_obstacle_in_path/avoid_breaches/walls/swarmer_hunting,
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/swarmer,
		/datum/ai_planning_subtree/find_and_hunt_target/swarmer_objects,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
	)

/datum/ai_planning_subtree/find_and_hunt_target/corpses/swarmer
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/swarmer
	hunt_range = 4

/datum/ai_planning_subtree/find_and_hunt_target/swarmer_objects
	finding_behavior = /datum/ai_behavior/find_hunt_target/swarmer_objects
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/swarmer
	hunt_targets = list(/obj/item, /obj/structure, /obj/machinery, /turf/simulated/wall, /mob/living)
	hunt_range = 4

/datum/ai_planning_subtree/attack_obstacle_in_path/avoid_breaches/walls/swarmer_hunting
	target_key = BB_CURRENT_HUNTING_TARGET

/datum/ai_behavior/hunt_target/interact_with_target/swarmer
	always_reset_target = TRUE
	hunt_cooldown = 0 SECONDS

/datum/ai_behavior/hunt_target/interact_with_target/swarmer/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	. = ..()
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED // Eat faster!

/datum/ai_behavior/find_hunt_target/swarmer_objects

/datum/ai_behavior/find_hunt_target/swarmer_objects/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, types_to_hunt, hunt_range)
	. = ..()
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED // Eat faster!

/datum/ai_behavior/find_hunt_target/swarmer_objects/valid_dinner(mob/living/source, atom/dinner, radius)
	if(is_type_in_list(dinner, GLOB.swarmer_blacklist))
		return FALSE
	if(HAS_TRAIT(dinner, TRAIT_SWARMER_DISINTEGRATING))
		return FALSE
	if(isitem(dinner) && !isturf(dinner.loc))
		return FALSE
	if(isobj(dinner))
		var/obj/obj_dinner = dinner
		if(obj_dinner.resistance_flags & INDESTRUCTIBLE)
			return FALSE
	if(isliving(dinner))
		var/mob/living/M = dinner
		if(M.stat == DEAD)
			return TRUE
	for(var/turf/T in range(1, dinner))
		var/datum/gas_mixture/environment = T.get_readonly_air()
		var/environment_pressure = environment.return_pressure()
		var/datum/tlv/cur_tlv = new/datum/tlv(ONE_ATMOSPHERE * 0.80, ONE_ATMOSPHERE  *0.90, ONE_ATMOSPHERE * 1.10,ONE_ATMOSPHERE * 1.20) /* kpa */
		var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)
		var/area/A = get_area(T)
		if(isspaceturf(T) || istype(A, /area/shuttle) || istype(A, /area/space) || istype(A, /area/station/engineering/engine/supermatter) || pressure_dangerlevel)
			return FALSE
	return TRUE

/// Run the barricade construction behaviour if we have an ability to use for it
/datum/ai_planning_subtree/swarmer_replicate
	/// Key where the trap action is stored
	var/action_key = BB_SWARMER_REPLICATE_ACTION

/datum/ai_planning_subtree/swarmer_replicate/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/swarmer/user = controller.pawn
	if(!istype(user))
		return
	if(user.resources < 50)
		return
	if(!controller.blackboard_key_exists(action_key))
		return
	var/datum/action/cooldown/mob_cooldown/swarmer_replicate/replicate_action = controller.blackboard[action_key]
	if(replicate_action.IsAvailable())
		controller.queue_behavior(/datum/ai_behavior/swarmer_replicate, action_key)
		return SUBTREE_RETURN_FINISH_PLANNING

/// REPLICATE
/datum/ai_behavior/swarmer_replicate
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/swarmer_replicate/setup(datum/ai_controller/controller, action_key)
	var/datum/action/cooldown/mob_cooldown/swarmer_replicate/replicate_action = controller.blackboard[action_key]
	var/mob/living/basic/swarmer/user = controller.pawn
	if(!istype(user))
		return FALSE
	if(!replicate_action || user.resources < 50)
		return FALSE
	return ..()

/datum/ai_behavior/swarmer_replicate/perform(seconds_per_tick, datum/ai_controller/controller, action_key)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/swarmer_replicate/replicate_action = controller.blackboard[action_key]
	var/result = replicate_action.Trigger()
	if(result)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/// Search for a nearby location to build on
/datum/ai_planning_subtree/swarmer_find_construction_target

/datum/ai_planning_subtree/swarmer_find_construction_target/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/swarmer/user = controller.pawn
	if(!istype(user))
		return
	if(user.resources < 25)
		return
	controller.queue_behavior(/datum/ai_behavior/swarmer_find_construction_target)

/// Find a nearby clear turf and store it
/datum/ai_behavior/swarmer_find_construction_target
	action_cooldown = 10 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// Where do we store the target data
	var/target_key = BB_SWARMER_CONSTRUCT_TARGET
	/// How far do we look for valid turfs?
	var/scan_range = 5

/datum/ai_behavior/swarmer_find_construction_target/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/swarmer = controller.pawn
	var/atom/current_target = controller.blackboard[target_key]
	if(current_target && !(locate(/obj/structure/swarmer) in current_target))
		// Already got a target
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.clear_blackboard_key(target_key)
	var/turf/our_turf = get_turf(swarmer)
	if(is_valid_construction_turf(our_turf, swarmer))
		controller.set_blackboard_key(target_key, our_turf)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	var/list/turfs_by_range = list()
	for(var/i in 1 to scan_range)
		turfs_by_range["[i]"] = list()
	for(var/turf/turf_in_view in oview(scan_range, our_turf))
		if(!is_valid_construction_turf(turf_in_view, swarmer))
			continue
		turfs_by_range["[get_dist(our_turf, turf_in_view)]"] += turf_in_view

	var/list/final_turfs
	for(var/list/turf_list as anything in turfs_by_range)
		if(length(turfs_by_range[turf_list]))
			final_turfs = turfs_by_range[turf_list]
			break
	if(!length(final_turfs))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(target_key, pick(final_turfs))
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/swarmer_find_construction_target/proc/is_valid_construction_turf(turf/target_turf, mob/living/swarmer)
	for(var/turf/turf_in_view in view(1, target_turf))
		if(locate(/obj/structure/swarmer) in turf_in_view)
			return FALSE
	if(HAS_TRAIT(target_turf, TRAIT_SWARMER_CONSTRUCTION))
		return FALSE
	if(isspaceturf(target_turf))
		return FALSE
	var/datum/gas_mixture/environment = target_turf.get_readonly_air()
	var/datum/tlv/cur_tlv = new/datum/tlv(ONE_ATMOSPHERE * 0.80, ONE_ATMOSPHERE  *0.90, ONE_ATMOSPHERE * 1.10,ONE_ATMOSPHERE * 1.20) /* kpa */
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)
	if(pressure_dangerlevel)
		return FALSE
	return !target_turf.is_blocked_turf(source_atom = swarmer)

/// Run the trap construction behaviour if we have an ability to use for it
/datum/ai_planning_subtree/swarmer_create_trap
	/// Key where the trap action is stored
	var/action_key = BB_SWARMER_TRAP_ACTION
	/// Key where the target turf is stored
	var/target_key = BB_SWARMER_CONSTRUCT_TARGET

/datum/ai_planning_subtree/swarmer_create_trap/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(action_key) || !controller.blackboard_key_exists(target_key))
		return
	var/datum/action/cooldown/mob_cooldown/swarmer_trap/trap_action = controller.blackboard[action_key]
	if(trap_action.IsAvailable())
		controller.queue_behavior(/datum/ai_behavior/swarmer_create_trap, action_key, target_key)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Move to an open nearby turf and build a trap
/datum/ai_behavior/swarmer_create_trap
	action_cooldown = 15 SECONDS // We don't want them doing this too quickly
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/swarmer_create_trap/setup(datum/ai_controller/controller, action_key, target_key)
	var/datum/action/cooldown/mob_cooldown/swarmer_trap/trap_action = controller.blackboard[action_key]
	var/turf/target_turf = controller.blackboard[target_key]
	var/mob/living/basic/swarmer/user = controller.pawn
	if(!istype(user))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(!trap_action || !target_turf || user.resources < 25)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	set_movement_target(controller, target_turf)
	return ..()

/datum/ai_behavior/swarmer_create_trap/perform(seconds_per_tick, datum/ai_controller/controller, action_key, target_key)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/swarmer_trap/trap_action = controller.blackboard[action_key]
	var/result = trap_action.Trigger()
	if(result)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/datum/ai_behavior/swarmer_create_trap/finish_action(datum/ai_controller/controller, succeeded, action_key, target_key)
	controller.clear_blackboard_key(target_key)
	return ..()

/// Run the barricade construction behaviour if we have an ability to use for it
/datum/ai_planning_subtree/swarmer_create_barricade
	/// Key where the trap action is stored
	var/action_key = BB_SWARMER_BARRIER_ACTION
	/// Key where the target turf is stored
	var/target_key = BB_SWARMER_CONSTRUCT_TARGET

/datum/ai_planning_subtree/swarmer_create_barricade/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(action_key) || !controller.blackboard_key_exists(target_key))
		return
	var/datum/action/cooldown/mob_cooldown/swarmer_barrier/barrier_action = controller.blackboard[action_key]
	if(barrier_action.IsAvailable())
		controller.queue_behavior(/datum/ai_behavior/swarmer_create_trap, action_key, target_key)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Move to an open nearby turf and build a barricade
/datum/ai_behavior/swarmer_create_barricade
	action_cooldown = 45 SECONDS
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/swarmer_create_barricade/setup(datum/ai_controller/controller, action_key, target_key)
	var/datum/action/cooldown/mob_cooldown/swarmer_barrier/barrier_action = controller.blackboard[action_key]
	var/turf/target_turf = controller.blackboard[target_key]
	var/mob/living/basic/swarmer/user = controller.pawn
	if(!istype(user))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(!barrier_action || !target_turf || user.resources < 25)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	set_movement_target(controller, target_turf)
	return ..()

/datum/ai_behavior/swarmer_create_barricade/perform(seconds_per_tick, datum/ai_controller/controller, action_key, target_key)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/swarmer_barrier/barrier_action = controller.blackboard[action_key]
	if(barrier_action?.Trigger())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/datum/ai_behavior/swarmer_create_barricade/finish_action(datum/ai_controller/controller, succeeded, action_key, target_key)
	controller.clear_blackboard_key(target_key)
	return ..()
