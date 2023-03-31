/datum/wires/tesla_coil
	wire_count = 1
	holder_type = /obj/machinery/power/tesla_coil
	proper_name = "Tesla coil"
	window_x = 320
	window_y = 50

/datum/wires/tesla_coil/New(atom/_holder)
	wires = list(WIRE_TESLACOIL_ZAP)
	return ..()

/datum/wires/tesla_coil/interactable(mob/user)
	var/obj/machinery/power/tesla_coil/T = holder
	if(T && T.panel_open)
		return TRUE
	return FALSE

/datum/wires/tesla_coil/on_pulse(wire)
	var/obj/machinery/power/tesla_coil/T = holder
	switch(wire)
		if(WIRE_TESLACOIL_ZAP)
			T.zap()
	..()
