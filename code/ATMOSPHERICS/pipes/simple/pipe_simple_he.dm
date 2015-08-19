/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/atmos/heat.dmi'
	icon_state = "intact"
	pipe_icon = "hepipe"
	level = 2
	var/initialize_directions_he
	var/surface = 2

	minimum_temperature_difference = 20
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/process()
	if(!parent)
		..()
	else
		var/environment_temperature = 0
		if(istype(loc, /turf/simulated/))
			if(loc:blocks_air)
				environment_temperature = loc:temperature
			else
				var/datum/gas_mixture/environment = loc.return_air()
				environment_temperature = environment.temperature
		else
			environment_temperature = loc:temperature
		var/datum/gas_mixture/pipe_air = return_air()
		if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
			parent.temperature_interact(loc, volume, thermal_conductivity)



// BubbleWrap
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/New()
	..()
	initialize_directions_he = initialize_directions	// The auto-detection from /pipe is good enough for a simple HE pipe
	// BubbleWrap END

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/initialize()
	normalize_dir()
	var/node1_dir
	var/node2_dir

	for(var/direction in cardinal)
		if(direction&initialize_directions_he)
			if (!node1_dir)
				node1_dir = direction
			else if (!node2_dir)
				node2_dir = direction

	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,node1_dir))
		if(target.initialize_directions_he & get_dir(target,src))
			node1 = target
			break
	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,node2_dir))
		if(target.initialize_directions_he & get_dir(target,src))
			node2 = target
			break

	if(!node1 && !node2)
		qdel(src)
		return

	update_icon()
	return


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/hidden
	level=1
	icon_state="intact-f"

/////////////////////////////////
// JUNCTION
/////////////////////////////////
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'icons/atmos/junction.dmi'
	icon_state = "intact"
	pipe_icon = "hejunction"
	level = 2
	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	// BubbleWrap
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/New()
	.. ()
	switch ( dir )
		if ( SOUTH )
			initialize_directions = NORTH
			initialize_directions_he = SOUTH
		if ( NORTH )
			initialize_directions = SOUTH
			initialize_directions_he = NORTH
		if ( EAST )
			initialize_directions = WEST
			initialize_directions_he = EAST
		if ( WEST )
			initialize_directions = EAST
			initialize_directions_he = WEST
	// BubbleWrap END

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/initialize()
	for(var/obj/machinery/atmospherics/target in get_step(src,initialize_directions))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break
	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,initialize_directions_he))
		if(target.initialize_directions_he & get_dir(target,src))
			node2 = target
			break

	if(!node1 && !node2)
		qdel(src)
		return

	update_icon()
	return

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/hidden
	level=1
	icon_state="intact-f"
