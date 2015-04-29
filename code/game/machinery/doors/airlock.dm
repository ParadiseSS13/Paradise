/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	arePowerSystemsOn - 1 if the main or backup power are functioning, 0 if not. Does not check whether the power grid is charged or an APC has equipment on or anything like that. (Check (stat & NOPOWER) for that)
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/


// Wires for the airlock are located in the datum folder, inside the wires datum folder.


/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door_closed"
	power_channel = ENVIRON

	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = 0 // if 1, this door can't be hacked by the AI
	var/electrified_until = 0	// World time when the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/main_power_lost_until = 0	 //World time when main power is restored.
	var/backup_power_lost_until = -1 //World time when backup power is restored.
	var/spawnPowerRestoreRunning = 0
	var/welded = null
	var/locked = 0
	var/lights = 1 // bolt lights show by default
	var/datum/wires/airlock/wires = null
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/lockdownbyai = 0
	var/assembly_type = /obj/structure/door_assembly
	var/mineral = null
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening
	var/frozen = 0 //special condition for airlocks that are frozen shut, this will look weird on not normal airlocks because of a lack of special overlays.
	autoclose = 1

/obj/machinery/door/airlock/command
	name = "Airlock"
	icon = 'icons/obj/doors/Doorcom.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_com

/obj/machinery/door/airlock/security
	name = "Airlock"
	icon = 'icons/obj/doors/Doorsec.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_sec

/obj/machinery/door/airlock/engineering
	name = "Airlock"
	icon = 'icons/obj/doors/Dooreng.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/medical
	name = "Airlock"
	icon = 'icons/obj/doors/Doormed.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/maintenance
	name = "Maintenance Access"
	icon = 'icons/obj/doors/Doormaint.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_mai

/obj/machinery/door/airlock/external
	name = "External Airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_ext

/obj/machinery/door/airlock/glass
	name = "Glass Airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/centcom
	name = "Airlock"
	icon = 'icons/obj/doors/Doorele.dmi'
	opacity = 0

/obj/machinery/door/airlock/vault
	name = "Vault"
	icon = 'icons/obj/doors/vault.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity //Until somebody makes better sprites.

/obj/machinery/door/airlock/freezer
	name = "Freezer Airlock"
	icon = 'icons/obj/doors/Doorfreezer.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/hatch
	name = "Airtight Hatch"
	icon = 'icons/obj/doors/Doorhatchele.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_hatch

/obj/machinery/door/airlock/hatch/gamma
	name = "Gamma Level Hatch"
	hackProof = 1
	aiControlDisabled = 1
	unacidable = 1

/obj/machinery/door/airlock/maintenance_hatch
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorhatchmaint2.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_mhatch

/obj/machinery/door/airlock/glass_command
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorcomglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_com
	glass = 1

/obj/machinery/door/airlock/glass_engineering
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorengglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_eng
	glass = 1

/obj/machinery/door/airlock/glass_security
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorsecglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_sec
	glass = 1

/obj/machinery/door/airlock/glass_medical
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doormedglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_med
	glass = 1

/obj/machinery/door/airlock/mining
	name = "Mining Airlock"
	icon = 'icons/obj/doors/Doormining.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = "Atmospherics Airlock"
	icon = 'icons/obj/doors/Dooratmo.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	name = "Airlock"
	icon = 'icons/obj/doors/Doorresearch.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/glass_research
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorresearchglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_research
	glass = 1
	heat_proof = 1

/obj/machinery/door/airlock/glass_mining
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorminingglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_min
	glass = 1

/obj/machinery/door/airlock/glass_atmos
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Dooratmoglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo
	glass = 1

/obj/machinery/door/airlock/gold
	name = "Gold Airlock"
	icon = 'icons/obj/doors/Doorgold.dmi'
	mineral = "gold"

/obj/machinery/door/airlock/silver
	name = "Silver Airlock"
	icon = 'icons/obj/doors/Doorsilver.dmi'
	mineral = "silver"

