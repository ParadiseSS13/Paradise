/datum/autochef_task
	var/obj/machinery/autochef/autochef
	var/current_state = AUTOCHEF_TASK_START
	var/repeating = FALSE

/datum/autochef_task/New(autochef_)
	autochef = autochef_

/datum/autochef_task/proc/resume()
	return

/datum/autochef_task/proc/finalize()
	return

/datum/autochef_task/proc/reset()
	return
