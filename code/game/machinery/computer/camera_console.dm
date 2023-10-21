/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras networks on the station."
	icon_keyboard = "security_key"
	icon_screen = "cameras"
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/camera

	var/mapping = 0 // For the overview file (overview.dm), not used on this page

	var/list/network = list("SS13","Mining Outpost")
	var/obj/machinery/camera/active_camera
	var/list/watchers = list()

	// Stuff needed to render the map
	var/map_name
	var/const/default_map_size = 15
	var/obj/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/list/cam_plane_masters
	var/obj/screen/background/cam_background

	// Parent object this camera is assigned to. Used for camera bugs
	var/atom/movable/parent

	/// is the console silent when switching cameras?
	var/silent_console = FALSE

/obj/machinery/computer/security/ui_host()
	return parent ? parent : src

/obj/machinery/computer/security/Initialize()
	. = ..()
	// Initialize map objects
	map_name = "camera_console_[UID()]_map"
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_masters = list()
	for(var/plane in subtypesof(/obj/screen/plane_master))
		var/obj/screen/instance = new plane()
		instance.assigned_map = map_name
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "[map_name]:CENTER"
		cam_plane_masters += instance
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/obj/machinery/computer/security/Destroy()
	qdel(cam_screen)
	QDEL_LIST_CONTENTS(cam_plane_masters)
	qdel(cam_background)
	return ..()

/obj/machinery/computer/security/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
	if(!ui)
		var/user_uid = user.UID()
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			watchers += user_uid
		// Turn on the console
		if(length(watchers) == 1 && is_living)
			if(!silent_console)
				playsound(src, 'sound/machines/terminal_on.ogg', 25, FALSE)
			use_power(active_power_consumption)
		// Register map objects
		user.client.register_map_obj(cam_screen)
		for(var/plane in cam_plane_masters)
			user.client.register_map_obj(plane)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, ui_key, "CameraConsole", name, 870, 708, master_ui, state)
		ui.open()

/obj/machinery/computer/security/ui_close(mob/user)
	..()
	watchers -= user.UID()
	user.client.clear_map(map_name)

/obj/machinery/computer/security/ui_data()
	var/list/data = list()
	data["network"] = network
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)
	return data

/obj/machinery/computer/security/ui_static_data()
	var/list/data = list()
	data["mapRef"] = map_name
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
		))
	return data


/obj/machinery/computer/security/ui_act(action, params)
	if(..())
		return

	if(action == "switch_camera")
		var/c_tag = params["name"]
		var/list/cameras = get_available_cameras()
		var/obj/machinery/camera/C = cameras[c_tag]
		active_camera = C
		if(!silent_console)
			playsound(src, get_sfx("terminal_type"), 25, FALSE)

		// Show static if can't use the camera
		if(!active_camera?.can_use())
			show_camera_static()
			return TRUE

		var/list/visible_turfs = list()
		for(var/turf/T in view(C.view_range, get_turf(C)))
			visible_turfs += T

		var/list/bbox = get_bbox_of_atoms(visible_turfs)
		var/size_x = bbox[3] - bbox[1] + 1
		var/size_y = bbox[4] - bbox[2] + 1

		cam_screen.vis_contents = visible_turfs
		cam_background.icon_state = "clear"
		cam_background.fill_rect(1, 1, size_x, size_y)

		return TRUE

// Returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	var/list/L = list()
	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if((is_away_level(z) || is_away_level(C.z)) && (C.z != z))//if on away mission, can only receive feed from same z_level cameras
			continue
		L.Add(C)
	var/list/D = list()
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network & network
		if(tempnetwork.len)
			D["[C.c_tag]"] = C
	return D

/obj/machinery/computer/security/attack_hand(mob/user)
	if(stat || ..())
		return

	ui_interact(user)

/obj/machinery/computer/security/attack_ai(mob/user)
	if(isAI(user))
		to_chat(user, "<span class='notice'>You realise it's kind of stupid to access a camera console when you have the entire camera network at your metaphorical fingertips.</span>")
		return

	ui_interact(user)


/obj/machinery/computer/security/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, default_map_size, default_map_size)

/obj/machinery/computer/security/telescreen/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/direction = input(user, "Which direction?", "Select direction!") as null|anything in list("North", "East", "South", "West", "Centre")
	if(!direction || !Adjacent(user))
		return
	pixel_x = 0
	pixel_y = 0
	switch(direction)
		if("North")
			pixel_y = 32
		if("East")
			pixel_x = 32
		if("South")
			pixel_y = -32
		if("West")
			pixel_x = -32

