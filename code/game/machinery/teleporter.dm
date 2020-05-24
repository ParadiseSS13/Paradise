/obj/machinery/computer/teleporter
	name = "teleporter control console"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/circuitboard/teleporter
	var/obj/item/gps/locked = null
	var/regime_set = "Teleporter"
	var/id = null
	var/obj/machinery/teleport/station/power_station
	var/calibrating
	var/turf/target //Used for one-time-use teleport cards (such as clown planet coordinates.)
						 //Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.
	var/area_bypass = FALSE
	var/cc_beacon = FALSE

/obj/machinery/computer/teleporter/New()
	src.id = "[rand(1000, 9999)]"
	link_power_station()
	..()
	return

/obj/machinery/computer/teleporter/Initialize()
	..()
	link_power_station()
	update_icon()

/obj/machinery/computer/teleporter/Destroy()
	if(power_station)
		power_station.teleporter_console = null
		power_station = null
	return ..()

/obj/machinery/computer/teleporter/proc/link_power_station()
	if(power_station)
		return
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		power_station = locate(/obj/machinery/teleport/station, get_step(src, dir))
		if(power_station)
			break
	return power_station

/obj/machinery/computer/teleporter/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/gps))
		var/obj/item/gps/L = I
		if(L.locked_location && !(stat & (NOPOWER|BROKEN)))
			if(!user.unEquip(L))
				to_chat(user, "<span class='warning'>[I] is stuck to your hand, you cannot put it in [src]</span>")
				return
			L.forceMove(src)
			locked = L
			to_chat(user, "<span class='caution'>You insert the GPS device into the [src]'s slot.</span>")
	else
		return ..()

/obj/machinery/computer/teleporter/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		to_chat(user, "<span class='notice'>The teleporter can now lock on to Syndicate beacons!</span>")
	else
		ui_interact(user)

/obj/machinery/computer/teleporter/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/teleporter/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/teleporter/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (NOPOWER|BROKEN))
		return

	// Set up the Nano UI
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "teleporter_console.tmpl", "Teleporter Console UI", 400, 400)
		ui.open()

/obj/machinery/computer/teleporter/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	data["powerstation"] = power_station
	if(power_station)
		data["teleporterhub"] = power_station.teleporter_hub
		data["calibrated"] = power_station.teleporter_hub.calibrated
		data["accurate"] = power_station.teleporter_hub.accurate
	else
		data["teleporterhub"] = null
		data["calibrated"] = null
		data["accurate"] = null
	data["regime"] = regime_set
	var/area/targetarea = get_area(target)
	data["target"] = (!target || !targetarea) ? "None" : sanitize(targetarea.name)
	data["calibrating"] = calibrating
	data["locked"] = locked
	return data

