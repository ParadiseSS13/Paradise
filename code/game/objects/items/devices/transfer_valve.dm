/obj/item/device/transfer_valve
	icon = 'icons/obj/assemblies.dmi'
	name = "tank transfer valve"
	icon_state = "valve_1"
	desc = "Regulates the transfer of air between two tanks"
	var/obj/item/weapon/tank/tank_one
	var/obj/item/weapon/tank/tank_two
	var/obj/item/device/attached_device
	var/mob/attacher = null
	var/valve_open = 0
	var/toggle = 1
	origin_tech = "materials=1;engineering=1"

/obj/item/device/transfer_valve/Destroy()
	if(tank_one)
		qdel(tank_one)
		tank_one = null
	if(tank_two)
		qdel(tank_two)
		tank_two = null
	if(attached_device)
		qdel(attached_device)
		attached_device = null
	return ..()

/obj/item/device/transfer_valve/proc/process_activation(var/obj/item/device/D)

/obj/item/device/transfer_valve/IsAssemblyHolder()
	return 1

/obj/item/device/transfer_valve/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/weapon/tank))
		if(tank_one && tank_two)
			to_chat(user, "<span class='warning'>There are already two tanks attached, remove one first.</span>")
			return

		if(!tank_one)
			tank_one = item
			user.drop_item()
			item.loc = src
			to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")
		else if(!tank_two)
			tank_two = item
			user.drop_item()
			item.loc = src
			to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")

		update_icon()
		nanomanager.update_uis(src) // update all UIs attached to src
//TODO: Have this take an assemblyholder
	else if(isassembly(item))
		var/obj/item/device/assembly/A = item
		if(A.secured)
			to_chat(user, "<span class='notice'>The device is secured.</span>")
			return
		if(attached_device)
			to_chat(user, "<span class='warning'>There is already a device attached to the valve, remove it first.</span>")
			return
		user.remove_from_mob(item)
		attached_device = A
		A.loc = src
		to_chat(user, "<span class='notice'>You attach the [item] to the valve controls and secure it.</span>")
		A.holder = src
		A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).

		bombers += "[key_name(user)] attached a [item] to a transfer valve."
		msg_admin_attack("[key_name_admin(user)]attached [item] to a transfer valve.")
		log_game("[key_name_admin(user)] attached [item] to a transfer valve.")
		attacher = user
		nanomanager.update_uis(src) // update all UIs attached to src
	return


/obj/item/device/transfer_valve/HasProximity(atom/movable/AM as mob|obj)
	if(!attached_device)	return
	attached_device.HasProximity(AM)
	return

/obj/item/device/transfer_valve/hear_talk(mob/living/M as mob, msg)
	..()
	for(var/obj/O in contents)
		O.hear_talk(M, msg)

/obj/item/device/transfer_valve/hear_message(mob/living/M as mob, msg)
	..()
	for(var/obj/O in contents)
		O.hear_message(M, msg)

/obj/item/device/transfer_valve/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/device/transfer_valve/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	// this is the data which will be sent to the ui
	var/data[0]
	data["attachmentOne"] = tank_one ? tank_one.name : null
	data["attachmentTwo"] = tank_two ? tank_two.name : null
	data["valveAttachment"] = attached_device ? attached_device.name : null
	data["valveOpen"] = valve_open ? 1 : 0

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "transfer_valve.tmpl", "Tank Transfer Valve", 460, 280)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		//ui.set_auto_update(1)

/obj/item/device/transfer_valve/Topic(href, href_list)
	..()
	if( usr.stat || usr.restrained() )
		return 0
	if(src.loc != usr)
		return 0
	if(tank_one && href_list["tankone"])
		split_gases()
		valve_open = 0
		tank_one.loc = get_turf(src)
		tank_one = null
		update_icon()
	else if(tank_two && href_list["tanktwo"])
		split_gases()
		valve_open = 0
		tank_two.loc = get_turf(src)
		tank_two = null
		update_icon()
	else if(href_list["open"])
		toggle_valve()
	else if(attached_device)
		if(href_list["rem_device"])
			attached_device.loc = get_turf(src)
			attached_device:holder = null
			attached_device = null
			update_icon()
		if(href_list["device"])
			attached_device.attack_self(usr)
	src.add_fingerprint(usr)
	return 1 // Returning 1 sends an update to attached UIs

/obj/item/device/transfer_valve/process_activation(var/obj/item/device/D)
	if(toggle)
		toggle = 0
		toggle_valve()
		spawn(50) // To stop a signal being spammed from a proxy sensor constantly going off or whatever
			toggle = 1

/obj/item/device/transfer_valve/update_icon()
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

/obj/item/device/transfer_valve/proc/merge_gases()
	tank_two.air_contents.volume += tank_one.air_contents.volume
	var/datum/gas_mixture/temp
	temp = tank_one.air_contents.remove_ratio(1)
	tank_two.air_contents.merge(temp)

/obj/item/device/transfer_valve/proc/split_gases()
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

/obj/item/device/transfer_valve/proc/toggle_valve()
	if(valve_open==0 && (tank_one && tank_two))
		valve_open = 1
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)

		var/attacher_name = ""
		if(!attacher)
			attacher_name = "Unknown"
		else
			attacher_name = "[key_name_admin(attacher)]"

		var/mob/mob = get_mob_by_key(src.fingerprintslast)

		bombers += "Bomb valve opened at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]) with [attached_device ? attached_device : "no device"], attached by [attacher_name]. Last touched by: [key_name(mob)]"
		message_admins("Bomb valve opened at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a> with [attached_device ? attached_device : "no device"], attached by [attacher_name]. Last touched by: [key_name_admin(mob)]")
		log_game("Bomb valve opened at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]) with [attached_device ? attached_device : "no device"], attached by [attacher_name]. Last touched by: [key_name(mob)]")
		merge_gases()
		spawn(20) // In case one tank bursts
			for(var/i=0,i<5,i++)
				src.update_icon()
				sleep(10)
			src.update_icon()

	else if(valve_open==1 && (tank_one && tank_two))
		split_gases()
		valve_open = 0
		src.update_icon()

// this doesn't do anything but the timer etc. expects it to be here
// eventually maybe have it update icon to show state (timer, prox etc.) like old bombs
/obj/item/device/transfer_valve/proc/c_state()
	return