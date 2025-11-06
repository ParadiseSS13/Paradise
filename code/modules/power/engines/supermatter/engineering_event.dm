/datum/engi_event
	var/name = "Unknown Engi Event (Report this to coders)"
	/// The severity of the event
	var/threat_level
	/// How long the event lasts
	var/duration

/// Starts an event
/datum/engi_event/proc/start_event()
	on_start()
	alert_engi()
	if(duration)
		addtimer(CALLBACK(src, PROC_REF(on_end)), duration)
	return

/// To be executed once an event has been started
/datum/engi_event/proc/on_start()
	return

/// Send an alert to engineering about the event
/datum/engi_event/proc/alert_engi()
	return

/// What happens when an event ends.
/datum/engi_event/proc/on_end()
	return
