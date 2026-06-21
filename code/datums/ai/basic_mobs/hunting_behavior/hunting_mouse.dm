// Mouse subtree to hunt down delicious cheese.
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese
	finding_behavior = /datum/ai_behavior/find_hunt_target/mouse
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/mouse
	hunt_targets = list(/obj/item/food/sliced/cheesewedge)
	hunt_range = 1
	finish_planning = FALSE

// Mouse subtree to hunt down ... delicious cabling?
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/mouse
	finding_behavior = /datum/ai_behavior/find_hunt_target/mouse_cable
	hunt_targets = list(/obj/structure/cable)
	hunt_range = 1
	hunt_chance = 1
	finish_planning = FALSE

/datum/ai_behavior/find_hunt_target/mouse
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

// When looking for a cable, we can only bite things we can reach.
/datum/ai_behavior/find_hunt_target/mouse_cable

/datum/ai_behavior/find_hunt_target/mouse_cable/valid_dinner(mob/living/source, obj/structure/cable/dinner, radius)
	. = ..()
	if(!.)
		return

	var/turf/simulated/floor/F = get_turf(dinner)
	if(F.intact || F.transparent_floor)
		return FALSE
	var/obj/structure/cable/C = locate() in F
	if(C)
		return TRUE
	return FALSE

// Our hunts have a decent cooldown.
/datum/ai_behavior/hunt_target/interact_with_target/mouse
	hunt_cooldown = 20 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
