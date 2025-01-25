/datum/buildmode_mode/portal
	key = "portal"

	var/obj/effect/portal/advanced/bmportal
	var/two_way = FALSE
	var/lifetime = 10 SECONDS
	var/portal_icon = 'icons/obj/stationobjs.dmi'
	var/portal_icon_state = "portal"
	var/turf/origin
	var/turf/destination

/datum/buildmode_mode/portal/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button        = Manually Select Origin then Destination</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button       = Quick Create Portal to a Selected Area</span>")
	to_chat(user, "<span class='notice'>Right click on tool icon to change the portal settings</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/portal/change_settings(mob/user)
	var/twoway_select = null
	var/lifetime_select = null
	var/style_select = null
	var/portal_styles = list("NT Standard", "Syndicate", "Cult", "Wormhole", "Vortex")
	var/list/portal_icon_maps = list( // It was either this or a mass of if statements, this is easier on the eyes.
		"NT Standard" = list(icon = 'icons/obj/stationobjs.dmi', state = "portal"),
		"Syndicate" = list(icon = 'icons/obj/stationobjs.dmi', state = "portal-syndicate"),
		"Cult" = list(icon = 'icons/obj/stationobjs.dmi', state = "portal1"),
		"Wormhole" = list(icon = 'icons/effects/effects.dmi', state = "anom"),
		"Vortex" = list(icon = 'icons/effects/effects.dmi', state = "bhole3"))

	style_select = tgui_input_list(user, "Choose the style of your portals.", "Portal Style", portal_styles)
	var/selected_portal = portal_icon_maps[style_select]
	if(selected_portal)
		portal_icon = selected_portal["icon"] // DM brings me pain, a LOT of guessing went into this.
		portal_icon_state = selected_portal["state"]
		to_chat(user, "<span class='notice'>Portal Style set to [style_select]</span>")
	else
		// Default to NT Standard
		portal_icon = 'icons/obj/stationobjs.dmi'
		portal_icon_state = "portal"
		to_chat(user, "<span class='warning'>Invalid portal style selected. Defaulting to Blue.</span>")

	// User has a choice of a way way portal or two-way.
	twoway_select = tgui_alert(user, "Portal Type", "Portal Type", list("One-Way", "Two-Way"))
	if(twoway_select == "Two-Way")
		two_way = TRUE
		to_chat(user, "<span class='notice'>Two-Way Portal Selected</span>")
	else
		two_way = FALSE
		to_chat(user, "<span class='notice'>One-Way Portal Selected</span>")

	// Duration for the portal to remain open for, 0 means infinite duration.
	lifetime_select = tgui_input_number(user, "Select how long you want the portal to remain open for in seconds, -1 means forever.", "Portal Duration", 10 , max_value = 60 SECONDS, min_value = -1 SECONDS)
	if(lifetime_select)
		lifetime = lifetime_select SECONDS
		to_chat(user, "<span class='notice'>Portal Lifetime set to [lifetime_select] seconds</span>")
		if (lifetime_select == -1)
			to_chat(user, "<span class='notice'>Portal Lifetime set to forever</span>")
	else // Default to 10 seconds
		lifetime = 10 SECONDS
		to_chat(user, "<span class='notice'>Portal Lifetime defaulted to 10 seconds</span>")

/datum/buildmode_mode/portal/handle_click(mob/user, params, obj/loc)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(left_click)
		if(!origin)
			origin = get_turf(loc)
			to_chat(user, "<span class='notice'>Origin set to [get_area(origin)].</span>")
		else
			destination = get_turf(loc)
			to_chat(user, "<span class='notice'>Destination set to [destination]</span>")
			if(origin && destination)
				if(two_way)
					bmportal = new /obj/effect/portal/advanced(origin, destination, null, lifetime)
					bmportal.icon = portal_icon
					bmportal.icon_state = portal_icon_state
					bmportal = new /obj/effect/portal/advanced(destination, origin, null, lifetime)
					bmportal.icon = portal_icon // second portal was always blue, this might fix it?
					bmportal.icon_state = portal_icon_state
					message_admins("[key_name_admin(user)] Created a two-way portal from <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[origin.x];Y=[origin.y];Z=[origin.z]'>[get_area(origin)] (JMP)</a> to <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[destination.x];Y=[destination.y];Z=[destination.z]'>[get_area(destination)] (JMP)</a> for a duration of [lifetime/10] seconds.")
				else
					bmportal = new /obj/effect/portal/advanced(origin, destination, null, lifetime)
					bmportal.icon = portal_icon
					bmportal.icon_state = portal_icon_state
					message_admins("[key_name_admin(user)] Created a portal from <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[origin.x];Y=[origin.y];Z=[origin.z]'>[get_area(origin)] (JMP)</a> to <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[destination.x];Y=[destination.y];Z=[destination.z]'>[get_area(destination)] (JMP)</a> for a duration of [lifetime/10] seconds.")
				origin = null
				destination = null


	if(right_click)
		if(!origin)
			origin = get_turf(loc)
			to_chat(user, "Origin set for quick portal creation.</span>")
		var/destination_area = tgui_input_list(user, "Location of Destination", "Target", SSmapping.ghostteleportlocs)
		if(destination_area)
			var/possible_destinations = get_area_turfs(SSmapping.ghostteleportlocs[destination_area])
			destination = pick(possible_destinations)
			if(origin && destination)
				if(two_way)
					bmportal = new /obj/effect/portal/advanced(origin, destination, null, lifetime)
					bmportal.icon = portal_icon
					bmportal.icon_state = portal_icon_state
					bmportal = new /obj/effect/portal/advanced(destination, origin, null, lifetime)
					bmportal.icon = portal_icon
					bmportal.icon_state = portal_icon_state
					message_admins("[key_name_admin(user)] Created a two-way portal from <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[origin.x];Y=[origin.y];Z=[origin.z]'>[get_area(origin)] (JMP)</a> to <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[destination.x];Y=[destination.y];Z=[destination.z]'>[get_area(destination)] (JMP)</a> for a duration of [lifetime/10] seconds.")
				else
					bmportal = new /obj/effect/portal/advanced(origin, destination, null, lifetime)
					bmportal.icon = portal_icon
					bmportal.icon_state = portal_icon_state
					message_admins("[key_name_admin(user)] Created a portal from <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[origin.x];Y=[origin.y];Z=[origin.z]'>[get_area(origin)] (JMP)</a> to <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[destination.x];Y=[destination.y];Z=[destination.z]'>[get_area(destination)] (JMP)</a> for a duration of [lifetime/10] seconds.")
				origin = null
				destination = null
		else
			to_chat(user, "<span class='warning'>No destination selected, aborting portal creation.</span>")
			origin = null
			destination = null
			return
