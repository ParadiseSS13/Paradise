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

#define UI_GREEN 2
#define UI_ORANGE 1
#define UI_RED 0


GLOBAL_LIST_EMPTY(airlock_overlays)
GLOBAL_LIST_EMPTY(airlock_emissive_underlays)

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "closed"
	anchored = TRUE
	max_integrity = 300
	integrity_failure = 70
	damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
	autoclose = TRUE
	explosion_block = 1
	hud_possible = list(DIAG_AIRLOCK_HUD)
	assemblytype = /obj/structure/door_assembly
	siemens_strength = 1
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	rad_insulation = RAD_MEDIUM_INSULATION
	smoothing_groups = list(SMOOTH_GROUP_AIRLOCK)
	var/security_level = 0 //How much are wires secured
	var/aiControlDisabled = AICONTROLDISABLED_OFF
	var/hackProof = FALSE // if TRUE, this door can't be hacked by the AI
	var/electrified_until = 0	// World time when the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/main_power_lost_until = 0	 //World time when main power is restored.
	var/backup_power_lost_until = -1 //World time when backup power is restored.
	var/electrified_timer
	var/main_power_timer
	var/backup_power_timer
	var/lights = TRUE // bolt lights show by default
	var/datum/wires/airlock/wires
	var/aiDisabledIdScanner = FALSE
	var/aiHacking = FALSE
	var/obj/machinery/door/airlock/closeOther
	var/closeOtherId
	var/obj/item/airlock_electronics/electronics
	var/shockCooldown = FALSE //Prevents multiple shocks from happening
	var/obj/item/note //Any papers pinned to the airlock
	var/airlock_material //material of inner filling; if its an airlock with glass, this should be set to "glass"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	var/note_overlay_file = 'icons/obj/doors/airlocks/station/overlays.dmi' //Used for papers and photos pinned to the airlock
	var/normal_integrity = AIRLOCK_INTEGRITY_N
	var/prying_so_hard = FALSE
	var/paintable = TRUE // If the airlock type can be painted with an airlock painter
	var/heat_resistance = 1500
	/// Have we created sparks too recently?
	var/on_spark_cooldown = FALSE

	var/mutable_appearance/old_buttons_underlay
	var/mutable_appearance/old_lights_underlay
	var/mutable_appearance/old_damag_underlay
	var/mutable_appearance/old_sparks_underlay

	var/doorOpen = 'sound/machines/airlock_open.ogg'
	var/doorClose = 'sound/machines/airlock_close.ogg'
	var/doorDeni = 'sound/machines/deniedbeep.ogg' // i'm thinkin' Deni's
	var/boltUp = 'sound/machines/boltsup.ogg'
	var/boltDown = 'sound/machines/boltsdown.ogg'
	var/is_special = FALSE
	/// Our ID tag for map-based linking shenanigans
	var/id_tag
	/// List of people who have shocked this door for logging purposes
	var/shockedby = list()
	/// Command currently being executed
	var/cur_command
	/// Is a command actually running
	var/command_running = FALSE


/obj/machinery/door/airlock/welded
	welded = TRUE

/*
 * reimp, imitate an access denied event.
 */
/obj/machinery/door/airlock/flicker()
	if(density && !operating && arePowerSystemsOn())
		do_animate("deny")
		return TRUE
	return FALSE

/obj/machinery/door/airlock/Initialize()
	. = ..()
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
	wires = new(src)

	if(closeOtherId != null)
		addtimer(CALLBACK(src, PROC_REF(update_other_id)), 5)
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
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_electrified()

/obj/machinery/door/airlock/proc/update_other_id()
	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.closeOtherId == closeOtherId && A != src)
			closeOther = A
			break

/obj/machinery/door/airlock/Destroy()
	SStgui.close_uis(wires)
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
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.remove_from_hud(src)
	return ..()

/obj/machinery/door/airlock/handle_atom_del(atom/A)
	if(A == note)
		note = null
		update_icon()

/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!issilicon(usr))
		if(isElectrified())
			if(shockCooldown <= world.time)
				if(shock(user, 100))
					return
			else
				return
		else if(user.AmountHallucinate() > 50 SECONDS && prob(10) && !operating)
			if(user.electrocute_act(50, src, flags = SHOCK_ILLUSION)) // We'll just go with a flat 50 damage, instead of doing powernet checks
				return
	..(user)

/obj/machinery/door/airlock/bumpopen(mob/living/simple_animal/user)
	..(user)

/obj/machinery/door/airlock/proc/isElectrified()
	if(electrified_until != 0)
		return 1
	return 0

/obj/machinery/door/airlock/proc/canAIControl()
	return ((aiControlDisabled != AICONTROLDISABLED_ON) && (!isAllPowerLoss()))

/obj/machinery/door/airlock/proc/canAIHack(mob/living/user)
	return ((aiControlDisabled == AICONTROLDISABLED_ON) && (!hackProof) && (!isAllPowerLoss()) && user.mind?.special_role)

/obj/machinery/door/airlock/proc/arePowerSystemsOn()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return (main_power_lost_until==0 || backup_power_lost_until==0)

