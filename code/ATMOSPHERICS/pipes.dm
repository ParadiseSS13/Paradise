/obj/machinery/atmospherics/pipe

	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent

	var/volume = 0
	var/frozen = 0 // used by the pipe freezer
	force = 20

	layer = 2.4 //under wires with their 2.44
	use_power = 0

	var/alert_pressure = 80*ONE_ATMOSPHERE
		//minimum pressure before check_pressure(...) should be called
/obj/machinery/atmospherics/pipe/New()
	..()
	//so pipes under walls are hidden
	if(istype(get_turf(src), /turf/simulated/wall) || istype(get_turf(src), /turf/simulated/shuttle/wall) || istype(get_turf(src), /turf/unsimulated/wall))
		level = 1

/obj/machinery/atmospherics/pipe/proc/pipeline_expansion()
	return null

/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	//Return 1 if parent should continue checking other pipes
	//Return null if parent should stop checking other pipes. Recall: del(src) will by default return null

	return 1

/obj/machinery/atmospherics/pipe/return_air()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.air

/obj/machinery/atmospherics/pipe/build_network()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.return_network()

/obj/machinery/atmospherics/pipe/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.network_expand(new_network, reference)

/obj/machinery/atmospherics/pipe/return_network(obj/machinery/atmospherics/reference)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.return_network(reference)


/obj/machinery/atmospherics/pipe/Destroy()
	del(parent)
	if(air_temporary && loc)
		loc.assume_air(air_temporary)

	..()

