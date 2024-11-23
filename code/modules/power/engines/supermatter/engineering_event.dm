/datum/engi_event
	var/name = "Unknown Engi Event (Report this to coders)"
	var/threat_level
	var/duration

/datum/engi_event/New()
	. = ..()

/datum/engi_event/proc/start_event()
	return

/datum/engi_event/proc/on_start()
	on_start()
	alert_engi()
	if(duration)
		addtimer(CALLBACK(src, PROC_REF(on_end)), duration)

/datum/engi_event/proc/alert_engi()
	return

/datum/engi_event/proc/on_end()
	return
