//Preset for general and toggled actions
/datum/action/innate
	var/active = FALSE

/datum/action/innate/Trigger(left_click)
	if(!..())
		return FALSE
	if(!active)
		Activate()
	else
		Deactivate()
	return TRUE

/datum/action/innate/proc/Activate()
	return

/datum/action/innate/proc/Deactivate()
	return