/obj/machinery/atmospherics/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if (istype(src, /obj/machinery/atmospherics/pipe/tank))
		return ..()
	if (istype(src, /obj/machinery/atmospherics/pipe/vent))
		return ..()

	if(istype(W,/obj/item/device/pipe_painter))
		return 0

	if (istype(W, /obj/item/device/pipe_freezer))
		if(!src.frozen) // If the pipe is not already frozen
			user << "\red You begin to freeze the [src]"
			if (do_after(user, 60))
				user.visible_message( \
					"[user] freezes \the [src].", \
					"\blue You finished freezing \the [src].", \
					"You hear the hiss of gas.")
				src.frozen = 1
				spawn (200)
					src.frozen = 0
					src.visible_message( \
					"\the ice arounds the [src] melts.", \
					"\blue Your frozen [src] has thawed.", \
					"You hear dripping water.")

		add_fingerprint(user)
		return 1

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	var/turf/T = src.loc
	if (level==1 && isturf(T) && T.intact)
		user << "\red You must remove the plating first."
		return 1

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		if (!src.frozen) // If the pipe is not frozen
			user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
			add_fingerprint(user)
			return 1
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user << "\blue You begin to unfasten \the [src]..."
	if (do_after(user, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"\blue You have unfastened \the [src].", \
			"You hear ratchet.")
		var/obj/item/P = new /obj/item/pipe(loc, make_from=src)
		for (var/obj/machinery/meter/meter in T)
			if (meter.target == src)
				new /obj/item/pipe_meter(T)
				del(meter)
		if(P)
			transfer_fingerprints_to(P)
			P.add_fingerprint(user)
		qdel(src)
	return 1

/obj/machinery/atmospherics/proc/change_color(var/new_color)
	//only pass valid pipe colors please ~otherwise your pipe will turn invisible
	if(!pipe_color_check(new_color))
		return

	pipe_color = new_color
	update_icon()

/*
/obj/machinery/atmospherics/pipe/add_underlay(var/obj/machinery/atmospherics/node, var/direction)
	if(istype(src, /obj/machinery/atmospherics/pipe/tank))	//todo: move tanks to unary devices
		return ..()

	if(node)
		var/temp_dir = get_dir(src, node)
		underlays += icon_manager.get_atmos_icon("pipe_underlay_intact", temp_dir, color_cache_name(node))
		return temp_dir
	else if(direction)
		underlays += icon_manager.get_atmos_icon("pipe_underlay_exposed", direction, pipe_color)
	else
		return null
*/

/obj/machinery/atmospherics/pipe/color_cache_name(var/obj/machinery/atmospherics/node)
	if(istype(src, /obj/machinery/atmospherics/pipe/tank))
		return ..()

	if(istype(node, /obj/machinery/atmospherics/pipe/manifold) || istype(node, /obj/machinery/atmospherics/pipe/manifold4w))
		if(pipe_color == node.pipe_color)
			return node.pipe_color
		else
			return null
	else if(istype(node, /obj/machinery/atmospherics/pipe/simple))
		return node.pipe_color
	else
		return pipe_color

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/atmos/pipes.dmi'
	icon_state = ""
	var/pipe_icon = "" //what kind of pipe it is and from which dmi is the icon manager getting its icons, "" for simple pipes, "hepipe" for HE pipes, "hejunction" for HE junctions
	name = "pipe"
	desc = "A one meter section of regular pipe"

	volume = 70

	dir = SOUTH
	initialize_directions = SOUTH|NORTH

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2

	var/minimum_temperature_difference = 300
	var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No

	var/maximum_pressure = 70*ONE_ATMOSPHERE
	var/fatigue_pressure = 55*ONE_ATMOSPHERE
	alert_pressure = 55*ONE_ATMOSPHERE

	level = 1

/obj/machinery/atmospherics/pipe/simple/New()
	..()

	// Pipe colors and icon states are handled by an image cache - so color and icon should
	//  be null. For mapping purposes color is defined in the object definitions.
	icon = null
	alpha = 255

	switch(dir)
		if(SOUTH || NORTH)
			initialize_directions = SOUTH|NORTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST
		if(NORTHEAST)
			initialize_directions = NORTH|EAST
		if(NORTHWEST)
			initialize_directions = NORTH|WEST
		if(SOUTHEAST)
			initialize_directions = SOUTH|EAST
		if(SOUTHWEST)
			initialize_directions = SOUTH|WEST

/obj/machinery/atmospherics/pipe/simple/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/pipe/simple/process()
	if(!parent) //This should cut back on the overhead calling build_network thousands of times per cycle
		..()
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/simple/check_pressure(pressure)
	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - environment.return_pressure()

	if(pressure_difference > maximum_pressure)
		burst()

	else if(pressure_difference > fatigue_pressure)
		//TODO: leak to turf, doing pfshhhhh
		if(prob(5))
			burst()

	else return 1

/obj/machinery/atmospherics/pipe/simple/proc/burst()
	src.visible_message("\red \bold [src] bursts!");
	playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
	var/datum/effect/effect/system/harmless_smoke_spread/smoke = new
	smoke.set_up(1,0, src.loc, 0)
	smoke.start()
	del(src)

/obj/machinery/atmospherics/pipe/simple/proc/normalize_dir()
	if(dir==3)
		dir = 1
	else if(dir==12)
		dir = 4

/obj/machinery/atmospherics/pipe/simple/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)

	..()

/obj/machinery/atmospherics/pipe/simple/pipeline_expansion()
	return list(node1, node2)

/obj/machinery/atmospherics/pipe/simple/change_color(var/new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node1)
		node1.update_underlays()
	if(node2)
		node2.update_underlays()

/obj/machinery/atmospherics/pipe/simple/update_icon(var/safety = 0)
	if(!check_icon_cache())
		return

	alpha = 255

	overlays.Cut()

	if(!node1 && !node2)
		var/turf/T = get_turf(src)
		new /obj/item/pipe(loc, make_from=src)
		for (var/obj/machinery/meter/meter in T)
			if (meter.target == src)
				new /obj/item/pipe_meter(T)
				del(meter)
		qdel(src)
	else if(node1 && node2)
		overlays += icon_manager.get_atmos_icon("pipe", , pipe_color, pipe_icon + "intact" + icon_connect_type)
	else
		overlays += icon_manager.get_atmos_icon("pipe", , pipe_color, pipe_icon + "exposed[node1?1:0][node2?1:0]" + icon_connect_type)

/obj/machinery/atmospherics/pipe/simple/update_underlays()
	return

