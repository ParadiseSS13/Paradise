/datum/wires/autolathe
	holder_type = /obj/machinery/autolathe
	wire_count = 10
	proper_name = "Autolathe"

/datum/wires/autolathe/New(atom/_holder)
	wires = list(WIRE_AUTOLATHE_HACK, WIRE_ELECTRIFY, WIRE_AUTOLATHE_DISABLE)
	return ..()

/datum/wires/autolathe/get_status()
	. = ..()
	var/obj/machinery/autolathe/A = holder
	. += "The red light is [A.disabled ? "off" : "on"]."
	. += "The green light is [A.shocked ? "off" : "on"]."
	. += "The blue light is [A.hacked ? "off" : "on"]."

/datum/wires/autolathe/interactable(mob/user)
	var/obj/machinery/autolathe/A = holder
	if(iscarbon(user) && A.Adjacent(user) && A.shocked && A.shock(user, 100))
		return FALSE
	if(A.panel_open)
		return TRUE
	return FALSE

/datum/wires/autolathe/on_cut(wire, mend)
	var/obj/machinery/autolathe/A = holder
	switch(wire)
		if(WIRE_AUTOLATHE_HACK)
			A.adjust_hacked(!mend)
		if(WIRE_ELECTRIFY)
			A.shocked = !mend
		if(WIRE_AUTOLATHE_DISABLE)
			A.disabled = !mend
	..()

/datum/wires/autolathe/on_pulse(wire)
	if(is_cut(wire))
		return
	var/obj/machinery/autolathe/A = holder
	switch(wire)
		if(WIRE_AUTOLATHE_HACK)
			A.adjust_hacked(!A.hacked)
			addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/autolathe, check_hacked_callback)), 5 SECONDS)

		if(WIRE_ELECTRIFY)
			A.shocked = !A.shocked
			addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/autolathe, check_electrified_callback)), 5 SECONDS)

		if(WIRE_AUTOLATHE_DISABLE)
			A.disabled = !A.disabled
			addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/autolathe, check_disabled_callback)), 5 SECONDS)
