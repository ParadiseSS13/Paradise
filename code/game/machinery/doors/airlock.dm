/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	arePowerSystemsOn - 1 if the main or backup power are functioning, 0 if not.
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/


// Wires for the airlock are located in the datum folder, inside the wires datum folder.

#define AIRLOCK_CLOSED	1
#define AIRLOCK_CLOSING	2
#define AIRLOCK_OPEN	3
#define AIRLOCK_OPENING	4
#define AIRLOCK_DENY	5
#define AIRLOCK_EMAG	6

#define AIRLOCK_SECURITY_NONE			0 //Normal airlock				//Wires are not secured
#define AIRLOCK_SECURITY_METAL			1 //Medium security airlock		//There is a simple metal over wires (use welder)
#define AIRLOCK_SECURITY_PLASTEEL_I_S	2 								//Sliced inner plating (use crowbar), jumps to 0
#define AIRLOCK_SECURITY_PLASTEEL_I		3 								//Removed outer plating, second layer here (use welder)
#define AIRLOCK_SECURITY_PLASTEEL_O_S	4 								//Sliced outer plating (use crowbar)
#define AIRLOCK_SECURITY_PLASTEEL_O		5 								//There is first layer of plasteel (use welder)
#define AIRLOCK_SECURITY_PLASTEEL		6 //Max security airlock		//Fully secured wires (use wirecutters to remove grille, that is electrified)

#define AIRLOCK_INTEGRITY_N			 300 // Normal airlock integrity
#define AIRLOCK_INTEGRITY_MULTIPLIER 1.5 // How much reinforced doors health increases
#define AIRLOCK_DAMAGE_DEFLECTION_N  21  // Normal airlock damage deflection
#define AIRLOCK_DAMAGE_DEFLECTION_R  30  // Reinforced airlock damage deflection

GLOBAL_LIST_EMPTY(airlock_overlays)

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "closed"
	anchored = 1
	max_integrity = 300
	integrity_failure = 70
	damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
	autoclose = TRUE
	explosion_block = 1
	assemblytype = /obj/structure/door_assembly
	normalspeed = 1
	siemens_strength = 1
	var/security_level = 0 //How much are wires secured
	var/aiControlDisabled = FALSE //If TRUE, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = FALSE // if TRUE, this door can't be hacked by the AI
	var/electrified_until = 0	// World time when the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/main_power_lost_until = 0	 //World time when main power is restored.
	var/backup_power_lost_until = -1 //World time when backup power is restored.
	var/electrified_timer
	var/main_power_timer
	var/backup_power_timer
	var/spawnPowerRestoreRunning = 0
	var/lights = TRUE // bolt lights show by default
	var/datum/wires/airlock/wires
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther
	var/closeOtherId
	var/lockdownbyai = 0
	var/justzap = 0
	var/obj/item/airlock_electronics/electronics
	var/shockCooldown = FALSE //Prevents multiple shocks from happening
	var/obj/item/note //Any papers pinned to the airlock
	var/previous_airlock = /obj/structure/door_assembly //what airlock assembly mineral plating was applied to
	var/airlock_material //material of inner filling; if its an airlock with glass, this should be set to "glass"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	var/note_overlay_file = 'icons/obj/doors/airlocks/station/overlays.dmi' //Used for papers and photos pinned to the airlock
	var/normal_integrity = AIRLOCK_INTEGRITY_N
	var/prying_so_hard = FALSE

	var/image/old_frame_overlay //keep those in order to prevent unnecessary updating
	var/image/old_filling_overlay
	var/image/old_lights_overlay
	var/image/old_panel_overlay
	var/image/old_weld_overlay
	var/image/old_sparks_overlay
	var/image/old_dam_overlay
	var/image/old_note_overlay

	var/doorOpen = 'sound/machines/airlock_open.ogg'
	var/doorClose = 'sound/machines/airlock_close.ogg'
	var/doorDeni = 'sound/machines/deniedbeep.ogg' // i'm thinkin' Deni's
	var/boltUp = 'sound/machines/boltsup.ogg'
	var/boltDown = 'sound/machines/boltsdown.ogg'
	var/is_special = 0

/obj/machinery/door/airlock/welded
	welded = TRUE
/*
About the new airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open. This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires.
*		one wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power). If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)
*		two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be open, but bolts-raising will not work. Cutting these wires may electrocute the user.
*		one wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is). Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*		two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter). Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*		one wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.
*		one wire for AI control. Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again). Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*		one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds. Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted. (Currently it is also STAYING electrified until someone mends the wire)
*		one wire for controling door safetys.  When active, door does not close on someone.  When cut, door will ruin someone's shit.  When pulsed, door will immedately ruin someone's shit.
*		one wire for controlling door speed.  When active, dor closes at normal rate.  When cut, door does not close manually.  When pulsed, door attempts to close every tick.
*/
// You can find code for the airlock wires in the wire datum folder.

/obj/machinery/door/airlock/New()
	..()
	wires = new(src)

/obj/machinery/door/airlock/Initialize()
	. = ..()
	if(closeOtherId != null)
		addtimer(CALLBACK(src, .proc/update_other_id), 5)
	if(glass)
		airlock_material = "glass"
	if(security_level > AIRLOCK_SECURITY_METAL)
		obj_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
		max_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
	else
		obj_integrity = normal_integrity
		max_integrity = normal_integrity
	if(damage_deflection == AIRLOCK_DAMAGE_DEFLECTION_N && security_level > AIRLOCK_SECURITY_METAL)
		damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
	update_icon()

/obj/machinery/door/airlock/proc/update_other_id()
	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.closeOtherId == closeOtherId && A != src)
			closeOther = A
			break

/obj/machinery/door/airlock/Destroy()
	QDEL_NULL(electronics)
	QDEL_NULL(wires)
	QDEL_NULL(note)
	if(main_power_timer)
		deltimer(main_power_timer)
		main_power_timer = null
	if(backup_power_timer)
		deltimer(backup_power_timer)
		backup_power_timer = null
	if(electrified_timer)
		deltimer(electrified_timer)
		electrified_timer = null
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/door/airlock/handle_atom_del(atom/A)
	if(A == note)
		note = null
		update_icon()

