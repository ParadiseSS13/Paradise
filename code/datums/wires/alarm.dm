
/datum/wires/alarm
	holder_type = /obj/machinery/alarm
	wire_count = 5
	proper_name = "Air alarm"

/datum/wires/alarm/New(atom/_holder)
	wires = list(
		WIRE_IDSCAN , WIRE_MAIN_POWER1 , WIRE_SIPHON,
		WIRE_AI_CONTROL, WIRE_AALARM
	)
	return ..()

/datum/wires/alarm/interactable(mob/user)
	var/obj/machinery/alarm/A = holder
	if(A.wiresexposed)
		return TRUE
	return FALSE

/datum/wires/alarm/get_status()
	. = ..()
	var/obj/machinery/alarm/A = holder
	. += "The Air Alarm is [A.locked ? "" : "un"]locked."
	. += "The Air Alarm is [(A.shorted || (A.stat & (NOPOWER|BROKEN))) ? "offline." : "working properly!"]"
	. += "The 'AI control allowed' light is [A.aidisabled ? "off" : "on"]."

/datum/wires/alarm/on_cut(wire, mend)
	var/obj/machinery/alarm/A = holder
	switch(wire)
		if(WIRE_IDSCAN)
			if(!mend)
				A.locked = TRUE

		if(WIRE_MAIN_POWER1)
			A.shock(usr, 50)
			A.shorted = !mend
			A.update_icon()

		if(WIRE_AI_CONTROL)
			A.aidisabled = !mend

		if(WIRE_SIPHON)
			if(!mend)
				A.mode = AALARM_MODE_PANIC
				A.apply_mode()

		if(WIRE_AALARM)
			A.alarm_area.atmosalert(ATMOS_ALARM_DANGER, A)
			A.update_icon()
	..()

/datum/wires/alarm/on_pulse(wire)
	var/obj/machinery/alarm/A = holder
	switch(wire)
		if(WIRE_IDSCAN)
			A.locked = !A.locked

		if(WIRE_MAIN_POWER1)
			if(!A.shorted)
				A.shorted = TRUE
				A.update_icon()
			addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/alarm, unshort_callback)), 120 SECONDS)

		if(WIRE_AI_CONTROL)
			if(!A.aidisabled)
				A.aidisabled = TRUE
			A.updateDialog()
			addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/alarm, enable_ai_control_callback)), 10 SECONDS)


		if(WIRE_SIPHON)
			if(A.mode == AALARM_MODE_FILTERING)
				A.mode = AALARM_MODE_PANIC
			else
				A.mode = AALARM_MODE_FILTERING
			A.apply_mode()

		if(WIRE_AALARM)
			A.alarm_area.atmosalert(ATMOS_ALARM_NONE, A)
			A.update_icon()
	..()
