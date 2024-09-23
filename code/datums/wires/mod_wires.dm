/datum/wires/mod
	holder_type = /obj/item/mod/control
	randomize = TRUE //Every modsuit is personalised
	wire_count = 6 // 4 actual, 2 duds
	proper_name = "MOD control unit"

/datum/wires/mod/New(atom/holder)
	wires = list(WIRE_HACK, WIRE_DISABLE, WIRE_ELECTRIFY, WIRE_INTERFACE)
	..()

/datum/wires/mod/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/mod/control/mod = holder
	if(mod.seconds_electrified && mod.shock(user))
		return FALSE
	return mod.open

/datum/wires/mod/get_status()
	var/obj/item/mod/control/mod = holder
	var/list/status = list()
	status += "The orange light is [mod.seconds_electrified ? "on" : "off"]."
	status += "The red light is [mod.malfunctioning ? "off" : "blinking"]."
	status += "The green light is [mod.locked ? "on" : "off"]."
	status += "The yellow light is [mod.interface_break ? "off" : "on"]."
	return status

/datum/wires/mod/on_pulse(wire)
	var/obj/item/mod/control/mod = holder
	switch(wire)
		if(WIRE_HACK)
			mod.locked = !mod.locked
		if(WIRE_DISABLE)
			mod.malfunctioning = TRUE
		if(WIRE_ELECTRIFY)
			mod.seconds_electrified = 30
		if(WIRE_INTERFACE)
			mod.interface_break = !mod.interface_break

/datum/wires/mod/on_cut(wire, mend)
	var/obj/item/mod/control/mod = holder
	switch(wire)
		if(WIRE_HACK)
			if(!mend)
				mod.req_access = list()
		if(WIRE_DISABLE)
			mod.malfunctioning = !mend
		if(WIRE_ELECTRIFY)
			if(mend)
				mod.seconds_electrified = 0
			else
				mod.seconds_electrified = -1
		if(WIRE_INTERFACE)
			mod.interface_break = !mend

/datum/wires/mod/ui_act(action, params)
	var/obj/item/mod/control/mod = holder
	if(!issilicon(usr) && mod.seconds_electrified && mod.shock(usr))
		return FALSE
	return ..()