/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!issilicon(usr))
		if(isElectrified())
			if(!justzap)
				if(shock(user, 100))
					justzap = 1
					spawn (10)
						justzap = 0
					return
			else /*if(justzap)*/
				return
		else if(user.hallucination > 50 && prob(10) && !operating)
			if(user.electrocute_act(50, src, 1, illusion = TRUE)) // We'll just go with a flat 50 damage, instead of doing powernet checks
				return
	..(user)

/obj/machinery/door/airlock/bumpopen(mob/living/simple_animal/user)
	..(user)

/obj/machinery/door/airlock/proc/isElectrified()
	if(electrified_until != 0)
		return 1
	return 0

/obj/machinery/door/airlock/proc/isWireCut(wireIndex)
	// You can find the wires in the datum folder.
	return wires.IsIndexCut(wireIndex)

/obj/machinery/door/airlock/proc/canAIControl()
	return ((aiControlDisabled!=1) && (!isAllPowerLoss()));

/obj/machinery/door/airlock/proc/canAIHack()
	return ((aiControlDisabled==1) && (!hackProof) && (!isAllPowerLoss()));

/obj/machinery/door/airlock/proc/arePowerSystemsOn()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return (main_power_lost_until==0 || backup_power_lost_until==0)

/obj/machinery/door/airlock/requiresID()
	return !(isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerLoss()
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(mainPowerCablesCut() && backupPowerCablesCut())
		return 1
	return 0

/obj/machinery/door/airlock/proc/mainPowerCablesCut()
	return isWireCut(AIRLOCK_WIRE_MAIN_POWER1)

/obj/machinery/door/airlock/proc/backupPowerCablesCut()
	return isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)

/obj/machinery/door/airlock/proc/loseMainPower()
	main_power_lost_until = mainPowerCablesCut() ? -1 : world.time + SecondsToTicks(60)
	if(main_power_lost_until > 0)
		main_power_timer = addtimer(CALLBACK(src, .proc/regainMainPower), SecondsToTicks(60), TIMER_UNIQUE | TIMER_STOPPABLE)
	// If backup power is permanently disabled then activate in 10 seconds if possible, otherwise it's already enabled or a timer is already running
	if(backup_power_lost_until == -1 && !backupPowerCablesCut())
		backup_power_lost_until = world.time + SecondsToTicks(10)
		backup_power_timer = addtimer(CALLBACK(src, .proc/regainBackupPower), SecondsToTicks(10), TIMER_UNIQUE | TIMER_STOPPABLE)
	// Disable electricity if required
	if(electrified_until && isAllPowerLoss())
		electrify(0)

/obj/machinery/door/airlock/proc/loseBackupPower()
	backup_power_lost_until = backupPowerCablesCut() ? -1 : world.time + SecondsToTicks(60)
	if(backup_power_lost_until > 0)
		backup_power_timer = addtimer(CALLBACK(src, .proc/regainBackupPower), SecondsToTicks(60), TIMER_UNIQUE | TIMER_STOPPABLE)

	// Disable electricity if required
	if(electrified_until && isAllPowerLoss())
		electrify(0)

/obj/machinery/door/airlock/proc/regainMainPower()
	main_power_timer = null

	if(!mainPowerCablesCut())
		main_power_lost_until = 0
		// If backup power is currently active then disable, otherwise let it count down and disable itself later
		if(!backup_power_lost_until)
			backup_power_lost_until = -1
		update_icon()

/obj/machinery/door/airlock/proc/regainBackupPower()
	backup_power_timer = null

	if(!backupPowerCablesCut())
		// Restore backup power only if main power is offline, otherwise permanently disable
		backup_power_lost_until = main_power_lost_until == 0 ? -1 : 0
		update_icon()

/obj/machinery/door/airlock/proc/electrify(duration, feedback = 0)
	if(electrified_timer)
		deltimer(electrified_timer)
		electrified_timer = null

	var/message = ""
	if(isWireCut(AIRLOCK_WIRE_ELECTRIFY) && arePowerSystemsOn())
		message = text("The electrification wire is cut - Door permanently electrified.")
		electrified_until = -1
	else if(duration && !arePowerSystemsOn())
		message = text("The door is unpowered - Cannot electrify the door.")
		electrified_until = 0
	else if(!duration && electrified_until != 0)
		message = "The door is now un-electrified."
		electrified_until = 0
	else if(duration)	//electrify door for the given duration seconds
		if(usr)
			shockedby += text("\[[time_stamp()]\] - [usr](ckey:[usr.ckey])")
			usr.create_attack_log("<font color='red'>Electrified the [name] at [x] [y] [z]</font>")
			add_attack_logs(usr, src, "Electrified")
		else
			shockedby += text("\[[time_stamp()]\] - EMP)")
		message = "The door is now electrified [duration == -1 ? "permanently" : "for [duration] second\s"]."
		electrified_until = duration == -1 ? -1 : world.time + SecondsToTicks(duration)
		if(duration != -1)
			electrified_timer = addtimer(CALLBACK(src, .proc/electrify, 0), SecondsToTicks(duration), TIMER_UNIQUE | TIMER_STOPPABLE)
	if(feedback && message)
		to_chat(usr, message)

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/shock(mob/user, prb)
	if(!arePowerSystemsOn())
		return FALSE
	if(shockCooldown > world.time)
		return FALSE	//Already shocked someone recently?
	if(..())
		shockCooldown = world.time + 10
		return TRUE
	else
		return FALSE

//Checks if the user can get shocked and shocks him if it can. Returns TRUE if it happened
/obj/machinery/door/airlock/proc/shock_user(mob/user, prob)
	return (!issilicon(user) && isElectrified() && shock(user, prob))

/obj/machinery/door/airlock/update_icon(state=0, override=0)
	if(operating && !override)
		return
	check_unres()
	icon_state = density ? "closed" : "open"
	switch(state)
		if(0)
			if(density)
				state = AIRLOCK_CLOSED
			else
				state = AIRLOCK_OPEN
		if(AIRLOCK_OPEN, AIRLOCK_CLOSED)
		if(AIRLOCK_DENY, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_EMAG)
			icon_state = "nonexistenticonstate" //MADNESS
	set_airlock_overlays(state)

