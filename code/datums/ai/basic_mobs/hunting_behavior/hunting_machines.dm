/// Find and attack machines
/datum/ai_planning_subtree/find_and_hunt_target/machines
	finding_behavior = /datum/ai_behavior/find_hunt_target/machines
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target
	hunt_targets = list(/obj/machinery)

/// Find nearby machines
/datum/ai_behavior/find_hunt_target/machines
	/// Do we allow it to find spaceable doors?
	var/spaceable = FALSE

/datum/ai_behavior/find_hunt_target/machines/valid_dinner(mob/living/source, obj/machinery/dinner, radius)
	if(!ismachinery(dinner))
		return FALSE
	if(is_type_in_list(dinner, GLOB.swarmer_blacklist))
		return FALSE
	if(spaceable)
		return TRUE
	if(!istype(dinner, /obj/machinery/door))
		return TRUE
	for(var/turf/T in range(1, dinner))
		var/area/A = get_area(T)
		if(isspaceturf(T) || istype(A, /area/shuttle) || istype(A, /area/space) || istype(A, /area/station/engineering/engine/supermatter))
			return FALSE
	return TRUE

/datum/ai_behavior/find_hunt_target/machines/spaceable
	spaceable = TRUE
