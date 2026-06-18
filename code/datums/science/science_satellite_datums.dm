/datum/satellite_stats
	var/weight = 0
	var/fuel_efficiency = 0
	var/fuel_capacity = 0
	var/science_multiplier = 0
	var/passive_power_generation = 0
	var/active_power_generation = 0
	var/power_consumption = 0
	var/power_capacity = 0
	var/current_fuel = 0
	var/current_power = 0
	var/engine_speed_constant = 0.0001//10
	var/fuel_usage = 1
	var/list/capabilities = list()

/datum/orbit_data
	var/apoapsis = -INFINITY // furthest
	var/vector/apoapsis_position
	var/periapsis = INFINITY // closest
	var/vector/periapsis_position

	var/atmosphere_start = 150
	var/light_airdrag = 0.99
	var/atmosphere_thick = 130
	var/thick_airdrag = 0.8

	//var/eccentricity = 0 // how oval the orbit is
	var/inclination = 0 // how tilted the orbit is
	//var/latitude = 0 // the center latitude of the orbit
	//var/altitude = 40000
	var/const/period_multiplier = 10//80000//4000
	var/period = 20 MINUTES // probably breaks physics, but its a video game
	//var/planet_mass = 5 // lavaland is less dense than earth, and will have a lower gravity
	var/launch_time = INFINITY

	//var/velocity = 0 // -1, 1

	//var/orbit_progress = 0 // 0, 1 - 0(periapsis), 0.5(apoapsis)

	var/list/planned_maneuvers = new()
	var/datum/satellite_stats/stats
	var/obj/machinery/science_satellite/owner

	var/has_been_launched = FALSE

	var/planet_gravitational_constant = 9
	var/planet_mass = 442
	var/gravitational_parameter = 3986// planet_gravitational_constant * planet_mass // known as "GM" gravity times mass. Default here is 3986 based off earth

	var/vector/position
	var/vector/velocity

	var/list/planned_orbit = list()
	var/should_update_orbit = TRUE

	var/data_processing_cooldown = 60 SECONDS

/// Called by `SSscience_satellitel.dm` in order to make the satellite move
/datum/orbit_data/proc/heartbeat(delta_time)
	if(!has_been_launched) // will trigger if no maneuvers have been planned
		return

	data_processing_cooldown -= delta_time

	if(!position)
		position = vector(0, 0, 300) // default velocity is calculated from this. Based off geostationary orbit on earth in km
		velocity = vector(3.6, 0, 0) // when a velocity parameter is equal to (gravitational parameter / magnitude of the position vector) we get a circular orbit.

	var/list/step = calculate_physics_step(position, velocity) // where the satellite should move this tick
	position = step["position"]
	velocity = step["velocity"]
	if(step["distance"] < atmosphere_start)
		should_update_orbit = TRUE
		velocity *= light_airdrag
	if(step["distance"] < atmosphere_thick) // even more airdrag
		velocity *= thick_airdrag

	for(var/datum/maneuver_data/maneuver in planned_maneuvers)
		if(world.time > maneuver.world_time_at_maneuver)
			if(launch_time > world.time) // yet to launch
				launch_time = world.time
			perform_burn(maneuver, stats)

	if(should_update_orbit) // if a burn has been performed
		should_update_orbit = FALSE
		var/list/last_step = step//list() // used to trace a predicted path for TGUI

		var/vector/initial_step = last_step["position"]

		var/list/path = list()
		path += initial_step
		apoapsis = -INFINITY
		periapsis = INFINITY
		//log_debug("-----------------physics step----------------")
		for(var/i = 0; i < 6000; i++) // TODO: Refine this number, its way to high
			//if(i < 7)
			//	log_debug("pos: ([last_step["position"]]) vel: ([last_step["velocity"]])")
			last_step = calculate_physics_step(last_step["position"], last_step["velocity"])

			var/vector/point = last_step["position"]

			path += point
			if(last_step["distance"] > apoapsis)
				apoapsis = last_step["distance"]
				apoapsis_position = last_step["position"]
			if(last_step["distance"] < periapsis)
				periapsis = last_step["distance"]
				periapsis_position = last_step["position"]
		planned_orbit = path

/datum/orbit_data/proc/process_weather_node(datum/weather_node/weather_node)
	for(var/capability in stats.capabilities)
		switch(capability)
			if(SCIENCE_SATELLITE_HAS_METEOROLOGY)
				if(istype(weather_node, /datum/weather_node/ash_storm) ||\
				istype(weather_node, /datum/weather_node/wind) ||\
				istype(weather_node, /datum/weather_node/acid_rain)
				)
					owner.collect_data(weather_node.science_yield)
			if(SCIENCE_SATELLITE_HAS_MAGNETOMETER)
				if(istype(weather_node, /datum/weather_node/volcanism) ||\
				istype(weather_node, /datum/weather_node/pole)
				)
					owner.collect_data(weather_node.science_yield)

/datum/orbit_data/proc/calculate_physics_step(vector/pos, vector/vel)
	var/dist = pos.size
	if(dist == 0)
		dist = 1 // we should delete the satellite as part of a crash into the planet before this, but just in case
	var/gravitational_pull = -gravitational_parameter / (dist ** 3)

	var/delta_time = 2 //TODO: Set to 0.1
	// calculate acceleration towards planet
	var/vector/accel = pos * gravitational_pull

	// get new velocity using acceleration
	var/vector/new_vel = vel + accel * delta_time

	// get new position using new velocity
	var/vector/new_pos = pos + new_vel * delta_time

	return list(
		"velocity" = new_vel,
		"position" = new_pos,
		"distance" = dist
		)

