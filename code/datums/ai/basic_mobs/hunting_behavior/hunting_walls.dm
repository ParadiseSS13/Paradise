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
	var/list/targets = can_see(source, dinner, radius)
	var/list/filtered = list()
	for(var/atom/target in targets)
		if(!iswallturf(target) && !istype(target, /obj/structure))
			continue
		if(istype(target, /turf/simulated/wall/indestructible))
			continue
		if(spaceable)
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
