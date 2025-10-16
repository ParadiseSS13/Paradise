/// Find and attack walls and structures
/datum/ai_planning_subtree/find_and_hunt_target/walls
	finding_behavior = /datum/ai_behavior/find_hunt_target/walls
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target
	hunt_targets = list(/turf/simulated/wall, /obj/structure)

/// Find nearby walls and structures
/datum/ai_behavior/find_hunt_target/walls
	/// Do we allow it to find spaceable walls and windows?
	var/spaceable = FALSE

/datum/ai_behavior/find_hunt_target/walls/valid_dinner(mob/living/source, atom/dinner, radius)
	if(!iswallturf(dinner) && !istype(dinner, /obj/structure))
		return FALSE
	if(is_type_in_list(dinner, GLOB.swarmer_blacklist))
		return FALSE
	if(spaceable)
		return TRUE
	for(var/turf/T in range(1, dinner))
		var/area/A = get_area(T)
		if(isspaceturf(T) || istype(A, /area/shuttle) || istype(A, /area/space) || istype(A, /area/station/engineering/engine/supermatter))
			return FALSE
	return TRUE

/datum/ai_behavior/find_hunt_target/walls/spaceable
	/// Do we allow it to find spaceable walls and windows?
	spaceable = TRUE
