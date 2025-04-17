/obj/item/whiteship_port_generator
	name = "docking area signaller"
	desc = "A signaling device for the NT expeditionary vessel, used to designate new docking areas."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-white"
	new_attack_chain = TRUE

	var/list/placed_docks = list()
	var/max_docks = 6
	var/shuttleId = "whiteship"
	var/possible_destinations

/obj/item/whiteship_port_generator/examine(mob/user)
	. = ..()
	var/count = max_docks - length(placed_docks)
	var/plural = count > 1
	. += "<span class='notice'>There [plural ? "are" : "is"] [count] use[plural ? "s" : ""] left.</span>"
	. += "<span class='notice'><b>Alt-Click</b> to call the ship to an existing docking area.</span>"

/obj/item/whiteship_port_generator/activate_self(mob/user)
	. = FINISH_ATTACK

	if(..())
		return

	if(is_station_level(user.z))
		log_admin("[key_name(user)] attempted to create a whiteship dock in the station's sector at [COORD(user)].")
		to_chat(user, "<span class='notice'>New docking areas cannot be designated within the station's sector!</span>")
		return

	if(is_admin_level(user.z))
		log_admin("[key_name(user)] attempted to create a whiteship dock on Centcomm level at [COORD(user)].")
		to_chat(user, "<span class='notice'>New docking areas cannot be designated in this sector!</span>")
		return

	if(is_mining_level(user.z))
		log_admin("[key_name(user)] attempted to create a whiteship dock on Lavaland at [COORD(user)].")
		to_chat(user, "<span class='notice'>New docking areas cannot be designated planet side!</span>")
		return

	var/list/docks_per_z = list()
	for(var/obj/placed_dock in placed_docks)
		if(!("[placed_dock.z]" in docks_per_z))
			docks_per_z["[placed_dock.z]"] = 0
		docks_per_z["[placed_dock.z]"]++

	if(docks_per_z["[user.z]"] >= 3)
		to_chat(user, "<span class='notice'>This sector cannot support any more docking areas!</span>")
		return

	var/list/dir_choices = list("North" = NORTH, "East" = EAST, "South" = SOUTH, "West" = WEST)
	var/dir_choice = tgui_input_list(user, "Select the new docking area orientation.", "Dock Orientation", dir_choices)
	if(!dir_choice)
		to_chat(user, "<span class='notice'>Docking placement cancelled.</span>")
		return

	var/dest_dir = dir_choices[dir_choice]
	var/turf/destination = get_step(user.loc, dest_dir)
	var/obj/docking_port/stationary/whiteship/port = new(destination)
	port.dir = dest_dir

	var/min_x = -1
	var/min_y = -1
	var/max_x = -1
	var/max_y = -1

	var/list/ordered_turfs = port.return_ordered_turfs()
	for(var/turf/T in ordered_turfs)
		min_x = min_x < 0 ? T.x : min(min_x, T.x)
		min_y = min_y < 0 ? T.y : min(min_y, T.y)
		max_x = max_x < 0 ? T.x : max(max_x, T.x)
		max_y = max_y < 0 ? T.y : max(max_y, T.y)
		if(!isspaceturf(T))
			to_chat(user, "<span class='notice'>Obstruction found in docking space area, aborting!</span>")
			qdel(port, force = TRUE)
			return
		for(var/obj/O in T.contents)
			if(O == port)
				continue
			else
				to_chat(user, "<span class='notice'>Objects found in docking space area, aborting!</span>")
				qdel(port, force = TRUE)
				return

	if(min_x <= TRANSITION_BORDER_WEST + 1 || max_x >= TRANSITION_BORDER_EAST - 1)
		to_chat(user, "<span class='notice'>Docking space area too close to edge of sector, aborting!</span>")
		qdel(port, force = TRUE)
		return
	if(min_y <= TRANSITION_BORDER_SOUTH + 1 || max_y >= TRANSITION_BORDER_NORTH - 1)
		to_chat(user, "<span class='notice'>Docking space area too close to edge of sector, aborting!</span>")
		qdel(port, force = TRUE)
		return

	var/basename = "Docking Port #[length(placed_docks) + 1]"
	var/name = tgui_input_text(user,
		message = "Select the new docking area name.",
		title = "New Dock Name",
		default = basename,
		max_length = 20
	)
	if(!name)
		to_chat(user, "<span class='notice'>Docking placement cancelled.</span>")
		qdel(port, force = TRUE)
		return

	placed_docks += port
	var/dock_count = length(placed_docks)

	port.name = name
	port.id = "whiteship_custom_[dock_count]"
	port.register()

	for(var/obj/machinery/computer/shuttle/white_ship/S in SSmachines.get_by_type(/obj/machinery/computer/shuttle/white_ship))
		S.possible_destinations = null
		S.connect()
		possible_destinations = S.possible_destinations

	log_admin("[key_name(user)] created a whiteship dock named '[name]' at [COORD(port)].")
	to_chat(user, "<span class='notice'>Landing zone set.</span>")

