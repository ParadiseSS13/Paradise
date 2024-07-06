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
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
			x = C.x,
			y = C.y,
			z = C.z,
			status = C.status
		))
	return data

/obj/machinery/computer/security/ui_static_data()
	var/list/data = list()
	data["mapRef"] = map_name
	data["stationLevel"] = level_name_to_num(MAIN_STATION)
	return data