/obj/machinery/door/airlock/diamond
	name = "Diamond Airlock"
	icon = 'icons/obj/doors/Doordiamond.dmi'
	mineral = "diamond"

/obj/machinery/door/airlock/uranium
	name = "Uranium Airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/Dooruranium.dmi'
	mineral = "uranium"
	var/last_event = 0

/obj/machinery/door/airlock/process()
	// Deliberate no call to parent.
	if(main_power_lost_until > 0 && world.time >= main_power_lost_until)
		regainMainPower()

	if(backup_power_lost_until > 0 && world.time >= backup_power_lost_until)
		regainBackupPower()

	else if(electrified_until > 0 && world.time >= electrified_until)
		electrify(0)

/obj/machinery/door/airlock/uranium/process()
	if(world.time > last_event+20)
		if(prob(50))
			radiate()
		last_event = world.time
	..()

/obj/machinery/door/airlock/uranium/proc/radiate()
	for(var/mob/living/L in range (3,src))
		L.apply_effect(15,IRRADIATE,0)
	return

/obj/machinery/door/airlock/plasma
	name = "plasma airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/Doorplasma.dmi'
	mineral = "plasma"

/obj/machinery/door/airlock/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 500)
	new/obj/structure/door_assembly( src.loc )
	del (src)

/obj/machinery/door/airlock/plasma/BlockSuperconductivity() //we don't stop the heat~
	return 0

/obj/machinery/door/airlock/clown
	name = "Bananium Airlock"
	icon = 'icons/obj/doors/Doorbananium.dmi'
	mineral = "clown"

/obj/machinery/door/airlock/mime
	name = "Airlock"
	icon = 'icons/obj/doors/Doorfreezer.dmi'

/obj/machinery/door/airlock/sandstone
	name = "Sandstone Airlock"
	icon = 'icons/obj/doors/Doorsand.dmi'
	mineral = "sandstone"

/obj/machinery/door/airlock/science
	name = "Airlock"
	icon = 'icons/obj/doors/Doorsci.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_science

/obj/machinery/door/airlock/glass_science
	name = "Glass Airlocks"
	icon = 'icons/obj/doors/Doorsciglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_science
	glass = 1

/obj/machinery/door/airlock/highsecurity
	name = "High Tech Security Airlock"
	icon = 'icons/obj/doors/hightechsecurity.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity

/obj/machinery/door/airlock/highsecurity/red
	name = "Secure Armory Airlock"
	hackProof = 1
	aiControlDisabled = 1

/obj/machinery/door/airlock/shuttle
	name = "shuttle airlock"
	icon = 'icons/obj/doors/doorshuttle.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_shuttle

/obj/machinery/door/airlock/alien
	name = "Alien Airlock"
	desc = "A mysterious alien airlock with a complicated opening mechanism."
	hackProof = 1
	icon = 'icons/obj/doors/Doorplasma.dmi'

/obj/machinery/door/airlock/alien/bumpopen(mob/living/user as mob)
	if(istype(user,/mob/living/carbon/alien) || isrobot(user) || isAI(user))
		..(user)
	else
		user << "You do not know how to operate this airlock's mechanism."
		return

/obj/machinery/door/airlock/alien/attackby(C as obj, mob/user as mob, params)
	if(isalien(user) || isrobot(user) || isAI(user))
		..(C, user)
	else
		user << "You do not know how to operate this airlock's mechanism."
		return



/*
About the new airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open. This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires.
*		one wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power). If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)
*		two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be \red open, but bolts-raising will not work. Cutting these wires may electrocute the user.
*		one wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is). Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*		two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter). Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*		one wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.
*		one wire for AI control. Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again). Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*		one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds. Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted. (Currently it is also STAYING electrified until someone mends the wire)
*		one wire for controling door safetys.  When active, door does not close on someone.  When cut, door will ruin someone's shit.  When pulsed, door will immedately ruin someone's shit.
*		one wire for controlling door speed.  When active, dor closes at normal rate.  When cut, door does not close manually.  When pulsed, door attempts to close every tick.
*/
// You can find code for the airlock wires in the wire datum folder.


