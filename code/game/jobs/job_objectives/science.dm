/////////////////////////////////////////////////////////////////////////////////////////
// Research
/////////////////////////////////////////////////////////////////////////////////////////

// MAXIMUM SCIENCE
/datum/job_objective/further_research
	objective_name = "Perform Research for Nanotrasen"
	description = "Utilize the facilities on this research installation to increase half of the research levels to level 5. \
	Copy the research onto disks and get the Supply department to ship them to the NAS Trurl."
	gives_payout = TRUE
	completion_payment = 150

/datum/job_objective/further_research/check_for_completion()
	var/techs_above_threshold = 0
	for(var/tech in SSeconomy.tech_levels)
		if(SSeconomy.tech_levels[tech] >= 5)
			techs_above_threshold++
	if(techs_above_threshold >= 6)
		return TRUE
	return FALSE

/////////////////////////////////////////////////////////////////////////////////////////
// Robotics
/////////////////////////////////////////////////////////////////////////////////////////

//Cyborgs
/datum/job_objective/make_cyborg
	objective_name = "Construct Additional Cyborgs"
	description = "Construct at least one cyborg for the station to increase workplace productivity."
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

/datum/job_objective/scan_organs
	objective_name = "Scan Extraterrestrial Organs"
	description = "Scan alien organs via the organ analyzer to learn more about their local ecology."
	gives_payout = TRUE
	completion_payment = 200
	/// How many organs should be scanned to complete this goal
	var/amount_to_scan = 10

/datum/job_objective/scan_organs/check_for_completion()
	var/total_organs
	for(var/item in GLOB.scanned_organs)
		total_organs += GLOB.scanned_organs[item]
	if(total_organs >= amount_to_scan)
		return TRUE
	return FALSE
