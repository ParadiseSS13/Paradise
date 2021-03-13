// NEW PLATNS
/datum/job_objective/further_plants
	completion_payment = 250
	per_unit = 1

/datum/job_objective/further_plants/get_description()
	var/desc = "Create new varieties of plants, and send it to centcomm from cargo."
	desc += "([units_completed] completed.)"
	return desc
