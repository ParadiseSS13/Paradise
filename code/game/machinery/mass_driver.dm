/*
	Mass Driver
	Mass Driver Frame
*/

#define DRIVER_FRAME 0
#define DRIVER_BOLTS 1
#define DRIVER_WELDED 2
#define DRIVER_WIRED 3
#define DRIVER_GRILLE 4

/obj/machinery/mass_driver
	name = "mass driver"
	desc = "Shoots things into space."
	icon = 'icons/obj/objects.dmi'
	icon_state = "mass_driver"
	anchored = TRUE
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
		to_chat(user, "<span class='notice'>You begin to unscrew the bolts off [src]...</span>")
		playsound(get_turf(src), W.usesound, 50, 1)
		if(do_after(user, 30 * W.toolspeed, target = src))
			var/obj/machinery/mass_driver_frame/F = new(get_turf(src))
			F.dir = src.dir
			F.anchored = TRUE
			F.buildstage = DRIVER_GRILLE
			F.update_icon()
			qdel(src)
		return 1

	return ..()

/obj/machinery/mass_driver/multitool_menu(mob/user, obj/item/multitool/P)
	return {"
	<ul>
	<li>[format_tag("ID Tag","id_tag","set_id")]</li>
	</ul>"}

/obj/machinery/mass_driver/proc/drive(amount)
	if(stat & (BROKEN|NOPOWER))
		return
	use_power(500*power)
	var/O_limit = 0
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if((!O.anchored && O.move_resist != INFINITY) || istype(O, /obj/mecha)) //Mechs need their launch platforms. Also checks if something is anchored or has move resist INFINITY, which should stop ghost flinging.
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
		emagged = TRUE
		to_chat(user, "You hack the Mass Driver, radically increasing the force at which it'll throw things. Better not stand in its way.")
		return 1
	return -1

////////////////MASS BUMPER///////////////////

/obj/machinery/mass_driver/bumper
	name = "mass bumper"
	desc = "Now you're here, now you're over there."
	density = TRUE

/obj/machinery/mass_driver/bumper/Bumped(M as mob|obj)
	density = FALSE
	step(M, get_dir(M,src))
	spawn(1)
		density = TRUE
	drive()
	return

////////////////MASS DRIVER FRAME///////////////////

/obj/machinery/mass_driver_frame
	name = "mass driver frame"
	icon = 'icons/obj/objects.dmi'
	icon_state = "mass_driver_frame"
	density = FALSE
	anchored = FALSE
	var/buildstage = DRIVER_FRAME

/obj/machinery/mass_driver_frame/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(DRIVER_FRAME)
			. += "<span class='notice'>Its <i>unbolted</i> from the [get_turf(src)] and could be <b>welded</b> down.</span>"
		if(DRIVER_BOLTS)
			. += "<span class='notice'>It could be securely <i>welded</i> to the [get_turf(src)] or could be <b>unbolted</b>.</span>"
		if(DRIVER_WELDED)
			. += "<span class='notice'>Its could be <i>wired</i> or <b>sliced</b> away from [get_turf(src)].</span>"
		if(DRIVER_WIRED)
			. += "<span class='notice'>Its missing its <i>grille</i> and is <b>wired</b>.</span>"
		if(DRIVER_GRILLE)
			. += "<span class='notice'>Its maintenance panel is <i>screwed</i> open and its <b>grille</b> is installed.</span>"

/obj/machinery/mass_driver_frame/attackby(obj/item/W as obj, mob/user as mob)
	switch(buildstage)
		if(DRIVER_WELDED) // Welded to the floor
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				to_chat(user, "You start adding cables to \the [src]...")
				playsound(get_turf(src), C.usesound, 50, 1)
				if(do_after(user, 20 * C.toolspeed, target = src) && (C.get_amount() >= 2) && buildstage == DRIVER_WELDED)
					C.use(2)
					to_chat(user, "<span class='notice'>You've added cables to \the [src].</span>")
					buildstage = DRIVER_WIRED
			return
		if(DRIVER_WIRED) // Wired
			if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/rods/R = W
				to_chat(user, "You begin to complete \the [src]...")
				playsound(get_turf(src), R.usesound, 50, 1)
				if(do_after(user, 20 * R.toolspeed, target = src) && (R.get_amount() >= 2) && buildstage == DRIVER_WIRED)
					R.use(2)
					to_chat(user, "<span class='notice'>You've added the grille to \the [src].</span>")
					buildstage = DRIVER_GRILLE
				return 1
			return
	return ..()

/obj/machinery/mass_driver_frame/wrench_act(mob/living/user, obj/item/I)
	switch(buildstage)
		if(DRIVER_FRAME) // Loose frame
			. = TRUE
			to_chat(user, "You begin to anchor \the [src] on the floor.")
			if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume) || buildstage != DRIVER_FRAME)
				return
			to_chat(user, "<span class='notice'>You anchor \the [src]!</span>")
			anchored = TRUE
			buildstage = DRIVER_BOLTS
		if(DRIVER_BOLTS) // Fixed to the floor
			. = TRUE
			to_chat(user, "You begin to de-anchor \the [src] from the floor.")
			if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume) || buildstage != DRIVER_BOLTS)
				return
			buildstage = DRIVER_FRAME
			anchored = FALSE
			to_chat(user, "<span class='notice'>You de-anchored \the [src]!</span>")