// Other computer monitors.
/obj/machinery/computer/security/telescreen
	name = "telescreen"
	desc = "Used for watching camera networks."
	icon_state = "telescreen_console"
	icon_screen = "telescreen"
	icon_keyboard = null
	light_range_on = 0
	density = FALSE
	circuit = /obj/item/circuitboard/camera/telescreen

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have Paradise TV on these things."
	icon_state = "entertainment_console"
	icon_screen = "entertainment_off"
	light_color = "#FFEEDB"
	light_range_on = 0
	network = list("news")
	luminosity = 0
	circuit = null
	/// Icon utilised when feeds_on is true
	var/icon_screen_on = "entertainment"
	/// Used to detect how many video cameras are active
	var/feeds_on = 0

/obj/machinery/computer/security/telescreen/entertainment/Initialize()
	. = ..()
	set_light(1, LIGHTING_MINIMUM_POWER) //so byond doesnt cull, and we get an emissive appearance

/obj/machinery/computer/security/telescreen/entertainment/update_overlays()
	if(feeds_on)
		icon_screen = icon_screen_on
	else
		icon_screen = initial(icon_screen)
	return ..()

/obj/machinery/computer/security/telescreen/entertainment/power_change()
	..()
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)

/obj/machinery/computer/security/telescreen/entertainment/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0 SECONDS))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct()

/obj/machinery/computer/security/telescreen/entertainment/on_deconstruction()
	. = ..()
	new /obj/item/mounted/frame/display/entertainment_frame(drop_location())

/obj/machinery/computer/security/telescreen/entertainment/television
	name = "television"
	desc = "A relic of a bygone age."
	icon_state = "television"
	icon_screen = null
	icon_screen_on = "detective_tv"
	density = TRUE

/obj/machinery/computer/security/telescreen/entertainment/television/wrench_act(mob/living/user, obj/item/I)
	if(default_unfasten_wrench(user, I, time = 4 SECONDS))
		return TRUE

/obj/machinery/computer/security/telescreen/entertainment/television/on_deconstruction()
	return

/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the station's camera network."
	icon_state = "television"
	icon_keyboard = null
	icon_screen = "detective_tv"
	light_color = "#3848B3"
	light_power_on = 0.5
	network = list("SS13")
	circuit = /obj/item/circuitboard/camera/wooden_tv

/obj/machinery/computer/security/mining
	name = "outpost camera monitor"
	desc = "Used to access the various cameras on the outpost."
	icon_keyboard = "tech_key"
	icon_screen = "mining"
	light_color = "#F9BBFC"
	network = list("Mining Outpost")
	circuit = /obj/item/circuitboard/camera/mining

/obj/machinery/computer/security/engineering
	name = "engineering camera monitor"
	desc = "Used to monitor fires and breaches."
	icon_keyboard = "power_key"
	icon_screen = "engie_cams"
	light_color = "#FAC54B"
	network = list("Power Alarms","Atmosphere Alarms","Fire Alarms")
	circuit = /obj/item/circuitboard/camera/engineering

/obj/machinery/computer/security/telescreen/engine
	name = "engine monitor"
	desc = "A telescreen that connects to the engine's camera network.";
	network = list("engine")
	circuit = /obj/item/circuitboard/camera/engine

/obj/machinery/computer/security/telescreen/research
	name = "research monitor"
	desc = "Used for watching the horrors within the test chamber.";
	network = list("TestChamber")
	circuit = /obj/item/circuitboard/camera/research

/obj/machinery/computer/security/telescreen/rd
	name = "research director monitor"
	desc = "Used for watching the RD's goons from the safety of his office.";
	network = list("Research","Research Outpost","RD","MiniSat")
	circuit = /obj/item/circuitboard/camera/rd

/obj/machinery/computer/security/telescreen/prison
	name = "prison monitor"
	desc = "Used for watching Prison Wing holding areas.";
	network = list("Prison")
	circuit = /obj/item/circuitboard/camera/prison

/obj/machinery/computer/security/telescreen/interrogation
	name = "interrogation monitor"
	desc = "Used for watching interrogations.";
	network = list("Interrogation")
	circuit = /obj/item/circuitboard/camera/interrogation

/obj/machinery/computer/security/telescreen/minisat
	name = "minisat monitor"
	desc = "Used for watching areas on the MiniSat.";
	network = list("MiniSat","tcomm")
	circuit = /obj/item/circuitboard/camera/minisat

/obj/machinery/computer/security/telescreen/upload
	name = "ai upload monitor"
	desc = "Used for watching the AI Upload.";
	network = list("AIUpload")
	circuit = /obj/item/circuitboard/camera/upload

/obj/machinery/computer/security/telescreen/vault
	name = "vault monitor"
	desc = "Used for watching the vault.";
	network = list("vault")
	circuit = /obj/item/circuitboard/camera/vault

/obj/machinery/computer/security/telescreen/turbine
	name = "turbine vent monitor"
	desc = "Used for watching the turbine vent.";
	network = list("Turbine")
	circuit = /obj/item/circuitboard/camera/turbine
