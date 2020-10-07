/datum/event/wizard/ghost //The spook is real

/datum/event/wizard/ghost/start()
	var/msg = "<span class='warning'>You suddenly feel extremely obvious...<br><b>Cast Boo! on an item to possess it!</b></span>"
	set_observer_default_invisibility(0, msg)
	set_ghost_power_level(GHOST_POWER_SPOOKY)

