/////////////////////////////////////////////////////////////////////////////////////////
//Service
/////////////////////////////////////////////////////////////////////////////////////////

// Janitor
/datum/job_objective/ultraclean/get_description()
	var/desc = "Make the station ULTRA clean"
	return desc

/datum/job_objective/ultraclean/check_in_the_end()
	if(!score_mess)
		return 1
	else return 0

/datum/job_objective/harvest/get_description()
	var/desc = "Harvest at least 30 plants (harvested [score_stuffharvested])"
	return desc

/datum/job_objective/harvest/check_in_the_end()
  if(score_stuffharvested < 30)
    return 0
  else return 1

/datum/job_objective/funeral/get_description()
	var/desc = "Do not left dead bodies on the station at the round end."
	return desc

/datum/job_objective/funeral/check_in_the_end()
  if(score_deadcrew)
    return 0
  else return 1
