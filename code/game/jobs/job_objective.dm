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
	var/text = "<hr><b><u>Выполнение работы</u></b>"

	for(var/datum/mind/employee in SSticker.minds)

		if(!employee.job_objectives.len)//If the employee had no objectives, don't need to process this.
			continue

		if(employee.assigned_role == employee.special_role || employee.offstation_role) //If the character is an offstation character, skip them.
			continue

		var/tasks_completed=0

		text += "<br>[employee.name] на должности [employee.assigned_role]:"

		var/count = 1
		for(var/datum/job_objective/objective in employee.job_objectives)
			if(objective.is_completed(1))
				text += "<br>&nbsp;-&nbsp;<B>Задача №[count]</B>: [objective.get_description()] <font color='green'><B>Выполнена!</B></font>"
				SSblackbox.record_feedback("nested tally", "employee_objective", 1, list("[objective.type]", "SUCCESS"))
				tasks_completed++
			else
				text += "<br>&nbsp;-&nbsp;<B>Задача №[count]</B>: [objective.get_description()] <font color='red'><b>Провалена.</b></font>"
				SSblackbox.record_feedback("nested tally", "employee_objective", 1, list("[objective.type]", "FAIL"))
			count++

		if(tasks_completed >= 1)
			text += "<br>&nbsp;<font color='green'><B>[employee.name] сделал свою чёртову работу!</B></font>"
			SSblackbox.record_feedback("tally", "employee_success", 1, "SUCCESS")

		else
			SSblackbox.record_feedback("tally", "employee_success", 1, "FAIL")

	return text

/datum/mind/proc/ambition_topic(href, href_list)
	var/ambition_func = FALSE

	if(href_list["amb_add"])
		ambition_func = TRUE
		if (ambition_objectives.len < ambition_limit)
			var/datum/ambition_objective/objective = new /datum/ambition_objective(usr.mind)

			var/counter = 0
			do
				counter = 0
				objective.description = objective.get_random_ambition()
				if (objective.description == null || objective.description == "")
					break
				for(var/datum/ambition_objective/amb in ambition_objectives)
					if (objective.description == amb.description) //&& objective.unique_datum_id != amb.unique_datum_id)
						counter++
						if (counter > 1)
							break
			while(counter > 1)

			to_chat(usr, "<span class='notice'>У вас появилась новая амбиция: [objective.description].</span>")
		else
			to_chat(usr, "<span class='warning'>Количество амбиций переполнено, избавьтесь от неосуществимых.</span>")
		add_misc_logs(usr, "has added [key_name(current)]'s ambition.")


	else if(href_list["amb_delete"])
		ambition_func = TRUE
		var/datum/ambition_objective/objective = locate(href_list["amb_delete"])
		if(!istype(objective))
			return
		ambition_objectives.Remove(objective)

		add_misc_logs(usr, "has removed one of [key_name(current)]'s ambitions: [objective]")
		qdel(objective)

	else if(href_list["amb_completed"])
		ambition_func = TRUE
		var/datum/ambition_objective/objective = locate(href_list["amb_completed"])
		if(!istype(objective))
			return
		objective.completed = !objective.completed

		if (objective.completed)
			to_chat(usr, "<span class='warning'>[pluralize_ru(usr.gender,"Моя","Наша")] амбиция выполнена. [pluralize_ru(usr.gender,"Поздравляю сам себя","Поздравим же нас")]!</span>")
		else
			to_chat(usr, "<span class='warning'>Пожалуй [pluralize_ru(usr.gender,"моя","наша")] амбиция еще не выполнена. Но у [pluralize_ru(usr.gender,"меня","нас")] еще будут возможности!</span>")
		add_misc_logs(usr, "[key_name(usr)] has toggled the completion of one of [key_name(current)]'s ambitions")

	// Обновляем открытую память
	if (ambition_func)
		show_memory()

	return ambition_func

