/obj/item/transfer_valve
	icon = 'icons/obj/assemblies.dmi'
	name = "tank transfer valve"
	icon_state = "valve_1"
	item_state = "ttv"
	desc = "Regulates the transfer of air between two tanks"
	var/obj/item/tank/tank_one = null
	var/obj/item/tank/tank_two = null
	var/obj/item/assembly/attached_device = null
	var/mob/living/attacher = null
	var/valve_open = 0
	var/toggle = 1
	origin_tech = "materials=1;engineering=1"

/obj/item/transfer_valve/Destroy()
	QDEL_NULL(tank_one)
	QDEL_NULL(tank_two)
	QDEL_NULL(attached_device)
	attacher = null
	return ..()

/obj/item/transfer_valve/IsAssemblyHolder()
	return 1

/obj/item/transfer_valve/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank))
		if(tank_one && tank_two)
			to_chat(user, "<span class='warning'>There are already two tanks attached, remove one first.</span>")
			return

		if(!tank_one)
			if(!user.unEquip(I))
				return
			tank_one = I
			I.forceMove(src)
			to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")
			if(I.w_class > w_class)
				w_class = I.w_class
		else if(!tank_two)
			if(!user.unEquip(I))
				return
			tank_two = I
			I.forceMove(src)
			to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")
			if(I.w_class > w_class)
				w_class = I.w_class

		update_icon()
		SSnanoui.update_uis(src) // update all UIs attached to src
//TODO: Have this take an assemblyholder
	else if(isassembly(I))
		var/obj/item/assembly/A = I
		if(A.secured)
			to_chat(user, "<span class='notice'>The device is secured.</span>")
			return
		if(attached_device)
			to_chat(user, "<span class='warning'>There is already a device attached to the valve, remove it first.</span>")
			return
		user.remove_from_mob(A)
		attached_device = A
		A.forceMove(src)
		to_chat(user, "<span class='notice'>You attach the [A] to the valve controls and secure it.</span>")
		A.holder = src
		A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).

		investigate_log("[key_name(user)] attached a [A] to a transfer valve.", INVESTIGATE_BOMB)
		msg_admin_attack("[key_name_admin(user)]attached [A] to a transfer valve.", ATKLOG_FEW)
		log_game("[key_name_admin(user)] attached [A] to a transfer valve.")
		attacher = user
		SSnanoui.update_uis(src) // update all UIs attached to src


/obj/item/transfer_valve/HasProximity(atom/movable/AM)
	if(!attached_device)
		return
	attached_device.HasProximity(AM)

/obj/item/transfer_valve/hear_talk(mob/living/M, list/message_pieces)
	..()
	for(var/obj/O in contents)
		O.hear_talk(M, message_pieces)

/obj/item/transfer_valve/hear_message(mob/living/M, msg)
	..()
	for(var/obj/O in contents)
		O.hear_message(M, msg)

/obj/item/transfer_valve/attack_self(mob/user)
	ui_interact(user)

/obj/item/transfer_valve/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "transfer_valve.tmpl", "Tank Transfer Valve", 460, 280)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		//ui.set_auto_update(1)

/obj/item/transfer_valve/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	data["attachmentOne"] = tank_one ? tank_one.name : null
	data["attachmentTwo"] = tank_two ? tank_two.name : null
	data["valveAttachment"] = attached_device ? attached_device.name : null
	data["valveOpen"] = valve_open ? 1 : 0

	return data

/obj/item/transfer_valve/Topic(href, href_list)
	..()
	if(usr.incapacitated())
		return 0
	if(loc != usr)
		return 0
	if(tank_one && href_list["tankone"])
		split_gases()
		valve_open = 0
		tank_one.forceMove(get_turf(src))
		tank_one = null
		update_icon()
		if((!tank_two || tank_two.w_class < WEIGHT_CLASS_BULKY) && (w_class > WEIGHT_CLASS_NORMAL))
			w_class = WEIGHT_CLASS_NORMAL
	else if(tank_two && href_list["tanktwo"])
		split_gases()
		valve_open = 0
		tank_two.forceMove(get_turf(src))
		tank_two = null
		update_icon()
		if((!tank_one || tank_one.w_class < WEIGHT_CLASS_BULKY) && (w_class > WEIGHT_CLASS_NORMAL))
			w_class = WEIGHT_CLASS_NORMAL
	else if(href_list["open"])
		toggle_valve()
	else if(attached_device)
		if(href_list["rem_device"])
			attached_device.forceMove(get_turf(src))
			attached_device.holder = null
			attached_device = null
			update_icon()
		if(href_list["device"])
			attached_device.attack_self(usr)
	add_fingerprint(usr)
	return 1 // Returning 1 sends an update to attached UIs

/obj/item/transfer_valve/proc/process_activation(obj/item/D)
	if(toggle)
		toggle = 0
		toggle_valve()
		spawn(50) // To stop a signal being spammed from a proxy sensor constantly going off or whatever
			toggle = 1

/obj/item/transfer_valve/update_icon()
	overlays.Cut()
	underlays = null

	if(!tank_one && !tank_two && !attached_device)
		icon_state = "valve_1"
		return
	icon_state = "valve"

	if(tank_one)
		overlays += "[tank_one.icon_state]"
	if(tank_two)
		var/icon/J = new(icon, icon_state = "[tank_two.icon_state]")
		J.Shift(WEST, 13)
		underlays += J
	if(attached_device)
		overlays += "device"

/obj/item/transfer_valve/proc/merge_gases()
	tank_two.air_contents.volume += tank_one.air_contents.volume
	var/datum/gas_mixture/temp
	temp = tank_one.air_contents.remove_ratio(1)
	tank_two.air_contents.merge(temp)

/obj/item/transfer_valve/proc/split_gases()
	if(!valve_open || !tank_one || !tank_two)
		return
	var/ratio1 = tank_one.air_contents.volume/tank_two.air_contents.volume
	var/datum/gas_mixture/temp
	temp = tank_two.air_contents.remove_ratio(ratio1)
	tank_one.air_contents.merge(temp)
	tank_two.air_contents.volume -=  tank_one.air_contents.volume

	/*
	Exadv1: I know this isn't how it's going to work, but this was just to check
	it explodes properly when it gets a signal (and it does).
	*/

/obj/item/transfer_valve/proc/toggle_valve()
	if(!valve_open && tank_one && tank_two)
		valve_open = 1
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)

		var/attacher_name = ""
		if(!attacher)
			attacher_name = "Unknown"
		else
			attacher_name = "[key_name_admin(attacher)]"

		var/mob/mob = get_mob_by_key(src.fingerprintslast)

		investigate_log("Bomb valve opened at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]) with [attached_device ? attached_device : "no device"], attached by [attacher_name]. Last touched by: [key_name(mob)]", INVESTIGATE_BOMB)
		message_admins("Bomb valve opened at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a> with [attached_device ? attached_device : "no device"], attached by [attacher_name]. Last touched by: [key_name_admin(mob)]")
		log_game("Bomb valve opened at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]) with [attached_device ? attached_device : "no device"], attached by [attacher_name]. Last touched by: [key_name(mob)]")
		merge_gases()
		spawn(20) // In case one tank bursts
			for(var/i in 1 to 5)
				update_icon()
				sleep(10)
			update_icon()

	else if(valve_open && tank_one && tank_two)
		split_gases()
		valve_open = 0
		update_icon()