/obj/machinery/door/airlock/requiresID()
	return !(wires.is_cut(WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerLoss()
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(wires.is_cut(WIRE_MAIN_POWER1) && wires.is_cut(WIRE_BACKUP_POWER1))
		return 1
	return 0

/obj/machinery/door/airlock/proc/loseMainPower()
	main_power_lost_until = wires.is_cut(WIRE_MAIN_POWER1) ? -1 : world.time + 60 SECONDS
	if(main_power_lost_until > 0)
		main_power_timer = addtimer(CALLBACK(src, PROC_REF(regainMainPower)), 60 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
	// If backup power is permanently disabled then activate in 10 seconds if possible, otherwise it's already enabled or a timer is already running
	if(backup_power_lost_until == -1 && !wires.is_cut(WIRE_BACKUP_POWER1))
		backup_power_lost_until = world.time + 10 SECONDS
		backup_power_timer = addtimer(CALLBACK(src, PROC_REF(regainBackupPower)), 10 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
	// Disable electricity if required
	if(electrified_until && isAllPowerLoss())
		electrify(0)

/obj/machinery/door/airlock/proc/loseBackupPower()
	backup_power_lost_until = wires.is_cut(WIRE_BACKUP_POWER1) ? -1 : world.time + 60 SECONDS
	if(backup_power_lost_until > 0)
		backup_power_timer = addtimer(CALLBACK(src, PROC_REF(regainBackupPower)), 60 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)

	// Disable electricity if required
	if(electrified_until && isAllPowerLoss())
		electrify(0)

/obj/machinery/door/airlock/proc/regainMainPower()
	main_power_timer = null

	if(!wires.is_cut(WIRE_MAIN_POWER1))
		main_power_lost_until = 0
		// If backup power is currently active then disable, otherwise let it count down and disable itself later
		if(!backup_power_lost_until)
			backup_power_lost_until = -1
		update_icon()

/obj/machinery/door/airlock/proc/regainBackupPower()
	backup_power_timer = null

	if(!wires.is_cut(WIRE_BACKUP_POWER1))
		// Restore backup power only if main power is offline, otherwise permanently disable
		backup_power_lost_until = main_power_lost_until == 0 ? -1 : 0
		update_icon()

/obj/machinery/door/airlock/proc/electrify(duration, mob/user = usr, feedback = FALSE)
	if(electrified_timer)
		deltimer(electrified_timer)
		electrified_timer = null

	var/message = ""
	if(wires.is_cut(WIRE_ELECTRIFY) && arePowerSystemsOn())
		message = "The electrification wire is cut - Door permanently electrified."
		electrified_until = -1
	else if(duration && !arePowerSystemsOn())
		message = "The door is unpowered - Cannot electrify the door."
		electrified_until = 0
	else if(!duration && electrified_until != 0)
		message = "The door is now un-electrified."
		add_attack_logs(user, src, "Un-electrified [ADMIN_COORDJMP(src)]", ATKLOG_ALL)
		electrified_until = 0
	else if(duration)	//electrify door for the given duration seconds
		if(user)
			shockedby += "\[[all_timestamps()]\] - [user](ckey:[user.ckey])"
			add_attack_logs(user, src, "Electrified [ADMIN_COORDJMP(src)]", ATKLOG_ALL)
		else
			shockedby += "\[[all_timestamps()]\] - EMP)"
		message = "The door is now electrified [duration == -1 ? "permanently" : "for [duration] second\s"]."
		electrified_until = duration == -1 ? -1 : world.time + duration SECONDS
		if(duration != -1)
			electrified_timer = addtimer(CALLBACK(src, PROC_REF(electrify), 0), duration SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
	if(feedback && message)
		to_chat(user, message)
	diag_hud_set_electrified()

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/shock(mob/living/user, prb)
	if(!istype(user) || !arePowerSystemsOn())
		return FALSE
	if(shockCooldown > world.time)
		return FALSE	//Already shocked someone recently?
	if(..())
		shockCooldown = world.time + 1 SECONDS //Time must be lowered from 2 seconds due to bump, bump was only 1 second.
		return TRUE
	else
		return FALSE

//Checks if the user can get shocked and shocks him if it can. Returns TRUE if it happened
/obj/machinery/door/airlock/proc/shock_user(mob/user, prob)
	var/output = !issilicon(user) && isElectrified() && shock(user, prob)
	if(output)
		return TRUE //We got shocked, end of story
	if(issilicon(user))
		return FALSE //Borgs don't get door shocked
	if(ishuman(user) && isElectrified()) //We don't want people without insulated gloves able to open doors.
		var/mob/living/carbon/human/H = user
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.siemens_coefficient == 0)
				return FALSE

	else if(isElectrified())
		return TRUE
	return FALSE

/obj/machinery/door/airlock/toggle_polarization()
	polarized_on = !polarized_on

	if(operating || !density)
		return // It's toggled, but don't try to animate the effect.

	var/animate_color
	var/image/polarized_image = get_airlock_overlay("[airlock_material]_closed", overlays_file)

	polarized_image.dir = dir

	if(!polarized_on)
		polarized_image.color = "#222222"
		animate_color = "#FFFFFF"
		set_opacity(FALSE)
	else
		polarized_image.color = "#FFFFFF"
		animate_color = "#222222"
		set_opacity(TRUE)

	overlays -= polarized_image

	// Animate() does not work on overlays, so a temporary effect is used
	new /obj/effect/temp_visual/polarized_airlock(get_turf(src), polarized_image, animate_color)

	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), 0, 0), 0.5 SECONDS)

//
// Polarization toggling effect
//

/obj/effect/temp_visual/polarized_airlock
	layer = OPEN_DOOR_LAYER
	duration = 0.5 SECONDS
	randomdir = FALSE

/obj/effect/temp_visual/polarized_airlock/Initialize(mapload, image/airlock_overlay, animate_color)
	. = ..()
	icon = airlock_overlay.icon
	icon_state = airlock_overlay.icon_state
	color = airlock_overlay.color
	dir = airlock_overlay.dir
	animate(src, color = animate_color, time = 0.5 SECONDS)

//
// Icon handling
//

/obj/machinery/door/airlock/update_icon(state=0, override=0)
	if(operating && !override)
		return

	icon_state = density ? "closed" : "open"
	switch(state)
		if(0)
			if(density)
				state = AIRLOCK_CLOSED
			else
				state = AIRLOCK_OPEN
		if(AIRLOCK_DENY, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_EMAG)
			icon_state = "nonexistenticonstate" //MADNESS

	. = ..(UPDATE_ICON_STATE) // Sent after the icon_state is changed

	set_airlock_overlays(state)

/obj/machinery/door/airlock/update_icon_state()
	return

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
	var/mutable_appearance/buttons_underlay
	var/mutable_appearance/lights_underlay
	var/mutable_appearance/damag_underlay
	var/mutable_appearance/sparks_underlay
	switch(state)
		if(AIRLOCK_CLOSED)
			frame_overlay = get_airlock_overlay("closed", icon)
			buttons_underlay = get_airlock_emissive_underlay("closed_lightmask", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				buttons_underlay = null
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
				damag_underlay = get_airlock_emissive_underlay( "sparks_broken_lightmask", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
				damag_underlay = get_airlock_emissive_underlay("sparks_damaged_lightmask", overlays_file)
			if(lights && arePowerSystemsOn())
				if(locked)
					lights_overlay = get_airlock_overlay("lights_bolts", overlays_file)
					lights_underlay = get_airlock_emissive_underlay("lights_bolts_lightmask", overlays_file)
				else if(emergency)
					lights_overlay = get_airlock_overlay("lights_emergency", overlays_file)
					lights_underlay = get_airlock_emissive_underlay("lights_emergency_lightmask", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)
				note_overlay.layer = layer + 0.1

		if(AIRLOCK_DENY)
			if(!arePowerSystemsOn())
				return
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				buttons_underlay = null
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
				damag_underlay = get_airlock_emissive_underlay( "sparks_broken_lightmask", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
				damag_underlay = get_airlock_emissive_underlay("sparks_damaged_lightmask", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			lights_overlay = get_airlock_overlay("lights_denied", overlays_file)
			lights_underlay = get_airlock_emissive_underlay("lights_denied_lightmask", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_EMAG)
			frame_overlay = get_airlock_overlay("closed", icon)
			buttons_underlay = get_airlock_emissive_underlay("closed_lightmask", overlays_file)
			sparks_overlay = get_airlock_overlay("sparks", overlays_file)
			sparks_underlay = get_airlock_emissive_underlay("sparks_lightmask", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				buttons_underlay = null
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
				damag_underlay = get_airlock_emissive_underlay( "sparks_broken_lightmask", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
				damag_underlay = get_airlock_emissive_underlay("sparks_damaged_lightmask", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_CLOSING)
			frame_overlay = get_airlock_overlay("closing", icon)
			buttons_underlay = get_airlock_emissive_underlay("closing_lightmask", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closing", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closing", icon)
			if(lights && arePowerSystemsOn())
				lights_overlay = get_airlock_overlay("lights_closing", overlays_file)
				lights_underlay = get_airlock_emissive_underlay("lights_closing_lightmask", overlays_file)
			if(panel_open)
				buttons_underlay = null
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
				damag_underlay = get_airlock_emissive_underlay("sparks_open_lightmask", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_open", note_overlay_file)

		if(AIRLOCK_OPENING)
			frame_overlay = get_airlock_overlay("opening", icon)
			buttons_underlay = get_airlock_emissive_underlay("opening_lightmask", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_opening", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_opening", icon)
			if(lights && arePowerSystemsOn())
				lights_overlay = get_airlock_overlay("lights_opening", overlays_file)
				lights_underlay = get_airlock_emissive_underlay("lights_opening_lightmask", overlays_file)
			if(panel_open)
				buttons_underlay = null
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_opening_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_opening", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_opening", note_overlay_file)

	if(polarized_on)
		filling_overlay.color = "#222222"
	else
		filling_overlay.color = "#FFFFFF"

	cut_overlays()

	overlays += frame_overlay
	overlays += filling_overlay
	overlays += lights_overlay
	overlays += panel_overlay
	overlays += weld_overlay
	overlays += sparks_overlay
	overlays += damag_overlay
	overlays += note_overlay

	overlays += check_unres()

	//EMISSIVE ICONS
	if(buttons_underlay != old_buttons_underlay)
		underlays -= old_buttons_underlay
		underlays += buttons_underlay
		old_buttons_underlay = buttons_underlay
	if(lights_underlay != old_lights_underlay)
		underlays -= old_lights_underlay
		underlays += lights_underlay
		old_lights_underlay = lights_underlay
	if(damag_underlay != old_damag_underlay)
		underlays -= old_damag_underlay
		underlays += damag_underlay
		old_damag_underlay = damag_underlay
	if(sparks_underlay != old_sparks_underlay)
		underlays -= old_sparks_underlay
		underlays += sparks_underlay
		old_sparks_underlay = sparks_underlay

/proc/get_airlock_overlay(icon_state, icon_file)
	var/iconkey = "[icon_state][icon_file]"
	if(GLOB.airlock_overlays[iconkey])
		return GLOB.airlock_overlays[iconkey]
	GLOB.airlock_overlays[iconkey] = image(icon_file, icon_state)
	return GLOB.airlock_overlays[iconkey]

/proc/get_airlock_emissive_underlay(icon_state, icon_file)
	var/iconkey = "[icon_state][icon_file]"
	if(GLOB.airlock_emissive_underlays[iconkey])
		return GLOB.airlock_emissive_underlays[iconkey]
	GLOB.airlock_emissive_underlays[iconkey] = emissive_appearance(icon_file, icon_state)
	return GLOB.airlock_emissive_underlays[iconkey]

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
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		. += "<span class='warning'>The access panel is coated in yellow ooze...</span>"
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
				if(get_dist(user, src) <= 1)
					wires.Interact(user)
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

/obj/machinery/door/airlock/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AiAirlock", name, 600, 400, master_ui, state)
		ui.open()


/obj/machinery/door/airlock/ui_data(mob/user)
	var/list/data = list()

	var/list/power = list()
	power["main"] = main_power_lost_until ? UI_RED : UI_GREEN
	power["main_timeleft"] = max(main_power_lost_until - world.time, 0) / 10
	power["backup"] = backup_power_lost_until ? UI_RED : UI_GREEN
	power["backup_timeleft"] = max(backup_power_lost_until - world.time, 0) / 10
	data["power"] = power
	if(electrified_until == -1)
		data["shock"] = UI_RED
	else if(electrified_until > 0)
		data["shock"] = UI_ORANGE
	else
		data["shock"] = UI_GREEN

	data["shock_timeleft"] = max(electrified_until - world.time, 0) / 10
	data["id_scanner"] = !aiDisabledIdScanner
	data["emergency"] = emergency // access
	data["locked"] = locked // bolted
	data["lights"] = lights // bolt lights
	data["safe"] = safe // safeties
	data["speed"] = normalspeed // safe speed
	data["welded"] = welded // welded
	data["opened"] = !density // opened

	var/list/wire = list()
	wire["main_power"] = !wires.is_cut(WIRE_MAIN_POWER1)
	wire["backup_power"] = !wires.is_cut(WIRE_BACKUP_POWER1)
	wire["shock"] = !wires.is_cut(WIRE_ELECTRIFY)
	wire["id_scanner"] = !wires.is_cut(WIRE_IDSCAN)
	wire["bolts"] = !wires.is_cut(WIRE_DOOR_BOLTS)
	wire["lights"] = !wires.is_cut(WIRE_BOLT_LIGHT)
	wire["safe"] = !wires.is_cut(WIRE_SAFETY)
	wire["timing"] = !wires.is_cut(WIRE_SPEED)

	data["wires"] = wire
	return data


/obj/machinery/door/airlock/proc/hack(mob/user)
	set waitfor = 0
	if(!aiHacking)
		aiHacking = TRUE
		to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
		sleep(3 SECONDS)
		if(canAIControl())
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!canAIHack(user))
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Fault confirmed: airlock control wire disabled or cut.")
		sleep(2 SECONDS)
		to_chat(user, "Attempting to hack into airlock. This may take some time.")
		sleep(15 SECONDS)
		if(canAIControl())
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!canAIHack(user))
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
		sleep(5 SECONDS)
		if(canAIControl())
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!canAIHack(user))
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Transfer complete. Forcing airlock to execute program.")
		sleep(5 SECONDS)
		//disable blocked control
		aiControlDisabled = AICONTROLDISABLED_BYPASS
		to_chat(user, "Receiving control information from airlock.")
		sleep(1 SECONDS)
		//bring up airlock dialog
		aiHacking = FALSE
		if(user)
			attack_ai(user)

/obj/machinery/door/airlock/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && !locked)
		if(mover.checkpass(PASSDOOR))
			return TRUE
		var/mob/living/living_mover = mover
		if((istype(living_mover) && HAS_TRAIT(living_mover, TRAIT_CONTORTED_BODY) && IS_HORIZONTAL(living_mover))) // We really dont want people to get shocked on a door they're passing through
			if(density && !do_mob(living_mover, living_mover, 2 SECONDS, requires_upright = FALSE))
				return FALSE
			living_mover.forceMove(get_turf(src))
			return TRUE
	if(isElectrified() && density && isitem(mover) && !on_spark_cooldown)
		var/obj/item/I = mover
		if(I.flags & CONDUCT)
			on_spark_cooldown = TRUE
			do_sparks(5, 1, src)
			addtimer(VARSET_CALLBACK(src, on_spark_cooldown, FALSE), 1 SECONDS)
	return ..()

/obj/machinery/door/airlock/attack_animal(mob/user)
	. = ..()
	if(isElectrified())
		shock(user, 100)

/obj/machinery/door/airlock/attack_hand(mob/user)
	if(shock_user(user, 100))
		return
	if(headbutt_airlock(user))
		return // Smack that head against that airlock
	if(remove_airlock_note(user, FALSE))
		return
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
				H.Weaken(10 SECONDS)
				if(istype(affecting) && affecting.receive_damage(10, 0))
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

/obj/machinery/door/airlock/proc/ai_control_check(mob/user)
	if(!issilicon(user))
		return TRUE
	if(ispulsedemon(user))
		return TRUE
	if(emagged || HAS_TRAIT(src, TRAIT_CMAGGED))
		to_chat(user, "<span class='warning'>Unable to interface: Internal error.</span>")
		return FALSE
	if(!canAIControl())
		if(canAIHack(user))
			hack(user)
		else
			if(isAllPowerLoss())
				to_chat(user, "<span class='warning'>Unable to interface: Connection timed out.</span>")
			else
				to_chat(user, "<span class='warning'>Unable to interface: Connection refused.</span>")
		return FALSE
	return TRUE

/obj/machinery/door/airlock/ui_act(action, params)
	if(..())
		return
	if(!issilicon(usr) && !usr.can_admin_interact() && !usr.has_unlimited_silicon_privilege)
		to_chat(usr, "<span class='warning'>Access denied. Only silicons may use this interface.</span>")
		return
	if(!ai_control_check(usr))
		return
	. = TRUE
	switch(action)
		if("disrupt-main")
			if(!main_power_lost_until)
				loseMainPower()
				update_icon()
			else
				to_chat(usr, "<span class='warning'>Main power is already offline.</span>")
				. = FALSE
		if("disrupt-backup")
			if(!backup_power_lost_until)
				loseBackupPower()
				update_icon()
			else
				to_chat(usr, "<span class='warning'>Backup power is already offline.</span>")
		if("shock-restore")
			electrify(0, usr, TRUE)
		if("shock-temp")
			if(wires.is_cut(WIRE_ELECTRIFY))
				to_chat(usr, "<span class='warning'>The electrification wire is cut - Door permanently electrified.</span>")
				. = FALSE
			else
				//electrify door for 30 seconds
				electrify(30, usr, TRUE)
		if("shock-perm")
			if(wires.is_cut(WIRE_ELECTRIFY))
				to_chat(usr, "<span class='warning'>The electrification wire is cut - Cannot electrify the door.</span>")
				. = FALSE
			else
				electrify(-1, usr, TRUE)
		if("idscan-toggle")
			if(wires.is_cut(WIRE_IDSCAN))
				to_chat(usr, "<span class='warning'>The IdScan wire has been cut - IdScan feature permanently disabled.</span>")
				. = FALSE
			else if(aiDisabledIdScanner)
				aiDisabledIdScanner = FALSE
				to_chat(usr, "<span class='notice'>IdScan feature has been enabled.</span>")
			else
				aiDisabledIdScanner = TRUE
				to_chat(usr, "<span class='notice'>IdScan feature has been disabled.</span>")
		if("emergency-toggle")
			toggle_emergency_status(usr)
		if("bolt-toggle")
			toggle_bolt(usr)
		if("light-toggle")
			toggle_light(usr)
		if("safe-toggle")
			if(wires.is_cut(WIRE_SAFETY))
				to_chat(usr, "<span class='warning'>The safety wire is cut - Cannot secure the door.</span>")
			else if(safe)
				safe = 0
				to_chat(usr, "<span class='notice'>The door safeties have been disabled.</span>")
			else
				safe = 1
				to_chat(usr, "<span class='notice'>The door safeties have been enabled.</span>")
		if("speed-toggle")
			toggle_speed(usr)
		if("open-close")
			open_close(usr)
		else
			. = FALSE

/obj/machinery/door/airlock/proc/open_close(mob/user)
	if(welded)
		to_chat(user, "<span class='warning'>The airlock has been welded shut!</span>")
		return FALSE
	else if(locked)
		to_chat(user, "<span class='warning'>The door bolts are down!</span>")
		return FALSE
	else if(density)
		return open()
	else
		return close()

/obj/machinery/door/airlock/proc/toggle_light(mob/user)
	if(wires.is_cut(WIRE_BOLT_LIGHT))
		to_chat(user, "<span class='warning'>The bolt lights wire has been cut - The door bolt lights are permanently disabled.</span>")
	else if(lights)
		lights = FALSE
		to_chat(user, "<span class='notice'>The door bolt lights have been disabled.</span>")
	else if(!lights)
		lights = TRUE
		to_chat(user, "<span class='notice'>The door bolt lights have been enabled.</span>")
	update_icon()

/obj/machinery/door/airlock/proc/toggle_bolt(mob/user)
	if(wires.is_cut(WIRE_DOOR_BOLTS))
		to_chat(user, "<span class='warning'>The door bolt control wire has been cut - Door bolts permanently dropped.</span>")
		return

	if(unlock()) // Trying to unbolt
		to_chat(user, "<span class='notice'>The door bolts have been raised.</span>")
		return

	if(lock()) // Trying to bolt
		to_chat(user, "<span class='notice'>The door bolts have been dropped.</span>")
		user.create_log(MISC_LOG, "Bolted", src)
		add_hiddenprint(user)

/obj/machinery/door/airlock/proc/toggle_emergency_status(mob/user)
	emergency = !emergency
	if(emergency)
		to_chat(user, "<span class='notice'>Emergency access has been enabled.</span>")
	else
		to_chat(user, "<span class='notice'>Emergency access has been disabled.</span>")
	update_icon()

/obj/machinery/door/airlock/proc/toggle_speed(mob/user)
	if(wires.is_cut(WIRE_SPEED))
		to_chat(user, "<span class='warning'>The timing wire has been cut - Cannot alter timing.</span>")
		return
	normalspeed = !normalspeed

	if(normalspeed)
		to_chat(user, "<span class='notice'>The door is now in <b>normal</b> mode.</span>")
	else
		to_chat(user, "<span class='notice'>The door is now in <b>fast</b> mode.</span>")

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

	if(istype(C, /obj/item/assembly/signaler))
		return interact_with_panel(user)
	else if(istype(C, /obj/item/pai_cable))	// -- TLE
		var/obj/item/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/paper) || istype(C, /obj/item/photo))
		if(note)
			to_chat(user, "<span class='warning'>There's already something pinned to this airlock! Use wirecutters or your hands to remove it.</span>")
			return
		if(!user.unEquip(C))
			to_chat(user, "<span class='warning'>For some reason, you can't attach [C]!</span>")
			return
		C.add_fingerprint(user)
		user.create_log(MISC_LOG, "put [C] on", src)
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
			user.visible_message("<span class='notice'>[user] removes \the [src]'s shielding.</span>",
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
			user.visible_message("<span class='notice'>[user] removes \the [src]'s shielding.</span>",
								"<span class='notice'>You remove \the [src]'s shielding.</span>")
			security_level = AIRLOCK_SECURITY_PLASTEEL_I
			spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
	else
		try_to_crowbar(user, I)

/obj/machinery/door/airlock/wirecutter_act(mob/user, obj/item/I)
	if(!headbutt_shock_check(user))
		return

	if(!panel_open)
		if(note)
			return remove_airlock_note(user, TRUE)
		// Can't do much else with the panel closed.
		return FALSE

	. = TRUE
	if(!I.tool_start_check(src, user, 0))
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
	interact_with_panel(user)

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
	if(panel_open) // panel should be open before we try to slice out any shielding.
		switch(security_level)
			if(AIRLOCK_SECURITY_METAL)
				to_chat(user, "<span class='notice'>You begin cutting the panel's shielding...</span>")
				if(!I.use_tool(src, user, 40, volume = I.tool_volume))
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
				visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
					"<span class='notice'>You cut through \the [src]'s shielding.</span>",
					"<span class='italics'>You hear welding.</span>")
				security_level = AIRLOCK_SECURITY_PLASTEEL_O_S
			if(AIRLOCK_SECURITY_PLASTEEL_I)
				to_chat(user, "<span class='notice'>You begin cutting the inner layer of shielding...</span>")
				if(!I.use_tool(src, user, 40, volume = I.tool_volume))
					return
				user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
					"<span class='notice'>You cut through \the [src]'s shielding.</span>",
					"<span class='italics'>You hear welding.</span>")
				security_level = AIRLOCK_SECURITY_PLASTEEL_I_S
	else
		if(user.a_intent != INTENT_HELP)
			user.visible_message("<span class='notice'>[user] is [welded ? "unwelding":"welding"] the airlock.</span>", \
				"<span class='notice'>You begin [welded ? "unwelding":"welding"] the airlock...</span>", \
				"<span class='italics'>You hear welding.</span>")

			if(I.use_tool(src, user, 40, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(weld_checks), I, user)))
				if(!density && !welded)
					return
				welded = !welded
				user.visible_message("<span class='notice'>[user.name] has [welded? "welded shut":"unwelded"] [src].</span>", \
					"<span class='notice'>You [welded ? "weld the airlock shut":"unweld the airlock"].</span>")
				update_icon()
		else if(obj_integrity < max_integrity)
			// Only attempt repairs if the door is solid (albeit closed)
			if(!density)
				to_chat(user, "<span class='warning'>The airlock must be closed for repairs.</span>")
				return
			user.visible_message("<span class='notice'>[user] is welding the airlock.</span>", \
				"<span class='notice'>You begin repairing the airlock...</span>", \
				"<span class='italics'>You hear welding.</span>")
			if(I.use_tool(src, user, 40, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(weld_checks), I, user)))
				obj_integrity = max_integrity
				stat &= ~BROKEN
				user.visible_message("<span class='notice'>[user.name] has repaired [src].</span>", \
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

/obj/machinery/door/airlock/try_to_crowbar(mob/living/user, obj/item/I)
	if(operating)
		return
	if(HAS_TRAIT(I, TRAIT_FORCES_OPEN_DOORS_ITEM))
		force_open_with_item(user, I)
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

/obj/machinery/door/airlock/proc/force_open_with_item(mob/living/user, obj/item/I)
	/// Time it takes to open an airlock with an item with the TRAIT_FORCES_OPEN_DOORS_ITEM trait, 5 seconds for wielded items, 10 seconds for nonwielded items
	var/time_to_open_airlock = 10 SECONDS
	/// Can we open the airlock while unpowered? Wielded item's can't, but unwielded items can
	var/can_force_open_while_unpowered = TRUE
	if(I.GetComponent(/datum/component/two_handed))
		can_force_open_while_unpowered = FALSE
		time_to_open_airlock = 5 SECONDS
		if(!HAS_TRAIT(I, TRAIT_WIELDED))
			to_chat(user, "<span class='warning'>You need to be wielding [I] to do that!</span>")
			return
	if(!density || prying_so_hard)
		return
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, 1) //is it aliens or just the CE being a dick?
	if(!arePowerSystemsOn() && can_force_open_while_unpowered)
		open(TRUE)
		return
	prying_so_hard = TRUE //so you dont pry the door when you are already trying to pry it
	var/result = do_after(user, time_to_open_airlock, target = src)
	prying_so_hard = FALSE
	if(result)
		open(TRUE)
		if(density && !open(TRUE))
			to_chat(user, "<span class='warning'>Despite your attempts, [src] refuses to open.</span>")

