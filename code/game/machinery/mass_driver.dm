/obj/machinery/mass_driver
	name = "mass driver"
	desc = "Shoots things into space."
	icon = 'icons/obj/objects.dmi'
	icon_state = "mass_driver"
	anchored = TRUE
	idle_power_consumption = 2
	active_power_consumption = 50

	/// Throw power
	var/power = 1
	/// ID tag, used for buttons
	var/id_tag = "default"
	/// This is mostly irrelevant since current mass drivers throw into space, but you could make a lower-range mass driver for interstation transport or something I guess.
	var/drive_range = 50

/obj/machinery/mass_driver/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return

	var/obj/machinery/mass_driver_frame/F = new (get_turf(src))
	F.dir = dir
	F.anchored = TRUE
	F.build = 4
	F.update_icon()
	qdel(src)

/obj/machinery/mass_driver/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	var/new_tag = clean_input("Enter a new ID tag", "ID Tag", id_tag, user)

	if(new_tag && Adjacent(user))
		id_tag = new_tag

/obj/machinery/mass_driver/proc/drive(amount)
	if(stat & (BROKEN|NOPOWER))
		return

	use_power(500 * power)
	var/O_limit = 0
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if((!O.anchored && O.move_resist != INFINITY) || ismecha(O)) //Mechs need their launch platforms. Also checks if something is anchored or has move resist INFINITY, which should stop ghost flinging.
			O_limit++

			if(O_limit >= 20)//so no more than 20 items are sent at a time, probably for counter-lag purposes
				break

			use_power(500)
			var/coef = 1
			if(emagged)
				coef = 5
			INVOKE_ASYNC(O, TYPE_PROC_REF(/atom/movable, throw_at), target, (drive_range * power * coef), (power * coef))

	flick("mass_driver1", src)

/obj/machinery/mass_driver/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return

	drive()
	..(severity)

/obj/machinery/mass_driver/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "You hack the Mass Driver, radically increasing the force at which it'll throw things. Better not stand in its way.")
		return TRUE

	return

////////////////MASS DRIVER FRAME///////////////////

/obj/machinery/mass_driver_frame
	name = "mass driver frame"
	icon = 'icons/obj/objects.dmi'
	icon_state = "mass_driver_frame"
	density = FALSE
	anchored = FALSE
	var/build = 0

/obj/machinery/mass_driver_frame/attackby(obj/item/W as obj, mob/user as mob)
	switch(build)
		if(0) // Loose frame
			if(istype(W, /obj/item/wrench))
				to_chat(user, "You begin to anchor \the [src] on the floor.")
				playsound(get_turf(src), W.usesound, 50, 1)
				if(do_after(user, 10 * W.toolspeed, target = src) && (build == 0))
					to_chat(user, "<span class='notice'>You anchor \the [src]!</span>")
					anchored = TRUE
					build++
				return TRUE
			return FALSE

		if(1) // Fixed to the floor
			if(istype(W, /obj/item/wrench))
				to_chat(user, "You begin to de-anchor \the [src] from the floor.")
				playsound(get_turf(src), W.usesound, 50, 1)
				if(do_after(user, 10 * W.toolspeed, target = src) && (build == 1))
					build--
					anchored = FALSE
					to_chat(user, "<span class='notice'>You de-anchored \the [src]!</span>")
				return TRUE
			return FALSE

		if(2) // Welded to the floor
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				to_chat(user, "You start adding cables to \the [src]...")
				playsound(get_turf(src), C.usesound, 50, 1)
				if(do_after(user, 20 * C.toolspeed, target = src) && (C.get_amount() >= 2) && (build == 2))
					C.use(2)
					to_chat(user, "<span class='notice'>You've added cables to \the [src].</span>")
					build++
				return TRUE
			return FALSE

		if(3) // Wired
			if(istype(W, /obj/item/wirecutters))
				to_chat(user, "You begin to remove the wiring from \the [src].")
				if(do_after(user, 10 * W.toolspeed, target = src) && (build == 3))
					new /obj/item/stack/cable_coil(loc,2)
					playsound(get_turf(src), W.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You've removed the cables from \the [src].</span>")
					build--
				return TRUE

			if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/rods/R = W
				to_chat(user, "You begin to complete \the [src]...")
				playsound(get_turf(src), R.usesound, 50, 1)
				if(do_after(user, 20 * R.toolspeed, target = src) && (R.get_amount() >= 2) && (build == 3))
					R.use(2)
					to_chat(user, "<span class='notice'>You've added the grille to \the [src].</span>")
					build++
				return TRUE

			return FALSE

		if(4) // Grille in place
			if(istype(W, /obj/item/crowbar))
				to_chat(user, "You begin to pry off the grille from \the [src]...")
				playsound(get_turf(src), W.usesound, 50, 1)
				if(do_after(user, 30 * W.toolspeed, target = src) && (build == 4))
					new /obj/item/stack/rods(loc,2)
					build--
				return TRUE
			return FALSE

	return ..()

/obj/machinery/mass_driver_frame/screwdriver_act(mob/living/user, obj/item/I)
	if(build != 4)
		return

	to_chat(user, "<span class='notice'>You finalize the Mass Driver.</span>")
	I.play_tool_sound(src)
	var/obj/machinery/mass_driver/M = new(get_turf(src))
	M.dir = dir
	qdel(src)
	return TRUE

/obj/machinery/mass_driver_frame/welder_act(mob/user, obj/item/I)
	if(build != 0 && build != 1 && build != 2)
		return

	. = TRUE

	if(!I.tool_use_check(user, 0))
		return

	if(build == 0) //can deconstruct
		WELDER_ATTEMPT_SLICING_MESSAGE
		if(I.use_tool(src, user, 30, volume = I.tool_volume))
			WELDER_SLICING_SUCCESS_MESSAGE
			new /obj/item/stack/sheet/plasteel(drop_location(),3)
			qdel(src)

	else if(build == 1) //wrenched but not welded down
		WELDER_ATTEMPT_FLOOR_WELD_MESSAGE
		if(I.use_tool(src, user, 40, volume = I.tool_volume) && build == 1)
			WELDER_FLOOR_WELD_SUCCESS_MESSAGE
			build = 2

	else if(build == 2) //welded down
		WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
		if(I.use_tool(src, user, 40, volume = I.tool_volume) && build == 2)
			WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
			build = 1

/obj/machinery/mass_driver_frame/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	dir = turn(dir, -90)