/obj/machinery/door/airlock/bumpopen(mob/living/user as mob) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!issilicon(usr))
		if(src.isElectrified())
			if(!src.justzap)
				if(src.shock(user, 100))
					src.justzap = 1
					spawn (10)
						src.justzap = 0
					return
			else /*if(src.justzap)*/
				return
		else if(user.hallucination > 50 && prob(10) && src.operating == 0)
			user << "\red <B>You feel a powerful shock course through your body!</B>"
			user.staminaloss += 50
			user.stunned += 5
			return
	..(user)

/obj/machinery/door/airlock/bumpopen(mob/living/simple_animal/user as mob)
	..(user)

/obj/machinery/door/airlock/proc/isElectrified()
	if(src.electrified_until != 0)
		return 1
	return 0

/obj/machinery/door/airlock/proc/isWireCut(var/wireIndex)
	// You can find the wires in the datum folder.
	return wires.IsIndexCut(wireIndex)

/obj/machinery/door/airlock/proc/canAIControl()
	return ((src.aiControlDisabled!=1) && (!src.isAllPowerLoss()));

/obj/machinery/door/airlock/proc/canAIHack()
	return ((src.aiControlDisabled==1) && (!hackProof) && (!src.isAllPowerLoss()));

/obj/machinery/door/airlock/proc/arePowerSystemsOn()
	if (stat & (NOPOWER|BROKEN))
		return 0
	return (src.main_power_lost_until==0 || src.backup_power_lost_until==0)

/obj/machinery/door/airlock/requiresID()
	return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerLoss()
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(mainPowerCablesCut() && backupPowerCablesCut())
		return 1
	return 0

/obj/machinery/door/airlock/proc/mainPowerCablesCut()
	return src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)

/obj/machinery/door/airlock/proc/backupPowerCablesCut()
	return src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)

/obj/machinery/door/airlock/proc/loseMainPower()
	main_power_lost_until = mainPowerCablesCut() ? -1 : world.time + SecondsToTicks(60)

	// If backup power is permanently disabled then activate in 10 seconds if possible, otherwise it's already enabled or a timer is already running
	if(backup_power_lost_until == -1 && !backupPowerCablesCut())
		backup_power_lost_until = world.time + SecondsToTicks(10)

	// Disable electricity if required
	if(electrified_until && isAllPowerLoss())
		electrify(0)

/obj/machinery/door/airlock/proc/loseBackupPower()
	backup_power_lost_until = backupPowerCablesCut() ? -1 : world.time + SecondsToTicks(60)

	// Disable electricity if required
	if(electrified_until && isAllPowerLoss())
		electrify(0)

/obj/machinery/door/airlock/proc/regainMainPower()
	if(!mainPowerCablesCut())
		main_power_lost_until = 0
		// If backup power is currently active then disable, otherwise let it count down and disable itself later
		if(!backup_power_lost_until)
			backup_power_lost_until = -1
		update_icon()

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(!backupPowerCablesCut())
		// Restore backup power only if main power is offline, otherwise permanently disable
		backup_power_lost_until = main_power_lost_until == 0 ? -1 : 0
		update_icon()

/obj/machinery/door/airlock/proc/electrify(var/duration, var/feedback = 0)
	var/message = ""
	if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY) && arePowerSystemsOn())
		message = text("The electrification wire is cut - Door permanently electrified.")
		src.electrified_until = -1
	else if(duration && !arePowerSystemsOn())
		message = text("The door is unpowered - Cannot electrify the door.")
		src.electrified_until = 0
	else if(!duration && electrified_until != 0)
		message = "The door is now un-electrified."
		src.electrified_until = 0
	else if(duration)	//electrify door for the given duration seconds
		if(usr)
			shockedby += text("\[[time_stamp()]\] - [usr](ckey:[usr.ckey])")
			usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
		else
			shockedby += text("\[[time_stamp()]\] - EMP)")
		message = "The door is now electrified [duration == -1 ? "permanently" : "for [duration] second\s"]."
		src.electrified_until = duration == -1 ? -1 : world.time + SecondsToTicks(duration)

	if(feedback && message)
		usr << message

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/proc/shock(mob/user, prb)
	if((stat & (NOPOWER)) || !src.arePowerSystemsOn())		// unpowered, no shock
		return 0
	if(hasShocked)
		return 0	//Already shocked someone recently?
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if(electrocute_mob(user, get_area(src), src))
		hasShocked = 1
		spawn(10)
			hasShocked = 0
		return 1
	else
		return 0


