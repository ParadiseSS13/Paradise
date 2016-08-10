#define SHUTTLE_MANIPULATOR_STATUS 1
#define SHUTTLE_MANIPULATOR_TEMPLATE 2
#define SHUTTLE_MANIPULATOR_MOD 3

/obj/machinery/shuttle_manipulator
	name = "shuttle manipulator"
	desc = "I shall be telling this with a sigh\n\
		Somewhere ages and ages hence:\n\
		Two roads diverged in a wood, and I,\n\
		I took the one less traveled by,\n\
		And that has made all the difference."

	icon = 'icons/obj/machines/shuttle_manipulator.dmi'
	icon_state = "holograph_on"

	var/current_tab = SHUTTLE_MANIPULATOR_STATUS
	var/busy
	// UI state variables
	var/datum/map_template/shuttle/selected

	var/obj/docking_port/mobile/existing_shuttle

	var/obj/docking_port/mobile/preview_shuttle
	var/datum/map_template/shuttle/preview_template
	var/list/templates = list()
	var/list/shuttle_data = list()

/obj/machinery/shuttle_manipulator/New()
	. = ..()
	update_icon()

/obj/machinery/shuttle_manipulator/update_icon()
	overlays.Cut()
	var/image/hologram_projection = image(icon, "hologram_on")
	hologram_projection.pixel_y = 22
	var/image/hologram_ship = image(icon, "hologram_whiteship")
	hologram_ship.pixel_y = 27
	overlays += hologram_projection
	overlays += hologram_ship

/obj/machinery/shuttle_manipulator/process()
	return

/obj/machinery/shuttle_manipulator/attack_hand(mob/user as mob)
		user.set_machine(src)
		interact(user)

/obj/machinery/shuttle_manipulator/interact(mob/user)

	for(var/shuttle_id in shuttle_templates)
		var/datum/map_template/shuttle/S = shuttle_templates[shuttle_id]

		if(!templates[S.port_id])
			templates[S.port_id] = list(
				"port_id" = S.port_id,
				"templates" = list())

		var/list/L = list()
		L["name"] = S.name
		L["shuttle_id"] = S.shuttle_id
		L["port_id"] = S.port_id
		L["description"] = S.description
		L["admin_notes"] = S.admin_notes

		if(selected == S)
			shuttle_data["selected"] = L

		templates[S.port_id]["templates"] += list(L)


		// Status panel
	for(var/i in shuttle_master.mobile)
		var/obj/docking_port/mobile/M = i
		var/list/L = list()
		L["name"] = M.name
		L["id"] = M.id
		L["timer"] = M.timer
		L["timeleft"] = M.getTimerStr()
		L["mode"] = capitalize(M.mode)
		L["status"] = M.getStatusText()
		if(M == existing_shuttle)
			shuttle_data["existing_shuttle"] = L

		shuttle_data["shuttles"] += list(L)

	var/dat = ""
	dat += "<center>"
	dat += "<a href='?src=\ref[src];[src]=tab;tab=[SHUTTLE_MANIPULATOR_STATUS]' [current_tab == SHUTTLE_MANIPULATOR_STATUS ? "class='linkOn'" : ""]>Status</a>"
	dat += "<a href='?src=\ref[src];[src]=tab;tab=[SHUTTLE_MANIPULATOR_TEMPLATE]' [current_tab == SHUTTLE_MANIPULATOR_TEMPLATE ? "class='linkOn'" : ""]>Templates</a>"
	dat += "<a href='?src=\ref[src];[src]=tab;tab=[SHUTTLE_MANIPULATOR_MOD]' [current_tab == SHUTTLE_MANIPULATOR_MOD ? "class='linkOn'" : ""]>Modification</a>"
	dat += "</center>"
	dat += "<HR>"

	if(busy)
		dat += "<div class='statusDisplay'>Shuttle Manipulation in progress...</div>"
	else
		dat += "<div class='statusDisplay'>"

		switch(current_tab)
			if(SHUTTLE_MANIPULATOR_STATUS)
				dat += "<div class='block'>"
				for(var/list/shuttle in shuttle_data["shuttles"])
					dat += "<span class='line'>"
					dat += "<span class='statusLabel'>[shuttle["name"]] [shuttle["id"]]: [shuttle["mode"]] [shuttle["status"]] [shuttle["timer"]] </span>"
					dat += "<a href='?src=\ref[src];jump_to=[shuttle["id"]]'>Jump To</a>"
					dat += "<a href='?src=\ref[src];fast_travel=[shuttle["id"]]'>Fast Travel</a>"
					dat += "<br></span>"
				dat += "</div>"
			if(SHUTTLE_MANIPULATOR_TEMPLATE)
				dat += "<div class='block'>"
				for(var/list/shuttle in shuttle_data["shuttles"])
					dat += "<span class='line'>"
					dat += "<span class='statusLabel'> [shuttle["name"]] <br>[shuttle["description"]]<br> [shuttle["admin_notes"]] <br></span>"
					dat += "<A href='?src=\ref[src];load=[shuttle["id"]]'>Load Template</A>"
					dat += "<A href='?src=\ref[src];select_template=[shuttle["id"]]'>Select Template</A>"
					dat += "<a href='?src=\ref[src];preview=[shuttle["id"]]'>Preview Template</A>"
					dat += "<br></span>"
				dat += "</div>"
			if(SHUTTLE_MANIPULATOR_MOD)
				dat += "<div class='block'>"
				for(var/list/shuttle in shuttle_data["shuttles"])
					dat += "<span class='line'>"
					dat += "<span class='statusLabel'>[shuttle["name"]] [shuttle["id"]] <br>[shuttle["description"]]<br> [shuttle["admin_notes"]] <br> </span>"
					dat += "<A href='?src=\ref[src];move=[shuttle["id"]]'>Send to port</A>"
					dat += "<a href='?src=\ref[src];jump_to=[shuttle["id"]]'>Jump To</A>"
					dat += "<br></span>"
				dat += "</div>"

	var/datum/browser/popup = new(user, "shuttle manipulator", "Shuttle Manipulator", 500, 500)
	popup.set_content(dat)
	popup.open()

	return

