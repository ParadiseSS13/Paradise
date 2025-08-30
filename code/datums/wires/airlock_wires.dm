// Wires for airlocks

/datum/wires/airlock
	holder_type = /obj/machinery/door/airlock
	wire_count = 12 // 10 actual, 2 duds.
	proper_name = "Airlock"

/datum/wires/airlock/New(atom/_holder)
	wires = list(
		WIRE_IDSCAN, WIRE_MAIN_POWER1, WIRE_DOOR_BOLTS, WIRE_BACKUP_POWER1, WIRE_OPEN_DOOR,
		WIRE_AI_CONTROL, WIRE_ELECTRIFY, WIRE_SAFETY, WIRE_SPEED, WIRE_BOLT_LIGHT
	)
	return ..()

/datum/wires/airlock/maint
	dictionary_key = /datum/wires/airlock/maint
	proper_name = "Maintenance Airlock"

/datum/wires/airlock/command
	dictionary_key = /datum/wires/airlock/command
	proper_name = "Command Airlock"

/datum/wires/airlock/service
	dictionary_key = /datum/wires/airlock/service
	proper_name = "Service Airlock"

/datum/wires/airlock/security
	dictionary_key = /datum/wires/airlock/security
	proper_name = "Security Airlock"

/datum/wires/airlock/engineering
	dictionary_key = /datum/wires/airlock/engineering
	proper_name = "Engineering Airlock"

/datum/wires/airlock/medbay
	dictionary_key = /datum/wires/airlock/medbay
	proper_name = "Medbay Airlock"

/datum/wires/airlock/science
	dictionary_key = /datum/wires/airlock/science
	proper_name = "Science Airlock"

/datum/wires/airlock/ai
	dictionary_key = /datum/wires/airlock/ai
	proper_name = "AI Airlock"

/datum/wires/airlock/cargo
	dictionary_key = /datum/wires/airlock/cargo
	proper_name = "Cargo Airlock"

// We want ruin airlocks to be configured by zlvl.
// I don't have a good way to do this. Please send me ideas.
/datum/wires/airlock/ruin
	dictionary_key = /datum/wires/airlock/ruin

/datum/wires/airlock/secure
	randomize = TRUE

/datum/wires/airlock/interactable(mob/user)
	var/obj/machinery/door/airlock/A = holder
	if(iscarbon(user) && A.Adjacent(user) && A.isElectrified() && A.shock(user, 100))
		return FALSE
	if(A.panel_open)
		return TRUE
	return FALSE

/datum/wires/airlock/get_status()
	. = ..()
	var/obj/machinery/door/airlock/A = holder
	var/haspower = A.arePowerSystemsOn()

	. += "The door bolts [A.locked ? "have fallen!" : "look up."]"
	. += "The door bolt lights are [(A.lights && haspower) ? "on." : "off!"]"
	. += "The test light is [haspower ? "on." : "off!"]"
	. += "The 'AI control allowed' light is [(A.aiControlDisabled == AICONTROLDISABLED_OFF && !A.emagged && haspower) ? "on" : "off"]."
	. += "The 'Check Wiring' light is [(A.safe == 0 && haspower) ? "on" : "off"]."
	. += "The 'Check Timing Mechanism' light is [(A.normalspeed == 0 && haspower) ? "on" : "off"]."
	. += "The emergency lights are [(A.emergency && haspower) ? "on" : "off"]."

/datum/wires/airlock/on_cut(wire, mend)
	var/obj/machinery/door/airlock/A = holder
	switch(wire)
		if(WIRE_IDSCAN)
			A.aiDisabledIdScanner = !mend
		if(WIRE_MAIN_POWER1)

			if(!mend)
				//Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be crowbarred open, but bolts-raising will not work. Cutting these wires may electocute the user.
				A.loseMainPower()
				A.shock(usr, 50)
			else
				A.regainMainPower()
				A.shock(usr, 50)

		if(WIRE_BACKUP_POWER1)

			if(!mend)
				//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
				A.loseBackupPower()
				A.shock(usr, 50)
			else
				A.regainBackupPower()
				A.shock(usr, 50)

		if(WIRE_DOOR_BOLTS)

			if(!mend)
				//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
				A.lock(1)
				A.update_icon()

		if(WIRE_AI_CONTROL)

			if(!mend)
				//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
				//aiControlDisabled: see explanation in code\__DEFINES\construction.dm#32
				if(A.aiControlDisabled == AICONTROLDISABLED_OFF)
					A.aiControlDisabled = AICONTROLDISABLED_ON
				else if(A.aiControlDisabled == AICONTROLDISABLED_PERMA)
					A.aiControlDisabled = AICONTROLDISABLED_BYPASS
			else
				if(A.aiControlDisabled == AICONTROLDISABLED_ON)
					A.aiControlDisabled = AICONTROLDISABLED_OFF
				else if(A.aiControlDisabled == AICONTROLDISABLED_BYPASS)
					A.aiControlDisabled = AICONTROLDISABLED_PERMA

		if(WIRE_ELECTRIFY)
			if(!mend)
				//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
				A.electrify(-1)
			else
				A.electrify(0)
			return // Don't update the dialog.

		if(WIRE_SAFETY)
			A.safe = mend

		if(WIRE_SPEED)
			A.autoclose = mend
			if(mend)
				if(!A.density)
					INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, close))

		if(WIRE_BOLT_LIGHT)
			A.lights = mend
			A.update_icon()
	..()

/datum/wires/airlock/on_pulse(wire)
	var/obj/machinery/door/airlock/A = holder
	switch(wire)
		if(WIRE_IDSCAN)
			//Sending a pulse through flashes the red light on the door (if the door has power).
			if(A.arePowerSystemsOn() && A.density)
				A.do_animate("deny")
				if(A.emergency)
					A.emergency = 0
					A.update_icon()

		if(WIRE_MAIN_POWER1)
			//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
			A.loseMainPower()

		if(WIRE_DOOR_BOLTS)
			//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
			//raises them if they are down (only if power's on)
			if(!A.locked)
				if(A.lock())
					A.audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", hearing_distance =  1)
			else if(A.unlock())
				A.audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", hearing_distance =  1)

		if(WIRE_BACKUP_POWER1)
			//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
			A.loseBackupPower()

		if(WIRE_AI_CONTROL)
			if(A.aiControlDisabled == AICONTROLDISABLED_OFF)
				A.aiControlDisabled = AICONTROLDISABLED_ON
			else if(A.aiControlDisabled == AICONTROLDISABLED_PERMA)
				A.aiControlDisabled = AICONTROLDISABLED_BYPASS

			addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/door/airlock, ai_control_callback)), 1 SECONDS)

		if(WIRE_ELECTRIFY)
			//one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
			A.electrify(30)

		if(WIRE_OPEN_DOOR)
			//tries to open the door without ID
			//will succeed only if the ID wire is cut or the door requires no access and it's not emagged
			if(A.emagged)	return
			if(!A.requiresID() || A.check_access(null))
				if(A.density)
					INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, open))
				else
					INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, close))

		if(WIRE_SAFETY)
			A.safe = !A.safe
			if(!A.density)
				INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, close))

		if(WIRE_SPEED)
			A.normalspeed = !A.normalspeed

		if(WIRE_BOLT_LIGHT)
			A.lights = !A.lights
			A.update_icon()

	..()
