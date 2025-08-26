#define REGIME_TELEPORT 0
#define REGIME_GATE 1
#define REGIME_GPS 2

/obj/machinery/computer/teleporter
	name = "teleporter control console"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/circuitboard/teleporter
	/// A GPS with a locked destination
	var/obj/item/gps/locked = null
	/// Switches mode between teleporter, gate and gps
	var/regime = REGIME_TELEPORT
	var/id = null
	/// The power station that's connected to the console
	var/obj/machinery/teleport/station/power_station
	/// Whether calibration is in progress or not. Calibration prevents changes.
	var/calibrating = FALSE
	/// The target turf of the teleporter
	var/atom/target

	/* 	var/area_bypass is for one-time-use teleport cards
		Setting this to TRUE will set var/obj/item/gps/locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.
	*/
	var/area_bypass = FALSE
	var/cc_beacon = FALSE

	/// When the teleporter is upgraded, it can lock onto beacons directly, rather than turfs. This is the variable for it.
	var/advanced_beacon_locking = FALSE

/obj/machinery/computer/teleporter/Initialize(mapload)
	. = ..()
	link_power_station()
	update_icon()
	id = "[rand(1000, 9999)]"

/obj/machinery/computer/teleporter/Destroy()
	if(power_station)
		power_station.teleporter_console = null
		power_station = null
	return ..()

/obj/machinery/computer/teleporter/proc/link_power_station()
	if(power_station)
		return
	power_station = locate(/obj/machinery/teleport/station, orange(1, src))
	return power_station

/obj/machinery/computer/teleporter/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/gps))
		var/obj/item/gps/L = used
		if(L.locked_location && !(stat & (NOPOWER|BROKEN)))
			if(!user.transfer_item_to(L, src))
				to_chat(user, "<span class='warning'>[used] is stuck to your hand, you cannot put it in [src]</span>")
				return ITEM_INTERACT_COMPLETE
			locked = L
			to_chat(user, "<span class='caution'>You insert the GPS device into [src]'s slot.</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/computer/teleporter/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='notice'>The teleporter can now lock on to Syndicate beacons!</span>")
		return TRUE
	else
		ui_interact(user)

/obj/machinery/computer/teleporter/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/teleporter/attack_hand(mob/user)
	ui_interact(user)


/obj/machinery/computer/teleporter/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/teleporter/ui_interact(mob/user, datum/tgui/ui = null)
	if(stat & (NOPOWER|BROKEN))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Teleporter", "Teleporter Console")
		ui.open()

/obj/machinery/computer/teleporter/ui_data(mob/user)
	var/list/data = list()
	data["powerstation"] = power_station
	if(power_station?.teleporter_hub)
		data["teleporterhub"] = power_station.teleporter_hub
		data["calibrated"] = power_station.teleporter_hub.calibrated
	else
		data["teleporterhub"] = null
		data["calibrated"] = null
	data["regime"] = regime
	var/area/target_area = get_area(target)
	data["target"] = target_area ? sanitize(target_area.name) : "None"
	data["calibrating"] = calibrating
	data["locked"] = locked ? TRUE : FALSE
	data["targetsTeleport"] = null
	if(power_station && power_station.efficiency >= 7)
		data["adv_beacon_allowed"] = 1
	data["advanced_beacon_locking"] = advanced_beacon_locking
	switch(regime)
		if(REGIME_TELEPORT)
			data["targetsTeleport"] = targets_teleport()
		if(REGIME_GATE)
			data["targetsTeleport"] = targets_gate()
		if(REGIME_GPS)
			data["targetsTeleport"] = null //clears existing entries, target is added by load action
	return data

