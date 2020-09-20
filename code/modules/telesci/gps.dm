GLOBAL_LIST_EMPTY(GPS_list)
/obj/item/gps
	name = "default gps"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;magnets=1;bluespace=2"
	var/gpstag = "COM0"
	var/emped = 0
	var/turf/locked_location
	var/tracking = TRUE
	var/local = FALSE	//local gps show up only to gps on same z level

/obj/item/gps/New()
	..()
	GLOB.GPS_list.Add(src)
	GLOB.poi_list.Add(src)
	if(name == "default gps")	//use default naming scheme
		name = "global positioning system ([gpstag])"
	overlays += "working"

/obj/item/gps/Destroy()
	GLOB.GPS_list.Remove(src)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/item/gps/emp_act(severity)
	emped = 1
	overlays -= "working"
	overlays += "emp"
	addtimer(CALLBACK(src, .proc/reboot), 300)

/obj/item/gps/proc/reboot()
	emped = FALSE
	overlays -= "emp"
	overlays += "working"

/obj/item/gps/AltClick(mob/user)
	if(CanUseTopic(user, GLOB.inventory_state) != STATUS_INTERACTIVE)
		return 1 //user not valid to use gps
	if(emped)
		to_chat(user, "<span class='warning'>It's busted!</span>")
	if(tracking)
		overlays -= "working"
		to_chat(user, "[src] is no longer tracking, or visible to other GPS devices.")
		tracking = FALSE
	else
		overlays += "working"
		to_chat(user, "[src] is now tracking, and visible to other GPS devices.")
		tracking = TRUE

/obj/item/gps/attack_self(mob/user as mob)
	if(!tracking)
		to_chat(user, "<span class='warning'>[src] is turned off. Use alt+click to toggle it back on.</span>")
		return

	var/obj/item/gps/t = ""
	var/gps_window_height = 110 + GLOB.GPS_list.len * 20 // Variable window height, depending on how many GPS units there are to show
	if(emped)
		t += "ERROR"
	else
		t += "<BR><A href='?src=[UID()];tag=1'>Set Tag</A> "
		t += "<BR>Tag: [gpstag]"
		if(locked_location && locked_location.loc)
			t += "<BR>Bluespace coordinates saved: [locked_location.loc]"
			gps_window_height += 20

		var/turf/own_pos = get_turf(src)
		var/own_z = own_pos.z
		for(var/obj/item/gps/G in GLOB.GPS_list)
			var/turf/pos = get_turf(G)
			var/area/gps_area = get_area(G)
			var/tracked_gpstag = G.gpstag
			if(G.emped == 1)
				t += "<BR>[tracked_gpstag]: ERROR"
			else if(G.tracking && (!G.local || (own_z == pos.z)))
				t += "<BR>[tracked_gpstag]: [format_text(gps_area.name)] ([pos.x], [pos.y], [pos.z])"
			else
				continue

	var/datum/browser/popup = new(user, "GPS", name, 360, min(gps_window_height, 800))
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/gps/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["tag"] )
		var/tag = input("Please enter desired tag.", name, gpstag) as text|null
		if(!tag || ..())
			return TRUE

		tag = uppertext(sanitize(copytext(tag, 1, 5)))
		gpstag = tag
		name = "global positioning system ([gpstag])"
		attack_self(usr)

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
