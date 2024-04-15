/datum/wires/vending
	holder_type = /obj/machinery/economy/vending
	wire_count = 4
	proper_name = "Vending machine"

/datum/wires/vending/New(atom/_holder)
	wires = list(WIRE_THROW_ITEM, WIRE_IDSCAN, WIRE_ELECTRIFY, WIRE_CONTRABAND)
	return ..()

/datum/wires/vending/interactable(mob/user)
	var/obj/machinery/economy/vending/V = holder
	if(!issilicon(user) && V.seconds_electrified && V.shock(user, 100))
		return FALSE
	if(V.panel_open)
		return TRUE
	return FALSE

/datum/wires/vending/get_status()
	. = ..()
	var/obj/machinery/economy/vending/V = holder
	. += "The orange light is [V.seconds_electrified ? "on" : "off"]."
	. += "The red light is [V.shoot_inventory ? "off" : "blinking"]."
	. += "The green light is [V.extended_inventory ? "on" : "off"]."
	. += "A [V.scan_id ? "purple" : "yellow"] light is on."

/datum/wires/vending/on_pulse(wire)
	var/obj/machinery/economy/vending/V = holder
	switch(wire)
		if(WIRE_THROW_ITEM)
			V.shoot_inventory = !V.shoot_inventory
		if(WIRE_CONTRABAND)
			V.extended_inventory = !V.extended_inventory
		if(WIRE_ELECTRIFY)
			V.seconds_electrified = 30
		if(WIRE_IDSCAN)
			V.scan_id = !V.scan_id
	..()

/datum/wires/vending/on_cut(wire, mend)
	var/obj/machinery/economy/vending/V = holder
	switch(wire)
		if(WIRE_THROW_ITEM)
			V.shoot_inventory = !mend
		if(WIRE_CONTRABAND)
			V.extended_inventory = FALSE
		if(WIRE_ELECTRIFY)
			if(mend)
				V.seconds_electrified = 0
			else
				V.seconds_electrified = -1
		if(WIRE_IDSCAN)
			V.scan_id = TRUE
	..()