/obj/machinery/door/airlock/update_icon()
	if(overlays) overlays.Cut()
	overlays = list()
	if(emergency && arePowerSystemsOn())
		overlays += image('icons/obj/doors/doorint.dmi', "elights")
	if(density)
		if(locked && lights)
			icon_state = "door_locked"
		else
			icon_state = "door_closed"
		if(p_open || welded || frozen)
			if(p_open)
				overlays += image(icon, "panel_open")
			if(welded)
				overlays += image(icon, "welded")
			if(frozen)
				overlays += image(icon, "frozen")

	else
		icon_state = "door_open"

	return


/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			if(overlays) overlays.Cut()
			if(p_open)
				spawn(2) // The only work around that works. Downside is that the door will be gone for a millisecond.
					flick("o_door_opening", src)  //can not use flick due to BYOND bug updating overlays right before flicking
					update_icon()
			else
				flick("door_opening", src)//[stat ? "_stat":]
				update_icon()
		if("closing")
			if(overlays) overlays.Cut()
			if(p_open)
				spawn(2)
					flick("o_door_closing", src)
					update_icon()
			else
				flick("door_closing", src)
				update_icon()
		if("spark")
			if(density)
				flick("door_spark", src)
		if("deny")
			if(density && src.arePowerSystemsOn())
				flick("door_deny", src)
	return

/obj/machinery/door/airlock/attack_ai(mob/user as mob)
	ui_interact(user)

/obj/machinery/door/airlock/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data["main_power_loss"]		= round(main_power_lost_until 	> 0 ? max(main_power_lost_until - world.time,	0) / 10 : main_power_lost_until,	1)
	data["backup_power_loss"]	= round(backup_power_lost_until	> 0 ? max(backup_power_lost_until - world.time,	0) / 10 : backup_power_lost_until,	1)
	data["electrified"] 		= round(electrified_until		> 0 ? max(electrified_until - world.time, 	0) / 10 	: electrified_until,		1)
	data["open"] = !density

	var/commands[0]
	commands[++commands.len] = list("name" = "IdScan",					"command"= "idscan",				"active" = !aiDisabledIdScanner,	"enabled" = "Enabled",	"disabled" = "Disable",		"danger" = 0, "act" = 1)
	commands[++commands.len] = list("name" = "Bolts",					"command"= "bolts",					"active" = !locked,					"enabled" = "Raised",	"disabled" = "Dropped",		"danger" = 0, "act" = 0)
	commands[++commands.len] = list("name" = "Bolt Lights",				"command"= "lights",				"active" = lights,					"enabled" = "Enabled",	"disabled" = "Disable",		"danger" = 0, "act" = 1)
	commands[++commands.len] = list("name" = "Safeties",				"command"= "safeties",				"active" = safe,					"enabled" = "Nominal",	"disabled" = "Overridden",	"danger" = 1, "act" = 0)
	commands[++commands.len] = list("name" = "Timing",					"command"= "timing",				"active" = normalspeed,				"enabled" = "Nominal",	"disabled" = "Overridden",	"danger" = 1, "act" = 0)
	commands[++commands.len] = list("name" = "Door State",				"command"= "open",					"active" = density,					"enabled" = "Closed",	"disabled" = "Opened", 		"danger" = 0, "act" = 0)
	commands[++commands.len] = list("name" = "Emergency Access",		"command"= "emergency",				"active" = !emergency,				"enabled" = "Disabled",	"disabled" = "Enabled", 	"danger" = 0, "act" = 0)

	data["commands"] = commands

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "door_control.tmpl", "Door Controls - [src]", 600, 375)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/door/airlock/proc/hack(mob/user as mob)
	if(src.aiHacking==0)
		src.aiHacking=1
		spawn(20)
			//TODO: Make this take a minute
			user << "Airlock AI control has been blocked. Beginning fault-detection."
			sleep(50)
			if(src.canAIControl())
				user << "Alert cancelled. Airlock control has been restored without our assistance."
				src.aiHacking=0
				return
			else if(!src.canAIHack(user))
				user << "We've lost our connection! Unable to hack airlock."
				src.aiHacking=0
				return
			user << "Fault confirmed: airlock control wire disabled or cut."
			sleep(20)
			user << "Attempting to hack into airlock. This may take some time."
			sleep(200)
			if(src.canAIControl())
				user << "Alert cancelled. Airlock control has been restored without our assistance."
				src.aiHacking=0
				return
			else if(!src.canAIHack(user))
				user << "We've lost our connection! Unable to hack airlock."
				src.aiHacking=0
				return
			user << "Upload access confirmed. Loading control program into airlock software."
			sleep(170)
			if(src.canAIControl())
				user << "Alert cancelled. Airlock control has been restored without our assistance."
				src.aiHacking=0
				return
			else if(!src.canAIHack(user))
				user << "We've lost our connection! Unable to hack airlock."
				src.aiHacking=0
				return
			user << "Transfer complete. Forcing airlock to execute program."
			sleep(50)
			//disable blocked control
			src.aiControlDisabled = 2
			user << "Receiving control information from airlock."
			sleep(10)
			//bring up airlock dialog
			src.aiHacking = 0
			if (user)
				src.attack_ai(user)