/// Performs a fraction of the maneuver
/datum/orbit_data/proc/perform_burn(datum/maneuver_data/maneuver, datum/satellite_stats/satellite_stats)

	if(!maneuver.magnitude)
		planned_maneuvers -= maneuver
		return

	// subtract from the maneuvers equally and proportionately
	var/fraction_burn = 1
	if(maneuver.burn_time > maneuver.burn_constant)
		maneuver.burn_time -= maneuver.burn_constant
	else if(maneuver.burn_time > 0)
		fraction_burn = maneuver.burn_time / maneuver.burn_constant
		maneuver.burn_time = 0
	else
		planned_maneuvers -= maneuver
		return

	var/vector/vel_copy = vector(velocity) // we need to copy the vectors as Normalize() modifies the vector itself!
	var/vector/pos_copy = vector(position)

	var/vector/prograde = vel_copy.Normalize()
	var/vector/radial = pos_copy.Normalize()

	var/vector/normal_cross = position.Cross(velocity) // Cross() returns a new vector though
	var/vector/normal = normal_cross.Normalize()

	//var/radial_cross = vector_3_cross(normal["x"], normal["y"], normal["z"], prograde["x"], prograde["y"], prograde["z"])

	velocity += prograde * maneuver.prograde * satellite_stats.engine_speed_constant * fraction_burn

	velocity += normal * maneuver.normal * satellite_stats.engine_speed_constant * fraction_burn

	velocity += radial * maneuver.radial * satellite_stats.engine_speed_constant * fraction_burn

	should_update_orbit = TRUE

/// Adds a manuever to the orbit
/// * `prograde` - can be negative. Affects the size of the orbit
/// * `normal` - can be negative. Affects how tilted the orbit is
/// * `time_to_maneuver` - deciseconds until the maneuver
/// * `burn_time` - how many ticks this should be done
/datum/orbit_data/proc/add_maneuver(prograde, normal, time_to_maneuver, burn_time, radial = 0)
	if(!has_been_launched)
		for(var/capability in stats.capabilities)
			if(capability == SCIENCE_SATELLITE_HAS_PLASMA_LAB)
				owner.collect_data(50)

	has_been_launched = TRUE // TODO: Use launch call

	var/datum/maneuver_data/maneuver = new()
	maneuver.prograde = prograde
	maneuver.normal = normal
	maneuver.radial = radial
	maneuver.magnitude = maneuver.get_magnitude()

	/*
	//normalize the vector
	maneuver.prograde /= maneuver.magnitude
	maneuver.normal /= maneuver.magnitude
	maneuver.radial /= maneuver.magnitude
	*/
	maneuver.world_time_at_maneuver = time_to_maneuver + world.time
	maneuver.burn_time = burn_time

	planned_maneuvers += maneuver

/datum/maneuver_data
	var/prograde = 0
	var/normal = 0
	var/radial = 0
	var/magnitude = 0
	var/world_time_at_maneuver = INFINITY
	var/burn_time = 0
	var/const/burn_constant = 1 SECONDS

/datum/maneuver_data/proc/get_magnitude()
	return ROOT(prograde ** 2 + normal ** 2 + radial ** 2, 2)

////////////////////////////////////////
// MARK: Chassis stats (base)
////////////////////////////////////////

/datum/satellite_stats/base_stats
	weight = 1
	fuel_efficiency = 1
	fuel_capacity = 1
	science_multiplier = 1
	passive_power_generation = 0
	active_power_generation = 0
	power_consumption = 0
	power_capacity = 1
	current_fuel = 1
	current_power = 1

////////////////////////////////////////
// MARK: Computers
////////////////////////////////////////

/datum/satellite_stats/computer/basic
	weight = 10
	power_consumption = 10
	science_multiplier = 10
	power_capacity = 10

/datum/satellite_stats/computer/science
	weight = 10
	power_consumption = 25
	science_multiplier = 20
	power_capacity = 10

/datum/satellite_stats/computer/efficient
	weight = 10
	power_consumption = 7
	science_multiplier = 5
	power_capacity = 10

////////////////////////////////////////
// MARK: Engines
////////////////////////////////////////

/datum/satellite_stats/engine/basic_engine
	weight = 10
	fuel_capacity = 10
	fuel_efficiency = 10
	active_power_generation = 1

/datum/satellite_stats/engine/small_engine
	weight = 5
	fuel_capacity = 5
	fuel_efficiency = 9
	active_power_generation = 1

/datum/satellite_stats/engine/ion_engine
	weight = 10
	fuel_capacity = 1
	fuel_efficiency = 50
	power_consumption = 10
	capabilities = list(SCIENCE_SATELLITE_NEEDS_VACUUM)

////////////////////////////////////////
// MARK: Science instruments
////////////////////////////////////////

/datum/satellite_stats/science_instrument/meteorological_surveyor
	weight = 10
	power_consumption = 10
	capabilities = list(SCIENCE_SATELLITE_HAS_METEOROLOGY)

/datum/satellite_stats/science_instrument/plasma_lab
	weight = 10
	power_consumption = 5
	capabilities = list(SCIENCE_SATELLITE_HAS_PLASMA_LAB)

/datum/satellite_stats/science_instrument/magnetometer
	weight = 10
	power_consumption = 10
	capabilities = list(SCIENCE_SATELLITE_HAS_MAGNETOMETER)


////////////////////////////////////////
// MARK: Misc parts
////////////////////////////////////////

/datum/satellite_stats/misc_part/solar_panel
	weight = 2
	passive_power_generation = 5

/datum/satellite_stats/misc_part/electric_generator
	weight = 5
	passive_power_generation = 20

/datum/satellite_stats/misc_parts/power_cell
	weight = 5
	power_capacity = 20
