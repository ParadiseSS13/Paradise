/datum/antagonist/mindslave/greet()
	SEND_SOUND(owner.current, sound('sound/ambience/alarm4.ogg'))
	return ..()
