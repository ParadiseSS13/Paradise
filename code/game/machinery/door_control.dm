/obj/machinery/door_control
	name = "remote door-control"
	desc = "A remote control-switch for a door."
	icon_state = "doorctrl0"
	power_channel = PW_CHANNEL_ENVIRONMENT
	var/id = null
	var/safety_z_check = TRUE
	var/normaldoorcontrol = FALSE
	/// FALSE is closed, TRUE is open.
	var/desiredstate_open = FALSE
	var/specialfunctions = 1
	/*
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties

	*/

	var/wires = 3
	/*
	Bitflag,	1=checkID
				2=Network Access
	*/

	anchored = TRUE
	idle_power_consumption = 2
	active_power_consumption = 4

/obj/machinery/door_control/attack_ai(mob/user as mob)
	if(wires & 2)
		return attack_hand(user)
	else
		to_chat(user, "Error, no route to host.")

/obj/machinery/door_control/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/detective_scanner))
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/door_control/emag_act(user as mob)
	if(!emagged)
		emagged = TRUE
		req_access = list()
		req_one_access = list()
		playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return TRUE

/obj/machinery/door_control/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door_control/attack_hand(mob/user as mob)
	add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && (wires & 1) && !user.can_advanced_admin_interact())
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		flick("doorctrl-denied",src)
		return

	use_power(5)
	icon_state = "doorctrl1"
	add_fingerprint(user)

	if(normaldoorcontrol)
		for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
			if(safety_z_check && D.z != z)
				continue
			if(D.id_tag == id)
				if(specialfunctions & OPEN)
					if(D.density)
						spawn(0)
							D.open()
							return
					else
						spawn(0)
							D.close()
							return
				if(desiredstate_open)
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
			if(safety_z_check && M.z != z)
				continue
			if(M.id_tag == id)
				if(M.density)
					spawn( 0 )
						M.open()
						return
				else
					spawn( 0 )
						M.close()
						return

	desiredstate_open = !desiredstate_open
	spawn(15)
		if(!(stat & NOPOWER))
			icon_state = "doorctrl0"

/obj/machinery/door_control/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/obj/machinery/door_control/no_emag
	desc = "A remote control-switch for a door. Looks tougher than usual."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/door_control/no_emag/emag_act(user as mob)
	to_chat(user, "<span class='notice'>The electronic systems in this button are far too advanced for your primitive hacking peripherals.</span>")
	return

/obj/machinery/door_control/no_emag/no_cyborg
	desc = "A remote control-switch for a door. Looks strangely analog in design."

/obj/machinery/door_control/no_emag/no_cyborg/attack_ai(mob/user)
	to_chat(user, "<span class='warning'>Error, no route to host.</span>")
	return
