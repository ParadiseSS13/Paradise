USER_VERB(mass_screenshot, R_DEBUG, "Mass Screenshot", "Take a sliced screenshot of a z-level.", VERB_CATEGORY_DEBUG)
	set waitfor = FALSE

	if(!client.mob)
		return

	var/mob/mob = client.mob

	var/confirmation = tgui_alert(
		client,
		"Are you sure you want to mass screenshot this z-level? \
		Ensure you have emptied your BYOND screenshots folder.",
		"Mass Screenshot",
		list("Yes", "No")
	)
	if(confirmation != "Yes")
		return

	var/sleep_duration = tgui_input_number(
		client,
		"Enter a delay in deciseconds between screenshots to allow the client to render changes.",
		"Screenshot delay",
		default = 2, max_value = 10, min_value = 1, round_value = TRUE
	)
	if(!sleep_duration)
		return

	if(!isobserver(mob))
		SSuser_verbs.invoke_verb(client, /datum/user_verb/admin_ghost)

	message_admins("[key_name(client)] started a mass screenshot operation")

	// Prepare for screenshot
	var/old_client_view = client.view
	var/old_status_bar_visible = winget(client, "menu.statusbar", "is-checked") == "false" ? "true" : "false"
	var/old_hud_version = mob.hud_used ? mob.hud_used.hud_version : HUD_STYLE_NOHUD
	var/old_mob_alpha = mob.alpha
	var/old_mob_movement = mob.animate_movement

	client.view = 15
	winset(client, "paramapwindow.status_bar", "is-visible=false")
	mob.hud_used?.show_hud(HUD_STYLE_NOHUD)
	mob.hud_used?.remove_parallax()
	mob.alpha = 0
	mob.animate_movement = NO_STEPS

	var/half_chunk_size = client.view + 1
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
				winset(client, null, "command='.screenshot auto'")
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
	client.view = old_client_view
	winset(client, "paramapwindow.status_bar", "is-visible=" + old_status_bar_visible)
	mob.alpha = old_mob_alpha
	mob.hud_used?.show_hud(old_hud_version)
	mob.hud_used?.update_parallax_pref()
	mob.animate_movement = old_mob_movement

	if(exception)
		throw exception

	to_chat(client, "Provide these values when asked for the MapTileImageTool: [width] [height] [half_chunk_size] [world.icon_size]")
