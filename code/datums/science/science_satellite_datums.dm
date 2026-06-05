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

/datum/orbit_data
	var/apoapsis = -INFINITY // furthest
	var/periapsis = INFINITY // closest
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
	var/datum/satellite_stats/owner

	var/has_been_launched = FALSE

	var/planet_gravitational_constant = 9
	var/planet_mass = 442
	var/gravitational_parameter = 3986// planet_gravitational_constant * planet_mass // known as "GM" gravity times mass. Default here is 3986 based off earth

	var/posX = 300 // default velocity is calculated from this. Based off geostationary orbit on earth in km
	var/posY = 0
	var/posZ = 0

	// when a velocity parameter is equal to (gravitational parameter / magnitude of the position vector) we get a circular orbit.
	var/velX = 3.6
	var/velY = 0
	var/velZ = 0

	var/list/planned_orbit = list()
	var/should_update_orbit = TRUE

/datum/orbit_data/proc/vector_3_magnitude(x,y,z)
	return sqrt(x**2 + y**2 + z**2)


/datum/orbit_data/proc/vector_3_normalize(x,y,z)
	var/mag = vector_3_magnitude(x,y,z)
	if(mag == 0)
		mag = 1 // avoid divide by 0

	var/normalized = list()
	normalized["x"] = x / mag
	normalized["y"] = y / mag
	normalized["z"] = z / mag
	return normalized

/datum/orbit_data/proc/vector_3_cross(ax, ay, az, bx, by, bz)
	var/list/cross = list()
	cross["x"] = ay * bz - az * by
	cross["y"] = az * bx - ax * bz
	cross["z"] = ax * by - ay * bx

	return cross

/// Called by `SSscience_satellitel.dm` in order to make the satellite move
/datum/orbit_data/proc/heartbeat()

	/*
	for(var/datum/maneuver_data/maneuver in planned_maneuvers)
		if(world.time > maneuver.world_time_at_maneuver)
			if(launch_time > world.time) // yet to launch
				launch_time = world.time
	*/
	if(!has_been_launched) // will trigger if no maneuvers have been planned
		return

	var/step = calculate_physics_step(posX, posY, posZ, velX, velY, velZ) // where the satellite should move this tick
	posX = step["position"]["X"]
	posY = step["position"]["Y"]
	posZ = step["position"]["Z"]

	velX = step["velocity"]["X"]
	velY = step["velocity"]["Y"]
	velZ = step["velocity"]["Z"]

	for(var/datum/maneuver_data/maneuver in planned_maneuvers)
		if(world.time > maneuver.world_time_at_maneuver)
			if(launch_time > world.time) // yet to launch
				launch_time = world.time
			perform_burn(maneuver, owner)

	if(should_update_orbit) // if a burn has been performed
		should_update_orbit = FALSE
		var/last_step = step//list() // used to trace a predicted path for TGUI

		var/initial_step = list()
		initial_step["X"] = last_step["position"]["X"]
		initial_step["Y"] = last_step["position"]["Y"]
		initial_step["Z"] = last_step["position"]["Z"]


		var/list/path = list()
		path += initial_step
		apoapsis = -INFINITY
		periapsis = INFINITY
		for(var/i = 0; i < 3000; i++) // TODO: Refine this number, its way to high
			last_step = calculate_physics_step(last_step["position"]["X"], last_step["position"]["Y"], last_step["position"]["Z"], last_step["velocity"]["X"], last_step["velocity"]["Y"], last_step["velocity"]["Z"])

			var/point = list()
			point["X"] = last_step["position"]["X"]
			point["Y"] = last_step["position"]["Y"]
			point["Z"] = last_step["position"]["Z"]

			path += point
			if(last_step["distance"] > apoapsis)
				apoapsis = last_step["distance"]
			if(last_step["distance"] < periapsis)
				periapsis = last_step["distance"]
		planned_orbit = path

	/*
	velocity = get_velocity()
	orbit_progress = get_orbit_progress()

	for(var/datum/maneuver_data/maneuver in planned_maneuvers)
		if(world.time > maneuver.world_time_at_maneuver)
			if(launch_time > world.time) // yet to launch
				launch_time = world.time
			perform_burn(maneuver, owner)
	*/
