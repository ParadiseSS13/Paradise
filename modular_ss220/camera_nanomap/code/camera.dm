/obj/machinery/camera
	var/nanomap_png

/obj/machinery/camera/Initialize(mapload, should_add_to_cameranet)
	. = ..()
	if(z == level_name_to_num(MAIN_STATION))
		nanomap_png = "[SSmapping.map_datum.technical_name]_nanomap_z1.png"
	else if(z == level_name_to_num(MINING))
		nanomap_png = "[MINING]_nanomap_z1.png"

/obj/machinery/computer/security
	var/list/z_levels = list() // Assoc list, "z_level":"nanomap.png"
	var/current_z_level_index

/obj/machinery/computer/security/ui_interact(mob/user, datum/tgui/ui = null)
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)
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
			var/atom/movable/screen/plane_master/instance = new plane()
			instance.assigned_map = map_name
			instance.del_on_map_removal = FALSE
			instance.screen_loc = "[map_name]:CENTER"
			instance.backdrop(user)

			user.client.register_map_obj(instance)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, "CameraConsole220", name)
		ui.open()

/obj/machinery/computer/security/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps)
	)

/obj/machinery/computer/security/ui_data()
	var/list/data = list()
	data["network"] = network
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	z_levels = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
			x = C.x,
			y = C.y,
			z = C.z,
			status = C.status
		))
		if("[C.z]" in z_levels || !C.nanomap_png)
			continue
		z_levels += list("[C.z]" = C.nanomap_png)
		// Sort it by z levels
	z_levels = sortAssoc(z_levels)
	if(isnull(current_z_level_index))
		current_z_level_index = clamp(z_levels.Find("[z]"), 1, length(z_levels))
	else
		current_z_level_index = clamp(current_z_level_index, 1, length(z_levels))
	// On null, it uses map datum value
	data["mapUrl"] = z_levels["[z_levels[current_z_level_index]]"] || null
	// On null, it uses station's z level
	data["selected_z_level"] = z_levels[current_z_level_index] || null
	return data

/obj/machinery/computer/security/ui_static_data()
	var/list/data = list()
	data["mapRef"] = map_name
	data["stationLevel"] = level_name_to_num(MAIN_STATION)
	return data

/obj/machinery/computer/security/ui_act(action, params)
	. = ..()
	if(. && action == "switch_camera")
		if(!active_camera)
			return
		current_z_level_index = z_levels.Find("[active_camera.z]")
		return
	if(.)
		return

	if(action == "switch_z_level")
		var/z_dir = params["z_dir"]
		current_z_level_index = clamp(current_z_level_index + z_dir, 1, length(z_levels))
		return TRUE
