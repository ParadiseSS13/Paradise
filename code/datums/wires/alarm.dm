
/datum/wires/alarm
	holder_type = /obj/machinery/alarm
	wire_count = 5

#define AALARM_WIRE_IDSCAN 1
#define AALARM_WIRE_POWER 2
#define AALARM_WIRE_SYPHON 4
#define AALARM_WIRE_AI_CONTROL 8
#define AALARM_WIRE_AALARM 16

/datum/wires/alarm/GetWireName(index)
	switch(index)
		if(AALARM_WIRE_IDSCAN)
			return "ID Scan"
		
		if(AALARM_WIRE_POWER)
			return "Power"
		
		if(AALARM_WIRE_SYPHON)
			return "Syphon"
		
		if(AALARM_WIRE_AI_CONTROL)
			return "AI Control"
			
		if(AALARM_WIRE_AALARM)
			return "Atmospherics Alarm"

/datum/wires/alarm/CanUse(mob/living/L)
	var/obj/machinery/alarm/A = holder
	if(A.wiresexposed)
		return 1
	return 0

/datum/wires/alarm/get_status()
	. = ..()
	var/obj/machinery/alarm/A = holder
	. += "The Air Alarm is [A.locked ? "" : "un"]locked."
	. += "The Air Alarm is [(A.shorted || (A.stat & (NOPOWER|BROKEN))) ? "offline." : "working properly!"]"
	. += "The 'AI control allowed' light is [A.aidisabled ? "off" : "on"]."

/datum/wires/alarm/UpdateCut(index, mended)
	var/obj/machinery/alarm/A = holder
	switch(index)
		if(AALARM_WIRE_IDSCAN)
			if(!mended)
				A.locked = 1
//				to_chat(world, "Idscan wire cut")

		if(AALARM_WIRE_POWER)
			A.shock(usr, 50)
			A.shorted = !mended
			A.update_icon()
//			to_chat(world, "Power wire cut")

		if(AALARM_WIRE_AI_CONTROL)
			A.aidisabled = !mended
//				to_chat(world, "AI Control Wire Cut")

		if(AALARM_WIRE_SYPHON)
			if(!mended)
				A.mode = 3 // AALARM_MODE_PANIC
				A.apply_mode()
//				to_chat(world, "Syphon Wire Cut")

		if(AALARM_WIRE_AALARM)
			if(A.alarm_area.atmosalert(2, A))
				A.post_alert(2)
			A.update_icon()
	..()

/datum/wires/alarm/UpdatePulsed(index)
	var/obj/machinery/alarm/A = holder
	switch(index)
		if(AALARM_WIRE_IDSCAN)
			A.locked = !A.locked
//			to_chat(world, "Idscan wire pulsed")

		if(AALARM_WIRE_POWER)
//			to_chat(world, "Power wire pulsed")
			if(A.shorted == 0)
				A.shorted = 1
				A.update_icon()

			spawn(12000)
				if(A.shorted == 1)
					A.shorted = 0
					A.update_icon()


		if(AALARM_WIRE_AI_CONTROL)
//			to_chat(world, "AI Control wire pulsed")
			if(A.aidisabled == 0)
				A.aidisabled = 1
			A.updateDialog()
			spawn(100)
				if(A.aidisabled == 1)
					A.aidisabled = 0

		if(AALARM_WIRE_SYPHON)
//			to_chat(world, "Syphon wire pulsed")
			if(A.mode == 1) // AALARM_MODE_SCRUB
				A.mode = 3 // AALARM_MODE_PANIC
			else
				A.mode = 1 // AALARM_MODE_SCRUB
			A.apply_mode()

		if(AALARM_WIRE_AALARM)
//			to_chat(world, "Aalarm wire pulsed")
			if(A.alarm_area.atmosalert(0, A))
				A.post_alert(0)
			A.update_icon()
	..()