/obj/machinery/computer/teleporter/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["eject"])
		eject()
		SSnanoui.update_uis(src)
		return

	if(!check_hub_connection())
		to_chat(usr, "<span class='warning'>Error: Unable to detect hub.</span>")
		SSnanoui.update_uis(src)
		return
	if(calibrating)
		to_chat(usr, "<span class='warning'>Error: Calibration in progress. Stand by.</span>")
		SSnanoui.update_uis(src)
		return

	if(href_list["regimeset"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		reset_regime()
		SSnanoui.update_uis(src)
	if(href_list["settarget"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		set_target(usr)
		SSnanoui.update_uis(src)
	if(href_list["lock"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		target = get_turf(locked.locked_location)
		SSnanoui.update_uis(src)
	if(href_list["calibrate"])
		if(!target)
			to_chat(usr, "<span class='warning'>Error: No target set to calibrate to.</span>")
			SSnanoui.update_uis(src)
			return
		if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accurate >= 3)
			to_chat(usr, "<span class='notice'>Hub is already calibrated.</span>")
			SSnanoui.update_uis(src)
			return
		src.visible_message("<span class='notice'>Processing hub calibration to target...</span>")

		calibrating = 1
		SSnanoui.update_uis(src)
		spawn(50 * (3 - power_station.teleporter_hub.accurate)) //Better parts mean faster calibration
			calibrating = 0
			if(check_hub_connection())
				power_station.teleporter_hub.calibrated = 1
				src.visible_message("<span class='notice'>Calibration complete.</span>")
			else
				src.visible_message("<span class='warning'>Error: Unable to detect hub.</span>")
			SSnanoui.update_uis(src)

	SSnanoui.update_uis(src)

/obj/machinery/computer/teleporter/proc/check_hub_connection()
	if(!power_station)
		return
	if(!power_station.teleporter_hub)
		return
	return 1

/obj/machinery/computer/teleporter/proc/reset_regime()
	target = null
	if(regime_set == "Teleporter")
		regime_set = "Gate"
	else
		regime_set = "Teleporter"

/obj/machinery/computer/teleporter/proc/eject()
	if(locked)
		locked.loc = loc
		locked = null

/obj/machinery/computer/teleporter/proc/set_target(mob/user)
	area_bypass = FALSE
	if(regime_set == "Teleporter")
		var/list/L = list()
		var/list/areaindex = list()

		for(var/obj/item/radio/beacon/R in GLOB.beacons)
			var/turf/T = get_turf(R)
			if(!T)
				continue
			if(!is_teleport_allowed(T.z) && !R.cc_beacon)
				continue
			if(R.syndicate == 1 && emagged == 0)
				continue
			var/tmpname = T.loc.name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R

		for(var/obj/item/implant/tracking/I in GLOB.tracked_implants)
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
				L[tmpname] = I

		var/desc = input("Please select a location to lock in.", "Locking Computer") in L
		target = L[desc]
		if(istype(target, /obj/item/radio/beacon))
			var/obj/item/radio/beacon/B = target
			if(B.area_bypass)
				area_bypass = TRUE
			cc_beacon = B.cc_beacon
	else
		var/list/L = list()
		var/list/areaindex = list()
		var/list/S = power_station.linked_stations
		if(!S.len)
			to_chat(user, "<span class='alert'>No connected stations located.</span>")
			return
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
			L[tmpname] = R
		var/desc = input("Please select a station to lock in.", "Locking Computer") in L
		target = L[desc]
		if(target)
			var/obj/machinery/teleport/station/trg = target
			trg.linked_stations |= power_station
			trg.stat &= ~NOPOWER
			if(trg.teleporter_hub)
				trg.teleporter_hub.stat &= ~NOPOWER
				trg.teleporter_hub.update_icon()
			if(trg.teleporter_console)
				trg.teleporter_console.stat &= ~NOPOWER
				trg.teleporter_console.update_icon()
	return

/proc/find_loc(obj/R as obj)
	if(!R)	return null
	var/turf/T = R.loc
	while(!istype(T, /turf))
		T = T.loc
		if(!T || istype(T, /area))	return null
	return T

/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	anchored = 1.0

/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	var/accurate = 0
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/teleport/station/power_station
	var/calibrated //Calibration prevents mutation
	var/admin_usage = 0 // if 1, works on z2. If 0, doesn't. Used for admin room teleport.

/obj/machinery/teleport/hub/New()
	..()
	link_power_station()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/teleporter_hub(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 3)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/teleport/hub/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/teleporter_hub(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 3)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	RefreshParts()

/obj/machinery/teleport/hub/Initialize()
	..()
	link_power_station()

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

/obj/machinery/teleport/hub/proc/link_power_station()
	if(power_station)
		return
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		power_station = locate(/obj/machinery/teleport/station, get_step(src, dir))
		if(power_station)
			break
	return power_station

/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	if(!is_teleport_allowed(z) && !admin_usage)
		to_chat(M, "You can't use this here.")
		return
	if(power_station && power_station.engaged && !panel_open)
		//--FalseIncarnate
		//Prevents AI cores from using the teleporter, prints out failure messages for clarity
		if(istype(M, /mob/living/silicon/ai) || istype(M, /obj/structure/AIcore))
			visible_message("<span class='warning'>The teleporter rejects the AI unit.</span>")
			if(istype(M, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/T = M
				var/list/TPError = list("<span class='warning'>Firmware instructions dictate you must remain on your assigned station!</span>",
				"<span class='warning'>You cannot interface with this technology and get rejected!</span>",
				"<span class='warning'>External firewalls prevent you from utilizing this machine!</span>",
				"<span class='warning'>Your AI core's anti-bluespace failsafes trigger and prevent teleportation!</span>")
				to_chat(T, "[pick(TPError)]")
			return
		else
			if(!teleport(M) && isliving(M)) // the isliving(M) is needed to avoid triggering errors if a spark bumps the telehub
				visible_message("<span class='warning'>[src] emits a loud buzz, as its teleport portal flickers and fails!</span>")
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
				power_station.toggle() // turn off the portal.

			use_power(5000)
		//--FalseIncarnate
	return

/obj/machinery/teleport/hub/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return
	return ..()

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
	if(!com.target)
		visible_message("<span class='alert'>Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if(istype(M, /atom/movable))
		if(!calibrated && com.cc_beacon)
			visible_message("<span class='alert'>Cannot lock on target. Please calibrate the teleporter before attempting long range teleportation.</span>")
		else if(!calibrated && prob(25 - ((accurate) * 10)) && !com.cc_beacon) //oh dear a problem
			. = do_teleport(M, locate(rand((2*TRANSITIONEDGE), world.maxx - (2*TRANSITIONEDGE)), rand((2*TRANSITIONEDGE), world.maxy - (2*TRANSITIONEDGE)), 3), 2, bypass_area_flag = com.area_bypass)
		else
			. = do_teleport(M, com.target, bypass_area_flag = com.area_bypass)
		calibrated = 0

/obj/machinery/teleport/hub/update_icon()
	if(panel_open)
		icon_state = "tele-o"
	else if(power_station && power_station.engaged)
		icon_state = "tele1"
	else
		icon_state = "tele0"

/obj/machinery/teleport/perma
	name = "permanent teleporter"
	desc = "A teleporter with the target pre-set on the circuit board."
	icon_state = "tele0"
	var/recalibrating = 0
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000

	var/target
	var/tele_delay = 50

/obj/machinery/teleport/perma/RefreshParts()
	for(var/obj/item/circuitboard/teleporter_perma/C in component_parts)
		target = C.target
	var/A = 40
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		A -= M.rating * 10
	tele_delay = max(A, 0)
	update_icon()

/obj/machinery/teleport/perma/Bumped(M as mob|obj)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!is_teleport_allowed(z))
		to_chat(M, "You can't use this here.")
		return
	if(target && !recalibrating && !panel_open)
		//--FalseIncarnate
		//Prevents AI cores from using the teleporter, prints out failure messages for clarity
		if(istype(M, /mob/living/silicon/ai) || istype(M, /obj/structure/AIcore))
			visible_message("<span class='warning'>The teleporter rejects the AI unit.</span>")
			if(istype(M, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/T = M
				var/list/TPError = list("<span class='warning'>Firmware instructions dictate you must remain on your assigned station!</span>",
				"<span class='warning'>You cannot interface with this technology and get rejected!</span>",
				"<span class='warning'>External firewalls prevent you from utilizing this machine!</span>",
				"<span class='warning'>Your AI core's anti-bluespace failsafes trigger and prevent teleportation!</span>")
				to_chat(T, "[pick(TPError)]")
			return
		else
			do_teleport(M, target)
			use_power(5000)

			if(tele_delay)
				recalibrating = 1
				update_icon()
				spawn(tele_delay)
					recalibrating = 0
					update_icon()
		//--FalseIncarnate
	return

/obj/machinery/teleport/perma/power_change()
	..()
	update_icon()

/obj/machinery/teleport/perma/update_icon()
	if(panel_open)
		icon_state = "tele-o"
	else if(target && !recalibrating && !(stat & (BROKEN|NOPOWER)))
		icon_state = "tele1"
	else
		icon_state = "tele0"

/obj/machinery/teleport/perma/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return
	return ..()

/obj/machinery/teleport/perma/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/teleport/perma/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", I))
		return TRUE

/obj/machinery/teleport/station
	name = "station"
	desc = "The power control station for a bluespace teleporter."
	icon_state = "controller"
	var/engaged = 0
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/computer/teleporter/teleporter_console
	var/obj/machinery/teleport/hub/teleporter_hub
	var/list/linked_stations = list()
	var/efficiency = 0

/obj/machinery/teleport/station/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/teleporter_station(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 2)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	link_console_and_hub()

/obj/machinery/teleport/station/Initialize()
	..()
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
		teleporter_hub.update_icon()
		teleporter_hub = null
	if(teleporter_console)
		teleporter_console.power_station = null
		teleporter_console = null
	return ..()

/obj/machinery/teleport/station/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return
	if(panel_open && istype(I, /obj/item/circuitboard/teleporter_perma))
		var/obj/item/circuitboard/teleporter_perma/C = I
		C.target = teleporter_console.target
		to_chat(user, "<span class='caution'>You copy the targeting information from [src] to [C]</span>")
		return
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
			if(linked_stations.len < efficiency)
				linked_stations.Add(M.buffer)
				M.buffer = null
				to_chat(user, "<span class='caution'>You upload the data from [M]'s buffer.</span>")
			else
				to_chat(user, "<span class='alert'>This station can't hold more information, try to use better parts.</span>")
		return
	M.set_multitool_buffer(user, src)

/obj/machinery/teleport/station/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "controller-o", "controller", I))
		update_icon()
		return TRUE

/obj/machinery/teleport/station/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open)
		link_console_and_hub()
		to_chat(user, "<span class='caution'>You reconnect the station to nearby machinery.</span>")


/obj/machinery/teleport/station/attack_ai()
	src.attack_hand()

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
		src.engaged = !src.engaged
		use_power(5000)
		visible_message("<span class='notice'>Teleporter [engaged ? "" : "dis"]engaged!</span>")
	else
		visible_message("<span class='alert'>No target detected.</span>")
		src.engaged = 0
	teleporter_hub.update_icon()
	if(istype(user))
		add_fingerprint(user)

/obj/machinery/teleport/station/power_change()
	..()
	update_icon()
	if(teleporter_hub)
		teleporter_hub.update_icon()

/obj/machinery/teleport/station/update_icon()
	if(panel_open)
		icon_state = "controller-o"
	else if(stat & NOPOWER)
		icon_state = "controller-p"
	else
		icon_state = "controller"