/obj/machinery/atmospherics/pipe/simple/initialize()
	normalize_dir()
	var/node1_dir
	var/node2_dir

	for(var/direction in cardinal)
		if(direction&initialize_directions)
			if (!node1_dir)
				node1_dir = direction
			else if (!node2_dir)
				node2_dir = direction

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_dir))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node1 = target
				break
	for(var/obj/machinery/atmospherics/target in get_step(src,node2_dir))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node2 = target
				break

	if(!node1 && !node2)
		qdel(src)
		return

	var/turf/T = get_turf(src)
	if(istype(T))
		hide(T.intact)
	update_icon()

/obj/machinery/atmospherics/pipe/simple/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			del(parent)
		node2 = null

	update_icon()

	return null

/obj/machinery/atmospherics/pipe/simple/visible
	icon_state = "intact"
	level = 2

/obj/machinery/atmospherics/pipe/simple/visible/scrubbers
	name = "Scrubbers pipe"
	desc = "A one meter section of scrubbers pipe"
	icon_state = "intact-scrubbers"
	connect_types = list(3)
	layer = 2.38
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/simple/visible/supply
	name = "Air supply pipe"
	desc = "A one meter section of supply pipe"
	icon_state = "intact-supply"
	connect_types = list(2)
	layer = 2.39
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/simple/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/simple/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/simple/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/simple/visible/purple
	color = PIPE_COLOR_PURPLE

/obj/machinery/atmospherics/pipe/simple/hidden
	icon_state = "intact"
	level = 1
	alpha = 128		//set for the benefit of mapping - this is reset to opaque when the pipe is spawned in game

/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers
	name = "Scrubbers pipe"
	desc = "A one meter section of scrubbers pipe"
	icon_state = "intact-scrubbers"
	connect_types = list(3)
	layer = 2.38
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/simple/hidden/supply
	name = "Air supply pipe"
	desc = "A one meter section of supply pipe"
	icon_state = "intact-supply"
	connect_types = list(2)
	layer = 2.39
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/simple/visible/universal
	name="Universal pipe adapter"
	desc = "An adapter for regular, supply and scrubbers pipes"
	connect_types = list(1,2,3)
	icon_state = "map_universal"

/obj/machinery/atmospherics/pipe/simple/visible/universal/update_icon(var/safety = 0)
	if(!check_icon_cache())
		return

	alpha = 255

	overlays.Cut()
	overlays += icon_manager.get_atmos_icon("pipe", , pipe_color, "universal")
	underlays.Cut()

	if (node1)
		universal_underlays(node1)
		if(node2)
			universal_underlays(node2)
		else
			var/node1_dir = get_dir(node1,src)
			universal_underlays(,node1_dir)
	else if (node2)
		universal_underlays(node2)
	else
		universal_underlays(,dir)
		universal_underlays(dir, -180)

/obj/machinery/atmospherics/pipe/simple/visible/universal/update_underlays()
	..()
	update_icon()



/obj/machinery/atmospherics/pipe/simple/hidden/universal
	name="Universal pipe adapter"
	desc = "An adapter for regular, supply and scrubbers pipes"
	connect_types = list(1,2,3)
	icon_state = "map_universal"

/obj/machinery/atmospherics/pipe/simple/hidden/universal/update_icon(var/safety = 0)
	if(!check_icon_cache())
		return

	alpha = 255

	overlays.Cut()
	overlays += icon_manager.get_atmos_icon("pipe", , pipe_color, "universal")
	underlays.Cut()

	if (node1)
		universal_underlays(node1)
		if(node2)
			universal_underlays(node2)
		else
			var/node2_dir = turn(get_dir(src,node1),-180)
			universal_underlays(,node2_dir)
	else if (node2)
		universal_underlays(node2)
		var/node1_dir = turn(get_dir(src,node2),-180)
		universal_underlays(,node1_dir)
	else
		universal_underlays(,dir)
		universal_underlays(,turn(dir, -180))

/obj/machinery/atmospherics/pipe/simple/hidden/universal/update_underlays()
	..()
	update_icon()