/obj/machinery/door/airlock/proc/set_airlock_overlays(state)
	var/image/frame_overlay
	var/image/filling_overlay
	var/image/lights_overlay
	var/image/panel_overlay
	var/image/weld_overlay
	var/image/damag_overlay
	var/image/sparks_overlay
	var/image/note_overlay
	var/notetype = note_type()
	switch(state)
		if(AIRLOCK_CLOSED)
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(lights && arePowerSystemsOn())
				if(locked)
					lights_overlay = get_airlock_overlay("lights_bolts", overlays_file)
				else if(emergency)
					lights_overlay = get_airlock_overlay("lights_emergency", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_DENY)
			if(!arePowerSystemsOn())
				return
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			lights_overlay = get_airlock_overlay("lights_denied", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_EMAG)
			frame_overlay = get_airlock_overlay("closed", icon)
			sparks_overlay = get_airlock_overlay("sparks", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_CLOSING)
			frame_overlay = get_airlock_overlay("closing", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closing", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closing", icon)
			if(lights && arePowerSystemsOn())
				lights_overlay = get_airlock_overlay("lights_closing", overlays_file)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closing_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closing", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_closing", note_overlay_file)

		if(AIRLOCK_OPEN)
			frame_overlay = get_airlock_overlay("open", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_open", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_open", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_open_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_open", overlays_file)
			if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_open", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_open", note_overlay_file)

		if(AIRLOCK_OPENING)
			frame_overlay = get_airlock_overlay("opening", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_opening", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_opening", icon)
			if(lights && arePowerSystemsOn())
				lights_overlay = get_airlock_overlay("lights_opening", overlays_file)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_opening_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_opening", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_opening", note_overlay_file)

	//doesn't use overlays.Cut() for performance reasons
	if(frame_overlay != old_frame_overlay)
		overlays -= old_frame_overlay
		overlays += frame_overlay
		old_frame_overlay = frame_overlay
	if(filling_overlay != old_filling_overlay)
		overlays -= old_filling_overlay
		overlays += filling_overlay
		old_filling_overlay = filling_overlay
	if(lights_overlay != old_lights_overlay)
		overlays -= old_lights_overlay
		overlays += lights_overlay
		old_lights_overlay = lights_overlay
	if(panel_overlay != old_panel_overlay)
		overlays -= old_panel_overlay
		overlays += panel_overlay
		old_panel_overlay = panel_overlay
	if(weld_overlay != old_weld_overlay)
		overlays -= old_weld_overlay
		overlays += weld_overlay
		old_weld_overlay = weld_overlay
	if(sparks_overlay != old_sparks_overlay)
		overlays -= old_sparks_overlay
		overlays += sparks_overlay
		old_sparks_overlay = sparks_overlay
	if(damag_overlay != old_dam_overlay)
		overlays -= old_dam_overlay
		overlays += damag_overlay
		old_dam_overlay = damag_overlay
	if(note_overlay != old_note_overlay)
		overlays -= old_note_overlay
		overlays += note_overlay
		old_note_overlay = note_overlay

/proc/get_airlock_overlay(icon_state, icon_file)
	var/iconkey = "[icon_state][icon_file]"
	if(GLOB.airlock_overlays[iconkey])
		return GLOB.airlock_overlays[iconkey]
	GLOB.airlock_overlays[iconkey] = image(icon_file, icon_state)
	return GLOB.airlock_overlays[iconkey]

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			update_icon(AIRLOCK_OPENING)
		if("closing")
			update_icon(AIRLOCK_CLOSING)
		if("deny")
			if(!stat)
				update_icon(AIRLOCK_DENY)
				playsound(src,doorDeni,50,0,3)
				sleep(6)
				update_icon(AIRLOCK_CLOSED)

/obj/machinery/door/airlock/examine(mob/user)
	. = ..()
	if(emagged)
		. += "<span class='warning'>Its access panel is smoking slightly.</span>"
	if(note)
		if(!in_range(user, src))
			. += "There's a [note.name] pinned to the front. You can't [note_type() == "note" ? "read" : "see"] it from here."
		else
			. += "There's a [note.name] pinned to the front..."
			note.examine(user)
			. += "<span class='notice'>Use an empty hand on the airlock on grab mode to remove [note.name].</span>"

	if(panel_open)
		switch(security_level)
			if(AIRLOCK_SECURITY_NONE)
				. += "Its wires are exposed!"
			if(AIRLOCK_SECURITY_METAL)
				. += "Its wires are hidden behind a welded metal cover."
			if(AIRLOCK_SECURITY_PLASTEEL_I_S)
				. += "There is some shredded plasteel inside."
			if(AIRLOCK_SECURITY_PLASTEEL_I)
				. += "Its wires are behind an inner layer of plasteel."
			if(AIRLOCK_SECURITY_PLASTEEL_O_S)
				. += "There is some shredded plasteel inside."
			if(AIRLOCK_SECURITY_PLASTEEL_O)
				. += "There is a welded plasteel cover hiding its wires."
			if(AIRLOCK_SECURITY_PLASTEEL)
				. += "There is a protective grille over its panel."
	else if(security_level)
		if(security_level == AIRLOCK_SECURITY_METAL)
			. += "It looks a bit stronger."
		else
			. += "It looks very robust."

/obj/machinery/door/airlock/attack_ghost(mob/user)
	if(panel_open)
		wires.Interact(user)
	ui_interact(user)

