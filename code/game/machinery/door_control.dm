/obj/machinery/door_control
	name = "remote door-control"
	desc = "A remote control-switch for a door."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
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
		req_one_access = list()
		playsound(loc, "sparks", 100, 1)

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

/obj/machinery/door_control/brass
	name = "brass door-control"
	desc = "A brass remote control-switch for a door."
	icon = 'icons/obj/clockwork_objects.dmi'

/obj/machinery/door_control/brass/beach_brass_temple_switch/Initialize()
	. = ..()
	id = "brassbeachtempledoor[rand(1, 12)]"

/obj/machinery/door_control/brass/beach_brass_temple_switch/attack_hand(mob/user as mob)
	. = ..()
	var/temple_traps = rand(1,10) //no forbidden temple is complete without some traps!
	switch(temple_traps)
		if(1 to 5)//You're safe, this time.
			return
		if(6,7)
			new /mob/living/simple_animal/hostile/poison/giant_spider(get_turf(src))
			visible_message("<span class='boldannounce'>A hatch opens above you and a giant spider falls down on your head!</span>")
			playsound(get_turf(src), 'sound/effects/bin_close.ogg', 200, TRUE)
		if(8,9)
			addtimer(CALLBACK(GLOBAL_PROC, .proc/explosion, user.loc, -1, rand(1,5), rand(1,5), rand(1,5), rand(1,5), 1, 0, 2), 50)
			playsound(get_turf(src), 'sound/mecha/powerup.ogg', 200, TRUE)
			visible_message("<span class='boldannounce'>A high pitched whine can be heard and the walls looks to be heating up!</span>")
		if(10)
			for(var/mob/M in range(5, src))
				shake_camera(M, 15, 1)
			visible_message("<span class='boldannounce'>The ground begins to shake and roaring machinery can be heard! RUN!</span>")
			addtimer(CALLBACK(src, .proc/temple_collapse), 5 SECONDS)

/obj/machinery/door_control/brass/beach_brass_temple_switch/proc/temple_collapse()
	for(var/mob/M in range(20, src))
		shake_camera(M, 15, 1)
	playsound(get_turf(src),'sound/effects/explosionfar.ogg', 200, TRUE)
	visible_message("<span class='boldannounce'>The brass floor collapses and forms a massive pit!</span>")
	for(var/turf/T in range(4,src))
		if(!T.density)
			T.TerraformTurf(/turf/simulated/floor/chasm/straight_down/lava_land_surface)
	qdel(src)


