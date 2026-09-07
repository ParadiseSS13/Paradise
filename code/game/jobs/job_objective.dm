/datum/mind/proc/find_job_task(typepath)
	return locate(typepath) in job_objectives

/datum/job_objective
	///Fluff name of the objective
	var/objective_name = "Placeholder Objective"
	///short description of what the objective entails, should include how to complete the objective if not immediately clear
	var/description = "A coder fucked up, one can finish this objective by making an issue report on the GitHub (Top-right of the screen has a button for it)"
	///Who owns the objective
	var/datum/mind/owner
	///Which money account this objective is tied to, makes life easier during payout (signficantly)
	var/datum/money_account/owner_account

	///Has this objective been completed?
	var/completed = FALSE
	///Has the owner been rewarded yet?
	var/payout_given = FALSE

	///does this objective give out monetary rewards upon completion?
	var/gives_payout = FALSE
	///how many credits are awarded upon completion of job objective
	var/completion_payment = 0

/datum/job_objective/New(datum/mind/new_owner)
	owner = new_owner
	owner.job_objectives += src

/datum/job_objective/proc/set_owner_account(datum/money_account/account) //needed for GC'ing
	owner_account = account
	RegisterSignal(owner_account, COMSIG_PARENT_QDELETING, PROC_REF(clear_owner_account))

/datum/job_objective/proc/clear_owner_account() //needed for GC'ing
	UnregisterSignal(owner_account, COMSIG_PARENT_QDELETING)
	owner_account = null

/datum/job_objective/proc/is_completed()
	if(!completed)
		completed = check_for_completion()
	return completed

/datum/job_objective/proc/check_for_completion()
	//please override me :)
	CRASH("check_for_completion() not overridden on [type]")



//below is game mode shit, why is this even in this file (instead of end of round scoreboard)?

/datum/game_mode/proc/declare_job_completion()
	var/text = "<hr><b><u>Job Completion</u></b>"

	for(var/datum/mind/employee in SSticker.minds)

		if(!length(employee.job_objectives)) //If the employee had no objectives, don't need to process this.
			continue

		if(employee.assigned_role == employee.special_role || employee.offstation_role) //If the character is an offstation character, skip them.
			continue

		var/tasks_completed = 0

		text += "<br>[employee.name] was a [employee.assigned_role]:"

		var/count = 1
		for(var/datum/job_objective/objective in employee.job_objectives)
			if(objective.is_completed(1))
				text += "<br>&nbsp;-&nbsp;<B>Task #[count]</B>: [objective.description] <font color='green'><B>Completed!</B></font>"
				SSblackbox.record_feedback("nested tally", "employee_objective", 1, list("[objective.type]", "SUCCESS"))
				tasks_completed++
			else
				text += "<br>&nbsp;-&nbsp;<B>Task #[count]</B>: [objective.description] <font color='red'><b>Failed.</b></font>"
				SSblackbox.record_feedback("nested tally", "employee_objective", 1, list("[objective.type]", "FAIL"))
			count++

		if(tasks_completed >= 1)
			text += "<br>&nbsp;<font color='green'><b>[employee.name] did their job!</b></font>"
			SSblackbox.record_feedback("tally", "employee_success", 1, "SUCCESS")
		else
			SSblackbox.record_feedback("tally", "employee_success", 1, "FAIL")

	return text
