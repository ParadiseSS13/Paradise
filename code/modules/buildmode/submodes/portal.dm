/datum/buildmode_mode/portal
	key = "portal"

	var/obj/effect/portal/advanced/bmportal
	var/two_way = FALSE
	var/lifetime = 5 SECONDS
	var/portal_icon = 'icons/obj/stationobjs.dmi'
	var/portal_icon_state = "portal"
	var/turf/origin
	var/turf/destination

/datum/buildmode_mode/portal/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button     = Manually Select Origin then Destination</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button    = Quick Create Portal to a Selected Area</span>")
	to_chat(user, "<span class='notice'>Right click on tool icon to change the portal settings</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/portal/change_settings(mob/user)
	// Using a list minimizes if statements.
	var/portal_styles = list("NT Standard", "Syndicate", "Cult", "Wormhole", "Vortex")
	var/list/portal_icon_maps = list(
		"NT Standard" = list(icon = 'icons/obj/stationobjs.dmi', state = "portal"),
		"Syndicate"   = list(icon = 'icons/obj/stationobjs.dmi', state = "portal-syndicate"),
		"Cult"        = list(icon = 'icons/obj/stationobjs.dmi', state = "portal1"),
		"Wormhole"    = list(icon = 'icons/effects/effects.dmi', state = "anom"),
		"Vortex"      = list(icon = 'icons/effects/effects.dmi', state = "bhole3"))

	var/style_name = tgui_input_list(user, "Choose the style of your portals.", "Portal Style", portal_styles)
	if(style_name == null)
		to_chat(user, "<span class='warning'>Portal Style not selected, returning to defaults.</span>")
		style_name = "NT Standard"
		return
	var/selected_style = portal_icon_maps[style_name]
	portal_icon = selected_style["icon"]
	portal_icon_state = selected_style["state"]
	to_chat(user, "<span class='notice'>Portal Style set to " + style_name + "</span>")

	var/two_way_choice = tgui_alert(user, "Portal Type", "Portal Type", list("One-Way", "Two-Way"))
	if(two_way_choice == null)
		to_chat(user, "<span class='warning'>Portal Type not selected, returning to defaults.</span>")
		two_way = FALSE
		return
	two_way = (two_way_choice == "Two-Way")
	to_chat(user, "<span class='notice'>" + (two_way ? "Two-Way Portal Selected" : "One-Way Portal Selected") + "</span>")

	var/lifetime_input = tgui_input_number(user, "Select how long you want the portal to remain open for in seconds, -1 means forever. Max 999, Min 1", "Portal Duration", 5, max_value = 999, min_value = -1)
	if(lifetime_input == null)
		to_chat(user, "<span class='warning'>Portal Lifetime not selected, returning to defaults.</span>")
		lifetime = 5 SECONDS
		return
	lifetime = lifetime_input SECONDS
	to_chat(user, "<span class='notice'>Portal Lifetime set to [lifetime / 10] seconds</span>")

/datum/buildmode_mode/portal/handle_click(mob/user, params, obj/loc)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	// Left clicking will allow you to manually select origin then destination
	if(left_click)
		if(!origin)
			origin = get_turf(loc)
			to_chat(user, "<span class='notice'>Origin set to [get_area(origin)]. Left click again to set destination, or right click to cancel portal creation.</span>")
		else
			destination = get_turf(loc)
			to_chat(user, "<span class='notice'>Destination set to [get_area(destination)]</span>")
			if(origin && destination)
				create_portals(user)
				origin = null
				destination = null
	// Right clicking will quick create a portal or exit if origin is already set.
	if(right_click)
		if(origin)
			origin = null
			destination = null
			to_chat(user, "<span class='notice'>Portal creation canceled.</span>")
			return
		if(!origin)
			origin = get_turf(loc)
			to_chat(user, "Origin set for quick portal creation.</span>")
		var/destination_area = tgui_input_list(user, "Location of Destination", "Target", SSmapping.ghostteleportlocs)
		if(destination_area)
			var/possible_destinations = get_area_turfs(SSmapping.ghostteleportlocs[destination_area])
			// Filter out dense turfs
			var/list/filtered_destinations = list()
			for(var/turf/T in possible_destinations)
				if(!T.density)
					var/clear = TRUE
					for(var/obj/O in T)
						if(O.density)
							clear = FALSE
							break
					if(clear)
						filtered_destinations += T
			possible_destinations = filtered_destinations
			destination = pick(possible_destinations)
			create_portals(user)
			origin = null
			destination = null
		else
			to_chat(user, "<span class='warning'>No destination selected, aborting portal creation.</span>")
			origin = null
			destination = null
			return

// Better to have this as a proc, so we have less repeated code
/datum/buildmode_mode/portal/proc/create_portals(user)
	if(two_way)
		bmportal = new /obj/effect/portal/advanced(origin, destination, null, lifetime)
		bmportal.icon = portal_icon
		bmportal.icon_state = portal_icon_state
		// need to set the icon and state again for the second portal, alternative is making a new portal type.
		bmportal = new /obj/effect/portal/advanced(destination, origin, null, lifetime)
		bmportal.icon = portal_icon
		bmportal.icon_state = portal_icon_state
		message_admins("[key_name_admin(user)] Created a two-way portal from <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[origin.x];Y=[origin.y];Z=[origin.z]'>[get_area(origin)] (JMP)</a> to <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[destination.x];Y=[destination.y];Z=[destination.z]'>[get_area(destination)] (JMP)</a> for a duration of [lifetime / 10] seconds")
	else
		bmportal = new /obj/effect/portal/advanced(origin, destination, null, lifetime)
		bmportal.icon = portal_icon
		bmportal.icon_state = portal_icon_state
		message_admins("[key_name_admin(user)] Created a portal from <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[origin.x];Y=[origin.y];Z=[origin.z]'>[get_area(origin)] (JMP)</a> to <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[destination.x];Y=[destination.y];Z=[destination.z]'>[get_area(destination)] (JMP)</a> for a duration of [lifetime / 10] seconds")
