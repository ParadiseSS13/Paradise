/obj/machinery/atmospherics/pipe/simple
	name = "pipe"
	desc = "A one meter section of regular pipe."
	icon = 'icons/atmos/pipes.dmi'
	icon_state = ""
	var/pipe_icon = "" //what kind of pipe it is and from which dmi is the icon manager getting its icons, "" for simple pipes, "hepipe" for HE pipes, "hejunction" for HE junctions

	volume = 70

	initialize_directions = SOUTH|NORTH

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2

	var/minimum_temperature_difference = 300
	var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No

	level = 1

/obj/machinery/atmospherics/pipe/simple/New()
	..()
	// Pipe colors and icon states are handled by an image cache - so color and icon should
	//  be null. For mapping purposes color is defined in the object definitions.
	icon = null
	alpha = 255

	switch(dir)
		if(SOUTH, NORTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST
		if(NORTHEAST)
			initialize_directions = NORTH|EAST
		if(NORTHWEST)
			initialize_directions = NORTH|WEST
		if(SOUTHEAST)
			initialize_directions = SOUTH|EAST
		if(SOUTHWEST)
			initialize_directions = SOUTH|WEST

/obj/machinery/atmospherics/pipe/simple/atmos_init(initPipe = 1)
	..()
	if(initPipe)
		normalize_dir()
		var/N = 2
		for(var/D in GLOB.cardinal)
			if(D & initialize_directions)
				N--
				for(var/obj/machinery/atmospherics/target in get_step(src, D))
					if(target.initialize_directions & get_dir(target,src))
						var/c = check_connect_types(target,src)
						if(!c)
							continue
						if(!node1 && N == 1)
							target.connected_to = c
							connected_to = c
							node1 = target
							break
						if(!node2 && N == 0)
							target.connected_to = c
							connected_to = c
							node2 = target
							break

		var/turf/T = loc			// hide if turf is not intact
		if(!T.transparent_floor)
			hide(T.intact)
		update_icon()

/obj/machinery/atmospherics/pipe/simple/proc/burst()
	src.visible_message("<span class='danger'>\The [src] bursts!</span>")
	playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, FALSE, loc)
	smoke.start()
	qdel(src)

/obj/machinery/atmospherics/pipe/simple/proc/normalize_dir()
	if(dir==3)
		dir = 1
	else if(dir==12)
		dir = 4

/obj/machinery/atmospherics/pipe/simple/Destroy()
	. = ..()

	if(node1)
		node1.disconnect(src)
		node1.defer_build_network()
		node1 = null
	if(node2)
		node2.disconnect(src)
		node2.defer_build_network()
		node2 = null

/obj/machinery/atmospherics/pipe/simple/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null
	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null
	check_nodes_exist()
	update_icon()
	..()

/obj/machinery/atmospherics/pipe/simple/pipeline_expansion()
	return list(node1, node2)

/obj/machinery/atmospherics/pipe/simple/change_color(new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node1)
		node1.update_underlays()
	if(node2)
		node2.update_underlays()

/obj/machinery/atmospherics/pipe/simple/update_overlays()
	. = ..()
	alpha = 255
	if(node1 && node2)
		. += GLOB.pipe_icon_manager.get_atmos_icon("pipe", null, pipe_color, pipe_icon + "intact" + icon_connect_type)
	else
		. += GLOB.pipe_icon_manager.get_atmos_icon("pipe", null, pipe_color, pipe_icon + "exposed[node1?1:0][node2?1:0]" + icon_connect_type)

// A check to make sure both nodes exist - self-delete if they aren't present
/obj/machinery/atmospherics/pipe/simple/check_nodes_exist()
	if(!node1 && !node2)
		deconstruct()
		return 0 // 0: No nodes exist
	// 1: 1-2 nodes exist, we continue existing
	return 1

/obj/machinery/atmospherics/pipe/simple/update_underlays()
	return

/obj/machinery/atmospherics/pipe/simple/hide(i)
	if(level == 1 && issimulatedturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
