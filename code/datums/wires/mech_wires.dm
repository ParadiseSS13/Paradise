
/datum/wires/mech
	holder_type = /obj/mecha
	wire_count = 16 // 10 actual, 6 duds
	proper_name = "Airlock"

/datum/wires/airlock/New(atom/_holder)
	wires = list(WIRE_MECH_DIRECTION, WIRE_MECH_DNA, WIRE_MECH_POWER , WIRE_MECH_SELECT_MODULE, WIRE_MECH_STRAFE, WIRE_MECH_USE_MODULE, WIRE_MECH_WALK, WIRE_MECH_RADIO , WIRE_MECH_VISUALDATA)
	return ..()

/datum/wires/mech/interactable(mob/user)
	var/obj/mecha/A = holder
	if(A)
		return TRUE
	return FALSE

/datum/wires/mech/get_status()
	. = ..()
	var/obj/mecha/A = holder
	. += "text text text"

/datum/wires/mech/on_cut(wire, mend)
	var/obj/mecha/A = holder
	switch(wire)
		if(WIRE_MECH_DIRECTION)
			return
		if(WIRE_MECH_DNA)
			return
		if(WIRE_MECH_POWER)
			return
		if(WIRE_MECH_SELECT_MODULE)
			return
		if(WIRE_MECH_STRAFE)
			return
		if(WIRE_MECH_USE_MODULE)
			return
		if(WIRE_MECH_WALK)
			return
		if(WIRE_MECH_RADIO)
			return
		if(WIRE_MECH_VISUALDATA)
			return

	. = ..()

/datum/wires/mech/on_pulse(wire)
	var/obj/mecha/A = holder
	switch(wire)
		if(WIRE_MECH_DIRECTION)
			return
		if(WIRE_MECH_DNA)
			return
		if(WIRE_MECH_POWER)
			return
		if(WIRE_MECH_SELECT_MODULE)
			return
		if(WIRE_MECH_STRAFE)
			return
		if(WIRE_MECH_USE_MODULE)
			return
		if(WIRE_MECH_WALK)
			return
		if(WIRE_MECH_RADIO)
			return
		if(WIRE_MECH_VISUALDATA)
			return

	. = ..()