/obj/machinery/atmospherics/proc/universal_underlays(var/obj/machinery/atmospherics/node, var/direction)
	var/turf/T = loc
	if(node)
		var/node_dir = get_dir(src,node)
		if(node.icon_connect_type == "-supply")
			add_underlay_adapter(T, , node_dir, "")
			add_underlay_adapter(T, node, node_dir, "-supply")
			add_underlay_adapter(T, , node_dir, "-scrubbers")
		else if (node.icon_connect_type == "-scrubbers")
			add_underlay_adapter(T, , node_dir, "")
			add_underlay_adapter(T, , node_dir, "-supply")
			add_underlay_adapter(T, node, node_dir, "-scrubbers")
		else
			add_underlay_adapter(T, node, node_dir, "")
			add_underlay_adapter(T, , node_dir, "-supply")
			add_underlay_adapter(T, , node_dir, "-scrubbers")
	else
		add_underlay_adapter(T, , direction, "-supply")
		add_underlay_adapter(T, , direction, "-scrubbers")
		add_underlay_adapter(T, , direction, "")

/obj/machinery/atmospherics/proc/add_underlay_adapter(var/turf/T, var/obj/machinery/atmospherics/node, var/direction, var/icon_connect_type) //modified from add_underlay, does not make exposed underlays
	if(node)
		if(T.intact && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe))
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "down" + icon_connect_type)
		else
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
	else
		underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "retracted" + icon_connect_type)

/obj/machinery/atmospherics/pipe/simple/hidden/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/simple/hidden/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/simple/hidden/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/simple/hidden/purple
	color = PIPE_COLOR_PURPLE

/obj/machinery/atmospherics/pipe/simple/insulated
	icon = 'icons/obj/atmospherics/red_pipe.dmi'
	icon_state = "intact"

	minimum_temperature_difference = 10000
	thermal_conductivity = 0
	maximum_pressure = 1000*ONE_ATMOSPHERE
	fatigue_pressure = 900*ONE_ATMOSPHERE
	alert_pressure = 900*ONE_ATMOSPHERE

	level = 2


/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/atmos/manifold.dmi'
	icon_state = ""
	name = "pipe manifold"
	desc = "A manifold composed of regular pipes"

	volume = 105

	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

	level = 1
	layer = 2.4 //under wires with their 2.44

/obj/machinery/atmospherics/pipe/manifold/New()
	..()
	alpha = 255
	icon = null

	switch(dir)
		if(NORTH)
			initialize_directions = EAST|SOUTH|WEST
		if(SOUTH)
			initialize_directions = WEST|NORTH|EAST
		if(EAST)
			initialize_directions = SOUTH|WEST|NORTH
		if(WEST)
			initialize_directions = NORTH|EAST|SOUTH

/obj/machinery/atmospherics/pipe/manifold/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/pipe/manifold/pipeline_expansion()
	return list(node1, node2, node3)

/obj/machinery/atmospherics/pipe/manifold/process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/manifold/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)
	if(node3)
		node3.disconnect(src)

	..()

