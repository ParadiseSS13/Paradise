/////////////////////////////////////////////////////////////////////////////////////////
// Research
/////////////////////////////////////////////////////////////////////////////////////////

// MAXIMUM SCIENCE
/datum/job_objective/further_research
	completion_payment = 5
	per_unit = 1

/datum/job_objective/further_research/get_description()
	var/desc = "Research tech levels, and have cargo ship them to centcomm."
	desc += "([units_completed] completed.)"
	return desc

/datum/job_objective/maximize_research/check_for_completion()
	for(var/tech in SSeconomy.techLevels)
		if(SSeconomy.techLevels[tech] > 0)
			return TRUE
	return FALSE

/////////////////////////////////////////////////////////////////////////////////////////
// Robotics
/////////////////////////////////////////////////////////////////////////////////////////

//Cyborgs
/datum/job_objective/make_cyborg
	completion_payment = 100
	per_unit = 1

/datum/job_objective/make_cyborg/get_description()
	var/desc = "Make a cyborg."
	desc += "([units_completed] created.)"
	return desc



//RIPLEY's
/datum/job_objective/make_ripley
	completion_payment = 600
	per_unit = 1

/datum/job_objective/make_ripley/get_description()
	var/desc = "Make a Ripley or Firefighter."
	desc += "([units_completed] created.)"
	return desc
