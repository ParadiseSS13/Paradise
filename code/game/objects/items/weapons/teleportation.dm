/* Teleportation devices.
 * Contains:
 *		Locator
 *		Hand-tele
 */

/*
 * Locator
 */
/obj/item/weapon/locator
	name = "locator"
	desc = "Used to track those with locater implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/temp = null
	var/frequency = 1451
	var/broadcasting = null
	var/listening = 1.0
	flags = CONDUCT
	w_class = 2
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=400)
	origin_tech = "magnets=1"

/obj/item/weapon/locator/attack_self(mob/user as mob)
	add_fingerprint(usr)
	var/dat
	if(temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=[UID()];temp=1'>Clear</A>"
	else
		dat = {"
<B>Persistent Signal Locator</B><HR>
Frequency:
<A href='byond://?src=[UID()];freq=-10'>-</A>
<A href='byond://?src=[UID()];freq=-2'>-</A> [format_frequency(src.frequency)]
<A href='byond://?src=[UID()];freq=2'>+</A>
<A href='byond://?src=[UID()];freq=10'>+</A><BR>

<A href='?src=[UID()];refresh=1'>Refresh</A>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/locator/Topic(href, href_list)
	if(..())
		return 1

	var/turf/current_location = get_turf(usr)//What turf is the user on?
	if(!current_location || is_admin_level(current_location.z))//If turf was not found or they're in the admin zone
		to_chat(usr, "<span class='warning'>\The [src] is malfunctioning.</span>")
		return 1

	if(href_list["refresh"])
		temp = "<B>Persistent Signal Locator</B><HR>"
		var/turf/sr = get_turf(src)

		if(sr)
			temp += "<B>Located Beacons:</B><BR>"

			for(var/obj/item/device/radio/beacon/W in beacons)
				if(W.frequency == frequency && !W.syndicate)
					if(W && W.z == z)
						var/turf/TB = get_turf(W)
						temp += "[W.code]: [TB.x], [TB.y], [TB.z]<BR>"

			temp += "<B>Located Implants:</B><BR>"
			for(var/obj/item/weapon/implant/tracking/T in tracked_implants)
				if(!T.implanted || !T.imp_in)
					continue

				if(T && T.z == z)
					temp += "[T.id]: [T.imp_in.x], [T.imp_in.y], [T.imp_in.z]<BR>"

			temp += "<B>You are at \[[sr.x],[sr.y],[sr.z]\]</B>."
			temp += "<BR><BR><A href='byond://?src=[UID()];refresh=1'>Refresh</A><BR>"
		else
			temp += "<B><FONT color='red'>Processing error:</FONT></B> Unable to locate orbital position.<BR>"
	else
		if(href_list["freq"])
			frequency += text2num(href_list["freq"])
			frequency = sanitize_frequency(frequency)
		else
			if(href_list["temp"])
				temp = null

	attack_self(usr)
	return 1

/*
 * Hand-tele
 */
/obj/item/weapon/hand_tele
	name = "hand tele"
	desc = "A portable item using blue-space technology."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 0
	w_class = 2
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000)
	origin_tech = "magnets=1;bluespace=3"
	var/active_portals = 0

/obj/item/weapon/hand_tele/attack_self(mob/user as mob)
	var/turf/current_location = get_turf(user)//What turf is the user on?
	if(!current_location||!is_teleport_allowed(current_location.z))//If turf was not found or they're somewhere teleproof
		to_chat(user, "<span class='notice'>\The [src] is malfunctioning.</span>")
		return
	var/list/L = list(  )
	for(var/obj/machinery/computer/teleporter/com in world)
		if(com.target)
			if(com.power_station && com.power_station.teleporter_hub && com.power_station.engaged)
				L["[com.id] (Active)"] = com.target
			else
				L["[com.id] (Inactive)"] = com.target
	var/list/turfs = list(	)
	var/area/A
	for(var/turf/T in orange(10))
		if(T.x>world.maxx-8 || T.x<8)	continue	//putting them at the edge is dumb
		if(T.y>world.maxy-8 || T.y<8)	continue
		A = get_area(T)
		if(A.tele_proof == 1) continue // Telescience-proofed areas require a beacon.
		turfs += T
	if(turfs.len)
		L["None (Dangerous)"] = pick(turfs)
	var/t1 = input(user, "Please select a teleporter to lock in on.", "Hand Teleporter") as null|anything in L
	if(!t1 || (user.get_active_hand() != src || user.stat || user.restrained()))
		return
	if(active_portals >= 3)
		user.show_message("<span class='notice'>\The [src] is recharging!</span>")
		return
	var/T = L[t1]
	user.show_message("<span class='notice'>Locked In.</span>", 2)
	var/obj/effect/portal/P = new /obj/effect/portal(get_turf(src), T, src)
	try_move_adjacent(P)
	active_portals++
	add_fingerprint(user)
	return
