/datum/mind/var/list/job_objectives=list()

#define FINDJOBTASK_DEFAULT_NEW 1 // Make a new task of this type if one can't be found.
/datum/mind/proc/findJobTask(var/typepath,var/options=0)
	var/datum/job_objective/task = locate(typepath) in src.job_objectives
	if(!istype(task,typepath))
		if(options & FINDJOBTASK_DEFAULT_NEW)
			task = new typepath()
			src.job_objectives += task
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
	owner=new_owner
	owner.job_objectives += src

/datum/job_objective/Destroy()

/datum/job_objective/proc/get_description()
	return "Placeholder objective."

/datum/job_objective/proc/unit_completed(var/count=1)
	units_completed += count

/datum/job_objective/proc/is_completed()
	if(!completed)
		completed = check_for_completion()
	return completed

/datum/job_objective/proc/check_for_completion()
	return per_unit && units_completed > 0

/datum/game_mode/proc/declare_job_completion()
	var/text = "<FONT size = 2><B>Job Completion:</B></FONT>"
	var/numEmployees=0
	for(var/datum/mind/employee in ticker.minds)
		if(!employee.job_objectives.len)//If the employee had no objectives, don't need to process this.
			continue
		if(!employee.assigned_role=="MODE")//If the employee is a gamemode thing, skip.
			continue
		numEmployees++
		var/tasks_completed=0

		//text += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job]:\n"
		text += "<br>[employee.key] was [employee.name], the [employee.assigned_role] ("
		if(employee.current)
			if(employee.current.stat == DEAD)
				text += "died"
			else
				text += "survived"
			if(employee.current.real_name != employee.name)
				text += " as [employee.current.real_name]"
		else
			text += "body destroyed"
		text += ")"

		var/count = 1
		for(var/datum/job_objective/objective in employee.job_objectives)
			if(objective.is_completed(1))
				text += "<br><B>Task #[count]</B>: [objective.get_description()] <font color='green'><B>Completed!</B></font>"
				feedback_add_details("employee_objective","[objective.type]|SUCCESS")
				tasks_completed++
			else
				feedback_add_details("employee_objective","[objective.type]|FAIL")
			count++

		if(tasks_completed>=1)
			text += "<br><font color='green'><B>The [employee.assigned_role] did their fucking job!</B></font>"
			feedback_add_details("employee_success","SUCCESS")
		else
			feedback_add_details("employee_success","FAIL")
	if(numEmployees>0)
		world << text
	return 1