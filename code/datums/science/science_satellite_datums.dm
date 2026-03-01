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
	var/engine_speed_constant = 10
	var/fuel_usage = 1

/datum/orbit_data
	var/apoapsis = 40000 // furthest
	var/periapsis = 40000 // closest
	//var/eccentricity = 0 // how oval the orbit is
	var/inclination = 0 // how tilted the orbit is
	var/latitude = 0 // the center latitude of the orbit
	//var/altitude = 40000
	var/const/period_multiplier = 4000
	var/period = 20 MINUTES // probably breaks physics, but its a video game
	//var/gravitational_constant = 6.67408
	//var/planet_mass = 5 // lavaland is less dense than earth, and will have a lower gravity
	var/launch_time = INFINITY

	var/velocity = 0 // -1, 1

	var/orbit_progress = 0 // 0, 1 - 0(periapsis), 0.5(apoapsis)
	var/list/planned_maneuvers = new()
	var/datum/satellite_stats/owner

/*
/datum/orbit_data/Initialize()
	get_period()


/datum/orbit_data/proc/get_semi_major_axis()
	return (periapsis + apoapsis)/2

/datum/orbit_data/proc/get_eccentricity()
	return (apoapsis - periapsis)/(apoapsis + periapsis)

/datum/orbit_data/proc/get_orbital_anomaly()
	var/theta = orbit_progress * 2 * PI
	var/semi_major = get_semi_major_axis()
	var/eccent = get_eccentricity()
	return (semi_major * (1 - eccent ** 2) / (1 + eccent * cos(theta)))
*/

///datum/orbit_data/proc/get_altitude()
//	return periapsis * (1 - abs(orbit_progress - 0.5) * 2) + (apoapsis * abs(orbit_progress - 0.5) * 2)

/// gives a sinus wave that peaks at 0.25 and -0.25, with a cycle the length of period
/datum/orbit_data/proc/get_velocity()
	return sin((world.time - launch_time) * 2 * PI) / period

/// gives the time it takes to finish 1 cycle around the planet in minutes
/datum/orbit_data/proc/get_period()
	return ((apoapsis + periapsis) / period_multiplier)

/// gives a value between 0 and 1 which is where the satellite is on the orbit
/datum/orbit_data/proc/get_orbit_progress()
	return LERP(0, 1, abs(velocity))


/datum/orbit_data/proc/heartbeat()
	velocity = get_velocity()
	orbit_progress = get_orbit_progress()

	for(var/datum/maneuver_data/maneuver in planned_maneuvers)
		if(world.time > maneuver.world_time_at_maneuver)
			perform_burn(maneuver, owner)

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

	// do the burn
	// add a proportionate amount to the apoapsis and periapsis, depending on how close we are to either
	var/bimodal_orbit = abs(orbit_progress - 0.5) * 2
	apoapsis += maneuver.prograde * bimodal_orbit * satellite_stats.engine_speed_constant * fraction_burn // 0 progress = at periapsis, abs(0-0.5)*2 = 1. 0.5 progress = at apoapsis, abs(0.5-0.5)*2 = 0. 1 progress(same as 0) = abs(1-0.5)*2 = 1
	periapsis += maneuver.prograde * (1 - bimodal_orbit) * satellite_stats.engine_speed_constant * fraction_burn // 0 progress = at periapsis, 1 - abs(0-0.5)*2 = 0. 0.5 progress = at apoapsis, 1-abs(0.5-0.5)* 2 = 1. 1 progress (same as 0) = 1-abs(1 - 0.5)*2 = 0

 	// normal burns are most efficient the closer to periapsis you are
	inclination += (maneuver.normal * bimodal_orbit * satellite_stats.engine_speed_constant * fraction_burn) % 360

	// subtract fuel, and add power
	satellite_stats.current_fuel -= satellite_stats.fuel_usage
	satellite_stats.current_power += satellite_stats.active_power_generation
	period = get_period()

/// Adds a manuever to the orbit
/// * `prograde` - can be negative. Affects the size of the orbit
/// * `normal` - can be negative. Affects how tilted the orbit is
/// * `time_to_maneuver` - deciseconds until the maneuver
/// * `burn_time` - how many repetitions should be done
/datum/orbit_data/proc/add_maneuver(prograde, normal, time_to_maneuver, burn_time)
	var/datum/maneuver_data/maneuver = new()
	maneuver.prograde = prograde
	maneuver.normal = normal
	maneuver.magnitude = maneuver.get_magnitude()

	//normalize the vector
	maneuver.prograde /= maneuver.magnitude
	maneuver.normal /= maneuver.magnitude

	maneuver.world_time_at_maneuver = time_to_maneuver + world.time
	maneuver.burn_time = burn_time

	planned_maneuvers += maneuver

/datum/maneuver_data
	var/prograde = 0
	var/normal = 0
	var/magnitude = 0
	var/world_time_at_maneuver = INFINITY
	var/burn_time = 0
	var/const/burn_constant = 0.1

/datum/maneuver_data/proc/get_magnitude()
	return ROOT(prograde ** 2 + normal ** 2, 2)

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
