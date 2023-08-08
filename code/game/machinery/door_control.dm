/obj/machinery/door_control
	name = "remote door-control"
	desc = "A remote control-switch for a door."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl"
	power_channel = ENVIRON
	var/id = null
	var/safety_z_check = 1
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
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/door_control/alt
	icon_state = "altdoorctrl"

/obj/machinery/door_control/attack_ai(mob/user as mob)
	if(wires & 2)
		return attack_hand(user)
	else
		to_chat(user, "Error, no route to host.")

/obj/machinery/door_control/attackby(obj/item/W, mob/user as mob, params)
	if(istype(W, /obj/item/detective_scanner))
		return
	return ..()

/obj/machinery/door_control/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		req_access = list()
		playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/machinery/door_control/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door_control/proc/do_main_action(mob/user as mob)
	if(normaldoorcontrol)
		for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
			if(safety_z_check && D.z != z || D.id_tag != id)
				continue
			if(specialfunctions & OPEN)
				if(D.density)
					spawn(0)
						D.open()
				else
					spawn(0)
						D.close()
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
		for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
			if(safety_z_check && M.z != z || M.id_tag != id)
				continue
			if(M.density)
				spawn(0)
					M.open()
			else
				spawn(0)
					M.close()

	desiredstate = !desiredstate

/obj/machinery/door_control/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && (wires & 1) && !user.can_advanced_admin_interact())
		to_chat(user, span_warning("Access Denied."))
		flick("[initial(icon_state)]-denied",src)
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return

	use_power(5)
	icon_state = "[initial(icon_state)]-inuse"

	do_main_action(user)

	addtimer(CALLBACK(src, PROC_REF(update_icon)), 15)

/obj/machinery/door_control/power_change()
	..()
	update_icon()

/obj/machinery/door_control/update_icon()
	if(stat & NOPOWER)
		icon_state = "[initial(icon_state)]-p"
	else
		icon_state = initial(icon_state)
