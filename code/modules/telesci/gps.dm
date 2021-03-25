GLOBAL_LIST_EMPTY(GPS_list)

#define EMP_DISABLE_TIME 30 SECONDS
#define POS_VECTOR(A) list(A.x, A.y, A.z)

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
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;magnets=1;bluespace=2"
	/// Whether the GPS is on.
	var/tracking = TRUE
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
	update_icon()

/obj/item/gps/Destroy()
	GLOB.GPS_list.Remove(src)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/item/gps/update_icon()
	cut_overlays()
	if(emped)
		add_overlay("emp")
	else if(tracking)
		add_overlay("working")

/obj/item/gps/emp_act(severity)
	emped = TRUE
	update_icon()
	addtimer(CALLBACK(src, .proc/reboot), EMP_DISABLE_TIME)

/obj/item/gps/AltClick(mob/user)
	if(ui_status(user, GLOB.inventory_state) != STATUS_INTERACTIVE)
		return //user not valid to use gps
	if(emped)
		to_chat(user, "<span class='warning'>It's busted!</span>")
		return

	tracking = !tracking
	update_icon()
	if(tracking)
		to_chat(user, "[src] is now tracking, and visible to other GPS devices.")
	else
		to_chat(user, "[src] is no longer tracking, or visible to other GPS devices.")
	SStgui.update_uis(src)

/obj/item/gps/ui_data(mob/user)
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
	data["position"] = POS_VECTOR(T)

	// Saved location
	if(locked_location)
		data["saved"] = POS_VECTOR(locked_location)
	else
		data["saved"] = null

	// GPS signals
	var/signals = list()
	for(var/g in GLOB.GPS_list)
		var/obj/item/gps/G = g
		var/turf/GT = get_turf(G)
		if(!GT)			//si la turf no existe no se muestra el gps
			continue 	//hispania estuvo acá
		if(!G.tracking || G == src)
			continue
		if((G.local || same_z) && (GT.z != T.z))
			continue
		var/list/signal = list("tag" = G.gpstag, "area" = null, "position" = null)
		if(!G.emped)
			signal["area"] = get_area_name(G, TRUE)
			signal["position"] = POS_VECTOR(GT)
		signals += list(signal)
	data["signals"] = signals

	return data

/obj/item/gps/attack_self(mob/user)
	ui_interact(user)

/obj/item/gps/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "GPS", "GPS", 450, 700)
		ui.open()

/obj/item/gps/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("tag")
			var/newtag = params["newtag"] || ""
			newtag = uppertext(paranoid_sanitize(copytext(newtag, 1, 5)))
			if(!length(newtag) || gpstag == newtag)
				return
			gpstag = newtag
			name = "global positioning system ([gpstag])"
		if("toggle")
			AltClick(usr)
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
	update_icon()

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

/obj/item/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."
	flags = NODROP

/obj/item/gps/internal
	icon_state = null
	flags = ABSTRACT
	local = TRUE
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
	while(tagged.len)
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
#undef POS_VECTOR