/obj/machinery/atmospherics/pipe/manifold/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			del(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			del(parent)
		node3 = null

	update_icon()

	..()

/obj/machinery/atmospherics/pipe/manifold/change_color(var/new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node1)
		node1.update_underlays()
	if(node2)
		node2.update_underlays()
	if(node3)
		node3.update_underlays()

/obj/machinery/atmospherics/pipe/manifold/update_icon(var/safety = 0)
	if(!check_icon_cache())
		return

	alpha = 255

	if(!node1 && !node2 && !node3)
		var/turf/T = get_turf(src)
		new /obj/item/pipe(loc, make_from=src)
		for (var/obj/machinery/meter/meter in T)
			if (meter.target == src)
				new /obj/item/pipe_meter(T)
				del(meter)
		qdel(src)
	else
		overlays.Cut()
		overlays += icon_manager.get_atmos_icon("manifold", , pipe_color, "core" + icon_connect_type)
		overlays += icon_manager.get_atmos_icon("manifold", , , "clamps" + icon_connect_type)
		underlays.Cut()

		var/turf/T = get_turf(src)
		var/list/directions = list(NORTH, SOUTH, EAST, WEST)
		var/node1_direction = get_dir(src, node1)
		var/node2_direction = get_dir(src, node2)
		var/node3_direction = get_dir(src, node3)

		directions -= dir

		directions -= add_underlay(T,node1,node1_direction,icon_connect_type)
		directions -= add_underlay(T,node2,node2_direction,icon_connect_type)
		directions -= add_underlay(T,node3,node3_direction,icon_connect_type)

		for(var/D in directions)
			add_underlay(T,,D,icon_connect_type)

/obj/machinery/atmospherics/pipe/manifold/update_underlays()
	..()
	update_icon()

/obj/machinery/atmospherics/pipe/manifold/initialize()
	var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					var/c = check_connect_types(target,src)
					if (c)
						target.connected_to = c
						src.connected_to = c
						node1 = target
						connect_directions &= ~direction
						break
			if (node1)
				break


	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					var/c = check_connect_types(target,src)
					if (c)
						target.connected_to = c
						src.connected_to = c
						node2 = target
						connect_directions &= ~direction
						break
			if (node2)
				break


	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					var/c = check_connect_types(target,src)
					if (c)
						target.connected_to = c
						src.connected_to = c
						node3 = target
						connect_directions &= ~direction
						break
			if (node3)
				break

	if(!node1 && !node2 && !node3)
		del(src)
		return

	var/turf/T = get_turf(src)
	if(istype(T))
		hide(T.intact)
	update_icon()

/obj/machinery/atmospherics/pipe/manifold/visible
	icon_state = "map"
	level = 2

/obj/machinery/atmospherics/pipe/manifold/visible/scrubbers
	name="Scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes"
	icon_state = "map-scrubbers"
	connect_types = list(3)
	layer = 2.38
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold/visible/supply
	name="Air supply pipe manifold"
	desc = "A manifold composed of supply pipes"
	icon_state = "map-supply"
	connect_types = list(2)
	layer = 2.39
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold/visible/purple
	color = PIPE_COLOR_PURPLE

/obj/machinery/atmospherics/pipe/manifold/hidden
	icon_state = "map"
	level = 1
	alpha = 128		//set for the benefit of mapping - this is reset to opaque when the pipe is spawned in game

/obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers
	name="Scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes"
	icon_state = "map-scrubbers"
	connect_types = list(3)
	layer = 2.38
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold/hidden/supply
	name="Air supply pipe manifold"
	desc = "A manifold composed of supply pipes"
	icon_state = "map-supply"
	connect_types = list(2)
	layer = 2.39
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold/hidden/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold/hidden/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold/hidden/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold/hidden/purple
	color = PIPE_COLOR_PURPLE

/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/atmos/manifold.dmi'
	icon_state = ""
	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes"

	volume = 140

	dir = SOUTH
	initialize_directions = NORTH|SOUTH|EAST|WEST

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3
	var/obj/machinery/atmospherics/node4

	level = 1
	layer = 2.4 //under wires with their 2.44

/obj/machinery/atmospherics/pipe/manifold4w/New()
	..()
	alpha = 255
	icon = null

/obj/machinery/atmospherics/pipe/manifold4w/pipeline_expansion()
	return list(node1, node2, node3, node4)

/obj/machinery/atmospherics/pipe/manifold4w/process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/manifold4w/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)
	if(node3)
		node3.disconnect(src)
	if(node4)
		node4.disconnect(src)

	..()