/obj/machinery/computer/teleporter/ui_act(action, params)
	if(..())
		return

	if(!check_hub_connection())
		atom_say("Error: Unable to detect hub.")
		return
	if(calibrating)
		atom_say("Error: Calibration in progress. Stand by.")
		return

	. = TRUE

	switch(action)
		if("eject") //eject gps device
			eject()
		if("load") //load gps coordinates
			target = locate(locked.locked_location.x, locked.locked_location.y, locked.locked_location.z)
		if("setregime")
			regime = text2num(params["regime"])
			resetPowerstation()
			target = null
		if("settarget")
			resetPowerstation()
			if(!advanced_beacon_locking)
				var/turf/tmpTarget = locate(text2num(params["x"]), text2num(params["y"]), text2num(params["z"]))
				if(!isturf(tmpTarget))
					atom_say("No valid targets available.")
					return
				target = tmpTarget
			else
				target = locateUID(params["tptarget"])
			if(regime == REGIME_TELEPORT)
				teleport_helper()
			if(regime == REGIME_GATE)
				gate_helper()
		if("calibrate")
			if(!target)
				atom_say("Error: No target set to calibrate to.")
				return
			if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accurate >= 3)
				atom_say("Hub is already calibrated.")
				return

			atom_say("Processing hub calibration to target...")
			calibrating = TRUE
			addtimer(CALLBACK(src, PROC_REF(calibrateCallback)), 50 * (3 - power_station.teleporter_hub.accurate)) //Better parts mean faster calibration
		if("advanced_beacon_locking")
			advanced_beacon_locking = !advanced_beacon_locking

/**
*	Resets the connected powerstation to initial values. Helper function of ui_act
*/
/obj/machinery/computer/teleporter/proc/resetPowerstation()
	power_station.engaged = FALSE
	if(power_station.teleporter_hub.accurate < 3)
		power_station.teleporter_hub.calibrated = FALSE
	power_station.teleporter_hub.update_icon(UPDATE_ICON_STATE)

/**
*	Calibrates the hub. Helper function of ui_act
*/
/obj/machinery/computer/teleporter/proc/calibrateCallback()
	calibrating = FALSE
	if(check_hub_connection())
		power_station.teleporter_hub.calibrated = TRUE
		atom_say("Calibration complete.")
	else
		atom_say("Error: Unable to detect hub.")

/obj/machinery/computer/teleporter/proc/check_hub_connection()
	if(!power_station)
		return
	if(!power_station.teleporter_hub)
		return
	return TRUE

/**
*	Helper function of ui_act
*
*	Triggered when ejecting a gps device. Sets the gps to the ground and resets the console
*/
/obj/machinery/computer/teleporter/proc/eject()
	if(locked)
		locked.loc = loc
		locked = null
	regime = REGIME_TELEPORT

/**
*	Creates a list of viable targets for the teleport. Helper function of ui_data
*/
/obj/machinery/computer/teleporter/proc/targets_teleport()
	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/beacon/R in GLOB.beacons)
		var/turf/T = get_turf(R)
		if(!T)
			continue
		if(!is_teleport_allowed(T.z) && !R.cc_beacon)
			continue
		if(R.wormhole_weaver)
			continue
		if(R.syndicate && !emagged)
			continue
		if(!R.broadcast_to_teleport_hubs)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = list(
			"name" = tmpname,
			"x" = T.x,
			"y" = T.y,
			"z" = T.z,
			"pretarget" = R.UID())

	for(var/obj/item/bio_chip/tracking/I in GLOB.tracked_implants)
		if(!I.implanted || !ismob(I.loc))
			continue
		else
			var/mob/M = I.loc
			if(M.stat == DEAD)
				if(M.timeofdeath + 6000 < world.time)
					continue
			var/turf/T = get_turf(M)
			if(!T)	continue
			if(!is_teleport_allowed(T.z))	continue
			var/tmpname = M.real_name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = list(
				"name" = tmpname,
				"x" = T.x,
				"y" = T.y,
				"z" = T.z,
				"pretarget" = M.UID())
	return L

/**
*	Creates a list of viable targets for the gate. Helper function of ui_data
*/
/obj/machinery/computer/teleporter/proc/targets_gate(mob/users)
	var/list/L = list()
	var/list/areaindex = list()
	var/list/S = power_station.linked_stations
	if(!length(S))
		return L
	for(var/obj/machinery/teleport/station/R in S)
		var/turf/T = get_turf(R)
		if(!T || !R.teleporter_hub || !R.teleporter_console)
			continue
		if(!is_teleport_allowed(T.z))
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = list(
				"name" = tmpname,
				"x" = T.x,
				"y" = T.y,
				"z" = T.z,
				"pretarget" = R.UID())
	return L

