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
		to_chat(user, "Error, no route to host.")

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user as mob, params)
	/* For later implementation
	if(istype(W, /obj/item/weapon/screwdriver))
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
		to_chat(user, "\red Access Denied")
		flick("doorctrl-denied",src)
		return

	use_power(5)
	icon_state = "doorctrl1"
	add_fingerprint(user)

	if(normaldoorcontrol)
		for(var/obj/machinery/door/airlock/D in range(range))
			if(D.id_tag == src.id)
				if(specialfunctions & OPEN)
					if(D.density)
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
		for(var/obj/machinery/door/poddoor/M in airlocks)
			if(M.id_tag == src.id)
				if(M.density)
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
