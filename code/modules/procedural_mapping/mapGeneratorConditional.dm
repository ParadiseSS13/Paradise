/datum/conditionalGenerator
	var/spawntype
	var/dir = SOUTH

/datum/conditionalGenerator/proc/condition(var/turf/T)
	return FALSE