/**
*	Helper function of ui_act.
*
*	Called after selecting a target for the gate in the UI. Sets area_bypass and cc_beacon.
*/
/obj/machinery/computer/teleporter/proc/teleport_helper()
	area_bypass = FALSE
	var/turf/T = get_turf(target)
	for(var/item in T.contents)
		if(istype(item, /obj/item/beacon))
			var/obj/item/beacon/B = item
			if(B.area_bypass)
				area_bypass = TRUE
			cc_beacon = B.cc_beacon

/**
*	Helper function of ui_act.
*
*	Called after selecting a target for the teleporter in the UI.
*/
/obj/machinery/computer/teleporter/proc/gate_helper()
	area_bypass = FALSE
	var/obj/machinery/teleport/station/trg = target
	trg.linked_stations |= power_station
	trg.stat &= ~NOPOWER
	if(trg.teleporter_hub)
		trg.teleporter_hub.stat &= ~NOPOWER
		trg.teleporter_hub.update_icon(UPDATE_ICON_STATE)
	if(trg.teleporter_console)
		trg.teleporter_console.stat &= ~NOPOWER
		trg.teleporter_console.update_icon()

/proc/find_loc(obj/R as obj)
	if(!R)	return null
	var/turf/T = R.loc
	while(!isturf(T))
		T = T.loc
		if(!T || isarea(T))	return null
	return T

/obj/machinery/teleport
	name = "teleport"
	density = TRUE
	anchored = TRUE
	///Used by the teleporter hub and permament teleporter to track how many teleports have been done this cycle.
	var/teleports_this_cycle = 0

/**
	Internal helper function

	Prevents AI from using the teleporter, prints out failure messages for clarity
*/
/obj/machinery/teleport/proc/blockAI(atom/A)
	if(is_ai(A) || istype(A, /obj/structure/ai_core))
		if(is_ai(A))
			var/mob/living/silicon/ai/T = A
			if(T.allow_teleporter)
				return FALSE
			var/list/TPError = list("<span class='warning'>Firmware instructions dictate you must remain on your assigned station!</span>",
			"<span class='warning'>You cannot interface with this technology and get rejected!</span>",
			"<span class='warning'>External firewalls prevent you from utilizing this machine!</span>",
			"<span class='warning'>Your AI core's anti-bluespace failsafes trigger and prevent teleportation!</span>")
			to_chat(T, "[pick(TPError)]")

		visible_message("<span class='warning'>The teleporter rejects the AI unit.</span>")
		return TRUE
	return FALSE

/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	density = FALSE
	layer = HOLOPAD_LAYER //Preventing mice and drones from sneaking under them.
	plane = FLOOR_PLANE
	var/accurate = 0
	idle_power_consumption = 10
	active_power_consumption = 2000
	var/obj/machinery/teleport/station/power_station
	var/calibrated //Calibration prevents mutation
	var/admin_usage = FALSE // if 1, works on CC level. If 0, doesn't. Used for admin room teleport.

/obj/machinery/teleport/hub/Initialize(mapload)
	. = ..()
	link_power_station()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/teleporter_hub(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 3)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	RefreshParts()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/machinery/teleport/hub/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/teleporter_hub(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 3)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	RefreshParts()

/obj/machinery/teleport/hub/process()
	teleports_this_cycle = 0

/obj/machinery/teleport/hub/Destroy()
	if(power_station)
		power_station.teleporter_hub = null
		power_station = null
	return ..()

/obj/machinery/teleport/hub/RefreshParts()
	var/A = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		A += M.rating
	accurate = A
	if(accurate >= 3)
		calibrated = TRUE

/obj/machinery/teleport/hub/proc/link_power_station()
	if(power_station)
		return
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		power_station = locate(/obj/machinery/teleport/station, get_step(src, dir))
		if(power_station)
			power_station.link_console_and_hub()
			break
	return power_station

