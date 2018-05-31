/datum/conditionalGenerator
	var/spawntype
	var/dir = SOUTH
	var/chance

/datum/conditionalGenerator/proc/condition(var/turf/T)
	return FALSE

/datum/mapGeneratorModule/conditional/place(var/turf/T)
	var/newtype = pickweight(spawnableAtoms)
	var/datum/conditionalGenerator/conGen = new newtype
	if(prob(chance) && conGen.condition(T))
		var/V = conGen.spawntype
		var/atom/A = new V(T)
		A.dir = conGen.dir