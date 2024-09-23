/////////////////////////////////////////////////////////////////////////////////////////
// Research
/////////////////////////////////////////////////////////////////////////////////////////

// MAXIMUM SCIENCE
/datum/job_objective/further_research
	objective_name = "Perform Research for Nanotrasen"
	description = "Utilize the facilities on this research installation to increase half the station's research levels above level 2, have cargo ship the research to centcomm in crates."
	gives_payout = TRUE
	completion_payment = 150

/datum/job_objective/further_research/check_for_completion()
	var/tech_above_two = 0
	for(var/tech in SSeconomy.tech_levels)
		if(SSeconomy.tech_levels[tech] > 2)
			tech_above_two++
	if(tech_above_two >= 6)
		return TRUE
	return FALSE

/////////////////////////////////////////////////////////////////////////////////////////
// Robotics
/////////////////////////////////////////////////////////////////////////////////////////

//Cyborgs
/datum/job_objective/make_cyborg
	objective_name = "Construct Additional Cyborgs"
	description = "Construct at least one cyborg for the station to increase workplace productivity"
	gives_payout = TRUE
	completion_payment = 100

/datum/job_objective/make_cyborg/check_for_completion()
	return completed

//RIPLEY's
/datum/job_objective/make_ripley
	objective_name = "Construct a Working Class Mech"
	description = "Construct a Ripley or Firefighter Mech for station usage. Don't forget about modules!"
	gives_payout = TRUE
	completion_payment = 200

/datum/job_objective/make_ripley/check_for_completion()
	return completed