/obj/machinery/shuttle_manipulator/Topic(href, href_list)
	if(..())
		return

	var/mob/user = usr

	// Preload some common parameters
	var/shuttle_id = href_list["shuttle_id"]
	var/datum/map_template/shuttle/S = shuttle_templates[shuttle_id]

	if(href_list["select_template"])
		if(S)
			existing_shuttle = shuttle_master.getShuttle(S.port_id)
			selected = S
			. = TRUE
	if(href_list["jump_to"])
		if(href_list["type"] == "mobile")
			. = TRUE
			for(var/i in shuttle_master.mobile)
				var/obj/docking_port/mobile/M = i
				if(M.id == href_list["id"])
					user.forceMove(get_turf(M))
					break

	if(href_list["preview"])
		if(S)
			. = TRUE
			unload_preview()
			load_template(S)
			if(preview_shuttle)
				preview_template = S
				user.forceMove(get_turf(preview_shuttle))

	if(href_list["load"])
		if(existing_shuttle == shuttle_master.backup_shuttle)
			// TODO make the load button disabled
			WARNING("The shuttle that the selected shuttle will replace \
				is the backup shuttle. Backup shuttle is required to be \
				intact for round sanity.")
		else if(S)
			. = TRUE
			// If successful, returns the mobile docking port
			var/mdp = action_load(S)
			if(mdp)
				user.forceMove(get_turf(mdp))

/obj/machinery/shuttle_manipulator/proc/action_load(
	datum/map_template/shuttle/loading_template)
	// Check for an existing preview
	if(preview_shuttle && (loading_template != preview_template))
		preview_shuttle.jumpToNullSpace()
		preview_shuttle = null
		preview_template = null

	if(!preview_shuttle)
		load_template(loading_template)
		preview_template = loading_template

	// get the existing shuttle information, if any
	var/timer = 0
	var/mode = SHUTTLE_IDLE
	var/obj/docking_port/stationary/D

	if(existing_shuttle)
		timer = existing_shuttle.timer
		mode = existing_shuttle.mode
		D = existing_shuttle.get_docked()
	else
		D = preview_shuttle.findRoundstartDock()

	if(!D)
		var/m = "No dock found for preview shuttle, aborting."
		WARNING(m)
		throw EXCEPTION(m)

	var/result = preview_shuttle.canDock(D)
	// truthy value means that it cannot dock for some reason
	// but we can ignore the someone else docked error because we'll
	// be moving into their place shortly
	if(result && (result != 6))
		var/m = "Unsuccessful dock of [preview_shuttle] ([result])."
		WARNING(m)
		return

	existing_shuttle.jumpToNullSpace()

	preview_shuttle.dock(D)
	. = preview_shuttle

	// Shuttle state involves a mode and a timer based on world.time, so
	// plugging the existing shuttles old values in works fine.
	preview_shuttle.timer = timer
	preview_shuttle.mode = mode

	preview_shuttle.register()

	// TODO indicate to the user that success happened, rather than just
	// blanking the modification tab
	preview_shuttle = null
	preview_template = null
	existing_shuttle = null
	selected = null

	return preview_shuttle

/obj/machinery/shuttle_manipulator/proc/load_template(
	datum/map_template/shuttle/S)
	// load shuttle template, centred at shuttle import landmark,
	var/turf/landmark_turf = get_turf(locate("landmark*Shuttle Import"))
	S.load(landmark_turf, centered = TRUE)

	var/affected = S.get_affected_turfs(landmark_turf, centered=TRUE)

	var/found = 0
	// Search the turfs for docking ports
	// - We need to find the mobile docking port because that is the heart of
	//   the shuttle.
	// - We need to check that no additional ports have slipped in from the
	//   template, because that causes unintended behaviour.
	for(var/T in affected)
		for(var/obj/docking_port/P in T)
			if(istype(P, /obj/docking_port/mobile))
				var/obj/docking_port/mobile/M = P
				found++
				if(found > 1)
					qdel(P, force=TRUE)
					world.log << "Map warning: Shuttle Template [S.mappath] \
						has multiple mobile docking ports."
				else if(!M.timid)
					// The shuttle template we loaded isn't "timid" which means
					// it's already registered with the shuttles subsystem.
					// This is a bad thing.
					var/m = "Template [S] is non-timid! Unloading."
					WARNING(m)
					M.jumpToNullSpace()
					return
				else
					preview_shuttle = P
			if(istype(P, /obj/docking_port/stationary))
				world.log << "Map warning: Shuttle Template [S.mappath] has a \
					stationary docking port."
	if(!found)
		var/msg = "load_template(): Shuttle Template [S.mappath] has no \
			mobile docking port. Aborting import."
		//for(var/T in affected)//wot do?
		//	var/turf/T0 = T
		//	T0.empty()

		message_admins(msg)
		WARNING(msg)

/obj/machinery/shuttle_manipulator/proc/unload_preview()
	if(preview_shuttle)
		preview_shuttle.jumpToNullSpace()
	preview_shuttle = null