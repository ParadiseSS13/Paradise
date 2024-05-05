/datum/wires/suitstorage
	holder_type = /obj/machinery/suit_storage_unit
	wire_count = 8
	proper_name = "Suit storage unit"

/datum/wires/suitstorage/New(atom/_holder)
	wires = list(WIRE_IDSCAN, WIRE_ELECTRIFY, WIRE_SAFETY, WIRE_SSU_UV)
	return ..()

/datum/wires/suitstorage/get_status()
	. = ..()
	var/obj/machinery/suit_storage_unit/A = holder
	. += "The blue light is [A.secure ? "on" : "off"]."
	. += "The red light is [A.safeties ? "off" : "blinking"]."
	. += "The green light is [A.shocked ? "on" : "off"]."
	. += "The UV display shows [A.uv_super ? "15 nm" : "185 nm"]."

/datum/wires/suitstorage/interactable(mob/user)
	var/obj/machinery/suit_storage_unit/A = holder
	if(A.panel_open)
		return TRUE
	return FALSE

/datum/wires/suitstorage/on_cut(wire, mend)
	var/obj/machinery/suit_storage_unit/A = holder
	switch(wire)
		if(WIRE_IDSCAN)
			A.secure = mend

		if(WIRE_SAFETY)
			A.safeties = mend

		if(WIRE_ELECTRIFY)
			A.shocked = !mend
			A.shock(usr, 50)

		if(WIRE_SSU_UV)
			A.uv_super = !mend
	..()

/datum/wires/suitstorage/on_pulse(wire)
	var/obj/machinery/suit_storage_unit/A = holder
	if(is_cut(wire))
		return
	switch(wire)
		if(WIRE_IDSCAN)
			A.secure = !A.secure

		if(WIRE_SAFETY)
			A.safeties = !A.safeties

		if(WIRE_ELECTRIFY)
			A.shocked = !A.shocked
			if(A.shocked)
				A.shock(usr, 100)
				addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/suit_storage_unit, check_electrified_callback)), 5 SECONDS)

		if(WIRE_SSU_UV)
			A.uv_super = !A.uv_super
	..()
