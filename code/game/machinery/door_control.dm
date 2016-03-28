/obj/machinery/door_control
	name = "remote door-control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	power_channel = ENVIRON
	var/id = null
	var/range = 10
	var/normaldoorcontrol = 0
	var/desiredstate = 0 // Zero is closed, 1 is open.
	var/specialfunctions = 1
	/*
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties

	*/

	var/exposedwires = 0
	var/wires = 3
	/*
	Bitflag,	1=checkID
				2=Network Access
	*/

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/door_control/attack_ai(mob/user as mob)
	if(wires & 2)
		return src.attack_hand(user)
	else
		user << "Error, no route to host."

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user as mob, params)
	/* For later implementation
	if (istype(W, /obj/item/weapon/screwdriver))
	{
		if(wiresexposed)
			icon_state = "doorctrl0"
			wiresexposed = 0

		else
			icon_state = "doorctrl-open"
			wiresexposed = 1

		return
	}
	*/
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/door_control/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		req_access = list()
		req_one_access = list()
		playsound(src.loc, "sparks", 100, 1)

/obj/machinery/door_control/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && (wires & 1))
		user << "\red Access Denied"
		flick("doorctrl-denied",src)
		return

	use_power(5)
	icon_state = "doorctrl1"
	add_fingerprint(user)

	if(normaldoorcontrol)
		for(var/obj/machinery/door/airlock/D in range(range))
			if(D.id_tag == src.id)
				if(specialfunctions & OPEN)
					if (D.density)
						spawn(0)
							D.open()
							return
					else
						spawn(0)
							D.close()
							return
				if(desiredstate == 1)
					if(specialfunctions & IDSCAN)
						D.aiDisabledIdScanner = 1
					if(specialfunctions & BOLTS)
						D.lock()
					if(specialfunctions & SHOCK)
						D.electrify(-1)
					if(specialfunctions & SAFE)
						D.safe = 0
				else
					if(specialfunctions & IDSCAN)
						D.aiDisabledIdScanner = 0
					if(specialfunctions & BOLTS)
						D.unlock()
					if(specialfunctions & SHOCK)
						D.electrify(0)
					if(specialfunctions & SAFE)
						D.safe = 1

	else
		for(var/obj/machinery/door/poddoor/M in world)
			if (M.id_tag == src.id)
				if (M.density)
					spawn( 0 )
						M.open()
						return
				else
					spawn( 0 )
						M.close()
						return

	desiredstate = !desiredstate
	spawn(15)
		if(!(stat & NOPOWER))
			icon_state = "doorctrl0"

/obj/machinery/door_control/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

//////////////////////////////////////
//			Driver Button			//
//////////////////////////////////////

/obj/machinery/driver_button/initialize()
	..()
	set_frequency(frequency)

/obj/machinery/driver_button/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_LOGIC)
	return

/obj/machinery/driver_button/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	return ..()


/obj/machinery/driver_button/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/weapon/W, mob/user as mob, params)

	if(istype(W, /obj/item/device/detective_scanner))
		return

	if(istype(W, /obj/item/device/multitool))
		update_multitool_menu(user)
		return 1

	if(istype(W, /obj/item/weapon/wrench))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 30, target = src))
			user << "<span class='notice'>You detach \the [src] from the wall.</span>"
			new/obj/item/mounted/frame/driver_button(get_turf(src))
			qdel(src)
		return 1

	return src.attack_hand(user)

/obj/machinery/driver_button/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<ul>
	<li><b>ID Tag:</b> [format_tag("ID Tag","id_tag")]</li>
	<li><b>Logic Connection:</b> <a href='?src=\ref[src];toggle_logic=1'>[logic_connect ? "On" : "Off"]</a></li>
	<li><b>Logic ID Tag:</b> [format_tag("Logic ID Tag", "logic_id_tag")]</li>
	</ul>"}

/obj/machinery/driver_button/attack_hand(mob/user as mob)

	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return
	add_fingerprint(user)

	use_power(5)

	launch_sequence()

	return

/obj/machinery/driver_button/proc/launch_sequence()
	active = 1
	icon_state = "launcheract"

	if(logic_connect)
		if(!radio_connection)		//can't output without this
			return

		if(logic_id_tag == null)	//Don't output to an undefined id_tag
			return

		var/datum/signal/signal = new
		signal.transmission_method = 1	//radio signal
		signal.source = src

		signal.data = list(
				"tag" = logic_id_tag,
				"sigtype" = "logic",
				"state" = LOGIC_FLICKER,	//Buttons are a FLICKER source, since they only register as ON when you press it, then turn OFF after you release
		)

		radio_connection.post_signal(src, signal, filter = RADIO_LOGIC)

	for(var/obj/machinery/door/poddoor/M in range(src,range))
		if (M.id_tag == src.id_tag && !M.protected)
			spawn()
				M.open()

	sleep(20)

	for(var/obj/machinery/mass_driver/M in range(src,range))
		if(M.id_tag == src.id_tag)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in range(src,range))
		if (M.id_tag == src.id_tag && !M.protected)
			spawn()
				M.close()
				return

	icon_state = "launcherbtt"
	active = 0

/obj/machinery/driver_button/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	..()
	if("toggle_logic" in href_list)
		logic_connect = !logic_connect