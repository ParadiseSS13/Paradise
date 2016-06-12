/obj/machinery/computer/teleporter
	name = "teleporter control console"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/weapon/circuitboard/teleporter
	var/obj/item/device/gps/locked = null
	var/regime_set = "Teleporter"
	var/id = null
	var/obj/machinery/teleport/station/power_station
	var/calibrating
	var/turf/target //Used for one-time-use teleport cards (such as clown planet coordinates.)
						 //Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.
	var/data[0]

/obj/machinery/computer/teleporter/New()
	src.id = "[rand(1000, 9999)]"
	link_power_station()
	..()
	return

/obj/machinery/computer/teleporter/initialize()
	link_power_station()
	update_icon()

/obj/machinery/computer/teleporter/Destroy()
	if (power_station)
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

/obj/machinery/computer/teleporter/attackby(I as obj, mob/living/user as mob, params)
	if(istype(I, /obj/item/device/gps))
		var/obj/item/device/gps/L = I
		if(L.locked_location && !(stat & (NOPOWER|BROKEN)))
			if(!user.unEquip(L))
				to_chat(user, "<span class='warning'>\the [I] is stuck to your hand, you cannot put it in \the [src]</span>")
				return
			L.loc = src
			locked = L
			to_chat(user, "<span class='caution'>You insert the GPS device into the [name]'s slot.</span>")
	else
		..()
	return

/obj/machinery/computer/teleporter/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		to_chat(user, "\blue The teleporter can now lock on to Syndicate beacons!")
	else
		ui_interact(user)

