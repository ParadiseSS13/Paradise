//ODYSSEUS
/datum/job_objective/make_odysseus
	completion_payment = 600
	per_unit = 1

/datum/job_objective/make_odysseus/get_description()
	var/desc = "Make a Odysseus."
	desc += "([units_completed] created.)"
	return desc