/obj/machinery/door/airlock/open(forced=0)
	if(operating || welded || locked || emagged)
		return 0
	if(!forced)
		if(!arePowerSystemsOn() || wires.is_cut(WIRE_OPEN_DOOR))
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
	SEND_SIGNAL(src, COMSIG_AIRLOCK_OPEN)
	operating = DOOR_OPENING
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
	operating = NONE
	return TRUE

/obj/machinery/door/airlock/close(forced=0, override = 0)
	if((operating & !override) || welded || locked || emagged)
		return
	if(density)
		return TRUE
	if(!forced)
		//despite the name, this wire is for general door control.
		//Bolts are already covered by the check for locked, above
		if(!arePowerSystemsOn() || wires.is_cut(WIRE_OPEN_DOOR))
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

	SEND_SIGNAL(src, COMSIG_AIRLOCK_CLOSE)
	operating = DOOR_CLOSING
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
	if((visible && !glass) || polarized_on)
		set_opacity(1)
	update_freelook_sight()
	sleep(1)
	update_icon(AIRLOCK_CLOSED, 1)
	operating = NONE
	if(safe)
		CheckForMobs()
	return TRUE

/obj/machinery/door/airlock/lock(forced=0)
	if(locked)
		return 0

	if(operating && !forced)
		return 0

	locked = TRUE
	playsound(src, boltDown, 30, 0, 3)
	update_icon()
	return 1