/obj/machinery/door/airlock/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/door/airlock/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "door_control.tmpl", "Door Controls - [src]", 600, 375)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/door/airlock/ui_data(mob/user, datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["main_power_loss"]		= round(main_power_lost_until 	> 0 ? max(main_power_lost_until - world.time,	0) / 10 : main_power_lost_until,	1)
	data["backup_power_loss"]	= round(backup_power_lost_until	> 0 ? max(backup_power_lost_until - world.time,	0) / 10 : backup_power_lost_until,	1)
	data["electrified"] 		= round(electrified_until		> 0 ? max(electrified_until - world.time, 	0) / 10 	: electrified_until,		1)
	data["open"] = !density

	var/commands[0]
	commands[++commands.len] = list("name" = "IdScan",			"command"= "idscan",	"active" = !aiDisabledIdScanner,"enabled" = "Enabled",	"disabled" = "Disable",		"danger" = 0, "act" = 1)
	commands[++commands.len] = list("name" = "Bolts",			"command"= "bolts",		"active" = !locked,				"enabled" = "Raised",	"disabled" = "Dropped",		"danger" = 0, "act" = 0)
	commands[++commands.len] = list("name" = "Bolt Lights",		"command"= "lights",	"active" = lights,				"enabled" = "Enabled",	"disabled" = "Disable",		"danger" = 0, "act" = 1)
	commands[++commands.len] = list("name" = "Safeties",		"command"= "safeties",	"active" = safe,				"enabled" = "Nominal",	"disabled" = "Overridden",	"danger" = 1, "act" = 0)
	commands[++commands.len] = list("name" = "Timing",			"command"= "timing",	"active" = normalspeed,			"enabled" = "Nominal",	"disabled" = "Overridden",	"danger" = 1, "act" = 0)
	commands[++commands.len] = list("name" = "Door State",		"command"= "open",		"active" = density,				"enabled" = "Closed",	"disabled" = "Opened", 		"danger" = 0, "act" = 0)
	commands[++commands.len] = list("name" = "Emergency Access","command"= "emergency",	"active" = !emergency,			"enabled" = "Disabled",	"disabled" = "Enabled", 	"danger" = 0, "act" = 0)

	data["commands"] = commands
	return data

/obj/machinery/door/airlock/proc/hack(mob/user)
	set waitfor = 0
	if(!aiHacking)
		aiHacking = TRUE
		to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
		sleep(50)
		if(canAIControl())
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!canAIHack(user))
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking=0
			return
		to_chat(user, "Fault confirmed: airlock control wire disabled or cut.")
		sleep(20)
		to_chat(user, "Attempting to hack into airlock. This may take some time.")
		sleep(200)
		if(canAIControl())
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!canAIHack(user))
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
		sleep(170)
		if(canAIControl())
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!canAIHack(user))
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Transfer complete. Forcing airlock to execute program.")
		sleep(50)
		//disable blocked control
		aiControlDisabled = 2
		to_chat(user, "Receiving control information from airlock.")
		sleep(10)
		//bring up airlock dialog
		aiHacking = FALSE
		if(user)
			attack_ai(user)

/obj/machinery/door/airlock/proc/check_unres() //unrestricted sides. This overlay indicates which directions the player can access even without an ID
	if(hasPower() && unres_sides)
		if(unres_sides & NORTH)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_n") //layer=src.layer+1
			I.pixel_y = 32
			set_light(l_range = 1, l_power = 1, l_color = "#00FF00")
			add_overlay(I)
		if(unres_sides & SOUTH)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_s") //layer=src.layer+1
			I.pixel_y = -32
			set_light(l_range = 1, l_power = 1, l_color = "#00FF00")
			add_overlay(I)
		if(unres_sides & EAST)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_e") //layer=src.layer+1
			I.pixel_x = 32
			set_light(l_range = 1, l_power = 1, l_color = "#00FF00")
			add_overlay(I)
		if(unres_sides & WEST)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_w") //layer=src.layer+1
			I.pixel_x = -32
			set_light(l_range = 1, l_power = 1, l_color = "#00FF00")
			add_overlay(I)
	else
		set_light(0)

/obj/machinery/door/airlock/CanPass(atom/movable/mover, turf/target, height=0)
	if(isElectrified() && density && istype(mover, /obj/item))
		var/obj/item/I = mover
		if(I.flags & CONDUCT)
			do_sparks(5, 1, src)
	return ..()

/obj/machinery/door/airlock/attack_animal(mob/user)
	. = ..()
	if(isElectrified())
		shock(user, 100)

/obj/machinery/door/airlock/attack_hand(mob/user)
	if(shock_user(user, 100))
		return

	if(headbutt_airlock(user))
		return//Smack that head against that airlock
	if(remove_airlock_note(user, FALSE))
		return

	if(panel_open)
		if(security_level)
			to_chat(user, "<span class='warning'>Wires are protected!</span>")
			return
		wires.Interact(user)
	else
		..()


