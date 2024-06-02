/obj/item/whiteship_port_generator
	name = "docking area signaller"
	desc = "A signaling device for the NT expeditionary vessel, used to designate new docking areas."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-white"

	var/list/placed_docks = list()
	var/max_docks = 3

/obj/item/whiteship_port_generator/examine(mob/user)
	. = ..()
	var/count = max_docks - length(placed_docks)
	var/plural = count > 1
	. += "There [plural ? "are" : "is"] [count] use[plural ? "s" : ""] left."

/obj/item/whiteship_port_generator/attack_self(mob/living/user)
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

	for(var/obj/placed_dock in placed_docks)
		if(placed_dock.z == user.z)
			to_chat(user, "<span class='notice'>A docking area has already been placed in this sector!</span>")
			return

	var/list/dir_choices = list("North" = NORTH, "East" = EAST, "South" = SOUTH, "West" = WEST)
	var/dir_choice = tgui_input_list(user, "Select the new docking area orientation.", "Dock Orientation", dir_choices)
	if(!dir_choice)
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

	placed_docks += port
	var/dock_count = length(placed_docks)

	var/basename = "Custom Dock #[dock_count]"
	var/name = tgui_input_text(user,
		message = "Select the new docking area name.",
		title = "New Dock Name",
		default = basename,
		max_length = 20
	)
	port.name = name ? name : basename
	port.id = "whiteship_custom_[dock_count]"
	port.register()

	for(var/obj/machinery/computer/shuttle/white_ship/S in GLOB.machines)
		S.possible_destinations = null
		S.connect()

	log_admin("[key_name(user)] created a whiteship dock named '[name]' at [COORD(port)].")

	if(dock_count < max_docks)
		to_chat(user, "<span class='info'>Landing zone set.</span>")
	else
		to_chat(user, "<span class='info'>Landing zone set. The signaller vanishes!</span>")
		qdel(src)
