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
	var/list/targets = can_see(source, dinner, radius)
	if(spaceable)
		return targets
	var/list/filtered = list()
	for(var/atom/target in targets)
		if(!istype(target, /obj/machinery/door))
			filtered += target
			continue
		var/passed = TRUE
		for(var/turf/T in range(1, target))
			var/area/A = get_area(T)
			if(isspaceturf(T) || istype(A, /area/shuttle) || istype(A, /area/space) || istype(A, /area/station/engineering/engine/supermatter))
				passed = FALSE
				break
		if(passed)
			filtered += target
	return filtered

/datum/ai_behavior/find_hunt_target/machines/spaceable
	spaceable = TRUE
