/obj/machinery/computer/drone_control
	name = "maintenance drone control console"
	desc = "Used to monitor the station's drone population and the assembler that services them."
	icon_screen = "power"
	icon_keyboard = "power_key"
	req_access = list(ACCESS_MAINT_TUNNELS)
	circuit = /obj/item/circuitboard/drone_control

	/// The linked fabricator
	var/obj/machinery/drone_fabricator/dronefab
	/// Used when pinging drones
	var/drone_call_area = "Engineering"
	/// Cooldown for area pings
	var/ping_cooldown = 0

/obj/machinery/computer/drone_control/Initialize(mapload)
	. = ..()
	find_fab()

/obj/machinery/computer/drone_control/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	ui_interact(user)

/obj/machinery/computer/drone_control/attack_ghost(mob/user)
	ui_interact(user)

// tgui\packages\tgui\interfaces\DroneConsole.js
/obj/machinery/computer/drone_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/drone_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DroneConsole", "Drone Control Console")
		ui.open()

/obj/machinery/computer/drone_control/ui_data(mob/user)
	var/list/data = list()
	data["drone_fab"] = FALSE
	data["fab_power"] = null
	data["active_drones"] = 0
	data["stored_drones"] = 0
	data["total_drones"] = 0
	if(dronefab)
		data["drone_fab"] = TRUE
		data["fab_power"] = dronefab.stat & NOPOWER ? FALSE : TRUE

	data["selected_area"] = drone_call_area
	data["ping_cd"] = ping_cooldown > world.time ? TRUE : FALSE

	data["drones"] = list()
	var/active_drones = 0
	var/stored_drones = 0
	var/total_drones = 0
	for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
		total_drones++
		if(D.loc == dronefab)
			stored_drones++
			continue
		if(D.client)
			active_drones++
		var/area/A = get_area(D)
		var/turf/T = get_turf(D)
		var/list/drone_data = list(
			name = D.real_name,
			uid = D.UID(),
			stat = D.stat,
			client = D.client ? TRUE : FALSE,
			health = round(D.health / D.maxHealth, 0.1),
			charge = round(D.cell.charge / D.cell.maxcharge, 0.1),
			location = "[A] ([T.x], [T.y])",
			sync_cd = D.sync_cooldown > world.time ? TRUE : FALSE,
			pathfinding = D.pathfinding
		)
		data["drones"] += list(drone_data)

	if(dronefab)
		data["active_drones"] = active_drones
		data["stored_drones"] = stored_drones
		data["total_drones"] = total_drones
	return data

/obj/machinery/computer/drone_control/ui_static_data(mob/user)
	var/list/data = list()
	data["area_list"] = GLOB.TAGGERLOCATIONS
	return data

/obj/machinery/computer/drone_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE

	switch(action)
		if("find_fab")
			find_fab(usr)

		if("set_area")
			drone_call_area = params["area"]

		if("ping")
			ping_cooldown = world.time + 1 MINUTES // One minute cooldown to prevent chat spam
			to_chat(usr, "<span class='notice'>You issue a maintenance request for all active drones, highlighting [drone_call_area].</span>")
			for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
				if(D.client && D.stat == CONSCIOUS)
					to_chat(D, "<span class='boldnotice'>-- Maintenance drone presence requested in: [drone_call_area].</span>")

		if("resync")
			var/mob/living/silicon/robot/drone/D = locateUID(params["uid"])
			if(D)
				D.sync_cooldown = world.time + 1 MINUTES // One minute cooldown to prevent chat spam
				to_chat(usr, "<span class='notice'>You issue a law synchronization directive for the drone.</span>")
				D.law_resync()

		if("recall")
			var/mob/living/silicon/robot/drone/D = locateUID(params["uid"])
			if(D)
				to_chat(usr, "<span class='warning'>You issue a recall command for the unfortunate drone.</span>")
				if(D != usr) // Don't need to bug admins about a suicide
					message_admins("[key_name_admin(usr)] issued recall order for drone [key_name_admin(D)] from control console.")
				log_game("[key_name(usr)] issued recall order for [key_name(D)] from control console.")
				D.timeofdeath = world.time
				D.shut_down()

/obj/machinery/computer/drone_control/proc/find_fab(mob/user)
	if(dronefab)
		return

	for(var/obj/machinery/drone_fabricator/fab in get_area(src))

		if(fab.stat & NOPOWER)
			continue

		dronefab = fab
		if(user)
			to_chat(user, "<span class='notice'>Drone fabricator located.</span>")
		return

	if(user)
		to_chat(user, "<span class='warning'>Unable to locate drone fabricator.</span>")
