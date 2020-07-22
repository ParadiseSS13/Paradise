/datum/wires/apc
	holder_type = /obj/machinery/power/apc
	wire_count = 4

var/const/APC_WIRE_IDSCAN = 1
var/const/APC_WIRE_MAIN_POWER1 = 2
var/const/APC_WIRE_MAIN_POWER2 = 4
var/const/APC_WIRE_AI_CONTROL = 8

/datum/wires/apc/GetWireName(index)
	switch(index)
		if(APC_WIRE_IDSCAN)
			return "ID Scan"

		if(APC_WIRE_MAIN_POWER1)
			return "Primary Power"

		if(APC_WIRE_MAIN_POWER2)
			return "Secondary Power"

		if(APC_WIRE_AI_CONTROL)
			return "AI Control"

/datum/wires/apc/get_status()
	. = ..()
	var/obj/machinery/power/apc/A = holder
	. += "The APC is [A.locked ? "" : "un"]locked."
	. += A.shorted ? "The APCs power has been shorted." : "The APC is working properly!"
	. += "The 'AI control allowed' light is [A.aidisabled ? "off" : "on"]."


/datum/wires/apc/CanUse(mob/living/L)
	var/obj/machinery/power/apc/A = holder
	if(A.panel_open && !A.opened)
		return TRUE
	return FALSE

/datum/wires/apc/UpdatePulsed(index)

	var/obj/machinery/power/apc/A = holder

	switch(index)

		if(APC_WIRE_IDSCAN)
			A.locked = 0

			spawn(300)
				if(A)
					A.locked = 1
					A.updateDialog()

		if(APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)
			if(A.shorted == 0)
				A.shorted = 1

				spawn(1200)
					if(A && !IsIndexCut(APC_WIRE_MAIN_POWER1) && !IsIndexCut(APC_WIRE_MAIN_POWER2))
						A.shorted = 0
						A.updateDialog()

		if(APC_WIRE_AI_CONTROL)
			if(A.aidisabled == 0)
				A.aidisabled = 1

				spawn(10)
					if(A && !IsIndexCut(APC_WIRE_AI_CONTROL))
						A.aidisabled = 0
						A.updateDialog()

	..()

/datum/wires/apc/UpdateCut(index, mended)
	var/obj/machinery/power/apc/A = holder

	switch(index)
		if(APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)

			if(!mended)
				A.shock(usr, 50)
				A.shorted = 1

			else if(!IsIndexCut(APC_WIRE_MAIN_POWER1) && !IsIndexCut(APC_WIRE_MAIN_POWER2))
				A.shorted = 0
				A.shock(usr, 50)

		if(APC_WIRE_AI_CONTROL)

			if(!mended)
				if(A.aidisabled == 0)
					A.aidisabled = 1
			else
				if(A.aidisabled == 1)
					A.aidisabled = 0
	..()