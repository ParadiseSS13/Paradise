/datum/event/wizard/ghost //The spook is real

/datum/event/wizard/ghost/start()
	var/msg = "<span class='warning'>You suddenly feel extremely obvious...</span>"
	set_observer_default_invisibility(0, msg)
