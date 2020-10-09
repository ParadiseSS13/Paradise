//POD
/datum/job_objective/make_pod
	completion_payment = 500
	per_unit = 1

/datum/job_objective/make_pod/get_description()
	var/desc = "Make a Spacepod."
	desc += "([units_completed] created.)"
	return desc

//ESTATION GOALS
/datum/job_objective/make_station_goal
	completion_payment = 20000
	per_unit = 1

/datum/job_objective/make_station_goal/get_description()
	var/desc = "Complete the station goal."
	return desc

/datum/job_objective/make_station_goal/check_for_completion()
	var/datum/station_goal/ss = new/datum/station_goal/station_shield
	var/datum/station_goal/bsa = new/datum/station_goal/bluespace_cannon
	var/datum/station_goal/dnav = new/datum/station_goal/dna_vault
	if(ss.check_completion() || bsa.check_completion() || dnav.check_completion())
		return TRUE
	return FALSE