/obj/machinery/atmospherics/pipe/manifold4w/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			del(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			del(parent)
		node3 = null

	if(reference == node4)
		if(istype(node4, /obj/machinery/atmospherics/pipe))
			del(parent)
		node4 = null

	update_icon()

	..()

/obj/machinery/atmospherics/pipe/manifold4w/change_color(var/new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node1)
		node1.update_underlays()
	if(node2)
		node2.update_underlays()
	if(node3)
		node3.update_underlays()
	if(node4)
		node4.update_underlays()

/obj/machinery/atmospherics/pipe/manifold4w/update_icon(var/safety = 0)
	if(!check_icon_cache())
		return

	alpha = 255

	if(!node1 && !node2 && !node3 && !node4)
		var/turf/T = get_turf(src)
		new /obj/item/pipe(loc, make_from=src)
		for (var/obj/machinery/meter/meter in T)
			if (meter.target == src)
				new /obj/item/pipe_meter(T)
				del(meter)
		qdel(src)
	else
		overlays.Cut()
		overlays += icon_manager.get_atmos_icon("manifold", , pipe_color, "4way" + icon_connect_type)
		overlays += icon_manager.get_atmos_icon("manifold", , , "clamps_4way" + icon_connect_type)
		underlays.Cut()

		/*
		var/list/directions = list(NORTH, SOUTH, EAST, WEST)

		directions -= add_underlay(node1)
		directions -= add_underlay(node2)
		directions -= add_underlay(node3)
		directions -= add_underlay(node4)

		for(var/D in directions)
			add_underlay(,D)
		*/

		var/turf/T = get_turf(src)
		var/list/directions = list(NORTH, SOUTH, EAST, WEST)
		var/node1_direction = get_dir(src, node1)
		var/node2_direction = get_dir(src, node2)
		var/node3_direction = get_dir(src, node3)
		var/node4_direction = get_dir(src, node4)

		directions -= dir

		directions -= add_underlay(T,node1,node1_direction,icon_connect_type)
		directions -= add_underlay(T,node2,node2_direction,icon_connect_type)
		directions -= add_underlay(T,node3,node3_direction,icon_connect_type)
		directions -= add_underlay(T,node4,node4_direction,icon_connect_type)

		for(var/D in directions)
			add_underlay(T,,D,icon_connect_type)

/obj/machinery/atmospherics/pipe/manifold4w/update_underlays()
	..()
	update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/initialize()

	for(var/obj/machinery/atmospherics/target in get_step(src,1))
		if(target.initialize_directions & 2)
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node1 = target
				break

	for(var/obj/machinery/atmospherics/target in get_step(src,2))
		if(target.initialize_directions & 1)
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node2 = target
				break

	for(var/obj/machinery/atmospherics/target in get_step(src,4))
		if(target.initialize_directions & 8)
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node3 = target
				break

	for(var/obj/machinery/atmospherics/target in get_step(src,8))
		if(target.initialize_directions & 4)
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node4 = target
				break

	if(!node1 && !node2 && !node3&& !node4)
		del(src)
		return

	var/turf/T = get_turf(src)
	if(istype(T))
		hide(T.intact)
	update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/visible
	icon_state = "map_4way"
	level = 2

/obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers
	name="4-way scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes"
	icon_state = "map_4way-scrubbers"
	connect_types = list(3)
	layer = 2.38
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/visible/supply
	name="4-way air supply pipe manifold"
	desc = "A manifold composed of supply pipes"
	icon_state = "map_4way-supply"
	connect_types = list(2)
	layer = 2.39
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold4w/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold4w/visible/purple
	color = PIPE_COLOR_PURPLE

/obj/machinery/atmospherics/pipe/manifold4w/hidden
	icon_state = "map_4way"
	level = 1
	alpha = 128		//set for the benefit of mapping - this is reset to opaque when the pipe is spawned in game

/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers
	name="4-way scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes"
	icon_state = "map_4way-scrubbers"
	connect_types = list(3)
	layer = 2.38
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply
	name="4-way air supply pipe manifold"
	desc = "A manifold composed of supply pipes"
	icon_state = "map_4way-supply"
	connect_types = list(2)
	layer = 2.39
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/hidden/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/hidden/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold4w/hidden/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold4w/hidden/purple
	color = PIPE_COLOR_PURPLE

/obj/machinery/atmospherics/pipe/cap
	name = "pipe endcap"
	desc = "An endcap for pipes"
	icon = 'icons/atmos/pipes.dmi'
	icon_state = "cap"
	level = 2
	layer = 2.4 //under wires with their 2.44

	volume = 35

	dir = SOUTH
	initialize_directions = SOUTH

	var/obj/machinery/atmospherics/node

/obj/machinery/atmospherics/pipe/cap/New()
	..()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/cap/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/pipe/cap/pipeline_expansion()
	return list(node)

/obj/machinery/atmospherics/pipe/cap/process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL
/obj/machinery/atmospherics/pipe/cap/Destroy()
	if(node)
		node.disconnect(src)

	..()

/obj/machinery/atmospherics/pipe/cap/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node)
		if(istype(node, /obj/machinery/atmospherics/pipe))
			del(parent)
		node = null

	update_icon()

	..()