/obj/machinery/door/airlock/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (src.isElectrified())
		if (istype(mover, /obj/item))
			var/obj/item/i = mover
			if (i.m_amt)
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
	return ..()
/obj/machinery/door/airlock/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/airlock/attack_hand(mob/user as mob)
	if(!istype(user, /mob/living/silicon))
		if(src.isElectrified())
			if(src.shock(user, 100))
				return

	if(ishuman(user) && prob(40) && src.density)
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				visible_message("\red [user] headbutts the airlock.")
				var/obj/item/organ/external/affecting = H.get_organ("head")
				H.Stun(8)
				H.Weaken(5)
				if(affecting.take_damage(10, 0))
					H.UpdateDamageIcon()
			else
				visible_message("\red [user] headbutts the airlock. Good thing they're wearing a helmet.")
			return

	if(src.p_open)
		wires.Interact(user)
	else
		..(user)
	return

/obj/machinery/door/airlock/CanUseTopic(var/mob/user, href_list)
	if(!issilicon(user))
		return STATUS_CLOSE

	if(operating < 0) //emagged
		user << "<span class='warning'>Unable to interface: Internal error.</span>"
		return STATUS_CLOSE
	if(!src.canAIControl())
		if(src.canAIHack(user))
			src.hack(user)
		else
			if (src.isAllPowerLoss()) //don't really like how this gets checked a second time, but not sure how else to do it.
				user << "<span class='warning'>Unable to interface: Connection timed out.</span>"
			else
				user << "<span class='warning'>Unable to interface: Connection refused.</span>"
		return STATUS_CLOSE

	return STATUS_INTERACTIVE