/obj/machinery/teleport/hub/proc/on_atom_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	if(!is_teleport_allowed(z) && !admin_usage)
		if(ismob(entered))
			to_chat(entered, "You can't use this here.")
		return
	if(power_station && power_station.engaged && !panel_open && !blockAI(entered) && !iseffect(entered))
		if(!teleport(entered) && isliving(entered)) // the isliving(M) is needed to avoid triggering errors if a spark bumps the telehub
			visible_message("<span class='warning'>[src] emits a loud buzz, as its teleport portal flickers and fails!</span>")
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
			power_station.toggle() // turn off the portal.
		use_power(5000)
	return

/obj/machinery/teleport/hub/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/teleport/hub/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", I))
		return TRUE

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj, turf/T)
	. = TRUE
	var/obj/machinery/computer/teleporter/com = power_station.teleporter_console
	if(!com)
		return
	if(MAX_ALLOWED_TELEPORTS_PER_PROCESS <= teleports_this_cycle)
		return
	if(!com.target)
		visible_message("<span class='alert'>Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if(istype(M, /atom/movable))
		if(!calibrated && com.cc_beacon)
			visible_message("<span class='alert'>Cannot lock on target. Please calibrate the teleporter before attempting long range teleportation.</span>")
		else if(!calibrated && prob(25 - ((accurate) * 10)) && !com.cc_beacon) //oh dear a problem
			var/list/target_z = levels_by_trait(SPAWN_RUINS)
			target_z -= M.z //Where to sir? Anywhere but here.
			. = do_teleport(M, locate(rand((2*TRANSITIONEDGE), world.maxx - (2*TRANSITIONEDGE)), rand((2*TRANSITIONEDGE), world.maxy - (2*TRANSITIONEDGE)), pick(target_z)), 2, bypass_area_flag = com.area_bypass)
		else
			. = do_teleport(M, com.target, bypass_area_flag = com.area_bypass)
		if(accurate < 3)
			calibrated = FALSE
		teleports_this_cycle++

/obj/machinery/teleport/hub/update_icon_state()
	if(panel_open)
		icon_state = "tele-o"
	else if(power_station && power_station.engaged)
		icon_state = "tele1"
	else
		icon_state = "tele0"

/obj/machinery/teleport/hub/update_overlays()
	. = ..()
	underlays.Cut()

	if(power_station && power_station.engaged && !panel_open)
		underlays += emissive_appearance(icon, "tele1_lightmask")

/obj/machinery/teleport/hub/proc/update_lighting()
	if(power_station && power_station.engaged && !panel_open)
		set_light(2, 1, "#f1f1bd")
	else
		set_light(0)

/obj/machinery/teleport/perma
	name = "permanent teleporter"
	desc = "A teleporter with the target pre-set on the circuit board. The permently aligned transmitter allows it to be more power efficient than a regular teleporter station at the cost of flexibility. \
	Built-in safeties prevent it from teleporting during a recalibration, so you will never get thrown into space."
	icon_state = "tele0"
	density = FALSE
	layer = HOLOPAD_LAYER
	plane = FLOOR_PLANE
	idle_power_consumption = 50 // Both of these are half the consumption of a non-permanent tele.
	active_power_consumption = 1000

	var/recalibrating = FALSE
	var/target
	var/tele_delay = 3 SECONDS
	var/teleport_cost = 1000 // 1/5 cost of a non permanent tele.
	var/admin_usage = FALSE // If TRUE, this will work on the CC Z-level.

/obj/machinery/teleport/perma/Initialize(mapload)
	. = ..()
	initialize_parts()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	update_lighting()

/obj/machinery/teleport/perma/proc/initialize_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/teleporter_perma(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 3)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/teleport/perma/process()
	teleports_this_cycle = 0

/obj/machinery/teleport/perma/RefreshParts()
	for(var/obj/item/circuitboard/teleporter_perma/C in component_parts)
		target = C.target
	var/A = 40
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		A -= M.rating * 10
	tele_delay = max(A, 0)

/obj/machinery/teleport/perma/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(stat & (BROKEN|NOPOWER))
		return

	if(!is_teleport_allowed(z) && !admin_usage)
		if(ismob(entered))
			to_chat(entered, "You can't use this here.")
		return

	if(entered == src)
		return

	teleport(entered)

/obj/machinery/teleport/perma/proc/teleport(atom/movable/entered as mob|obj)
	if(target && !recalibrating && !panel_open && !blockAI(entered) && (teleports_this_cycle <= MAX_ALLOWED_TELEPORTS_PER_PROCESS) && !iseffect(entered))
		do_teleport(entered, target)
		use_power(teleport_cost)
		teleports_this_cycle++
		if(tele_delay)
			recalibrating = TRUE
			update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
			update_lighting()
			addtimer(CALLBACK(src, PROC_REF(CrossedCallback)), tele_delay)

/obj/machinery/teleport/perma/Destroy()
	. = ..()

/obj/machinery/teleport/perma/proc/CrossedCallback()
	recalibrating = FALSE
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	update_lighting()

/obj/machinery/teleport/perma/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	update_lighting()

/obj/machinery/teleport/perma/update_icon_state()
	if(panel_open)
		icon_state = "tele-o"
	else if(target && !recalibrating && !(stat & (BROKEN|NOPOWER)))
		icon_state = "tele1"
	else
		icon_state = "tele0"

/obj/machinery/teleport/perma/update_overlays()
	. = ..()
	underlays.Cut()

	if(target && !recalibrating && !(stat & (BROKEN|NOPOWER)) && !panel_open)
		underlays += emissive_appearance(icon, "tele1_lightmask")

/obj/machinery/teleport/perma/proc/update_lighting()
	if(target && !recalibrating && !panel_open && !(stat & (BROKEN|NOPOWER)))
		set_light(2, 1, "#f1f1bd")
	else
		set_light(0)

/obj/machinery/teleport/perma/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/teleport/perma/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", I))
		return TRUE

/obj/machinery/teleport/perma/preset
	var/target_beacon_type

/obj/machinery/teleport/perma/preset/Initialize(mapload)
	. = ..()
	if(target_beacon_type)
		target = locate(target_beacon_type)
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	update_lighting()

/obj/machinery/teleport/perma/preset/initialize_parts()
	. = ..()
	tele_delay = 0 // Act like a fully upgraded tele, no T4 stock parts to plunder.

/obj/machinery/teleport/perma/preset/cerestation

/obj/machinery/teleport/perma/preset/cerestation/medbay
	target_beacon_type = /obj/machinery/bluespace_beacon/cerestation/medbay

/obj/machinery/teleport/perma/preset/cerestation/service
	target_beacon_type = /obj/machinery/bluespace_beacon/cerestation/service

/obj/machinery/teleport/perma/preset/cerestation/cargo
	target_beacon_type = /obj/machinery/bluespace_beacon/cerestation/cargo

/obj/machinery/teleport/perma/preset/cerestation/brig
	target_beacon_type = /obj/machinery/bluespace_beacon/cerestation/brig

/obj/machinery/teleport/perma/preset/cerestation/science
	target_beacon_type = /obj/machinery/bluespace_beacon/cerestation/science

/obj/machinery/teleport/perma/preset/cerestation/departures
	target_beacon_type = /obj/machinery/bluespace_beacon/cerestation/departures

/obj/machinery/teleport/perma/preset/cerestation/engineering
	target_beacon_type = /obj/machinery/bluespace_beacon/cerestation/engineering

/obj/machinery/bluespace_beacon/cerestation
	broadcast_to_teleport_hubs = FALSE

/obj/machinery/bluespace_beacon/cerestation/medbay

/obj/machinery/bluespace_beacon/cerestation/cargo

/obj/machinery/bluespace_beacon/cerestation/brig

/obj/machinery/bluespace_beacon/cerestation/science

/obj/machinery/bluespace_beacon/cerestation/departures

/obj/machinery/bluespace_beacon/cerestation/engineering

/obj/machinery/bluespace_beacon/cerestation/service

/obj/machinery/teleport/station
	name = "station"
	desc = "The power control station for a bluespace teleporter."
	icon_state = "controller"
	idle_power_consumption = 10
	active_power_consumption = 2000

	var/obj/machinery/computer/teleporter/teleporter_console
	var/obj/machinery/teleport/hub/teleporter_hub
	var/list/linked_stations = list()
	var/efficiency = 0
	var/engaged = FALSE

/obj/machinery/teleport/station/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/teleporter_station(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 2)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	link_console_and_hub()

/obj/machinery/teleport/station/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/teleporter_station(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 2)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	link_console_and_hub()

/obj/machinery/teleport/station/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E - 1

/obj/machinery/teleport/station/proc/link_console_and_hub()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		teleporter_hub = locate(/obj/machinery/teleport/hub, get_step(src, dir))
		if(teleporter_hub)
			teleporter_hub.link_power_station()
			break
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		teleporter_console = locate(/obj/machinery/computer/teleporter, get_step(src, dir))
		if(teleporter_console)
			teleporter_console.link_power_station()
			break
	return teleporter_hub && teleporter_console


/obj/machinery/teleport/station/Destroy()
	if(teleporter_hub)
		teleporter_hub.power_station = null
		teleporter_hub.update_icon(UPDATE_ICON_STATE)
		teleporter_hub = null
	if(teleporter_console)
		teleporter_console.power_station = null
		teleporter_console = null
	return ..()

/obj/machinery/teleport/station/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(panel_open && istype(used, /obj/item/circuitboard/teleporter_perma))
		if(!teleporter_console)
			to_chat(user, "<span class='caution'>[src] is not linked to a teleporter console.</span>")
			return ITEM_INTERACT_COMPLETE

		var/obj/item/circuitboard/teleporter_perma/C = used
		C.target = teleporter_console.target
		to_chat(user, "<span class='caution'>You copy the targeting information from [src] to [C].</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/teleport/station/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/teleport/station/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	if(!panel_open)
		if(M.buffer && istype(M.buffer, /obj/machinery/teleport/station) && M.buffer != src)
			if(length(linked_stations) < efficiency)
				linked_stations.Add(M.buffer)
				M.buffer = null
				to_chat(user, "<span class='caution'>You upload the data from [M]'s buffer.</span>")
			else
				to_chat(user, "<span class='alert'>This station can't hold more information, try to use better parts.</span>")
		return
	M.set_multitool_buffer(user, src)

/obj/machinery/teleport/station/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "controller-o", "controller", I))
		update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
		return TRUE