/obj/machinery/atmospherics/pipe/cap/change_color(var/new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node)
		node.update_underlays()

/obj/machinery/atmospherics/pipe/cap/update_icon(var/safety = 0)
	if(!check_icon_cache())
		return

	alpha = 255

	overlays.Cut()
	overlays += icon_manager.get_atmos_icon("pipe", , pipe_color, "cap" + icon_connect_type)

/obj/machinery/atmospherics/pipe/cap/initialize()
	for(var/obj/machinery/atmospherics/target in get_step(src, dir))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node = target
				break

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	update_icon()

/obj/machinery/atmospherics/pipe/cap/visible
	level = 2
	icon_state = "cap"

/obj/machinery/atmospherics/pipe/cap/visible/scrubbers
	name = "scrubbers pipe endcap"
	desc = "An endcap for scrubbers pipes"
	icon_state = "cap-scrubbers"
	connect_types = list(3)
	layer = 2.38
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/cap/visible/supply
	name = "supply pipe endcap"
	desc = "An endcap for supply pipes"
	icon_state = "cap-supply"
	connect_types = list(2)
	layer = 2.39
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/cap/hidden
	level = 1
	icon_state = "cap"
	alpha = 128

/obj/machinery/atmospherics/pipe/cap/hidden/scrubbers
	name = "scrubbers pipe endcap"
	desc = "An endcap for scrubbers pipes"
	icon_state = "cap-scrubbers"
	connect_types = list(3)
	layer = 2.38
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/cap/hidden/supply
	name = "supply pipe endcap"
	desc = "An endcap for supply pipes"
	icon_state = "cap-supply"
	connect_types = list(2)
	layer = 2.39
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/tank
	icon = 'icons/atmos/tank.dmi'
	icon_state = "air_map"

	name = "Pressure Tank"
	desc = "A large vessel containing pressurized gas."

	volume = 10000 //in liters, 1 meters by 1 meters by 2 meters ~tweaked it a little to simulate a pressure tank without needing to recode them yet

	level = 1
	dir = SOUTH
	initialize_directions = SOUTH
	density = 1

	var/obj/machinery/atmospherics/node1

/obj/machinery/atmospherics/pipe/tank/New()
	icon_state = "air"
	initialize_directions = dir
	..()

/obj/machinery/atmospherics/pipe/tank/process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/tank/Destroy()
	if(node1)
		node1.disconnect(src)

	..()

/obj/machinery/atmospherics/pipe/tank/pipeline_expansion()
	return list(node1)

/obj/machinery/atmospherics/pipe/tank/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, dir)

/obj/machinery/atmospherics/pipe/tank/hide()
	update_underlays()

/obj/machinery/atmospherics/pipe/tank/initialize()
	var/connect_direction = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node1 = target
				break

	update_underlays()

/obj/machinery/atmospherics/pipe/tank/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	update_underlays()

	return null

/obj/machinery/atmospherics/pipe/tank/attackby(var/obj/item/W as obj, var/mob/user as mob, params)
	if(istype(W, /obj/item/device/pipe_painter))
		return

	if(istype(W, /obj/item/device/analyzer) && in_range(user, src))
		for (var/mob/O in viewers(user, null))
			O << "\red [user] has used the analyzer on \icon[icon]"

		var/pressure = parent.air.return_pressure()
		var/total_moles = parent.air.total_moles()

		user << "\blue Results of analysis of \icon[icon]"
		if (total_moles>0)
			var/o2_concentration = parent.air.oxygen/total_moles
			var/n2_concentration = parent.air.nitrogen/total_moles
			var/co2_concentration = parent.air.carbon_dioxide/total_moles
			var/toxins_concentration = parent.air.toxins/total_moles

			var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+toxins_concentration)

			user << "\blue Pressure: [round(pressure,0.1)] kPa"
			user << "\blue Nitrogen: [round(n2_concentration*100)]%"
			user << "\blue Oxygen: [round(o2_concentration*100)]%"
			user << "\blue CO2: [round(co2_concentration*100)]%"
			user << "\blue Toxins: [round(toxins_concentration*100)]%"
			if(unknown_concentration>0.01)
				user << "\red Unknown: [round(unknown_concentration*100)]%"
			user << "\blue Temperature: [round(parent.air.temperature-T0C)]&deg;C"
		else
			user << "\blue Tank is empty!"

