/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/atmos/heat.dmi'
	icon_state = "intact"
	pipe_icon = "hepipe"
	level = 2
	var/initialize_directions_he
	var/surface = 2

	minimum_temperature_difference = 20
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

	color = "#404040"
	buckle_lying = TRUE
	var/icon_temperature = T20C //stop small changes in temperature causing icon refresh
	resistance_flags = LAVA_PROOF | FIRE_PROOF

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/process_atmos()
	var/environment_temperature = 0
	var/datum/gas_mixture/pipe_air = return_air()
	if(!pipe_air)
		return

	var/turf/simulated/T = loc
	if(istype(T))
		if(T.blocks_air)
			environment_temperature = T.temperature
		else
			var/datum/gas_mixture/environment = T.return_air()
			environment_temperature = environment.temperature
	else
		environment_temperature = T.temperature

	if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
		parent.temperature_interact(T, volume, thermal_conductivity)

	//Heat causes pipe to glow
	if(pipe_air.temperature && (icon_temperature > 500 || pipe_air.temperature > 500)) //glow starts at 500K
		if(abs(pipe_air.temperature - icon_temperature) > 10)
			icon_temperature = pipe_air.temperature

			var/h_r = heat2color_r(icon_temperature)
			var/h_g = heat2color_g(icon_temperature)
			var/h_b = heat2color_b(icon_temperature)

			if(icon_temperature < 2000)//scale glow until 2000K
				var/scale = (icon_temperature - 500) / 1500
				h_r = 64 + (h_r - 64) * scale
				h_g = 64 + (h_g - 64) * scale
				h_b = 64 + (h_b - 64) * scale

			animate(src, color = rgb(h_r, h_g, h_b), time = 20, easing = SINE_EASING)

	//burn any mobs buckled based on temperature
	if(has_buckled_mobs())
		var/heat_limit = 1000
		if(pipe_air.temperature > heat_limit + 1)
			for(var/m in buckled_mobs)
				var/mob/living/buckled_mob = m
				buckled_mob.apply_damage(4 * log(pipe_air.temperature - heat_limit), BURN, "chest")


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/New()
	..()
	initialize_directions_he = initialize_directions	// The auto-detection from /pipe is good enough for a simple HE pipe
	color = "#404040"

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/atmos_init(initPipe = 1)
	..(0)
	if(initPipe)
		normalize_dir()
		var/N = 2
		for(var/D in cardinal)
			if(D & initialize_directions_he)
				N--
				for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src, D))
					if(target.initialize_directions_he & get_dir(target,src))
						if(!node1 && N == 1)
							node1 = target
							break
						if(!node2 && N == 0)
							node2 = target
							break
		update_icon()

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

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/New()
	.. ()
	switch(dir)
		if(SOUTH)
			initialize_directions = NORTH
			initialize_directions_he = SOUTH
		if(NORTH)
			initialize_directions = SOUTH
			initialize_directions_he = NORTH
		if(EAST)
			initialize_directions = WEST
			initialize_directions_he = EAST
		if(WEST)
			initialize_directions = EAST
			initialize_directions_he = WEST

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/atmos_init()
	..(0)
	for(var/obj/machinery/atmospherics/target in get_step(src,initialize_directions))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break
	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,initialize_directions_he))
		if(target.initialize_directions_he & get_dir(target,src))
			node2 = target
			break

	update_icon()
	return

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/hidden
	level=1
	icon_state="intact-f"