/obj/machinery/door/airlock/Topic(href, href_list, var/nowindow = 0)
	if(..())
		return 1

	var/activate = text2num(href_list["activate"])
	switch (href_list["command"])
		if("idscan")
			if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
				usr << "The IdScan wire has been cut - IdScan feature permanently disabled."
			else if(activate && src.aiDisabledIdScanner)
				src.aiDisabledIdScanner = 0
				usr << "IdScan feature has been enabled."
			else if(!activate && !src.aiDisabledIdScanner)
				src.aiDisabledIdScanner = 1
				usr << "IdScan feature has been disabled."
		if("main_power")
			if(!main_power_lost_until)
				src.loseMainPower()
		if("backup_power")
			if(!backup_power_lost_until)
				src.loseBackupPower()
		if("bolts")
			if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
				usr << "The door bolt control wire has been cut - Door bolts permanently dropped."
			else if(activate && src.lock())
				usr << "The door bolts have been dropped."
			else if(!activate && src.unlock())
				usr << "The door bolts have been raised."
		if("electrify_temporary")
			if(activate && src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
				usr << text("The electrification wire is cut - Door permanently electrified.")
			else if(!activate && electrified_until != 0)
				usr << "The door is now un-electrified."
				src.electrified_until = 0
			else if(activate)	//electrify door for 30 seconds
				shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
				usr << "The door is now electrified for thirty seconds."
				src.electrified_until = world.time + SecondsToTicks(30)
		if("electrify_permanently")
			if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
				usr << text("The electrification wire is cut - Cannot electrify the door.")
			else if(!activate && electrified_until != 0)
				usr << "The door is now un-electrified."
				src.electrified_until = 0
			else if(activate)
				shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
				usr << "The door is now electrified."
				electrified_until = -1
		if("open")
			if(src.welded)
				usr << text("The airlock has been welded shut!")
			else if(src.locked)
				usr << text("The door bolts are down!")
			else if(activate && density)
				open()
			else if(!activate && !density)
				close()
		if("safeties")
			// Safeties!  We don't need no stinking safeties!
			if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
				usr << text("The safety wire is cut - Cannot secure the door.")
			else if (activate && src.safe)
				safe = 0
			else if (!activate && !src.safe)
				safe = 1
		if("timing")
			// Door speed control
			if(src.isWireCut(AIRLOCK_WIRE_SPEED))
				usr << text("The timing wire is cut - Cannot alter timing.")
			else if (activate && src.normalspeed)
				normalspeed = 0
			else if (!activate && !src.normalspeed)
				normalspeed = 1
		if("lights")
			// Bolt lights
			if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
				usr << "The bolt lights wire has been cut - The door bolt lights are permanently disabled."
			else if (!activate && src.lights)
				lights = 0
				usr << "The door bolt lights have been disabled."
			else if (activate && !src.lights)
				lights = 1
				usr << "The door bolt lights have been enabled."
		if("emergency")
			// Emergency access
			if (src.emergency)
				emergency = 0
				usr << "Emergency access has been disabled."
			else
				emergency = 1
				usr << "Emergency access has been enabled."

	update_icon()
	return 1

/obj/machinery/door/airlock/attackby(C as obj, mob/user as mob, params)
	//world << text("airlock attackby src [] obj [] mob []", src, C, user)
	if(!istype(usr, /mob/living/silicon))
		if(src.isElectrified())
			if(src.shock(user, 75))
				return
	if(istype(C, /obj/item/device/detective_scanner) || istype(C, /obj/item/taperoll))
		return

	src.add_fingerprint(user)
	if((istype(C, /obj/item/weapon/weldingtool) && !( src.operating ) && src.density))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0,user))
			if(frozen)
				frozen = 0
			if(!src.welded)
				src.welded = 1
			else
				src.welded = null
			src.update_icon()
			return
		else
			return
	else if(istype(C, /obj/item/weapon/screwdriver))
		src.p_open = !( src.p_open )
		src.update_icon()
	else if(istype(C, /obj/item/weapon/wirecutters))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/multitool))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/assembly/signaler))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/weapon/pai_cable))	// -- TLE
		var/obj/item/weapon/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/weapon/crowbar) || istype(C, /obj/item/weapon/twohanded/fireaxe) )
		var/beingcrowbarred = null
		if(istype(C, /obj/item/weapon/crowbar) )
			beingcrowbarred = 1 //derp, Agouri
		else
			beingcrowbarred = 0
		if( beingcrowbarred && src.p_open && (operating == -1 || (density && welded && operating != 1 && !src.arePowerSystemsOn() && !src.locked)) )
			playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
			user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly.")
			if(do_after(user,40))
				user << "\blue You removed the airlock electronics!"

				var/obj/structure/door_assembly/da = new assembly_type(src.loc)
				da.anchored = 1
				if(mineral)
					da.glass = mineral
				//else if(glass)
				else if(glass && !da.glass)
					da.glass = 1
				da.state = 1
				da.created_name = src.name
				da.update_state()

				var/obj/item/weapon/airlock_electronics/ae
				if(!electronics)
					ae = new/obj/item/weapon/airlock_electronics( src.loc )
					if(!src.req_access)
						src.check_access()
					if(src.req_access.len)
						ae.conf_access = src.req_access
					else if (src.req_one_access.len)
						ae.conf_access = src.req_one_access
						ae.one_access = 1
				else
					ae = electronics
					electronics = null
					ae.loc = src.loc
				if(operating == -1)
					ae.icon_state = "door_electronics_smoked"
					operating = 0

				del(src)
				return
		else if(arePowerSystemsOn())
			user << "\blue The airlock's motors resist your efforts to force it."
		else if(locked)
			user << "\blue The airlock's bolts prevent it from being forced."
		else if( !welded && !operating )
			if(density)
				if(beingcrowbarred == 0) //being fireaxe'd
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F.wielded)
						spawn(0)	open(1)
					else
						user << "\red You need to be wielding \the [C] to do that."
				else
					spawn(0)	open(1)
			else
				if(beingcrowbarred == 0)
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F.wielded)
						spawn(0)	close(1)
					else
						user << "\red You need to be wielding \the [C] to do that."
				else
					spawn(0)	close(1)
	else
		..()
	return