/obj/machinery/mass_driver_frame/screwdriver_act(mob/living/user, obj/item/I)
	switch(buildstage)
		if(DRIVER_GRILLE) // Grille in place
			. = TRUE
			to_chat(user, "You finalize the Mass Driver...")
			if(!I.use_tool(src, user, 0, volume = I.tool_volume) || buildstage != DRIVER_GRILLE)
				return
			var/obj/machinery/mass_driver/M = new(get_turf(src))
			M.dir = dir
			qdel(src)

/obj/machinery/mass_driver_frame/wirecutter_act(mob/living/user, obj/item/I)
	switch(buildstage)
		if(DRIVER_WIRED) // Wired
			to_chat(user, "You begin to remove the wiring from \the [src].")
			if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume || buildstage != DRIVER_WIRED))
				return
			new /obj/item/stack/cable_coil(loc,2)
			to_chat(user, "<span class='notice'>You've removed the cables from \the [src].</span>")
			buildstage = DRIVER_WELDED
		if(DRIVER_GRILLE) // Grille in place
			. = TRUE
			to_chat(user, "You begin to cut [src]'s grille apart...")
			if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume) || buildstage != DRIVER_GRILLE)
				return
			to_chat(user, "You cut [src]'s grille apart.")
			new /obj/item/stack/rods(loc,2)
			buildstage = DRIVER_WIRED

/obj/machinery/mass_driver_frame/welder_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0))
		return
	switch(buildstage)
		if(DRIVER_FRAME) //can deconstruct
			. = TRUE
			WELDER_ATTEMPT_SLICING_MESSAGE
			if(I.use_tool(src, user, 30, volume = I.tool_volume) && buildstage == DRIVER_FRAME)
				WELDER_SLICING_SUCCESS_MESSAGE
				new /obj/item/stack/sheet/plasteel(drop_location(),3)
				qdel(src)
		if(DRIVER_BOLTS) //wrenched but not welded down
			. = TRUE
			WELDER_ATTEMPT_FLOOR_WELD_MESSAGE
			if(I.use_tool(src, user, 40, volume = I.tool_volume) && buildstage == DRIVER_BOLTS)
				WELDER_FLOOR_WELD_SUCCESS_MESSAGE
				buildstage = DRIVER_WELDED
		if(DRIVER_WELDED) //welded down
			. = TRUE
			WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
			if(I.use_tool(src, user, 40, volume = I.tool_volume) && buildstage == DRIVER_WELDED)
				WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
				buildstage = DRIVER_BOLTS

/obj/machinery/mass_driver_frame/verb/rotate() // This should be converted to Alt-Click or something
	set category = "Object"
	set name = "Rotate Frame"
	set src in view(1)

	if(usr.stat || usr.restrained() || HAS_TRAIT(usr, TRAIT_FAKEDEATH))
		return

	dir = turn(dir, -90)

#undef DRIVER_FRAME
#undef DRIVER_BOLTS
#undef DRIVER_WELDED
#undef DRIVER_WIRED
#undef DRIVER_GRILLE
