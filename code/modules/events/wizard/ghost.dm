/datum/event/wizard/ghost //The spook is real

/datum/event/wizard/ghost/start()
	var/msg = span_warning("You suddenly feel extremely obvious...")
	set_observer_default_invisibility(0, msg)

/datum/event/wizard/ghost_mute //The spook is silent

/datum/event/wizard/ghost_mute/start()
	GLOB.dsay_enabled = FALSE
	var/sound/S = sound('sound/hallucinations/wail.ogg')
	for(var/mob/dead/observer/silenced in GLOB.player_list)
		to_chat(silenced, span_warning("Magical forces wrap around your spectral form. You can no longer speak to other ghosts!"))
		SEND_SOUND(silenced, S)