/obj/machinery/teleport/station/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open)
		link_console_and_hub()
		to_chat(user, "<span class='caution'>You reconnect the station to nearby machinery.</span>")


/obj/machinery/teleport/station/attack_ai()
	attack_hand()

/obj/machinery/teleport/station/attack_hand(mob/user)
	if(!panel_open)
		toggle(user)
	else
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")

/obj/machinery/teleport/station/proc/toggle(mob/user)
	if(stat & (BROKEN|NOPOWER) || !teleporter_hub || !teleporter_console)
		return
	if(teleporter_hub.panel_open)
		to_chat(user, "<span class='notice'>Close the hub's maintenance panel first.</span>")
		return
	if(teleporter_console.target)
		engaged = !engaged
		use_power(5000)
		visible_message("<span class='notice'>Teleporter [engaged ? "" : "dis"]engaged!</span>")
	else
		visible_message("<span class='alert'>No target detected.</span>")
		engaged = FALSE
	teleporter_hub.update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	teleporter_hub.update_lighting()
	if(istype(user))
		add_fingerprint(user)

/obj/machinery/teleport/station/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

	if(teleporter_hub)
		teleporter_hub.update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
		teleporter_hub.update_lighting()

	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)

/obj/machinery/teleport/station/update_icon_state()
	if(panel_open)
		icon_state = "controller-o"
	else if(stat & NOPOWER)
		icon_state = "controller-p"
	else
		icon_state = "controller"

/obj/machinery/teleport/station/update_overlays()
	. = ..()
	underlays.Cut()

	if(!(stat & NOPOWER) && !panel_open)
		underlays += emissive_appearance(icon, "controller_lightmask")

#undef REGIME_TELEPORT
#undef REGIME_GATE
#undef REGIME_GPS
