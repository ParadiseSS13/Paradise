/obj/machinery/mass_driver
	name = "mass driver"
	desc = "Shoots things into space."
	icon = 'icons/obj/objects.dmi'
	icon_state = "mass_driver"
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 50

	var/power = 1.0
	var/code = 1.0
	var/id_tag = "default"
	settagwhitelist = list("id_tag")
	var/drive_range = 50 //this is mostly irrelevant since current mass drivers throw into space, but you could make a lower-range mass driver for interstation transport or something I guess.

/obj/machinery/mass_driver/attackby(obj/item/W, mob/user as mob)

	if(istype(W, /obj/item/multitool))
		update_multitool_menu(user)
		return 1

	if(istype(W, /obj/item/screwdriver))
		to_chat(user, "You begin to unscrew the bolts off the [src]...")
		playsound(get_turf(src), W.usesound, 50, 1)
		if(do_after(user, 30 * W.toolspeed, target = src))
			var/obj/machinery/mass_driver_frame/F = new(get_turf(src))
			F.dir = src.dir
			F.anchored = 1
			F.build = 4
			F.update_icon()
			qdel(src)
		return 1

	return ..()

/obj/machinery/mass_driver/multitool_menu(var/mob/user, var/obj/item/multitool/P)
	return {"
	<ul>
	<li>[format_tag("ID Tag","id_tag")]</li>
	</ul>"}

/obj/machinery/mass_driver/proc/drive(amount)
	if(stat & (BROKEN|NOPOWER))
		return
	use_power(500*power)
	var/O_limit = 0
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if(!O.anchored||istype(O, /obj/mecha))//Mechs need their launch platforms.
			O_limit++
			if(O_limit >= 20)//so no more than 20 items are sent at a time, probably for counter-lag purposes
				break
			use_power(500)
			spawn()
				var/coef = 1
				if(emagged)
					coef = 5
				O.throw_at(target, drive_range * power * coef, power * coef)
	flick("mass_driver1", src)
	return

/obj/machinery/mass_driver/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	drive()
	..(severity)

/obj/machinery/mass_driver/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		to_chat(user, "You hack the Mass Driver, radically increasing the force at which it'll throw things. Better not stand in its way.")
		return 1
	return -1

////////////////MASS BUMPER///////////////////

/obj/machinery/mass_driver/bumper
	name = "mass bumper"
	desc = "Now you're here, now you're over there."
	density = 1

/obj/machinery/mass_driver/bumper/Bumped(M as mob|obj)
	density = 0
	step(M, get_dir(M,src))
	spawn(1)
		density = 1
	drive()
	return

////////////////MASS DRIVER FRAME///////////////////

/obj/machinery/mass_driver_frame
	name = "mass driver frame"
	icon = 'icons/obj/objects.dmi'
	icon_state = "mass_driver_b0"
	density = 0
	anchored = 0
	var/build = 0

/obj/machinery/mass_driver_frame/attackby(var/obj/item/W as obj, var/mob/user as mob)
	switch(build)
		if(0) // Loose frame
			if(istype(W, /obj/item/wrench))
				to_chat(user, "You begin to anchor \the [src] on the floor.")
				playsound(get_turf(src), W.usesound, 50, 1)
				if(do_after(user, 10 * W.toolspeed, target = src) && (build == 0))
					to_chat(user, "<span class='notice'>You anchor \the [src]!</span>")
					anchored = 1
					build++
					update_icon()
				return 1
			return
		if(1) // Fixed to the floor
			if(istype(W, /obj/item/wrench))
				to_chat(user, "You begin to de-anchor \the [src] from the floor.")
				playsound(get_turf(src), W.usesound, 50, 1)
				if(do_after(user, 10 * W.toolspeed, target = src) && (build == 1))
					build--
					update_icon()
					anchored = 0
					to_chat(user, "<span class='notice'>You de-anchored \the [src]!</span>")
				return 1
		if(2) // Welded to the floor
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				to_chat(user, "You start adding cables to \the [src]...")
				playsound(get_turf(src), C.usesound, 50, 1)
				if(do_after(user, 20 * C.toolspeed, target = src) && (C.amount >= 2) && (build == 2))
					C.use(2)
					to_chat(user, "<span class='notice'>You've added cables to \the [src].</span>")
					build++
					update_icon()
			return
		if(3) // Wired
			if(istype(W, /obj/item/wirecutters))
				to_chat(user, "You begin to remove the wiring from \the [src].")
				if(do_after(user, 10 * W.toolspeed, target = src) && (build == 3))
					new /obj/item/stack/cable_coil(loc,2)
					playsound(get_turf(src), W.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You've removed the cables from \the [src].</span>")
					build--
					update_icon()
				return 1
			if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/rods/R = W
				to_chat(user, "You begin to complete \the [src]...")
				playsound(get_turf(src), R.usesound, 50, 1)
				if(do_after(user, 20 * R.toolspeed, target = src) && (R.amount >= 2) && (build == 3))
					R.use(2)
					to_chat(user, "<span class='notice'>You've added the grille to \the [src].</span>")
					build++
					update_icon()
				return 1
			return
		if(4) // Grille in place
			if(istype(W, /obj/item/crowbar))
				to_chat(user, "You begin to pry off the grille from \the [src]...")
				playsound(get_turf(src), W.usesound, 50, 1)
				if(do_after(user, 30 * W.toolspeed, target = src) && (build == 4))
					new /obj/item/stack/rods(loc,2)
					build--
					update_icon()
				return 1
			if(istype(W, /obj/item/screwdriver))
				to_chat(user, "You finalize the Mass Driver...")
				playsound(get_turf(src), W.usesound, 50, 1)
				var/obj/machinery/mass_driver/M = new(get_turf(src))
				M.dir = src.dir
				qdel(src)
				return 1
			return
	return ..()

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
	update_icon()

/obj/machinery/mass_driver_frame/update_icon()
	icon_state = "mass_driver_b[build]"

/obj/machinery/mass_driver_frame/verb/rotate()
	set category = "Object"
	set name = "Rotate Frame"
	set src in view(1)

	if( usr.stat || usr.restrained()  || (usr.status_flags & FAKEDEATH))
		return

	src.dir = turn(src.dir, -90)
	return
