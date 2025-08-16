GLOBAL_LIST_EMPTY(GPS_list)

#define EMP_DISABLE_TIME 30 SECONDS

/**
  * # GPS
  *
  * A small item that reports its current location. Has a tag to help distinguish between them.
  */
/obj/item/gps
	name = "default gps"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "materials=2;magnets=1;bluespace=2"
	/// Whether the GPS is on.
	var/tracking = FALSE
	/// The tag that is visible to other GPSes.
	var/gpstag = "COM0"
	/// Whether to only list signals that are on the same Z-level.
	var/same_z = FALSE
	/// Whether the GPS should only show up to GPSes on the same Z-level.
	var/local = FALSE
	/// Whether the GPS is EMPed, disabling it temporarily.
	var/emped = FALSE
	/// Turf reference. If set, it will appear in the UI. Used by [/obj/machinery/computer/telescience].
	var/turf/locked_location

/obj/item/gps/Initialize(mapload)
	. = ..()
	GLOB.GPS_list.Add(src)
	GLOB.poi_list.Add(src)
	if(name == initial(name))
		name = "global positioning system ([gpstag])"
	update_icon(UPDATE_OVERLAYS)

/obj/item/gps/Destroy()
	GLOB.GPS_list.Remove(src)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/item/gps/update_overlays()
	. = ..()
	if(emped)
		. += "emp"
	else if(tracking)
		. += "working"

/obj/item/gps/pickup(mob/user)
	..()
	ADD_TRAIT(user, TRAIT_HAS_GPS, "GPS[UID()]")

/obj/item/gps/dropped(mob/user, silent)
	REMOVE_TRAIT(user, TRAIT_HAS_GPS, "GPS[UID()]")
	REMOVE_TRAIT(user, TRAIT_CAN_VIEW_HEALTH, "HEALTH[UID()]")
	return ..()

/obj/item/gps/emp_act(severity)
	emped = TRUE
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(reboot)), EMP_DISABLE_TIME)

/obj/item/gps/AltClick(mob/user, state)
	if(ui_status(user, state) != UI_INTERACTIVE)
		return //user not valid to use gps
	if(emped)
		to_chat(user, "<span class='warning'>It's busted!</span>")
		return

	tracking = !tracking
	update_icon(UPDATE_OVERLAYS)
	if(tracking)
		to_chat(user, "[src] is now tracking, and visible to other GPS devices.")
	else
		to_chat(user, "[src] is no longer tracking, or visible to other GPS devices.")
	SStgui.update_uis(src)

/obj/item/gps/ui_data(mob/user)
	var/list/mining_zlevels = levels_by_trait(ORE_LEVEL)
	var/list/data = list()
	if(emped)
		data["emped"] = TRUE
		return data

	// General
	data["active"] = tracking
	data["tag"] = gpstag
	data["same_z"] = same_z
	if(!tracking)
		return data
	var/turf/T = get_turf(src)
	data["area"] = get_area_name(src, TRUE)
	data["position"] = ATOM_COORDS(T)

	// Saved location
	if(locked_location)
		data["saved"] = ATOM_COORDS(locked_location)
	else
		data["saved"] = null

	// GPS signals
	var/signals = list()
	for(var/g in GLOB.GPS_list)
		var/obj/item/gps/G = g
		var/turf/GT = get_turf(G)
		if(isnull(GT) || !G.tracking || G == src)
			continue

		// If both signals are on lavaland, we don't skip them, because we want
		// to have some indication of where lavaland sector bridges are, which
		// we do by providing a directional arrow, without distance, in the GPS UI.
		var/both_lavaland = (T.z in mining_zlevels) && (G.z in mining_zlevels)
		if((!both_lavaland) && (G.local || same_z) && (GT.z != T.z))
			continue

		var/list/signal = list("tag" = G.gpstag, "area" = null, "position" = null)
		if(!G.emped)
			signal["area"] = get_area_name(G, TRUE)
			signal["position"] = ATOM_COORDS(GT)

			if(both_lavaland && T.z != GT.z)
				var/bridge_direction = SSmapping.lavaland_theme.get_bridge_direction(GT.z, T.z)
				if(bridge_direction)
					signal["due"] = dir2angle(text2num(bridge_direction))

		signals += list(signal)
	data["signals"] = signals

	return data

/obj/item/gps/attack_self__legacy__attackchain(mob/user)
	ui_interact(user)

/obj/item/gps/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/gps/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GPS", "GPS")
		ui.open()

/obj/item/gps/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	switch(action)
		if("tag")
			var/newtag = params["newtag"] || ""
			newtag = uppertext(paranoid_sanitize(copytext_char(newtag, 1, 5)))
			if(!length(newtag) || gpstag == newtag)
				return
			gpstag = newtag
			name = "global positioning system ([gpstag])"
		if("toggle")
			AltClick(usr, state)
			return FALSE
		if("same_z")
			same_z = !same_z
		else
			return FALSE

/**
  * Turns off the GPS's EMPed state. Called automatically after an EMP.
  */
/obj/item/gps/proc/reboot()
	emped = FALSE
	update_icon(UPDATE_OVERLAYS)

/obj/item/gps/security
	icon_state = "gps-sec"
	gpstag = "SEC0"
	desc = "A positioning system helpful for monitoring prisoners that are implanted with a tracking implant."
	local = TRUE

/obj/item/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/gps/mining
	icon_state = "gps-m"
	gpstag = "MINE0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/gps/mod
	icon_state = "gps-m"
	gpstag = "MOD0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, after you have become lost from rolling around at the speed of sound."

/obj/item/gps/mod/ui_state()
	return GLOB.deep_inventory_state

/obj/item/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."
	flags = NODROP
	tracking = TRUE

/obj/item/gps/internal
	icon_state = null
	flags = ABSTRACT
	local = TRUE
	tracking = TRUE
	gpstag = "Eerie Signal"
	desc = "Report to a coder immediately."
	invisibility = INVISIBILITY_MAXIMUM

/obj/item/gps/internal/mining
	icon_state = "gps-m"
	gpstag = "MINER"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/gps/internal/base
	gpstag = "NT_AUX"
	desc = "A homing signal from Nanotrasen's mining base."

/obj/item/gps/visible_debug
	name = "visible GPS"
	gpstag = "ADMIN"
	desc = "This admin-spawn GPS unit leaves the coordinates visible \
		on any turf that it passes over, for debugging. Especially useful \
		for marking the area around the transition edges."
	tracking = TRUE
	var/list/turf/tagged

/obj/item/gps/visible_debug/Initialize(mapload)
	. = ..()
	tagged = list()
	START_PROCESSING(SSfastprocess, src)

/obj/item/gps/visible_debug/process()
	var/turf/T = get_turf(src)
	if(T)
		// I assume it's faster to color,tag and OR the turf in, rather
		// then checking if its there
		T.color = RANDOM_COLOUR
		T.maptext = "[T.x],[T.y],[T.z]"
		tagged |= T

/obj/item/gps/visible_debug/proc/clear()
	while(length(tagged))
		var/turf/T = pop(tagged)
		T.color = initial(T.color)
		T.maptext = initial(T.maptext)

/obj/item/gps/visible_debug/Destroy()
	if(tagged)
		clear()
	tagged = null
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

#undef EMP_DISABLE_TIME