/obj/machinery/atmospherics/pipe/tank/air
	name = "Pressure Tank (Air)"
	icon_state = "air_map"

/obj/machinery/atmospherics/pipe/tank/air/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.oxygen = (25*ONE_ATMOSPHERE*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	air_temporary.nitrogen = (25*ONE_ATMOSPHERE*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()
	icon_state = "air"

/obj/machinery/atmospherics/pipe/tank/oxygen
	name = "Pressure Tank (Oxygen)"
	icon_state = "o2_map"

/obj/machinery/atmospherics/pipe/tank/oxygen/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.oxygen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()
	icon_state = "o2"

/obj/machinery/atmospherics/pipe/tank/nitrogen
	name = "Pressure Tank (Nitrogen)"
	icon_state = "n2_map"

/obj/machinery/atmospherics/pipe/tank/nitrogen/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.nitrogen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()
	icon_state = "n2"

/obj/machinery/atmospherics/pipe/tank/carbon_dioxide
	name = "Pressure Tank (Carbon Dioxide)"
	icon_state = "co2_map"

/obj/machinery/atmospherics/pipe/tank/carbon_dioxide/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.carbon_dioxide = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()
	icon_state = "co2"

/obj/machinery/atmospherics/pipe/tank/toxins
	name = "Pressure Tank (Toxins)"
	icon_state = "toxins_map"

/obj/machinery/atmospherics/pipe/tank/toxins/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.toxins = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()
	icon_state = "toxins"

/obj/machinery/atmospherics/pipe/tank/nitrous_oxide
	name = "Pressure Tank (Nitrous Oxide)"
	icon_state = "n2o_map"

/obj/machinery/atmospherics/pipe/tank/nitrous_oxide/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T0C

	var/datum/gas/sleeping_agent/trace_gas = new
	trace_gas.moles = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	air_temporary.trace_gases += trace_gas

	..()
	icon_state = "n2o"

/obj/machinery/atmospherics/pipe/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "intact"

	name = "Vent"
	desc = "A large air vent"

	level = 1

	volume = 250

	dir = SOUTH
	initialize_directions = SOUTH

	var/build_killswitch = 1

	var/obj/machinery/atmospherics/node1

/obj/machinery/atmospherics/pipe/vent/New()
	initialize_directions = dir
	..()

/obj/machinery/atmospherics/pipe/vent/high_volume
	name = "Larger vent"
	volume = 1000

/obj/machinery/atmospherics/pipe/vent/process()
	if(!parent)
		if(build_killswitch <= 0)
			. = PROCESS_KILL
		else
			build_killswitch--
		..()
		return
	else
		parent.mingle_with_turf(loc, volume)

/obj/machinery/atmospherics/pipe/vent/Destroy()
	if(node1)
		node1.disconnect(src)

	..()

/obj/machinery/atmospherics/pipe/vent/pipeline_expansion()
	return list(node1)

/obj/machinery/atmospherics/pipe/vent/update_icon()
	if(node1)
		icon_state = "intact"

		dir = get_dir(src, node1)

	else
		icon_state = "exposed"

/obj/machinery/atmospherics/pipe/vent/initialize()
	var/connect_direction = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node1 = target
				break

	update_icon()

/obj/machinery/atmospherics/pipe/vent/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	update_icon()

	return null

/obj/machinery/atmospherics/pipe/vent/hide(var/i) //to make the little pipe section invisible, the icon changes.
	if(node1)
		icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
		dir = get_dir(src, node1)
	else
		icon_state = "exposed"
