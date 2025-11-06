///if the icon_state for the TTV's tank is in assemblies.dmi
#define TTV_TANK_ICON_STATES list("anesthetic", "emergency", "emergency_double", "emergency_engi", "emergency_sleep", "jetpack", "jetpack_black", "jetpack_void", "oxygen", "oxygen_f", "oxygen_fr", "plasma")

/obj/item/transfer_valve
	name = "tank transfer valve"
	desc = "Regulates the transfer of air between two tanks."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "valve_1"
	inhand_icon_state = "ttv"
	var/obj/item/tank/tank_one = null
	var/obj/item/tank/tank_two = null
	var/obj/item/assembly/attached_device = null
	var/mob/living/attacher = null
	var/valve_open = FALSE
	var/toggle = TRUE
	origin_tech = "materials=1;engineering=1"

/obj/item/transfer_valve/Destroy()
	QDEL_NULL(tank_one)
	QDEL_NULL(tank_two)
	QDEL_NULL(attached_device)
	attacher = null
	return ..()

/obj/item/transfer_valve/IsAssemblyHolder()
	return 1

/obj/item/transfer_valve/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank))
		if(tank_one && tank_two)
			to_chat(user, "<span class='warning'>There are already two tanks attached, remove one first.</span>")
			return

		if(!tank_one)
			if(!user.transfer_item_to(I, src))
				return
			tank_one = I
			to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")
			if(I.w_class > w_class)
				w_class = I.w_class
		else if(!tank_two)
			if(!user.transfer_item_to(I, src))
				return
			tank_two = I
			to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")
			if(I.w_class > w_class)
				w_class = I.w_class

		update_icon()
		SStgui.update_uis(src) // update all UIs attached to src
//TODO: Have this take an assemblyholder
	else if(isassembly(I))
		var/obj/item/assembly/A = I
		if(A.secured)
			to_chat(user, "<span class='notice'>The device is secured.</span>")
			return
		if(attached_device)
			to_chat(user, "<span class='warning'>There is already a device attached to the valve, remove it first.</span>")
			return
		if(!user.transfer_item_to(A, src))
			return
		attached_device = A
		to_chat(user, "<span class='notice'>You attach [A] to the valve controls and secure it.</span>")
		A.holder = src
		A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).

		investigate_log("[key_name(user)] attached a [A] to a transfer valve.", INVESTIGATE_BOMB)
		add_attack_logs(user, src, "attached [A] to a transfer valve", ATKLOG_FEW)
		log_game("[key_name_admin(user)] attached [A] to a transfer valve.")
		attacher = user
		SStgui.update_uis(src) // update all UIs attached to src


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

/obj/item/transfer_valve/attack_self__legacy__attackchain(mob/user)
	ui_interact(user)

/obj/item/transfer_valve/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/transfer_valve/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TransferValve",  name)
		ui.open()

/obj/item/transfer_valve/ui_data(mob/user)
	var/list/data = list()
	data["tank_one"] = tank_one ? tank_one.name : null
	data["tank_two"] = tank_two ? tank_two.name : null
	data["attached_device"] = attached_device ? attached_device.name : null
	data["valve"] = valve_open
	return data



/obj/item/transfer_valve/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("tankone")
			if(tank_one)
				split_gases()
				valve_open = FALSE
				tank_one.forceMove(get_turf(src))
				tank_one = null
				update_icon()
				if((!tank_two || tank_two.w_class < WEIGHT_CLASS_BULKY) && (w_class > WEIGHT_CLASS_NORMAL))
					w_class = WEIGHT_CLASS_NORMAL
		if("tanktwo")
			if(tank_two)
				split_gases()
				valve_open = FALSE
				tank_two.forceMove(get_turf(src))
				tank_two = null
				update_icon()
				if((!tank_one || tank_one.w_class < WEIGHT_CLASS_BULKY) && (w_class > WEIGHT_CLASS_NORMAL))
					w_class = WEIGHT_CLASS_NORMAL
		if("toggle")
			toggle_valve(usr)
		if("device")
			if(attached_device)
				attached_device.attack_self__legacy__attackchain(usr)
		if("remove_device")
			if(attached_device)
				attached_device.forceMove(get_turf(src))
				attached_device.holder = null
				attached_device = null
				update_icon()
		else
			. = FALSE
	if(.)
		update_icon()
		add_fingerprint(usr)


/obj/item/transfer_valve/proc/process_activation(obj/item/D)
	if(toggle)
		toggle = FALSE
		toggle_valve()
		spawn(50) // To stop a signal being spammed from a proxy sensor constantly going off or whatever
			toggle = TRUE

/obj/item/transfer_valve/update_icon_state()
	if(!tank_one && !tank_two && !attached_device)
		icon_state = "valve_1"
	else
		icon_state = "valve"

/obj/item/transfer_valve/update_overlays()
	. = ..()
	underlays.Cut()
	if(!tank_one && !tank_two && !attached_device)
		return

	if(tank_one)
		var/tank_one_icon_state = tank_one.icon_state
		if(!(tank_one_icon_state in TTV_TANK_ICON_STATES)) //if no valid sprite fall back to an oxygen tank
			tank_one_icon_state = "oxygen"
			stack_trace("[tank_one] was inserted into a TTV with an invalid icon_state, \"[tank_one.icon_state]\"")
		. += "[tank_one_icon_state]"

	if(tank_two)
		var/tank_two_icon_state = tank_two.icon_state
		if(!(tank_two_icon_state in TTV_TANK_ICON_STATES)) //if no valid sprite fall back to an oxygen tank
			tank_two_icon_state = "oxygen"
			stack_trace("[tank_two] was inserted into a TTV with an invalid icon_state, \"[tank_two.icon_state]\"")
		var/icon/tank_two_icon = new(icon, icon_state = tank_two_icon_state)
		tank_two_icon.Shift(WEST, 13)
		underlays += tank_two_icon

	if(attached_device)
		. += "device"

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

/obj/item/transfer_valve/proc/toggle_valve(mob/user)
	if(!valve_open && tank_one && tank_two)
		valve_open = TRUE
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)

		var/attacher_name = ""
		if(!attacher)
			attacher_name = "Unknown"
		else
			attacher_name = "[key_name_admin(attacher)]"

		var/mob/mob = get_mob_by_key(src.fingerprintslast)

		investigate_log("Bomb valve opened at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]) with [attached_device ? attached_device : "no device"], attached by [attacher_name]. Last touched by: [key_name(mob)]", INVESTIGATE_BOMB)
		message_admins("Bomb valve opened at <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a> with [attached_device ? attached_device : "no device"], attached by [attacher_name]. Last touched by: [key_name_admin(mob)]")
		log_game("Bomb valve opened at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]) with [attached_device ? attached_device : "no device"], attached by [attacher_name]. Last touched by: [key_name(mob)]")
		if(user)
			add_attack_logs(user, src, "Bomb valve opened with [attached_device ? attached_device : "no device"], attached by [attacher_name]. Last touched by: [key_name(mob)]", ATKLOG_FEW)
		merge_gases()
		spawn(20) // In case one tank bursts
			for(var/i in 1 to 5)
				update_icon()
				sleep(10)
			update_icon()

	else if(valve_open && tank_one && tank_two)
		split_gases()
		valve_open = FALSE
		update_icon()

#undef TTV_TANK_ICON_STATES
