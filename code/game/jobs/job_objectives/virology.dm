/datum/job_objective/virus_samples
	objective_name = "Create and Deliver Virus Samples"
	description = "Complete at least 2 of the virology goals requesting various virus samples, have cargo ship the virus samples to centcomm in crates."
	gives_payout = TRUE
	completion_payment = 200

/datum/job_objective/virus_samples/check_for_completion()
	var/completed_goals = 0
	for(var/datum/virology_goal/goal in (GLOB.virology_goals + GLOB.archived_virology_goals))
		if(goal.completed)
			completed_goals++
	return completed_goals >= 2
