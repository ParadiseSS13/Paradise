/* Teleportation devices.
 * Contains:
 *		Locator
 *		Hand-tele
 */

/*
 * Locator
 */
/obj/item/locator
	name = "locator"
	desc = "Used to track those with locater implants."
	icon = 'icons/obj/implants.dmi'
	icon_state = "locator"
	var/temp = null
	var/frequency = 1451
	var/broadcasting = FALSE
	var/listening = TRUE
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=400)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, RAD = 0, FIRE = 100, ACID = 100)
	origin_tech = "magnets=3;bluespace=2"

/obj/item/locator/attack_self(mob/user as mob)
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

/obj/item/locator/Topic(href, href_list)
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

			for(var/obj/item/radio/beacon/W in GLOB.beacons)
				if(W.frequency == frequency && !W.syndicate)
					if(W && W.z == z)
						var/turf/TB = get_turf(W)
						temp += "[W.code]: [TB.x], [TB.y], [TB.z]<BR>"

			temp += "<B>Located Implants:</B><BR>"
			for(var/obj/item/implant/tracking/T in GLOB.tracked_implants)
				if(!T.implanted || !T.imp_in)
					continue
				var/turf/Tr = get_turf(T)

				if(Tr && Tr.z == sr.z)
					temp += " [Tr.x], [Tr.y], [Tr.z]<BR>"

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
/obj/item/hand_tele
	name = "hand tele"
	desc = "A portable item using bluespace technology."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000)
	origin_tech = "magnets=3;bluespace=4"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/icon_state_inactive = "hand_tele_inactive"
	var/active_portals = 0
	/// Variable contains next time hand tele can be used to make it not EMP proof
	var/emp_timer = 0

/obj/item/hand_tele/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(alert_admins_on_destroy))

/obj/item/hand_tele/attack_self(mob/user)
	var/turf/current_location = get_turf(user)//What turf is the user on?
	if(emp_timer > world.time)
		do_sparks(5, 0, loc)
		to_chat(user, "<span class='warning'>[src] attempts to create a portal, but abruptly shuts off.</span>")
		return
	if(!current_location||!is_teleport_allowed(current_location.z))//If turf was not found or they're somewhere teleproof
		to_chat(user, "<span class='notice'>\The [src] is malfunctioning.</span>")
		return
	var/list/L = list(  )
	for(var/obj/machinery/computer/teleporter/com in GLOB.machines)
		if(com.target)
			if(com.power_station && com.power_station.teleporter_hub && com.power_station.engaged)
				L["[com.id] (Active)"] = com.target
			else
				L["[com.id] (Inactive)"] = com.target
	var/list/turfs = list(	)
	var/area/A
	for(var/turf/T in orange(10))
		if(T.x>world.maxx-8 || T.x<8)
			continue	//putting them at the edge is dumb
		if(T.y>world.maxy-8 || T.y<8)
			continue
		A = get_area(T)
		if(A.tele_proof)
			continue // Telescience-proofed areas require a beacon.
		turfs += T
	if(turfs.len)
		L["None (Dangerous)"] = pick(turfs)
	var/t1 = input(user, "Please select a teleporter to lock in on.", "Hand Teleporter") as null|anything in L
	if(!t1 || (!user.is_in_active_hand(src) || user.stat || user.restrained()))
		return
	if(active_portals >= 3)
		user.show_message("<span class='notice'>\The [src] is recharging!</span>")
		return
	var/T = L[t1]
	user.show_message("<span class='notice'>Locked In.</span>", 2)
	var/obj/effect/portal/P = new /obj/effect/portal/hand_tele(get_turf(src), T, src, creation_mob = user)
	try_move_adjacent(P)
	active_portals++
	add_fingerprint(user)

/obj/item/hand_tele/emp_act(severity)
	make_inactive(severity)
	return ..()

/obj/item/hand_tele/proc/make_inactive(severity)
	icon_state = icon_state_inactive
	var/time = rand(25 SECONDS, 30 SECONDS) * severity
	emp_timer = world.time + time
	addtimer(CALLBACK(src, PROC_REF(check_inactive), emp_timer), time)

/obj/item/hand_tele/proc/check_inactive(current_emp_timer)
	if(emp_timer != current_emp_timer)
		return
	icon_state = initial(icon_state)

/obj/item/hand_tele/examine(mob/user)
	. = ..()
	if(emp_timer > world.time)
		. += "<span class='warning'>It looks inactive.</span>"

/obj/item/hand_tele/portal_destroyed(obj/effect/portal/P)
	active_portals--
