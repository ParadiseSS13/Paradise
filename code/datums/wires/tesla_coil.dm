/datum/wires/tesla_coil
	wire_count = 1
	holder_type = /obj/machinery/power/tesla_coil

#define TESLACOIL_WIRE_ZAP 1

/datum/wires/tesla_coil/GetWireName(index)
	switch(index)
		if(TESLACOIL_WIRE_ZAP)
			return "Zap"

/datum/wires/tesla_coil/CanUse(mob/living/L)
	var/obj/machinery/power/tesla_coil/T = holder
	if(T && T.panel_open)
		return 1
	return 0

/datum/wires/tesla_coil/UpdatePulsed(index)
	var/obj/machinery/power/tesla_coil/T = holder
	switch(index)
		if(TESLACOIL_WIRE_ZAP)
			T.zap()
	..()