/obj/machinery/door/airlock/unlock(forced=0)
	if(!locked)
		return

	if(!forced)
		if(operating || !arePowerSystemsOn() || wires.is_cut(WIRE_DOOR_BOLTS))
			return

	locked = FALSE
	playsound(src,boltUp, 30, 0, 3)
	update_icon()
	return 1

/obj/machinery/door/airlock/CanPathfindPass(obj/item/card/id/ID, to_dir, atom/movable/caller, no_id = FALSE)
//Airlock is passable if it is open (!density), bot has access, and is not bolted or welded shut)
	return !density || (check_access(ID) && !locked && !welded && arePowerSystemsOn() && !no_id)

/obj/machinery/door/airlock/emag_act(mob/user)
	if(!operating && density && arePowerSystemsOn() && !emagged)
		operating = DOOR_MALF
		update_icon(AIRLOCK_EMAG, 1)
		sleep(6)
		if(QDELETED(src))
			return
		electronics = new /obj/item/airlock_electronics/destroyed()
		operating = NONE
		if(!open())
			update_icon(AIRLOCK_CLOSED, 1)
		emagged = TRUE
		return 1

/obj/machinery/door/airlock/cmag_act(mob/user)
	if(operating || HAS_TRAIT(src, TRAIT_CMAGGED) || !density || !arePowerSystemsOn())
		return
	operating = DOOR_MALF
	update_icon(AIRLOCK_EMAG, 1)
	sleep(6)
	if(QDELETED(src))
		return
	operating = NONE
	update_icon(AIRLOCK_CLOSED, 1)
	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
	return TRUE