/obj/machinery/door/airlock/plasma/attackby(C as obj, mob/user as mob, params)
	if(C)
		ignite(is_hot(C))
	..()

/obj/machinery/door/airlock/open(var/forced=0)
	if( operating || welded || locked )
		return 0
	if(!forced)
		if( !arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_OPEN_DOOR) )
			return 0
	use_power(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people
	if(forced)
		playsound(src.loc, 'sound/machines/airlockforced.ogg', 30, 1)
	else if(istype(src, /obj/machinery/door/airlock/glass))
		playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	else if(istype(src, /obj/machinery/door/airlock/clown))
		playsound(src.loc, 'sound/items/bikehorn.ogg', 30, 1)
	else if(istype(src, /obj/machinery/door/airlock/mime))
		// Play nothing
	else
		playsound(src.loc, 'sound/machines/airlock.ogg', 30, 1)
	if(src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
		src.closeOther.close()
	return ..()

/obj/machinery/door/airlock/close(var/forced=0)
	if(operating || welded || locked)
		return
	if(!forced)
		//despite the name, this wire is for general door control.
		//Bolts are already covered by the check for locked, above
		if( !arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_OPEN_DOOR) )
			return
	if(safe)
		for(var/turf/turf in locs)
			if(locate(/mob/living) in turf)
			//	playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)	//THE BUZZING IT NEVER STOPS	-Pete
				spawn (60)
					autoclose()
				return

	use_power(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people
	if(forced)
		playsound(src.loc, 'sound/machines/airlockforced.ogg', 30, 1)
	else if(istype(src, /obj/machinery/door/airlock/glass))
		playsound(src.loc, 'sound/machines/windowdoor.ogg', 30, 1)
	else if(istype(src, /obj/machinery/door/airlock/clown))
		playsound(src.loc, 'sound/items/bikehorn.ogg', 30, 1)
	else if(istype(src, /obj/machinery/door/airlock/mime))
		// Do nothing
	else
		playsound(src.loc, 'sound/machines/airlock.ogg', 30, 1)
	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(2)//Smashin windows

	if(density)
		return 1
	operating = 1
	do_animate("closing")
	src.layer = 3.1
	sleep(5)
	src.density = 1
	if(!safe)
		crush()
	sleep(5)
	update_icon()
	if(visible && !glass)
		SetOpacity(1)
	operating = 0
	air_update_turf(1)
	update_freelok_sight()
	if(locate(/mob/living) in get_turf(src))
		open()

	return

/obj/machinery/door/airlock/proc/lock(var/forced=0)
	if(locked)
		return 0

	if (operating && !forced) return 0

	src.locked = 1
	for(var/mob/M in range(1,src))
		M.show_message("You hear a click from the bottom of the door.", 2)
	update_icon()
	return 1

/obj/machinery/door/airlock/proc/unlock(var/forced=0)
	if(!src.locked)
		return

	if (!forced)
		if(operating || !src.arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_DOOR_BOLTS)) return

	src.locked = 0
	for(var/mob/M in range(1,src))
		M.show_message("You hear a click from the bottom of the door.", 2)
	update_icon()
	return 1

/obj/machinery/door/airlock/New()
	..()
	wires = new(src)
	if(src.closeOtherId != null)
		spawn (5)
			for (var/obj/machinery/door/airlock/A in world)
				if(A.closeOtherId == src.closeOtherId && A != src)
					src.closeOther = A
					break
	if(frozen)
		welded = 1
		update_icon()


/obj/machinery/door/airlock/proc/prison_open()
	src.unlock()
	src.open()
	src.locked = 1
	return


/obj/machinery/door/airlock/hatch/gamma/attackby(C as obj, mob/user as mob, params)
	//world << text("airlock attackby src [] obj [] mob []", src, C, user)
	if(!istype(usr, /mob/living/silicon))
		if(src.isElectrified())
			if(src.shock(user, 75))
				return
	if(istype(C, /obj/item/device/detective_scanner) || istype(C, /obj/item/taperoll))
		return

	if(istype(C, /obj/item/weapon/c4))
		user << "The hatch is coated with a product that prevents the shaped charge from sticking!"
		return

	if(istype(C, /obj/item/mecha_parts/mecha_equipment/tool/rcd) || istype(C, /obj/item/weapon/rcd))
		user << "The hatch is made of an advanced compound that cannot be deconstructed using an RCD."
		return

	src.add_fingerprint(user)
	if((istype(C, /obj/item/weapon/weldingtool) && !( src.operating > 0 ) && src.density))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0,user))
			if(frozen)
				frozen = 0
			if(!src.welded)
				src.welded = 1
			else
				src.welded = null
			src.update_icon()
			return
		else
			return