//Checks if the user can headbutt the airlock and does it if it can. Returns TRUE if it happened
/obj/machinery/door/airlock/proc/headbutt_airlock(mob/user)
	if(ishuman(user) && prob(40) && density)
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60 && Adjacent(user))
			playsound(loc, 'sound/effects/bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				visible_message("<span class='warning'>[user] headbutts the airlock.</span>")
				var/obj/item/organ/external/affecting = H.get_organ("head")
				H.Stun(5)
				H.Weaken(5)
				if(affecting.receive_damage(10, 0))
					H.UpdateDamageIcon()
			else
				visible_message("<span class='warning'>[user] headbutts the airlock. Good thing [user.p_theyre()] wearing a helmet.</span>")
			return TRUE
	return FALSE

//For the tools being used on the door. Since you don't want to call the attack_hand method if you're using hands. That would be silly
//Also it's a bit inconsistent that when you access the panel you headbutt it. But not while crowbarring
//Try to interact with the panel. If the user can't it'll try activating the door
/obj/machinery/door/airlock/proc/interact_with_panel(mob/user)
	if(shock_user(user, 100))
		return

	if(panel_open)
		if(security_level)
			to_chat(user, "<span class='warning'>Wires are protected!</span>")
			return
		wires.Interact(user)
	else
		try_to_activate_door(user)

/obj/machinery/door/airlock/CanUseTopic(mob/user)
	if(!issilicon(user) && !isobserver(user))
		return STATUS_CLOSE

	if(emagged)
		to_chat(user, "<span class='warning'>Unable to interface: Internal error.</span>")
		return STATUS_CLOSE
	if(!canAIControl() && !isobserver(user))
		if(canAIHack(user))
			hack(user)
		else
			if(isAllPowerLoss()) //don't really like how this gets checked a second time, but not sure how else to do it.
				to_chat(user, "<span class='warning'>Unable to interface: Connection timed out.</span>")
			else
				to_chat(user, "<span class='warning'>Unable to interface: Connection refused.</span>")
		return STATUS_CLOSE

	return ..()

/obj/machinery/door/airlock/Topic(href, href_list, nowindow = 0)
	if(..())
		return 1

	var/activate = text2num(href_list["activate"])
	switch(href_list["command"])
		if("idscan")
			if(isWireCut(AIRLOCK_WIRE_IDSCAN))
				to_chat(usr, "The IdScan wire has been cut - IdScan feature permanently disabled.")
			else if(activate && aiDisabledIdScanner)
				aiDisabledIdScanner = 0
				to_chat(usr, "IdScan feature has been enabled.")
			else if(!activate && !aiDisabledIdScanner)
				aiDisabledIdScanner = 1
				to_chat(usr, "IdScan feature has been disabled.")
		if("main_power")
			if(!main_power_lost_until)
				loseMainPower()
				update_icon()
		if("backup_power")
			if(!backup_power_lost_until)
				loseBackupPower()
				update_icon()
		if("bolts")
			if(isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
				to_chat(usr, "The door bolt control wire has been cut - Door bolts permanently dropped.")
			else if(activate && lock())
				to_chat(usr, "The door bolts have been dropped.")
			else if(!activate && unlock())
				to_chat(usr, "The door bolts have been raised.")
		if("electrify_temporary")
			if(activate && isWireCut(AIRLOCK_WIRE_ELECTRIFY))
				to_chat(usr, text("The electrification wire is cut - Door permanently electrified."))
			else if(!activate && electrified_until != 0)
				to_chat(usr, "The door is now un-electrified.")
				electrify(0)
			else if(activate)	//electrify door for 30 seconds
				shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				usr.create_attack_log("<font color='red'>Electrified the [name] at [x] [y] [z]</font>")
				add_attack_logs(usr, src, "Electrified")
				to_chat(usr, "The door is now electrified for thirty seconds.")
				electrify(30)
		if("electrify_permanently")
			if(isWireCut(AIRLOCK_WIRE_ELECTRIFY))
				to_chat(usr, text("The electrification wire is cut - Cannot electrify the door."))
			else if(!activate && electrified_until != 0)
				to_chat(usr, "The door is now un-electrified.")
				electrify(0)
			else if(activate)
				shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				usr.create_attack_log("<font color='red'>Electrified the [name] at [x] [y] [z]</font>")
				add_attack_logs(usr, src, "Electrified")
				to_chat(usr, "The door is now electrified.")
				electrify(-1)
		if("open")
			if(welded)
				to_chat(usr, text("The airlock has been welded shut!"))
			else if(locked)
				to_chat(usr, text("The door bolts are down!"))
			else if(activate && density)
				open()
			else if(!activate && !density)
				close()
		if("safeties")
			// Safeties!  We don't need no stinking safeties!
			if(isWireCut(AIRLOCK_WIRE_SAFETY))
				to_chat(usr, text("The safety wire is cut - Cannot secure the door."))
			else if(activate && safe)
				safe = 0
			else if(!activate && !safe)
				safe = 1
		if("timing")
			// Door speed control
			if(isWireCut(AIRLOCK_WIRE_SPEED))
				to_chat(usr, text("The timing wire is cut - Cannot alter timing."))
			else if(activate && normalspeed)
				normalspeed = 0
			else if(!activate && !normalspeed)
				normalspeed = 1
		if("lights")
			// Bolt lights
			if(isWireCut(AIRLOCK_WIRE_LIGHT))
				to_chat(usr, "The bolt lights wire has been cut - The door bolt lights are permanently disabled.")
			else if(!activate && lights)
				lights = 0
				to_chat(usr, "The door bolt lights have been disabled.")
			else if(activate && !lights)
				lights = 1
				to_chat(usr, "The door bolt lights have been enabled.")
			update_icon()
		if("emergency")
			// Emergency access
			if(emergency)
				emergency = 0
				to_chat(usr, "Emergency access has been disabled.")
			else
				emergency = 1
				to_chat(usr, "Emergency access has been enabled.")
			update_icon()
	return 1

/obj/machinery/door/airlock/attackby(obj/item/C, mob/user, params)
	add_fingerprint(user)
	if(!headbutt_shock_check(user))
		return
	if(panel_open)
		switch(security_level)
			if(AIRLOCK_SECURITY_NONE)
				if(istype(C, /obj/item/stack/sheet/metal))
					var/obj/item/stack/sheet/metal/S = C
					if(S.get_amount() < 2)
						to_chat(user, "<span class='warning'>You need at least 2 metal sheets to reinforce [src].</span>")
						return
					to_chat(user, "<span class='notice'>You start reinforcing [src]...</span>")
					if(do_after(user, 20, 1, target = src))
						if(!panel_open || !S.use(2))
							return
						user.visible_message("<span class='notice'>[user] reinforces \the [src] with metal.</span>",
											"<span class='notice'>You reinforce \the [src] with metal.</span>")
						security_level = AIRLOCK_SECURITY_METAL
						update_icon()
					return
				else if(istype(C, /obj/item/stack/sheet/plasteel))
					var/obj/item/stack/sheet/plasteel/S = C
					if(S.get_amount() < 2)
						to_chat(user, "<span class='warning'>You need at least 2 plasteel sheets to reinforce [src].</span>")
						return
					to_chat(user, "<span class='notice'>You start reinforcing [src]...</span>")
					if(do_after(user, 20, 1, target = src))
						if(!panel_open || !S.use(2))
							return
						user.visible_message("<span class='notice'>[user] reinforces \the [src] with plasteel.</span>",
											"<span class='notice'>You reinforce \the [src] with plasteel.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL
						modify_max_integrity(normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER)
						damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
						update_icon()
					return

	else if(istype(C, /obj/item/assembly/signaler))
		return interact_with_panel(user)
	else if(istype(C, /obj/item/pai_cable))	// -- TLE
		var/obj/item/pai_cable/cable = C
		cable.plugin(src, user)
	else if((istype(C, /obj/item/paper) && !istype(C, /obj/item/paper/talisman)) || istype(C, /obj/item/photo))
		if(note)
			to_chat(user, "<span class='warning'>There's already something pinned to this airlock! Use wirecutters or your hands to remove it.</span>")
			return
		if(!user.unEquip(C))
			to_chat(user, "<span class='warning'>For some reason, you can't attach [C]!</span>")
			return
		C.forceMove(src)
		user.visible_message("<span class='notice'>[user] pins [C] to [src].</span>", "<span class='notice'>You pin [C] to [src].</span>")
		note = C
		update_icon()
	else
		return ..()

/obj/machinery/door/airlock/screwdriver_act(mob/user, obj/item/I)
	if(!headbutt_shock_check(user))
		return
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	panel_open = !panel_open
	to_chat(user, "<span class='notice'>You [panel_open ? "open":"close"] [src]'s maintenance panel.</span>")
	update_icon()

/obj/machinery/door/airlock/crowbar_act(mob/user, obj/item/I)
	if(!headbutt_shock_check(user))
		return
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(panel_open && security_level == AIRLOCK_SECURITY_PLASTEEL_I_S)
		to_chat(user, "<span class='notice'>You start removing the inner layer of shielding...</span>")
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			if(!panel_open || security_level != AIRLOCK_SECURITY_PLASTEEL_I_S)
				return
			user.visible_message("<span class='notice'>[user] remove \the [src]'s shielding.</span>",
								"<span class='notice'>You remove \the [src]'s inner shielding.</span>")
			security_level = AIRLOCK_SECURITY_NONE
			modify_max_integrity(normal_integrity)
			damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
			spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
			update_icon()
	else if(panel_open && security_level == AIRLOCK_SECURITY_PLASTEEL_O_S)
		to_chat(user, "<span class='notice'>You start removing outer layer of shielding...</span>")
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			if(!panel_open || security_level != AIRLOCK_SECURITY_PLASTEEL_O_S)
				return
			user.visible_message("<span class='notice'>[user] remove \the [src]'s shielding.</span>",
								"<span class='notice'>You remove \the [src]'s shielding.</span>")
			security_level = AIRLOCK_SECURITY_PLASTEEL_I
			spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
	else
		try_to_crowbar(user, I)

/obj/machinery/door/airlock/wirecutter_act(mob/user, obj/item/I)
	if(!headbutt_shock_check(user))
		return
	if(!panel_open || user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(!I.tool_start_check(user, 0))
		return
	if(security_level == AIRLOCK_SECURITY_PLASTEEL)
		if(arePowerSystemsOn() && shock(user, 60)) // Protective grille of wiring is electrified
			return
		to_chat(user, "<span class='notice'>You start cutting through the outer grille.</span>")
		if(I.use_tool(src, user, 10, volume = I.tool_volume))
			if(!panel_open || security_level != AIRLOCK_SECURITY_PLASTEEL)
				return
			user.visible_message("<span class='notice'>[user] cut through \the [src]'s outer grille.</span>",
								"<span class='notice'>You cut through \the [src]'s outer grille.</span>")
			security_level = AIRLOCK_SECURITY_PLASTEEL_O
		return
	if(note)
		remove_airlock_note(user, TRUE)
	else
		return interact_with_panel(user)

/obj/machinery/door/airlock/multitool_act(mob/user, obj/item/I)
	if(!headbutt_shock_check(user))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	interact_with_panel(user)

/obj/machinery/door/airlock/welder_act(mob/user, obj/item/I) //This is god awful but I don't care
	if(!headbutt_shock_check(user))
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	switch(security_level)
		if(AIRLOCK_SECURITY_METAL)
			to_chat(user, "<span class='notice'>You begin cutting the panel's shielding...</span>")
			if(!I.use_tool(src, user, 40, volume = I.tool_volume))
				return
			if(!panel_open)
				return
			visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
				"<span class='notice'>You cut through \the [src]'s shielding.</span>",
				"<span class='italics'>You hear welding.</span>")
			security_level = AIRLOCK_SECURITY_NONE
			spawn_atom_to_turf(/obj/item/stack/sheet/metal, user.loc, 2)
		if(AIRLOCK_SECURITY_PLASTEEL_O)
			to_chat(user, "<span class='notice'>You begin cutting the outer layer of shielding...</span>")
			if(!I.use_tool(src, user, 40, volume = I.tool_volume))
				return
			if(!panel_open)
				return
			visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
				"<span class='notice'>You cut through \the [src]'s shielding.</span>",
				"<span class='italics'>You hear welding.</span>")
			security_level = AIRLOCK_SECURITY_PLASTEEL_O_S
		if(AIRLOCK_SECURITY_PLASTEEL_I)
			to_chat(user, "<span class='notice'>You begin cutting the inner layer of shielding...</span>")
			if(!I.use_tool(src, user, 40, volume = I.tool_volume))
				return
			if(!panel_open)
				return
			user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
				"<span class='notice'>You cut through \the [src]'s shielding.</span>",
				"<span class='italics'>You hear welding.</span>")
			security_level = AIRLOCK_SECURITY_PLASTEEL_I_S
		else
			if(user.a_intent != INTENT_HELP)
				user.visible_message("[user] is [welded ? "unwelding":"welding"] the airlock.", \
					"<span class='notice'>You begin [welded ? "unwelding":"welding"] the airlock...</span>", \
					"<span class='italics'>You hear welding.</span>")

				if(I.use_tool(src, user, 40, volume = I.tool_volume, extra_checks = list(CALLBACK(src, .proc/weld_checks, I, user))))
					if(!density && !welded)
						return
					welded = !welded
					user.visible_message("[user.name] has [welded? "welded shut":"unwelded"] [src].", \
						"<span class='notice'>You [welded ? "weld the airlock shut":"unweld the airlock"].</span>")
					update_icon()
			else if(obj_integrity < max_integrity)
				user.visible_message("[user] is welding the airlock.", \
					"<span class='notice'>You begin repairing the airlock...</span>", \
					"<span class='italics'>You hear welding.</span>")
				if(I.use_tool(src, user, 40, volume = I.tool_volume, extra_checks = list(CALLBACK(src, .proc/weld_checks, I, user))))
					obj_integrity = max_integrity
					stat &= ~BROKEN
					user.visible_message("[user.name] has repaired [src].", \
						"<span class='notice'>You finish repairing the airlock.</span>")
				update_icon()
			else
				to_chat(user, "<span class='notice'>The airlock doesn't need repairing.</span>")
	update_icon()

/obj/machinery/door/airlock/proc/weld_checks(obj/item/I, mob/user)
	return !operating && density && user && I && I.tool_use_check() && user.loc

/obj/machinery/door/airlock/proc/headbutt_shock_check(mob/user)
	if(shock_user(user, 75))
		return
	if(headbutt_airlock(user))//See if the user headbutts the airlock
		return
	return TRUE

/obj/machinery/door/airlock/try_to_crowbar(mob/living/user, obj/item/I)	//*scream
	if(operating)
		return
	if(istype(I, /obj/item/twohanded/fireaxe)) //let's make this more specific //FUCK YOU
		var/obj/item/twohanded/fireaxe/F = I
		if(F.wielded)
			spawn(0)
				if(density)
					open(1)
				else
					close(1)
		else
			to_chat(user, "<span class='warning'>You need to be wielding the fire axe to do that!</span>")
		return
	var/beingcrowbarred = FALSE
	if(I.tool_behaviour == TOOL_CROWBAR && I.tool_use_check(user, 0))
		beingcrowbarred = TRUE
	if(beingcrowbarred && panel_open && (emagged || (density && welded && !operating && !arePowerSystemsOn() && !locked)))
		user.visible_message("[user] removes the electronics from the airlock assembly.", \
							 "<span class='notice'>You start to remove electronics from the airlock assembly...</span>")
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			deconstruct(TRUE, user)
		return
	if(welded)
		to_chat(user, "<span class='warning'>[src] is welded shut!</span>")
		return
	if(locked)
		to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
		return
	else if(!arePowerSystemsOn())
		spawn(0)
			if(density)
				open(1)
			else
				close(1)
		return
	else if(!ispowertool(I))
		to_chat(user, "<span class='warning'>The airlock's motors resist your efforts to force it!</span>")
		return
	if(isElectrified())
		shock(user, 100)//it's like sticking a forck in a power socket
		return

	if(!density)//already open
		return

	var/time_to_open = 5
	if(!prying_so_hard)
		time_to_open = 50
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, 1) //is it aliens or just the CE being a dick?
		prying_so_hard = TRUE
		var/result = do_after(user, time_to_open, target = src)
		prying_so_hard = FALSE
		if(result)
			open(1)
			if(density && !open(1))
				to_chat(user, "<span class='warning'>Despite your attempts, [src] refuses to open.</span>")

