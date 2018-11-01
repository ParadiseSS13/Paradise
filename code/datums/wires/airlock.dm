// Wires for airlocks

/datum/wires/airlock/secure
	random = 1

/datum/wires/airlock
	holder_type = /obj/machinery/door/airlock
	wire_count = 12
	window_x = 410
	window_y = 570

var/const/AIRLOCK_WIRE_IDSCAN = 1
var/const/AIRLOCK_WIRE_MAIN_POWER1 = 2
var/const/AIRLOCK_WIRE_DOOR_BOLTS = 4
var/const/AIRLOCK_WIRE_BACKUP_POWER1 = 8
var/const/AIRLOCK_WIRE_OPEN_DOOR = 16
var/const/AIRLOCK_WIRE_AI_CONTROL = 32
var/const/AIRLOCK_WIRE_ELECTRIFY = 64
var/const/AIRLOCK_WIRE_SAFETY = 128
var/const/AIRLOCK_WIRE_SPEED = 256
var/const/AIRLOCK_WIRE_LIGHT = 512

/datum/wires/airlock/GetWireName(index)
	switch(index)
		if(AIRLOCK_WIRE_IDSCAN)
			return "ID Scan"

		if(AIRLOCK_WIRE_MAIN_POWER1)
			return "Primary Power"

		if(AIRLOCK_WIRE_DOOR_BOLTS)
			return "Door Bolts"

		if(AIRLOCK_WIRE_BACKUP_POWER1)
			return "Primary Backup Power"

		if(AIRLOCK_WIRE_OPEN_DOOR)
			return "Door State"

		if(AIRLOCK_WIRE_AI_CONTROL)
			return "AI Control"

		if(AIRLOCK_WIRE_ELECTRIFY)
			return "Electrification"

		if(AIRLOCK_WIRE_ELECTRIFY)
			return "Door Safeties"

		if(AIRLOCK_WIRE_ELECTRIFY)
			return "Door Timing"

		if(AIRLOCK_WIRE_ELECTRIFY)
			return "Bolt Lights"

/datum/wires/airlock/CanUse(mob/living/L)
	var/obj/machinery/door/airlock/A = holder
	if(iscarbon(L))
		if(A.Adjacent(L))
			if(A.isElectrified())
				if(A.shock(L, 100))
					return 0
	if(A.panel_open)
		return 1
	return 0

/datum/wires/airlock/get_status()
	. = ..()
	var/obj/machinery/door/airlock/A = holder
	var/haspower = A.arePowerSystemsOn()

	. += "The door bolts [A.locked ? "have fallen!" : "look up."]"
	. += "The door bolt lights are [(A.lights && haspower) ? "on." : "off!"]"
	. +=  "The test light is [haspower ? "on." : "off!"]"
	. += "The 'AI control allowed' light is [(A.aiControlDisabled == 0 && !A.emagged && haspower) ? "on" : "off"]."
	. += "The 'Check Wiring' light is [(A.safe == 0 && haspower) ? "on" : "off"]."
	. += "The 'Check Timing Mechanism' light is [(A.normalspeed == 0 && haspower) ? "on" : "off"]."
	. += "The emergency lights are [(A.emergency && haspower) ? "on" : "off"]."

/datum/wires/airlock/UpdateCut(index, mended)

	var/obj/machinery/door/airlock/A = holder
	switch(index)
		if(AIRLOCK_WIRE_IDSCAN)
			A.aiDisabledIdScanner = !mended
		if(AIRLOCK_WIRE_MAIN_POWER1)

			if(!mended)
				//Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be crowbarred open, but bolts-raising will not work. Cutting these wires may electocute the user.
				A.loseMainPower()
				A.shock(usr, 50)
			else
				A.regainMainPower()
				A.shock(usr, 50)

		if(AIRLOCK_WIRE_BACKUP_POWER1)

			if(!mended)
				//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
				A.loseBackupPower()
				A.shock(usr, 50)
			else
				A.regainBackupPower()
				A.shock(usr, 50)

		if(AIRLOCK_WIRE_DOOR_BOLTS)

			if(!mended)
				//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
				A.lock(1)
				A.update_icon()

		if(AIRLOCK_WIRE_AI_CONTROL)

			if(!mended)
				//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
				//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
				if(A.aiControlDisabled == 0)
					A.aiControlDisabled = 1
				else if(A.aiControlDisabled == -1)
					A.aiControlDisabled = 2
			else
				if(A.aiControlDisabled == 1)
					A.aiControlDisabled = 0
				else if(A.aiControlDisabled == 2)
					A.aiControlDisabled = -1

		if(AIRLOCK_WIRE_ELECTRIFY)
			if(!mended)
				//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
				A.electrify(-1)
			else
				A.electrify(0)
			return // Don't update the dialog.

		if(AIRLOCK_WIRE_SAFETY)
			A.safe = mended

		if(AIRLOCK_WIRE_SPEED)
			A.autoclose = mended
			if(mended)
				if(!A.density)
					spawn(0)
						A.close()

		if(AIRLOCK_WIRE_LIGHT)
			A.lights = mended
			A.update_icon()
	..()

/datum/wires/airlock/UpdatePulsed(index)

	var/obj/machinery/door/airlock/A = holder
	switch(index)
		if(AIRLOCK_WIRE_IDSCAN)
			//Sending a pulse through flashes the red light on the door (if the door has power).
			if(A.arePowerSystemsOn() && A.density)
				A.do_animate("deny")
				if(A.emergency)
					A.emergency = 0
					A.update_icon()
		if(AIRLOCK_WIRE_MAIN_POWER1)
			//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
			A.loseMainPower()
		if(AIRLOCK_WIRE_DOOR_BOLTS)
			//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
			//raises them if they are down (only if power's on)
			if(!A.locked)
				if(A.lock())
					A.audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", null,  1)
			else if(A.unlock())
				A.audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", null,  1)

		if(AIRLOCK_WIRE_BACKUP_POWER1)
			//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
			A.loseBackupPower()
		if(AIRLOCK_WIRE_AI_CONTROL)
			if(A.aiControlDisabled == 0)
				A.aiControlDisabled = 1
			else if(A.aiControlDisabled == -1)
				A.aiControlDisabled = 2

			spawn(10)
				if(A)
					if(A.aiControlDisabled == 1)
						A.aiControlDisabled = 0
					else if(A.aiControlDisabled == 2)
						A.aiControlDisabled = -1

		if(AIRLOCK_WIRE_ELECTRIFY)
			//one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
			A.electrify(30)
		if(AIRLOCK_WIRE_OPEN_DOOR)
			//tries to open the door without ID
			//will succeed only if the ID wire is cut or the door requires no access and it's not emagged
			if(A.emagged)	return
			if(!A.requiresID() || A.check_access(null))
				spawn(0)
					if(A.density)
						A.open()
					else
						A.close()
		if(AIRLOCK_WIRE_SAFETY)
			A.safe = !A.safe
			if(!A.density)
				spawn(0)
					A.close()

		if(AIRLOCK_WIRE_SPEED)
			A.normalspeed = !A.normalspeed

		if(AIRLOCK_WIRE_LIGHT)
			A.lights = !A.lights
			A.update_icon()

	..()
