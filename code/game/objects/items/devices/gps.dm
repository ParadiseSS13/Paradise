var/list/sps_list = list()
/obj/item/device/sps
	name = "space positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = 2.0
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;magnets=3;bluespace=2"
	var/spstag = "COM0"
	var/emped = 0
	var/turf/locked_location

/obj/item/device/sps/New()
	..()
	sps_list.Add(src)
	name = "space positioning system ([spstag])"
	overlays += "working"

/obj/item/device/sps/Destroy()
	sps_list.Remove(src)
	..()

/obj/item/device/sps/emp_act(severity)
	emped = 1
	overlays -= "working"
	overlays += "emp"
	spawn(300)
		emped = 0
		overlays -= "emp"
		overlays += "working"

/obj/item/device/sps/attack_self(mob/user as mob)

	var/obj/item/device/sps/t = ""
	var/sps_window_height = 110 + sps_list.len * 20 // Variable window height, depending on how many sps units there are to show
	if(emped)
		t += "ERROR"
	else
		t += "<A href='?src=\ref[src];tag=1'>Set Tag</A><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		t += "<BR>Tag: [spstag]"
		if(locked_location && locked_location.loc)
			t += "<BR>Bluespace coordinates saved: [locked_location.loc]"
			sps_window_height += 20

		for(var/obj/item/device/sps/G in sps_list)
			var/turf/pos = get_turf(G)
			var/area/sps_area = get_area(G)
			var/tracked_spstag = G.spstag
			if(G.emped == 1)
				t += "<BR>[tracked_spstag]: ERROR"
			else
				t += "<BR>[tracked_spstag]: [format_text(sps_area.name)] ([pos.x], [pos.y], [pos.z])"

	var/datum/browser/popup = new(user, "sps", name, 360, min(sps_window_height, 800))
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/sps/Topic(href, href_list)
	..()
	if(href_list["tag"] )
		var/a = input("Please enter desired tag.", name, spstag) as text
		a = uppertext(copytext(sanitize(a), 1, 5))
		if(src.loc == usr)
			spstag = a
			name = "space positioning system ([spstag])"
			attack_self(usr)
	if(href_list["refresh"] )
		if(src.loc == usr)
			attack_self(usr)

/obj/item/device/sps/science
	icon_state = "gps-s"
	spstag = "SCI0"

/obj/item/device/sps/engineering
	icon_state = "gps-e"
	spstag = "ENG0"

/obj/item/device/sps/mining
	icon_state = "gps-m"
	spstag = "MINE0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."