/datum/orbit_data/proc/calculate_physics_step(positionX, positionY, positionZ, velocityX, velocityY, velocityZ)
	var/dist = vector_3_magnitude(positionX, positionY, positionZ)
	if(dist == 0)
		dist = 1 // we should delete the satellite as part of a crash into the planet before this, but just in case
	var/gravitational_pull = -gravitational_parameter / dist ** 3

	// calculate acceleration towards planet
	var/accel = list()
	accel["X"] = positionX * gravitational_pull
	accel["Y"] = positionY * gravitational_pull
	accel["Z"] = positionZ * gravitational_pull

	// get new velocity using acceleration
	var/vel = list()
	vel["X"] = velocityX + accel["X"]
	vel["Y"] = velocityY + accel["Y"]
	vel["Z"] = velocityZ + accel["Z"]

	// get new position using new velocity
	var/pos = list()
	pos["X"] = positionX + vel["X"]
	pos["Y"] = positionY + vel["Y"]
	pos["Z"] = positionZ + vel["Z"]

	return list(
		"velocity" = vel,
		"position" = pos,
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

	var/prograde = vector_3_normalize(velX, velY, velZ)
	var/radial = vector_3_normalize(posX, posY, posZ)

	var/normal_cross = vector_3_cross(posX, posY, posZ, velX, velY, velZ)
	var/normal = vector_3_normalize(normal_cross["x"], normal_cross["y"], normal_cross["z"])

	//var/radial_cross = vector_3_cross(normal["x"], normal["y"], normal["z"], prograde["x"], prograde["y"], prograde["z"])

	velX += prograde["x"] * maneuver.prograde * satellite_stats.engine_speed_constant * fraction_burn
	velY += prograde["y"] * maneuver.prograde * satellite_stats.engine_speed_constant * fraction_burn
	velZ += prograde["z"] * maneuver.prograde * satellite_stats.engine_speed_constant * fraction_burn

	velX += normal["x"] * maneuver.normal * satellite_stats.engine_speed_constant * fraction_burn
	velY += normal["y"] * maneuver.normal * satellite_stats.engine_speed_constant * fraction_burn
	velZ += normal["z"] * maneuver.normal * satellite_stats.engine_speed_constant * fraction_burn

	velX += radial["x"] * maneuver.radial * satellite_stats.engine_speed_constant * fraction_burn
	velY += radial["y"] * maneuver.radial * satellite_stats.engine_speed_constant * fraction_burn
	velZ += radial["z"] * maneuver.radial * satellite_stats.engine_speed_constant * fraction_burn

	should_update_orbit = TRUE

	/*
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

	// do the burn
	// add a proportionate amount to the apoapsis and periapsis, depending on how close we are to either
	var/bimodal_orbit = abs(orbit_progress - 0.5) * 2
	apoapsis += maneuver.prograde * bimodal_orbit * satellite_stats.engine_speed_constant * fraction_burn // 0 progress = at periapsis, abs(0-0.5)*2 = 1. 0.5 progress = at apoapsis, abs(0.5-0.5)*2 = 0. 1 progress(same as 0) = abs(1-0.5)*2 = 1
	periapsis += maneuver.prograde * (1 - bimodal_orbit) * satellite_stats.engine_speed_constant * fraction_burn // 0 progress = at periapsis, 1 - abs(0-0.5)*2 = 0. 0.5 progress = at apoapsis, 1-abs(0.5-0.5)* 2 = 1. 1 progress (same as 0) = 1-abs(1 - 0.5)*2 = 0

	// TODO: Recalculate orbit progress bases off periapsis

 	// normal burns are most efficient the closer to periapsis you are
	inclination += (maneuver.normal * bimodal_orbit * satellite_stats.engine_speed_constant * fraction_burn)
	inclination %= 360

	// subtract fuel, and add power
	satellite_stats.current_fuel -= satellite_stats.fuel_usage
	satellite_stats.current_power += satellite_stats.active_power_generation
	period = get_period()
	*/

/// Adds a manuever to the orbit
/// * `prograde` - can be negative. Affects the size of the orbit
/// * `normal` - can be negative. Affects how tilted the orbit is
/// * `time_to_maneuver` - deciseconds until the maneuver
/// * `burn_time` - how many ticks this should be done
/datum/orbit_data/proc/add_maneuver(prograde, normal, time_to_maneuver, burn_time, radial = 0)
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

////////////////////////////////////////
// MARK: Science instruments
////////////////////////////////////////

/datum/satellite_stats/science_instrument/meteorological_surveyor
	weight = 10
	power_consumption = 10

/datum/satellite_stats/science_instrument/plasma_lab
	weight = 10
	power_consumption = 5

/datum/satellite_stats/science_instrument/magnetometer
	weight = 10
	power_consumption = 10

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
