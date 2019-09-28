//POD
/datum/job_objective/make_pod
	completion_payment = 500
	per_unit = 1

/datum/job_objective/make_pod/get_description()
	var/desc = "Make a Spacepod."
	desc += "([units_completed] created.)"
	return desc