/obj/machinery/door/airlock/open(forced=0)
	if(operating || welded || locked || emagged)
		return 0
	if(!forced)
		if(!arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
			return 0
	use_power(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people
	if(forced)
		playsound(loc, 'sound/machines/airlockforced.ogg', 30, 1)
	else
		playsound(loc, doorOpen, 30, 1)
	if(closeOther != null && istype(closeOther, /obj/machinery/door/airlock/) && !closeOther.density)
		closeOther.close()

	if(autoclose)
		autoclose_in(normalspeed ? auto_close_time : auto_close_time_dangerous)

	if(!density)
		return TRUE
	operating = TRUE
	update_icon(AIRLOCK_OPENING, 1)
	sleep(1)
	set_opacity(0)
	update_freelook_sight()
	sleep(4)
	density = FALSE
	air_update_turf(1)
	sleep(1)
	layer = OPEN_DOOR_LAYER
	update_icon(AIRLOCK_OPEN, 1)
	operating = FALSE
	return TRUE

/obj/machinery/door/airlock/close(forced=0, override = 0)
	if((operating & !override) || welded || locked || emagged)
		return
	if(density)
		return TRUE
	if(!forced)
		//despite the name, this wire is for general door control.
		//Bolts are already covered by the check for locked, above
		if(!arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
			return
	if(safe)
		for(var/turf/turf in locs)
			for(var/atom/movable/M in turf)
				if(M.density && M != src) //something is blocking the door
					autoclose_in(60)
					return

	use_power(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people
	if(forced)
		playsound(loc, 'sound/machines/airlockforced.ogg', 30, 1)
	else
		playsound(loc, doorClose, 30, 1)
	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(EXPLODE_HEAVY)//Smashin windows

	operating = TRUE
	update_icon(AIRLOCK_CLOSING, 1)
	layer = CLOSED_DOOR_LAYER
	if(!override)
		sleep(1)
	density = TRUE
	air_update_turf(1)
	if(!override)
		sleep(4)
	if(!safe)
		crush()
	if(visible && !glass)
		set_opacity(1)
	update_freelook_sight()
	sleep(1)
	update_icon(AIRLOCK_CLOSED, 1)
	operating = FALSE
	if(safe)
		CheckForMobs()
	return TRUE

/obj/machinery/door/airlock/lock(forced=0)
	if(locked)
		return 0

	if(operating && !forced)
		return 0

	locked = 1
	playsound(src, boltDown, 30, 0, 3)
	update_icon()
	return 1

/obj/machinery/door/airlock/unlock(forced=0)
	if(!locked)
		return

	if(!forced)
		if(operating || !arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
			return

	locked = 0
	playsound(src,boltUp, 30, 0, 3)
	update_icon()
	return 1

/obj/machinery/door/airlock/CanAStarPass(obj/item/card/id/ID)
//Airlock is passable if it is open (!density), bot has access, and is not bolted or welded shut)
	return !density || (check_access(ID) && !locked && !welded && arePowerSystemsOn())

/obj/machinery/door/airlock/emag_act(mob/user)
	if(!operating && density && arePowerSystemsOn() && !emagged)
		operating = TRUE
		update_icon(AIRLOCK_EMAG, 1)
		sleep(6)
		if(QDELETED(src))
			return
		operating = FALSE
		if(!open())
			update_icon(AIRLOCK_CLOSED, 1)
		emagged = TRUE
		return 1

/obj/machinery/door/airlock/emp_act(severity)
	..()
	if(prob(40/severity))
		var/duration = world.time + SecondsToTicks(30 / severity)
		if(duration > electrified_until)
			electrify(duration)

/obj/machinery/door/airlock/attack_alien(mob/living/carbon/alien/humanoid/user)
	add_fingerprint(user)
	if(isElectrified())
		shock(user, 100) //Mmm, fried xeno!
		return
	if(!density) //Already open
		return
	if(locked || welded) //Extremely generic, as aliens only understand the basics of how airlocks work.
		to_chat(user, "<span class='warning'>[src] refuses to budge!</span>")
		return
	user.visible_message("<span class='warning'>[user] begins prying open [src].</span>",\
						"<span class='noticealien'>You begin digging your claws into [src] with all your might!</span>",\
						"<span class='warning'>You hear groaning metal...</span>")
	var/time_to_open = 5
	if(arePowerSystemsOn())
		time_to_open = 50 //Powered airlocks take longer to open, and are loud.
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)


	if(do_after(user, time_to_open, TRUE, src))
		if(density && !open(2)) //The airlock is still closed, but something prevented it opening. (Another player noticed and bolted/welded the airlock in time!)
			to_chat(user, "<span class='warning'>Despite your efforts, [src] managed to resist your attempts to open it!</span>")

/obj/machinery/door/airlock/power_change() //putting this is obj/machinery/door itself makes non-airlock doors turn invisible for some reason
	..()
	if(stat & NOPOWER)
		// If we lost power, disable electrification
		// Keeping door lights on, runs on internal battery or something.
		electrified_until = 0
	update_icon()

/obj/machinery/door/airlock/proc/prison_open()
	if(emagged)
		return
	if(arePowerSystemsOn())
		unlock()
		open()
		lock()

/obj/machinery/door/airlock/hostile_lockdown(mob/origin)
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !stat)
		locked = FALSE //For airlocks that were bolted open.
		safe = FALSE //DOOR CRUSH
		close()
		lock() //Bolt it!
		electrified_until = -1  //Shock it!
		if(origin)
			shockedby += "\[[time_stamp()]\][origin](ckey:[origin.ckey])"

/obj/machinery/door/airlock/disable_lockdown()
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !stat)
		unlock()
		electrified_until = 0
		open()
		safe = TRUE

/obj/machinery/door/airlock/obj_break(damage_flag)
	if(!(flags & BROKEN) && !(flags & NODECONSTRUCT))
		stat |= BROKEN
		if(!panel_open)
			panel_open = TRUE
		wires.CutAll()
		update_icon()

/obj/machinery/door/airlock/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(obj_integrity < (0.75 * max_integrity))
		update_icon()

/obj/machinery/door/airlock/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags & NODECONSTRUCT))
		var/obj/structure/door_assembly/DA
		if(assemblytype)
			DA = new assemblytype(loc)
		else
			DA = new /obj/structure/door_assembly(loc)
			//If you come across a null assemblytype, it will produce the default assembly instead of disintegrating.
		DA.heat_proof_finished = heat_proof //tracks whether there's rglass in
		DA.anchored = TRUE
		DA.glass = src.glass
		DA.state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
		DA.created_name = name
		DA.previous_assembly = previous_airlock
		DA.update_name()
		DA.update_icon()

		if(!disassembled)
			if(DA)
				DA.obj_integrity = DA.max_integrity * 0.5
		if(user)
			to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")
		var/obj/item/airlock_electronics/ae
		if(!electronics)
			ae = new/obj/item/airlock_electronics(loc)
			check_access()
			if(req_access.len)
				ae.conf_access = req_access
			else if(req_one_access.len)
				ae.conf_access = req_one_access
				ae.one_access = 1
		else
			ae = electronics
			electronics = null
			ae.forceMove(loc)
		if(emagged)
			ae.icon_state = "door_electronics_smoked"
			operating = 0
	qdel(src)

