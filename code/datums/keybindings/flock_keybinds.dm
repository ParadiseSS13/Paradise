/datum/keybinding/flock/can_use(client/C, mob/M)
	return isflockmob(M) && ..()

/datum/keybinding/flock/intent
	/// The intent to switch to.
	var/intent

/datum/keybinding/flock/intent/down(client/C)
	. = ..()
	var/mob/living/basic/flock/M = C.mob
	M.a_intent_change(intent)

/datum/keybinding/flock/intent/help
	name = "Help Intent (Tap)"
	intent = INTENT_HELP
	keys = list("1")

/datum/keybinding/flock/intent/disarm
	name = "Disarm Intent (Tap)"
	intent = INTENT_DISARM
	keys = list("2")

/datum/keybinding/flock/intent/grab
	name = "Grab Intent (Tap)"
	intent = INTENT_GRAB
	keys = list("3")

/datum/keybinding/flock/intent/harm
	name = "Harm Intent (Tap)"
	intent = INTENT_HARM
	keys = list("4")

/datum/keybinding/flock/cycle_part
	name = "Cycle Part"
	keys = list("X")

/datum/keybinding/flock/cycle_part/can_use(client/C, mob/M)
	return isflockdrone(M)

/datum/keybinding/flock/cycle_part/down(client/C)
	. = ..()
	var/mob/living/basic/flock/drone/M = C.mob
	if(M.active_part == M.parts[1])
		M.set_active_part(M.parts[2])
	else if(M.active_part == M.parts[2])
		M.set_active_part(M.parts[3])
	else if(M.active_part == M.parts[3])
		M.set_active_part(M.parts[1])

/datum/keybinding/flock/flockphase
	name = "Toggle Flockphase"
	keys = list("C")

/datum/keybinding/flock/flockphase/can_use(client/C, mob/M)
	return isflockdrone(M)

/datum/keybinding/flock/flockphase/down(client/C)
	. = ..()
	var/mob/living/basic/flock/drone/M = C.mob
	if(HAS_TRAIT(M, TRAIT_FLOCKPHASE))
		M.stop_flockphase()
	else
		if(M.can_flockphase() && M.flockphase_tax())
			M.start_flockphase()