/obj/item/whiteship_port_generator/AltClick(mob/user, modifiers)
	for(var/obj/machinery/computer/shuttle/white_ship/S in SSmachines.get_by_type(/obj/machinery/computer/shuttle/white_ship))
		possible_destinations = S.possible_destinations
		break

	ui_interact(user)

/obj/item/whiteship_port_generator/ui_state(mob/user)
	return GLOB.default_state

/obj/item/whiteship_port_generator/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleConsole", name)
		ui.open()

/// Pretty much a straight copy-paste of [/obj/machinery/computer/shuttle/proc/ui_data].
/// Yes it could be refactored but tearing all of the "make the shuttle move" code out of
/// the console whose job it is to exclusively do that is unsurprisingly messy.
/obj/item/whiteship_port_generator/ui_data(mob/user)
	var/list/data = list()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	data["status"] = M ? M.getStatusText() : null
	if(M)
		data["shuttle"] = TRUE	//this should just be boolean, right?
		var/list/docking_ports = list()
		data["docking_ports"] = docking_ports
		var/list/options = params2list(possible_destinations)
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary_docking_ports)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S))
				continue
			docking_ports[++docking_ports.len] = list("name" = S.name, "id" = S.id)
		data["docking_ports_len"] = length(docking_ports)
	return data

/// Pretty much a straight copy-paste of [/obj/machinery/computer/shuttle/proc/ui_act].
/// Yes it could be refactored but tearing all of the "make the shuttle move" code out of
/// the console whose job it is to exclusively do that is unsurprisingly messy.
/obj/item/whiteship_port_generator/ui_act(action, params)
	if(..())	//we can't actually interact, so no action
		return TRUE
	if(!allowed(usr))
		to_chat(usr, "<span class='danger'>Access denied.</span>")
		return TRUE
	var/list/options = params2list(possible_destinations)
	if(action == "move")
		var/destination = params["move"]
		if(!options.Find(destination))//figure out if this translation works
			message_admins("<span class='boldannounceooc'>EXPLOIT:</span> [ADMIN_LOOKUPFLW(usr)] attempted to move [src] to an invalid location! [ADMIN_COORDJMP(src)]")
			return
		switch(SSshuttle.moveShuttle(shuttleId, destination, TRUE, usr))
			if(0)
				atom_say("Shuttle en route.")
				usr.create_log(MISC_LOG, "used [src] to call the [shuttleId] shuttle")
				add_fingerprint(usr)
				return TRUE
			if(1)
				to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
			if(2)
				to_chat(usr, "<span class='notice'>Unable to comply.</span>")
			if(3)
				atom_say("Shuttle is regenerating fuel. Please wait...")
			if(4)
				atom_say("Shuttle is currently en-route. The shuttle cannot be rerouted at this time.")
			if(5)
				atom_say("Shuttle is currently departing. Please wait...")
