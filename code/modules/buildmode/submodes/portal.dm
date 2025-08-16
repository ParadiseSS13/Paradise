/datum/buildmode_mode/portal
	key = "portal"

	var/obj/effect/portal/advanced/bmportal
	var/two_way = FALSE
	var/lifetime = 5 SECONDS
	var/portal_icon = 'icons/obj/stationobjs.dmi'
	var/portal_icon_state = "portal"
	var/turf/origin
	var/turf/destination
	var/image/portal_origin_overlay

/datum/buildmode_mode/portal/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button       = Set origin then a destination to create a portal/s</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button      = Quick create portal to an area of choice</span>")
	to_chat(user, "<span class='notice'>Alt + Left Mouse Button = Alt+Click on any portal to close it</span>")
	to_chat(user, "<span class='notice'>Right click on tool icon= Change portal settings</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

// Allows user to change portal settings like style, type, and lifetime.
/datum/buildmode_mode/portal/change_settings(mob/user)
	var/portal_styles = list("NT Standard", "Syndicate", "Cult", "Wormhole", "Vortex")
	var/list/portal_icon_maps = list(
		"NT Standard" = list(icon = 'icons/obj/stationobjs.dmi', state = "portal"),
		"Syndicate"   = list(icon = 'icons/obj/stationobjs.dmi', state = "portal-syndicate"),
		"Cult"        = list(icon = 'icons/obj/stationobjs.dmi', state = "portal1"),
		"Wormhole"    = list(icon = 'icons/effects/effects.dmi', state = "anom"),
		"Vortex"      = list(icon = 'icons/effects/effects.dmi', state = "bhole3")
	)
	var/style_name = tgui_input_list(user, "Choose the style of your portals.", "Portal Style", portal_styles)
	if(style_name == null)
		to_chat(user, "<span class='warning'>Portal Style not selected, returning to defaults.</span>")
		style_name = "NT Standard"
		return
	var/selected_style = portal_icon_maps[style_name]
	portal_icon = selected_style["icon"]
	portal_icon_state = selected_style["state"]
	to_chat(user, "<span class='notice'>Portal Style set to [style_name]</span>")

	var/two_way_choice = tgui_alert(user, "Portal Type", "Portal Type", list("One-Way", "Two-Way"))
	if(two_way_choice == null)
		to_chat(user, "<span class='warning'>Portal Type not selected, returning to defaults.</span>")
		two_way = FALSE
		return
	two_way = (two_way_choice == "Two-Way")
	if(two_way)
		to_chat(user, "<span class='notice'>Two-Way Portal Selected</span>")
	else
		to_chat(user, "<span class='notice'>One-Way Portal Selected</span>")

	var/lifetime_input = tgui_input_number(user, "Select portal duration in seconds (-1 for forever, Min 1, Max 999)", "Portal Duration", 5, max_value = 999, min_value = -1)
	if(lifetime_input == null)
		to_chat(user, "<span class='warning'>Portal Lifetime not selected, returning to defaults.</span>")
		lifetime = 5 SECONDS
		return
	lifetime = lifetime_input SECONDS
	to_chat(user, "<span class='notice'>Portal Lifetime set to [lifetime_input] seconds</span>")

// Handles user click interactions for setting portal origin and destination, or deleting portals.
/datum/buildmode_mode/portal/handle_click(mob/user, params, obj/loc)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/alt_click = pa.Find("alt")

	if(left_click && alt_click)
		if(istype(loc, /obj/effect/portal))
			message_admins("[key_name(user)] closed a portal at [get_area(loc)]")
			qdel(loc)
		return
	else if(left_click)
		if(!origin)
			origin = get_turf(loc)
			portal_origin_overlay = image(icon = portal_icon, loc = origin, icon_state = portal_icon_state)
			portal_origin_overlay.color = "#15d12d"
			user.client.images += portal_origin_overlay
			to_chat(user, "<span class='notice'>Origin set to [get_area(origin)] Left click again for destination or right click to cancel.</span>")
		else
			destination = get_turf(loc)
			to_chat(user, "<span class='notice'>Destination set to [get_area(destination)]</span>")
			if(origin && destination)
				process_portals(user)
				reset_portal_selection(user)
	else if(right_click)
		if(origin)
			reset_portal_selection(user)
			to_chat(user, "<span class='notice'>Portal creation canceled.</span>")
			return
		quick_create_portal(user, loc)

// Quickly creates a portal using the clicked location and user input for destination area.
/datum/buildmode_mode/portal/proc/quick_create_portal(mob/user, obj/loc)
	origin = get_turf(loc)
	portal_origin_overlay = image(icon = portal_icon, loc = origin, icon_state = portal_icon_state)
	portal_origin_overlay.color = "#15d12d"
	user.client.images += portal_origin_overlay
	to_chat(user, "Origin set for quick portal creation.")
	var/destination_area = tgui_input_list(user, "Location of Destination", "Target", SSmapping.ghostteleportlocs)
	if(destination_area)
		var/possible_destinations = get_area_turfs(SSmapping.ghostteleportlocs[destination_area])
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
		destination = pick(filtered_destinations)
		process_portals(user)
	else
		to_chat(user, "<span class='warning'>No destination selected, aborting portal creation.</span>")
	reset_portal_selection(user)

// Processes portal creation by spawning portals and with feedback for admins.
/datum/buildmode_mode/portal/proc/process_portals(user)
	if(two_way)
		spawn_portal(origin, destination, user)
		spawn_portal(destination, origin, user)
		message_admins("[key_name_admin(user)] Created two-way portals from [get_area(origin)][ADMIN_COORDJMP(origin)] to [get_area(destination)][ADMIN_COORDJMP(destination)] for [lifetime / 10] seconds")
	else
		spawn_portal(origin, destination, user)
		message_admins("[key_name_admin(user)] Created a portal from [get_area(origin)][ADMIN_COORDJMP(origin)] to [get_area_name(destination)][ADMIN_COORDJMP(destination)] for [lifetime / 10] seconds")

// Resets the portal selection, clearing stored origin, destination and overlay.
/datum/buildmode_mode/portal/proc/reset_portal_selection(mob/user)
	origin = null
	destination = null
	remove_origin_overlay(user)

// Spawns a portal between given origin and destination.
/datum/buildmode_mode/portal/proc/spawn_portal(turf/origin, turf/destination, mob/user)
	var/obj/effect/portal/advanced/bmportal = new /obj/effect/portal/advanced(origin, destination, null, lifetime)
	bmportal.admin_spawned = TRUE
	bmportal.icon = portal_icon
	bmportal.icon_state = portal_icon_state
	return bmportal

// Removes the origin overlay image from the user's client.
/datum/buildmode_mode/portal/proc/remove_origin_overlay(mob/user)
	if(portal_origin_overlay)
		user.client.images -= portal_origin_overlay
		portal_origin_overlay = null

// should buildmode be exited clear the users overlays should they have any.
/datum/buildmode_mode/portal/Destroy()
	if(portal_origin_overlay)
		usr.client.images -= portal_origin_overlay
		portal_origin_overlay = null
	..()