/obj/machinery/door/airlock/emp_act(severity)
	. = ..()
	if(prob(20 / severity))
		open()
	if(prob(40 / severity))
		var/duration = world.time + (30 / severity) SECONDS
		if(duration > electrified_until)
			electrify(duration)

/obj/machinery/door/airlock/ex_act(severity)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	switch(severity)
		if(EXPLODE_DEVASTATE) //Destroy the airlock completely.
			qdel(src)
		if(EXPLODE_HEAVY) //Deconstruct the airlock, leaving damaged airlock frame and parts behind
			deconstruct(FALSE, null)
		if(EXPLODE_LIGHT) //Deals 150 damage to the airlock, half a standard airlock's integrity
			take_damage(150)

/obj/machinery/door/airlock/attack_alien(mob/living/carbon/alien/humanoid/user)
	add_fingerprint(user)
	if(isElectrified())
		shock(user, 100) //Mmm, fried xeno!
		return
	if(!density) //Already open
		if(!arePowerSystemsOn())
			close(TRUE)
			return
		if(HAS_TRAIT_FROM(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
			close(TRUE)
			return
		return
	if(locked || welded) //Extremely generic, as aliens only understand the basics of how airlocks work.
		to_chat(user, "<span class='warning'>[src] refuses to budge!</span>")
		return
	if(prying_so_hard)
		return
	prying_so_hard = TRUE
	var/time_to_open = 0
	if(arePowerSystemsOn())
		if(HAS_TRAIT_FROM(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
			open(TRUE)
			visible_message("<span class='danger'>[user] forces the door!</span>")
			playsound(loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			prying_so_hard = FALSE
			return
		user.visible_message("<span class='warning'>[user] begins prying open [src].</span>",\
							"<span class='noticealien'>You begin digging your claws into [src] with all your might!</span>",\
							"<span class='warning'>You hear groaning metal...</span>")
		time_to_open = 50 //Powered airlocks take longer to open, and are loud.
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
	else
		visible_message("<span class='danger'>[user] forces the door!</span>")
		playsound(loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	if(do_after(user, time_to_open, TRUE, src))
		if(density && !open(2)) //The airlock is still closed, but something prevented it opening. (Another player noticed and bolted/welded the airlock in time!)
			to_chat(user, "<span class='warning'>Despite your efforts, [src] managed to resist your attempts to open it!</span>")
	prying_so_hard = FALSE

/obj/machinery/door/airlock/power_change() //putting this is obj/machinery/door itself makes non-airlock doors turn invisible for some reason
	if(!..())
		return
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
			shockedby += "\[[all_timestamps()]\][origin](ckey:[origin.ckey])"

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
		wires.cut_all()
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
		DA.reinforced_glass = src.reinforced_glass //tracks whether there's rglass in
		DA.anchored = TRUE
		DA.glass = src.glass
		DA.polarized_glass = polarized_glass
		DA.state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
		DA.created_name = name
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
				ae.selected_accesses = req_access
			else if(req_one_access.len)
				ae.selected_accesses = req_one_access
				ae.one_access = 1
			ae.unres_access_from = unres_sides
		else
			ae = electronics
			electronics = null
			ae.forceMove(loc)
	qdel(src)

/obj/machinery/door/airlock/proc/note_type() //Returns a string representing the type of note pinned to this airlock
	if(!note)
		return
	if(istype(note, /obj/item/paper))
		var/obj/item/paper/pinned_paper = note
		if(pinned_paper.info)
			return "note_words"
		else
			return "note"
	if(istype(note, /obj/item/photo))
		return "photo"

//Removes the current note on the door if any. Returns if a note is removed
/obj/machinery/door/airlock/proc/remove_airlock_note(mob/user, wirecutters_used = TRUE)
	if(!note)
		return FALSE

	if(!wirecutters_used)
		if(ishuman(user) && (user.a_intent == INTENT_GRAB)) //grab that note
			user.visible_message("<span class='notice'>[user] removes [note] from [src].</span>", "<span class='notice'>You remove [note] from [src].</span>")
			playsound(src, 'sound/items/poster_ripped.ogg', 50, 1)
		else
			return FALSE
	else
		user.visible_message("<span class='notice'>[user] cuts down [note] from [src].</span>", "<span class='notice'>You remove [note] from [src].</span>")
		playsound(src, 'sound/items/wirecutter.ogg', 50, 1)
	note.add_fingerprint(user)
	user.create_log(MISC_LOG, "removed [note] from", src)
	user.put_in_hands(note)
	note = null
	update_icon()
	return TRUE

/obj/machinery/door/airlock/narsie_act(weak = FALSE)
	var/turf/T = get_turf(src)
	var/runed = prob(20)
	var/obj/machinery/door/airlock/cult/A
	if(weak)
		A = new/obj/machinery/door/airlock/cult/weak(T)
	else
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
	A.stealth_icon = icon
	A.stealth_overlays = overlays_file
	A.stealth_opacity = opacity
	A.stealth_glass = glass
	A.stealth_airlock_material = airlock_material
	qdel(src)

/obj/machinery/door/airlock/proc/ai_control_callback()
	if(aiControlDisabled == AICONTROLDISABLED_ON)
		aiControlDisabled = AICONTROLDISABLED_OFF
	else if(aiControlDisabled == AICONTROLDISABLED_BYPASS)
		aiControlDisabled = AICONTROLDISABLED_PERMA

/obj/machinery/door/airlock/proc/airlock_cycle_callback(cmd)
	cur_command = cmd
	INVOKE_ASYNC(src, PROC_REF(execute_current_command))

/obj/machinery/door/airlock/proc/execute_current_command()
	if(operating || emagged)
		return //emagged or busy doing something else

	if(!cur_command)
		return

	do_command(cur_command)
	if(command_completed(cur_command))
		cur_command = null
	else
		START_PROCESSING(SSmachines, src)

/obj/machinery/door/airlock/proc/do_command(command)
	if(command_running)
		return

	command_running = TRUE
	switch(command)
		if("open")
			open()

		if("close")
			close()

		if("unlock")
			unlock()

		if("lock")
			lock()

		if("secure_open")
			unlock()

			sleep(2)
			open()

			lock()

		if("secure_close")
			unlock()
			close()

			lock()
			sleep(2)
	command_running = FALSE

/obj/machinery/door/airlock/proc/command_completed(command)
	switch(command)
		if("open")
			return (!density)

		if("close")
			return density

		if("unlock")
			return !locked

		if("lock")
			return locked

		if("secure_open")
			return (locked && !density)

		if("secure_close")
			return (locked && density)

	return TRUE //Unknown command. Just assume it's completed.

/obj/machinery/door/airlock/process()
	if(arePowerSystemsOn() && cur_command)
		execute_current_command()
	else
		return PROCESS_KILL

/obj/machinery/door/airlock/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(heat_proof)
		return
	if(exposed_temperature > (T0C + heat_resistance))
		take_damage(round(exposed_volume / 100), BURN, 0, 0)

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

#undef UI_GREEN
#undef UI_ORANGE
#undef UI_RED
