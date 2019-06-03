/datum/mind/var/list/job_objectives = list()

#define FINDJOBTASK_DEFAULT_NEW 1 // Make a new task of this type if one can't be found.
/datum/mind/proc/findJobTask(var/typepath, var/options = 0)
	var/datum/job_objective/task = locate(typepath) in job_objectives
	if(!istype(task,typepath))
		if(options & FINDJOBTASK_DEFAULT_NEW)
			task = new typepath()
			job_objectives += task
	return task

/datum/job_objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/completed = 0					//currently only used for custom objectives.
	var/per_unit = 0
	var/units_completed = 0
	var/units_compensated = 0 // Shit paid for
	var/units_requested = INFINITY
	var/completion_payment = 0			// Credits paid to owner when completed

/datum/job_objective/New(var/datum/mind/new_owner)
	owner = new_owner
	owner.job_objectives += src


/datum/job_objective/proc/get_description()
	var/desc = "Placeholder Objective"
	return desc

/datum/job_objective/proc/unit_completed(var/count=1)
	units_completed += count

/datum/job_objective/proc/is_completed()
	if(!completed)
		completed = check_for_completion()
	return completed

/datum/job_objective/proc/check_for_completion()
	if(per_unit)
		if(units_completed > 0)
			return 1
	return 0

/datum/game_mode/proc/declare_job_completion()
	var/text = "<hr><b><u>Job Completion</u></b>"

	for(var/datum/mind/employee in SSticker.minds)

		if(!employee.job_objectives.len)//If the employee had no objectives, don't need to process this.
			continue

		if(employee.assigned_role == employee.special_role || employee.offstation_role) //If the character is an offstation character, skip them.
			continue

		var/tasks_completed=0

		text += "<br>[employee.name] was a [employee.assigned_role]:"

		var/count = 1
		for(var/datum/job_objective/objective in employee.job_objectives)
			if(objective.is_completed(1))
				text += "<br>&nbsp;-&nbsp;<B>Task #[count]</B>: [objective.get_description()] <font color='green'><B>Completed!</B></font>"
				feedback_add_details("employee_objective","[objective.type]|SUCCESS")
				tasks_completed++
			else
				text += "<br>&nbsp;-&nbsp;<B>Task #[count]</B>: [objective.get_description()] <font color='red'><b>Failed.</b></font>"
				feedback_add_details("employee_objective","[objective.type]|FAIL")
			count++

		if(tasks_completed >= 1)
			text += "<br>&nbsp;<font color='green'><B>[employee.name] did [employee.p_their()] fucking job!</B></font>"
			feedback_add_details("employee_success","SUCCESS")
		else
			feedback_add_details("employee_success","FAIL")

	return text