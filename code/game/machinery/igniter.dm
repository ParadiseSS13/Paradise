/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter1"
	armor = list(melee = 50, bullet = 30, laser = 70, energy = 50, bomb = 20, bio = 0, rad = 0)
	var/id = null
	var/on = 1.0
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/igniter/attack_ai(mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/igniter/attack_hand(mob/user as mob)
	if(..())
		return
	add_fingerprint(user)

	use_power(50)
	src.on = !( src.on )
	src.icon_state = text("igniter[]", src.on)
	return

/obj/machinery/igniter/process()	//ugh why is this even in process()?
	if(src.on && !(stat & NOPOWER) )
		var/turf/location = src.loc
		if(isturf(location))
			location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/igniter/New()
	..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/power_change()
	if(!( stat & NOPOWER) )
		icon_state = "igniter[src.on]"
	else
		icon_state = "igniter0"

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/base_state = "migniter"
	anchored = 1

/obj/machinery/sparker/New()
	..()

/obj/machinery/sparker/power_change()
	if( powered() && disable == 0 )
		stat &= ~NOPOWER
		icon_state = "[base_state]"
//		src.sd_set_light(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]-p"
//		src.sd_set_light(0)

/obj/machinery/sparker/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/detective_scanner))
		return
	if(isscrewdriver(I))
		add_fingerprint(user)
		disable = !disable
		if(disable)
			user.visible_message("<span class='warning'>[user] has disabled [src]!</span>", "<span class='warning'>You disable the connection to [src].</span>")
			icon_state = "[base_state]-d"
		if(!disable)
			user.visible_message("<span class='warning'>[user] has reconnected [src]!</span>", "<span class='warning'>You fix the connection to [src].</span>")
			if(powered())
				icon_state = "[base_state]"
			else
				icon_state = "[base_state]-p"
	else
		return ..()

/obj/machinery/sparker/attack_ai()
	if(src.anchored)
		return src.spark()
	else
		return

/obj/machinery/sparker/proc/spark()
	if(!(powered()))
		return

	if((src.disable) || (src.last_spark && world.time < src.last_spark + 50))
		return


	flick("[base_state]-spark", src)
	do_sparks(2, 1, src)
	src.last_spark = world.time
	use_power(1000)
	var/turf/location = src.loc
	if(isturf(location))
		location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/sparker/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	spark()
	..(severity)
