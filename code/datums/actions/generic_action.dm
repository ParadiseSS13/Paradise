//Preset for action that call specific procs (consider innate)
/datum/action/generic
	var/procname

/datum/action/generic/Trigger(left_click)
	if(!..())
		return FALSE
	if(target && procname)
		call(target,procname)(usr)
	return TRUE