/obj/machinery/computer/teleporter/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/teleporter/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/teleporter/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

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
	data["target"] = (!target) ? "None" : sanitize(targetarea.name)
	data["calibrating"] = calibrating
	data["locked"] = locked

	// Set up the Nano UI
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "teleporter_console.tmpl", "Teleporter Console UI", 400, 400)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/teleporter/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["eject"])
		eject()
		nanomanager.update_uis(src)
		return

	if(!check_hub_connection())
		to_chat(usr, "<span class='warning'>Error: Unable to detect hub.</span>")
		nanomanager.update_uis(src)
		return
	if(calibrating)
		to_chat(usr, "<span class='warning'>Error: Calibration in progress. Stand by.</span>")
		nanomanager.update_uis(src)
		return

	if(href_list["regimeset"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		reset_regime()
		nanomanager.update_uis(src)
	if(href_list["settarget"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		set_target(usr)
		nanomanager.update_uis(src)
	if(href_list["lock"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		target = get_turf(locked.locked_location)
		nanomanager.update_uis(src)
	if(href_list["calibrate"])
		if(!target)
			to_chat(usr, "<span class='warning'>Error: No target set to calibrate to.</span>")
			nanomanager.update_uis(src)
			return
		if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accurate >= 3)
			to_chat(usr, "<span class='notice'>Hub is already calibrated.</span>")
			nanomanager.update_uis(src)
			return
		src.visible_message("<span class='notice'>Processing hub calibration to target...</span>")

		calibrating = 1
		nanomanager.update_uis(src)
		spawn(50 * (3 - power_station.teleporter_hub.accurate)) //Better parts mean faster calibration
			calibrating = 0
			if(check_hub_connection())
				power_station.teleporter_hub.calibrated = 1
				src.visible_message("<span class='notice'>Calibration complete.</span>")
			else
				src.visible_message("<span class='warning'>Error: Unable to detect hub.</span>")
			nanomanager.update_uis(src)

	nanomanager.update_uis(src)

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
	if(regime_set == "Teleporter")
		var/list/L = list()
		var/list/areaindex = list()

		for(var/obj/item/device/radio/beacon/R in beacons)
			var/turf/T = get_turf(R)
			if (!T)
				continue
			if((T.z in config.admin_levels) || T.z > 7)
				continue
			if(R.syndicate == 1 && emagged == 0)
				continue
			var/tmpname = T.loc.name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R

		for (var/obj/item/weapon/implant/tracking/I in tracked_implants)
			if (!I.implanted || !ismob(I.loc))
				continue
			else
				var/mob/M = I.loc
				if (M.stat == 2)
					if (M.timeofdeath + 6000 < world.time)
						continue
				var/turf/T = get_turf(M)
				if(!T)	continue
				if((T.z in config.admin_levels))	continue
				var/tmpname = M.real_name
				if(areaindex[tmpname])
					tmpname = "[tmpname] ([++areaindex[tmpname]])"
				else
					areaindex[tmpname] = 1
				L[tmpname] = I

		var/desc = input("Please select a location to lock in.", "Locking Computer") in L
		target = L[desc]

	else
		var/list/L = list()
		var/list/areaindex = list()
		var/list/S = power_station.linked_stations
		if(!S.len)
			to_chat(user, "<span class='alert'>No connected stations located.</span>")
			return
		for(var/obj/machinery/teleport/station/R in S)
			var/turf/T = get_turf(R)
			if (!T || !R.teleporter_hub || !R.teleporter_console)
				continue
			if((T.z in config.admin_levels) || T.z > 7)
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
	if (!R)	return null
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
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/teleport/station/power_station
	var/calibrated //Calibration prevents mutation

/obj/machinery/teleport/hub/New()
	..()
	link_power_station()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/teleporter_hub(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/teleport/hub/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/teleporter_hub(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	RefreshParts()

/obj/machinery/teleport/hub/initialize()
	link_power_station()

/obj/machinery/teleport/hub/Destroy()
	if (power_station)
		power_station.teleporter_hub = null
		power_station = null
	return ..()

/obj/machinery/teleport/hub/RefreshParts()
	var/A = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
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
	if(z == ZLEVEL_CENTCOMM)
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
			teleport(M)
			use_power(5000)
		//--FalseIncarnate
	return

/obj/machinery/teleport/hub/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", W))
		return

	if(exchange_parts(user, W))
		return

	default_deconstruction_crowbar(W)

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj, turf/T)
	var/obj/machinery/computer/teleporter/com = power_station.teleporter_console
	if (!com)
		return
	if (!com.target)
		visible_message("<span class='alert'>Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if (istype(M, /atom/movable))
		if(!calibrated && prob(25 - ((accurate) * 10))) //oh dear a problem
			do_teleport(M, locate(rand((2*TRANSITIONEDGE), world.maxx - (2*TRANSITIONEDGE)), rand((2*TRANSITIONEDGE), world.maxy - (2*TRANSITIONEDGE)), 3), 2)
		else
			do_teleport(M, com.target)
		calibrated = 0
	return

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
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	
	var/target
	var/tele_delay = 50

/obj/machinery/teleport/perma/RefreshParts()
	for(var/obj/item/weapon/circuitboard/teleporter_perma/C in component_parts)
		target = C.target
	var/A = 40
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		A -= M.rating * 10
	tele_delay = max(A, 0)
	update_icon()

/obj/machinery/teleport/perma/Bumped(M as mob|obj)
	if(stat & (BROKEN|NOPOWER))
		return
	if(z == ZLEVEL_CENTCOMM)
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

/obj/machinery/teleport/perma/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", W))
		return

	if(exchange_parts(user, W))
		return

	default_deconstruction_crowbar(W)

/obj/machinery/teleport/station
	name = "station"
	desc = "The power control station for a bluespace teleporter."
	icon_state = "controller"
	var/engaged = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/computer/teleporter/teleporter_console
	var/obj/machinery/teleport/hub/teleporter_hub
	var/list/linked_stations = list()
	var/efficiency = 0

/obj/machinery/teleport/station/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/teleporter_station(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()
	link_console_and_hub()

/obj/machinery/teleport/station/initialize()
	link_console_and_hub()

/obj/machinery/teleport/station/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
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
	if (teleporter_console)
		teleporter_console.power_station = null
		teleporter_console = null
	return ..()

/obj/machinery/teleport/station/attackby(var/obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool) && !panel_open)
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/teleport/station) && M.buffer != src)
			if(linked_stations.len < efficiency)
				linked_stations.Add(M.buffer)
				M.buffer = null
				to_chat(user, "<span class='caution'>You upload the data from the [W.name]'s buffer.</span>")
			else
				to_chat(user, "<span class='alert'>This station can't hold more information, try to use better parts.</span>")
	if(default_deconstruction_screwdriver(user, "controller-o", "controller", W))
		update_icon()
		return

	if(exchange_parts(user, W))
		return

	default_deconstruction_crowbar(W)

	if(panel_open)
		if(istype(W, /obj/item/device/multitool))
			var/obj/item/device/multitool/M = W
			M.buffer = src
			to_chat(user, "<span class='caution'>You download the data to the [W.name]'s buffer.</span>")
			return
		if(istype(W, /obj/item/weapon/wirecutters))
			link_console_and_hub()
			to_chat(user, "<span class='caution'>You reconnect the station to nearby machinery.</span>")
			return
		if(istype(W, /obj/item/weapon/circuitboard/teleporter_perma))
			var/obj/item/weapon/circuitboard/teleporter_perma/C = W
			C.target = teleporter_console.target
			to_chat(user, "<span class='caution'>You copy the targeting information from \the [src] to \the [W]</span>")
			return

/obj/machinery/teleport/station/attack_ai()
	src.attack_hand()

/obj/machinery/teleport/station/attack_hand(mob/user)
	if(!panel_open)
		toggle(user)
	else
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")

/obj/machinery/teleport/station/proc/toggle(mob/user)
	if (stat & (BROKEN|NOPOWER) || !teleporter_hub || !teleporter_console)
		return
	if (teleporter_hub.panel_open)
		to_chat(user, "<span class='notice'>Close the hub's maintenance panel first.</span>")
		return
	if (teleporter_console.target)
		src.engaged = !src.engaged
		use_power(5000)
		visible_message("<span class='notice'>Teleporter [engaged ? "" : "dis"]engaged!</span>")
	else
		visible_message("<span class='alert'>No target detected.</span>")
		src.engaged = 0
	teleporter_hub.update_icon()
	src.add_fingerprint(user)
	return

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
