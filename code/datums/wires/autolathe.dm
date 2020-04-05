/datum/wires/autolathe
	holder_type = /obj/machinery/autolathe
	wire_count = 10

#define AUTOLATHE_HACK_WIRE 1
#define AUTOLATHE_SHOCK_WIRE 2
#define AUTOLATHE_DISABLE_WIRE 4

/datum/wires/autolathe/GetWireName(index)
	switch(index)
		if(AUTOLATHE_HACK_WIRE)
			return "Hack"

		if(AUTOLATHE_SHOCK_WIRE)
			return "Shock"

		if(AUTOLATHE_DISABLE_WIRE)
			return "Disable"

/datum/wires/autolathe/get_status()
	. = ..()
	var/obj/machinery/autolathe/A = holder
	. += "The red light is [A.disabled ? "off" : "on"]."
	. += "The green light is [A.shocked ? "off" : "on"]."
	. += "The blue light is [A.hacked ? "off" : "on"]."

/datum/wires/autolathe/CanUse()
	var/obj/machinery/autolathe/A = holder
	if(A.panel_open)
		return 1
	return 0

/datum/wires/autolathe/UpdateCut(index, mended)
	var/obj/machinery/autolathe/A = holder
	switch(index)
		if(AUTOLATHE_HACK_WIRE)
			A.adjust_hacked(!mended)
		if(AUTOLATHE_SHOCK_WIRE)
			A.shocked = !mended
		if(AUTOLATHE_DISABLE_WIRE)
			A.disabled = !mended
	..()

/datum/wires/autolathe/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/autolathe/A = holder
	switch(index)
		if(AUTOLATHE_HACK_WIRE)
			A.adjust_hacked(!A.hacked)
			updateUIs()
			spawn(50)
				if(A && !IsIndexCut(index))
					A.adjust_hacked(0)
					updateUIs()
		if(AUTOLATHE_SHOCK_WIRE)
			A.shocked = !A.shocked
			updateUIs()
			spawn(50)
				if(A && !IsIndexCut(index))
					A.shocked = 0
					updateUIs()
		if(AUTOLATHE_DISABLE_WIRE)
			A.disabled = !A.disabled
			updateUIs()
			spawn(50)
				if(A && !IsIndexCut(index))
					A.disabled = 0
					updateUIs()

/datum/wires/autolathe/proc/updateUIs()
	SSnanoui.update_uis(src)
	if(holder)
		SSnanoui.update_uis(holder)
