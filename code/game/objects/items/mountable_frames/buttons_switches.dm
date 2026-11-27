/obj/item/mounted/frame/driver_button
	name = "mass driver button frame"
	desc = "Used for repairing or building mass driver buttons."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt_frame"

	mount_requirements = MOUNTED_FRAME_SIMFLOOR
	metal_sheets_refunded = 1

/obj/item/mounted/frame/driver_button/do_build(turf/on_wall, mob/user)
	new /obj/machinery/driver_button(get_turf(user), get_dir(user, on_wall))
	qdel(src)

/obj/item/mounted/frame/light_switch
	name = "light switch frame"
	desc = "Used for repairing or building light switches."
	dir = NORTH
	icon = 'icons/obj/machines/light_switch.dmi'
	icon_state = "light-p"

	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE
	metal_sheets_refunded = 1

/obj/item/mounted/frame/light_switch/setDir(newdir)
	// we simply don't. NORTH facing switches have the largest surface area and
	// are the most legible in-hand and on the ground, and once the frame is
	// placed on a wall it's no longer a frame.
	return

/obj/item/mounted/frame/light_switch/do_build(turf/on_wall, mob/user)
	var/build_dir = get_dir(user, on_wall)
	// try_build only allows cardinal directions through at this point
	// so that's all we need to check for
	switch(build_dir)
		if(NORTH)
			new /obj/machinery/light_switch/directional/north(get_turf(user))
		if(SOUTH)
			new /obj/machinery/light_switch/directional/south(get_turf(user))
		if(EAST)
			new /obj/machinery/light_switch/directional/east(get_turf(user))
		if(WEST)
			new /obj/machinery/light_switch/directional/west(get_turf(user))

	qdel(src)

/obj/item/mounted/frame/light_switch/windowtint
	name = "window tint control button frame"
	desc = "Used for repairing or building window tint control buttons."

/obj/item/mounted/frame/light_switch/windowtint/do_build(turf/on_wall, mob/user)
	var/build_dir = get_dir(user, on_wall)
	// try_build only allows cardinal directions through at this point
	// so that's all we need to check for
	switch(build_dir)
		if(NORTH)
			new /obj/machinery/button/windowtint/directional/north(get_turf(user))
		if(SOUTH)
			new /obj/machinery/button/windowtint/directional/south(get_turf(user))
		if(EAST)
			new /obj/machinery/button/windowtint/directional/east(get_turf(user))
		if(WEST)
			new /obj/machinery/button/windowtint/directional/west(get_turf(user))

	qdel(src)
