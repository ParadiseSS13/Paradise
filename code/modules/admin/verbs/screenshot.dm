/client/proc/cmd_mass_screenshot()
	set category = "Debug"
	set name = "Mass Screenshot"
	set waitfor = FALSE

	if(!check_rights(R_DEBUG) || !mob)
		return

	var/confirmation = tgui_alert(
		usr,
		"Are you sure you want to mass screenshot this z-level? \
		Ensure you have emptied your BYOND screenshots folder.",
		"Mass Screenshot",
		list("Yes", "No")
	)
	if(confirmation != "Yes")
		return
	
	var/sleep_duration = tgui_input_number(
		usr,
		"Enter a delay in deciseconds between screenshots to allow the client to render changes.",
		"Screenshot delay",
		default = 2, max_value = 10, min_value = 1, round_value = TRUE
	)
	if(!sleep_duration)
		return

	if(!isobserver(mob))
		admin_ghost()

	message_admins("[key_name(usr)] started a mass screenshot operation")

	// Prepare for screenshot
	var/old_client_view = view
	var/old_status_bar_visible = winget(src, "menu.statusbar", "is-checked") == "false" ? "true" : "false"
	var/old_hud_version = mob.hud_used ? mob.hud_used.hud_version : HUD_STYLE_NOHUD
	var/old_mob_alpha = mob.alpha
	var/old_mob_movement = mob.animate_movement

	view = 15
	winset(src, "paramapwindow.status_bar", "is-visible=false")
	mob.hud_used?.show_hud(HUD_STYLE_NOHUD)
	mob.hud_used?.remove_parallax()
	mob.alpha = 0
	mob.animate_movement = NO_STEPS

	var/half_chunk_size = view + 1
	var/chunk_size = half_chunk_size * 2 - 1
	var/cur_x = half_chunk_size
	var/cur_y = half_chunk_size
	var/cur_z = mob.z
	var/width = world.maxx - half_chunk_size + 2
	var/height = world.maxy - half_chunk_size + 2
	var/width_inside = width - 1
	var/height_inside = height - 1

	var/exception = null
	try
		while(cur_y < height)
			while(cur_x < width)
				mob.forceMove(locate(cur_x, cur_y, cur_z))
				sleep(sleep_duration)
				winset(src, null, "command='.screenshot auto'")
				if(cur_x == width_inside)
					break
				cur_x += chunk_size
				cur_x = min(cur_x, width_inside)
			if(cur_y == height_inside)
				break
			cur_x = half_chunk_size
			cur_y += chunk_size
			cur_y = min(cur_y, height_inside)
	catch(var/exception/e)
		exception = e
	
	// Bring UI back
	view = old_client_view
	winset(src, "paramapwindow.status_bar", "is-visible=" + old_status_bar_visible)
	mob.alpha = old_mob_alpha
	mob.hud_used?.show_hud(old_hud_version)
	mob.hud_used?.update_parallax_pref()
	mob.animate_movement = old_mob_movement

	if(exception)
		throw exception

	to_chat(usr, "Provide these values when asked for the MapTileImageTool: [width] [height] [half_chunk_size] [world.icon_size]")