/obj/machinery/door/airlock/highsecurity/red/attackby(C as obj, mob/user as mob, params)
	//world << text("airlock attackby src [] obj [] mob []", src, C, user)
	if(!istype(usr, /mob/living/silicon))
		if(src.isElectrified())
			if(src.shock(user, 75))
				return
	if(istype(C, /obj/item/device/detective_scanner) || istype(C, /obj/item/taperoll))
		return

	src.add_fingerprint(user)
	if((istype(C, /obj/item/weapon/weldingtool) && !( src.operating > 0 ) && src.density))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0,user))
			if(frozen)
				frozen = 0
			if(!src.welded)
				src.welded = 1
			else
				src.welded = null
			src.update_icon()
			return
		else
			return

/obj/machinery/door/airlock/CanAStarPass(var/obj/item/weapon/card/id/ID)
//Airlock is passable if it is open (!density), bot has access, and is not bolted shut)
	return !density || (check_access(ID) && !locked)

/obj/machinery/door/airlock/emp_act(var/severity)
	if(prob(40/severity))
		var/duration = world.time + SecondsToTicks(30 / severity)
		if(duration > electrified_until)
			electrify(duration)
	..()

/obj/machinery/door/airlock/power_change() //putting this is obj/machinery/door itself makes non-airlock doors turn invisible for some reason
	..()
	if(stat & NOPOWER)
		// If we lost power, disable electrification
		// Keeping door lights on, runs on internal battery or something.
		electrified_until = 0
	update_icon()