/obj/machinery/door/airlock/proc/note_type() //Returns a string representing the type of note pinned to this airlock
	if(!note)
		return
	else if(istype(note, /obj/item/paper))
		return "note"
	else if(istype(note, /obj/item/photo))
		return "photo"

//Removes the current note on the door if any. Returns if a note is removed
/obj/machinery/door/airlock/proc/remove_airlock_note(mob/user, wirecutters_used=TRUE)
	if(note)
		if(!wirecutters_used)
			if (ishuman(user) && user.a_intent == INTENT_GRAB)//grab that note
				user.visible_message("<span class='notice'>[user] removes [note] from [src].</span>", "<span class='notice'>You remove [note] from [src].</span>")
				playsound(src, 'sound/items/poster_ripped.ogg', 50, 1)
			else return FALSE
		else
			user.visible_message("<span class='notice'>[user] cuts down [note] from [src].</span>", "<span class='notice'>You remove [note] from [src].</span>")
			playsound(src, 'sound/items/wirecutter.ogg', 50, 1)
		user.put_in_hands(note)
		note = null
		update_icon()
		return TRUE
	return FALSE

/obj/machinery/door/airlock/narsie_act()
	var/turf/T = get_turf(src)
	var/runed = prob(20)
	var/obj/machinery/door/airlock/cult/A
	if(glass)
		if(runed)
			A = new/obj/machinery/door/airlock/cult/glass(T)
		else
			A = new/obj/machinery/door/airlock/cult/unruned/glass(T)
	else
		if(runed)
			A = new/obj/machinery/door/airlock/cult(T)
		else
			A = new/obj/machinery/door/airlock/cult/unruned(T)
	A.name = name
	qdel(src)

#undef AIRLOCK_CLOSED
#undef AIRLOCK_CLOSING
#undef AIRLOCK_OPEN
#undef AIRLOCK_OPENING
#undef AIRLOCK_DENY
#undef AIRLOCK_EMAG

#undef AIRLOCK_SECURITY_NONE
#undef AIRLOCK_SECURITY_METAL
#undef AIRLOCK_SECURITY_PLASTEEL_I_S
#undef AIRLOCK_SECURITY_PLASTEEL_I
#undef AIRLOCK_SECURITY_PLASTEEL_O_S
#undef AIRLOCK_SECURITY_PLASTEEL_O
#undef AIRLOCK_SECURITY_PLASTEEL

#undef AIRLOCK_INTEGRITY_N
#undef AIRLOCK_INTEGRITY_MULTIPLIER
#undef AIRLOCK_DAMAGE_DEFLECTION_N
#undef AIRLOCK_DAMAGE_DEFLECTION_R
