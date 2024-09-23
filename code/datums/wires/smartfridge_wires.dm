/datum/wires/smartfridge
	holder_type = /obj/machinery/smartfridge
	wire_count = 3
	proper_name = "Smartfridge"

/datum/wires/smartfridge/New(atom/_holder)
	wires = list(WIRE_ELECTRIFY, WIRE_IDSCAN, WIRE_THROW_ITEM)
	return ..()

/datum/wires/smartfridge/secure
	randomize = TRUE
	wire_count = 4 // 3 actual, 1 dud.

/datum/wires/smartfridge/interactable(mob/user)
	var/obj/machinery/smartfridge/S = holder
	if(iscarbon(user) && S.Adjacent(user) && S.seconds_electrified && S.shock(user, 100))
		return FALSE
	if(S.panel_open)
		return TRUE
	return FALSE

/datum/wires/smartfridge/get_status()
	. = ..()
	var/obj/machinery/smartfridge/S = holder
	. += "The orange light is [S.seconds_electrified ? "off" : "on"]."
	. += "The red light is [S.shoot_inventory ? "off" : "blinking"]."
	. += "A [S.scan_id ? "purple" : "yellow"] light is on."

/datum/wires/smartfridge/on_pulse(wire)
	var/obj/machinery/smartfridge/S = holder
	switch(wire)
		if(WIRE_THROW_ITEM)
			S.shoot_inventory = !S.shoot_inventory
		if(WIRE_ELECTRIFY)
			S.seconds_electrified = 30
		if(WIRE_IDSCAN)
			S.scan_id = !S.scan_id
	..()

/datum/wires/smartfridge/on_cut(wire, mend)
	var/obj/machinery/smartfridge/S = holder
	switch(wire)
		if(WIRE_THROW_ITEM)
			S.shoot_inventory = !mend
		if(WIRE_ELECTRIFY)
			if(mend)
				S.seconds_electrified = 0
			else
				S.seconds_electrified = -1
		if(WIRE_IDSCAN)
			S.scan_id = TRUE
	..()
