/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon_state = "igniter1"
	plane = FLOOR_PLANE
	max_integrity = 300
	armor = list(MELEE = 50, BULLET = 30, LASER = 70, ENERGY = 50, BOMB = 20, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	anchored = TRUE
	idle_power_consumption = 2
	active_power_consumption = 4
	/// ID to hook buttons into
	var/id = null
	/// Are we on?
	var/on = FALSE

/obj/machinery/igniter/on
	on = TRUE

/obj/machinery/igniter/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/igniter/attack_hand(mob/user as mob)
	if(..())
		return

	add_fingerprint(user)

	use_power(50)
	on = !on
	update_icon()

	if(on)
		set_light(1, 1, "#ff821c")
	else
		set_light(0)


/obj/machinery/igniter/update_icon_state()
	. = ..()

	if(stat & (NOPOWER|BROKEN))
		icon_state = "igniter0"
		return

	icon_state = "igniter[on]"

/obj/machinery/igniter/update_overlays()
	. = ..()
	underlays.Cut()

	if(on)
		underlays += emissive_appearance(icon, "igniter_lightmask")

/obj/machinery/igniter/process()	//ugh why is this even in process()? // AA 2022-08-02 - I guess it cant go anywhere else?
	if(on && !(stat & NOPOWER))
		var/turf/location = get_turf(src)
		if(isturf(location))
			location.hotspot_expose(1000, 1)
	return TRUE

/obj/machinery/igniter/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/igniter/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		on = FALSE
	update_icon()

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon_state = "migniter"
	resistance_flags = FIRE_PROOF
	var/id = null
	var/disable = FALSE
	var/last_spark = FALSE
	var/base_state = "migniter"
	anchored = TRUE

/obj/machinery/sparker/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "[base_state]-p"
	else
		icon_state = "[base_state]"

/obj/machinery/sparker/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/sparker/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	disable = !disable

	if(disable)
		user.visible_message("<span class='warning'>[user] has disabled [src]!</span>", "<span class='warning'>You disable the connection to [src].</span>")
		icon_state = "[base_state]-d"
	else
		user.visible_message("<span class='warning'>[user] has reconnected [src]!</span>", "<span class='warning'>You fix the connection to [src].</span>")
		if(has_power())
			icon_state = "[base_state]"
		else
			icon_state = "[base_state]-p"

/obj/machinery/sparker/attack_ai()
	if(anchored)
		return spark()


/obj/machinery/sparker/proc/spark()
	if(!has_power())
		return

	if(disable || (last_spark && world.time < last_spark + 5 SECONDS))
		return

	flick("[base_state]-spark", src)
	do_sparks(2, 1, src)
	last_spark = world.time
	use_power(1000)

	var/turf/location = get_turf(src)
	if(isturf(location))
		location.hotspot_expose(1000, 500)

	return TRUE

/obj/machinery/sparker/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	spark()
	..(severity)
