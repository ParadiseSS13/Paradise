/////////////////////////////////////////////////////////////////////////////////////////
//Medical
/////////////////////////////////////////////////////////////////////////////////////////

/datum/job_objective/disease/get_description()
	var/desc = "Don't let the rampant diseases capture the station!"
	return desc

/datum/job_objective/disease/check_in_the_end()
  if(score_disease)
    return 0
  else return 1

/datum/job_objective/hurt/get_description()
	var/desc = "Heal all personnel on the evac shuttle at the round end."
	return desc

/datum/job_objective/hurt/check_in_the_end()
  if(score_dmgestdamage > 10)
    return 0
  else return 1
