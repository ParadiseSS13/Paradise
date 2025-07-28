/* Teleportation devices.
 * Contains:
 *		Hand-tele
 */

/*
 * Hand-tele
 */
/obj/item/hand_tele
	name = "hand tele"
	desc = "An experimental portable teleportation station developed by Nanotrasen, small enough to be carried in a pocket."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	worn_icon_state = "electronic"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000)
	origin_tech = null
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/icon_state_inactive = "hand_tele_inactive"
	/// The number of open teleportals.
	var/active_portals = 0
	/// Variable contains next time hand tele can be used to make it not EMP proof
	var/emp_timer = 0

/obj/item/hand_tele/examine_more(mob/user)
	. = ..()
	. += "Conventional teleportation technology requires either inflexible quantum pad setups that can only send users between two fixed locations, \
	or large immobile portal generators connected to an even larger set of computer equipment that is required for safe translation through extradimensional space."
	. += ""
	. += "This specialised portable teleporter is an experimental miniaturisation of the latter category. It utilises highly specialised analogue circuitry to perform the bulk of the teleportation calculations, \
	allowing for a far more compact package than more generalised digital computer technology would allow. Some digital components are present, which handle the user interface and beacon tracking functions. \
	In order to allow the device to be fully portable, it has no frame to stabilise the portals it generates. This comes at the cost of the portals only being able to persist for a limited time."
	. += ""
	. += "A limited number of these experimental devices exist. Due manufacturing difficulties (particularly regarding the analogue computer), \
	Nanotrasen has delayed releasing it onto the market until it can improve its production methods."

/obj/item/hand_tele/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/hand_tele/attack_self__legacy__attackchain(mob/user)
	// The turf the user is currently located in.
	var/turf/current_location = get_turf(user)
	if(emp_timer > world.time)
		do_sparks(5, 0, loc)
		to_chat(user, "<span class='warning'>[src] attempts to create a portal, but abruptly shuts off.</span>")
		return
	if(!current_location||!is_teleport_allowed(current_location.z))//If turf was not found or they're somewhere teleproof
		to_chat(user, "<span class='notice'>\The [src] is malfunctioning.</span>")
		return
	var/list/L = list()
	for(var/obj/machinery/computer/teleporter/com in SSmachines.get_by_type(/obj/machinery/computer/teleporter))
		if(com.target)
			if(com.power_station && com.power_station.teleporter_hub && com.power_station.engaged)
				L["[com.id] (Active)"] = com.target
			else
				L["[com.id] (Inactive)"] = com.target
	var/list/turfs = list()
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
	if(length(turfs))
		L["None (Dangerous)"] = pick(turfs)
	flick("hand_tele_activated", src)
	var/t1 = tgui_input_list(user, "Please select a teleporter to lock in on.", "Hand Teleporter", L)
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
