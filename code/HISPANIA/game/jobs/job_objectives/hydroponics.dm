// NEW PLATNS

/datum/job_objective/further_plants
	completion_payment = 250
	per_unit = 1

/datum/job_objective/further_plants/get_description()
	var/desc = "create new varieties of plants, and send it to centcomm from cargo."
	desc += "([units_completed] completed.)"
	return desc

/datum/job_objective/exotic_plants/check_for_completion()
	for(var/plant in SSshuttle.techLevels)
		if(SSshuttle.discoveredPlants[plant] > 0)
			return 1
	return 0
