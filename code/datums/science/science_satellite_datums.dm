#define VELOCITY_STRING "VELOCITY"
#define POSITION_STRING "POSITION"
#define DISTANCE_STRING "DISTANCE"
#define APOAPSIS_STRING "APOAPSIS"
#define PERIAPSIS_STRING "PERIAPSIS"
#define APOAPSIS_POSITION_STRING "APOAPSIS_POSITION"
#define PERIAPSIS_POSITION_STRING "PERIAPSIS_POSITION"
#define PREDICTED_ORBIT_STRING "PREDICTED_ORBIT"

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
	var/fuel_usage = 0
	var/list/capabilities = list()

/datum/orbit_data
	var/apoapsis = -INFINITY // furthest
	var/vector/apoapsis_position
	var/periapsis = INFINITY // closest
	var/vector/periapsis_position

	var/atmosphere_start = 150
	var/light_airdrag = 0.999
	var/atmosphere_thick = 130
	var/thick_airdrag = 0.99

	var/inclination = 0 // how tilted the orbit is

	var/period = 20 MINUTES // probably breaks physics, but its a video game
	var/launch_time = INFINITY

	var/list/planned_maneuvers = new()
	var/datum/satellite_stats/stats // initialized by `satellite.dm`
	var/obj/machinery/science_satellite/owner // initialized by `satellite.dm`

	var/has_been_launched = FALSE

	var/planet_gravitational_constant = 9
	var/planet_mass = 442
	var/gravitational_parameter = 3986 // planet_gravitational_constant * planet_mass // known as "GM" gravity times mass. Default here is 3986 based off earth

	var/vector/position
	var/vector/velocity

	var/list/predicted_orbit = list()
	var/should_update_orbit = TRUE

	var/physics_delta_time = 4 //TODO: Set to 0.1

////////////////////////////////////////
// MARK: heartbeat
////////////////////////////////////////
/// Called by `SSscience_satellitel.dm` in order to make the satellite move
/datum/orbit_data/proc/heartbeat(delta_time)
	owner.calculate_status()

	if(!has_been_launched)
		return

	stats.add_power(stats.passive_power_generation)

	var/list/step = calculate_physics_step(position, velocity) // where the satellite should move this tick
	position = step[POSITION_STRING]
	velocity = step[VELOCITY_STRING]

	velocity = handle_air_drag(step[DISTANCE_STRING], position, velocity, TRUE)
	handle_maneuvers()

	if(should_update_orbit) // if a function that requires an orbit update has been called
		var/prediction = predict_orbit(list(
			POSITION_STRING = position,
			VELOCITY_STRING = velocity
		))

		predicted_orbit = prediction[PREDICTED_ORBIT_STRING]

		apoapsis = prediction[APOAPSIS_STRING]
		periapsis = prediction[PERIAPSIS_STRING]

		apoapsis_position = prediction[APOAPSIS_POSITION_STRING]
		periapsis_position = prediction[PERIAPSIS_POSITION_STRING]

		should_update_orbit = FALSE

////////////////////////////////////////
// MARK: predict_orbit
////////////////////////////////////////
/datum/orbit_data/proc/predict_orbit(physics_step)

	//if(should_update_orbit) // if a burn has been performed
	//	should_update_orbit = FALSE


	var/list/initial_step = physics_step

	var/list/last_step = physics_step // used to trace a predicted path for TGUI

	var/list/path = list()
	path += initial_step[POSITION_STRING]

	var/new_apoapsis = -INFINITY
	var/new_periapsis = INFINITY
	var/new_apoapsis_position
	var/new_periapsis_position
	var/new_predicted_orbit = list()

	for(var/i = 0; i < 6000; i++) // TODO: Refine this number, its way to high
		last_step = calculate_physics_step(last_step[POSITION_STRING], last_step[VELOCITY_STRING])

		var/vector/point = last_step[POSITION_STRING]

		path += point
		if(last_step[DISTANCE_STRING] > new_apoapsis)
			new_apoapsis = last_step[DISTANCE_STRING]
			new_apoapsis_position = last_step[POSITION_STRING]
		if(last_step[DISTANCE_STRING] < new_periapsis)
			new_periapsis = last_step[DISTANCE_STRING]
			new_periapsis_position = last_step[POSITION_STRING]
	new_predicted_orbit = path

	return list(
		POSITION_STRING = initial_step[POSITION_STRING],
		VELOCITY_STRING = initial_step[VELOCITY_STRING],
		PREDICTED_ORBIT_STRING = new_predicted_orbit,
		APOAPSIS_STRING = new_apoapsis,
		PERIAPSIS_STRING = new_periapsis,
		APOAPSIS_POSITION_STRING = new_apoapsis_position,
		PERIAPSIS_POSITION_STRING = new_periapsis_position
	)

////////////////////////////////////////
// MARK: handle_air_drag
////////////////////////////////////////
/datum/orbit_data/proc/handle_air_drag(distance, vector/position_to_copy, vector/velocity_to_affect, check_for_crash)
	if(distance < SSscience_satellite.planet_radius && check_for_crash)
		owner.Destroy("[owner.internal_name] crashed, and it's data has been lost!")
		return

	var/had_air_drag = FALSE
	if(distance < atmosphere_thick) // if the satellite is very deep into the atmosphere
		had_air_drag = TRUE
		velocity_to_affect *= thick_airdrag
	else if(distance < atmosphere_start) // if the satellite is slightly into the atmosphere
		had_air_drag = TRUE
		//should_update_orbit = TRUE
		velocity_to_affect *= light_airdrag

	if(had_air_drag)
		should_update_orbit = TRUE

	return velocity_to_affect

////////////////////////////////////////
// MARK: launch
////////////////////////////////////////
/datum/orbit_data/proc/launch()
	owner.try_collecting_data_from_all_components(SCIENCE_SATELLITE_HAS_PLASMA_LAB, SCIENCE_YIELD_FROM_PLASMA_LAB)

	position = vector(0, 0, 300) // default velocity is calculated from this. Based off geostationary orbit on earth in km
	velocity = vector(3.6, 0, 0) // when a velocity parameter is equal to (gravitational parameter / magnitude of the position vector) we get a circular orbit.

	has_been_launched = TRUE
	launch_time = world.time

	//var/first_step = calculate_physics_step(position, velocity)
	//log_debug("first_step POSITION_STRING: [first_step[POSITION_STRING]] VELOCITY_STRING: [first_step[VELOCITY_STRING]] ")

	should_update_orbit = TRUE

////////////////////////////////////////
// MARK: physics_step
////////////////////////////////////////
/datum/orbit_data/proc/calculate_physics_step(vector/pos, vector/vel)
	var/dist = pos.size
	if(dist == 0)
		dist = 1 // we should delete the satellite as part of a crash into the planet before this, but just in case
	var/gravitational_pull = -gravitational_parameter / (dist ** 3)

	// calculate acceleration towards planet
	var/vector/accel = pos * gravitational_pull

	// get new velocity using acceleration
	var/vector/new_vel = vel + accel * physics_delta_time

	// get new position using new velocity
	var/vector/new_pos = pos + new_vel * physics_delta_time

	return list(
		VELOCITY_STRING = new_vel,
		POSITION_STRING = new_pos,
		DISTANCE_STRING = dist
		)

////////////////////////////////////////
// MARK: perform_burn
////////////////////////////////////////
/// Performs a fraction of the maneuver
/datum/orbit_data/proc/perform_burn(datum/maneuver_data/maneuver, datum/satellite_stats/satellite_stats)//, vector/position_to_copy, vector/velocity_to_modify)
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

	log_debug("INITIAL perform_burn: new velocity: [velocity]")

	var/obj/item/satellite_component/engine/engine = locate(/obj/item/satellite_component/engine/) in owner.parts
	var/fuel_step = stats.fuel_usage * fraction_burn
	if(fuel_step > stats.current_fuel) // if we dont have enough fuel
		fraction_burn *= stats.current_fuel / fuel_step // multiply the fraction burn with the percentage of fuel we do have
		// stats.current_fuel = 0
		fuel_step = stats.fuel_usage * fraction_burn // then recalculate the fuel step
		if(maneuver in planned_maneuvers)
			planned_maneuvers -= maneuver

	stats.add_power(engine.component_stats.active_power_generation * fraction_burn)
	stats.current_fuel -= fuel_step
	stats.update_fuel_usage()
	if(SCIENCE_SATELLITE_USES_POWER_ON_THRUST in stats.capabilities)
		// multiply the fraction of the burn with the fraction of the power to get power draw
		var/power_fraction = stats.remove_power(engine.component_stats.power_consumption * fraction_burn)
		if(power_fraction < 1) // if we dont have enough power
			fraction_burn *= power_fraction // reduce the fraction of the burn (can also happen in conjunction with the fuel division)
			if(maneuver in planned_maneuvers)
				planned_maneuvers -= maneuver

	var/vector/vel_copy = vector(velocity) // we need to copy the vectors as Normalize() modifies the vector itself!
	var/vector/pos_copy = vector(position)

	//log_debug("POST-COPY perform_burn: new velocity: [velocity_to_modify]")
	//log_debug("POST-COPY perform_burn: vel_copy: [vel_copy] pos_copy: [pos_copy]")

	var/vector/prograde = vel_copy.Normalize()
	var/vector/radial = pos_copy.Normalize()

	//log_debug("POST-NORMALIZE perform_burn: new velocity: [velocity_to_modify]")

	var/vector/normal_cross = position.Cross(velocity) // Cross() returns a new vector though
	var/vector/normal = normal_cross.Normalize()

	//var/radial_cross = vector_3_cross(normal["x"], normal["y"], normal["z"], prograde["x"], prograde["y"], prograde["z"])

	log_debug("PRE-MULTIPLY perform_burn: new velocity: [velocity] maneuver.prograde: [maneuver.prograde] maneuver.normal: [maneuver.normal] maneuver.radial: [maneuver.radial]")
	velocity += prograde * maneuver.prograde * satellite_stats.engine_speed_constant * fraction_burn

	velocity += normal * maneuver.normal * satellite_stats.engine_speed_constant * fraction_burn

	velocity += radial * maneuver.radial * satellite_stats.engine_speed_constant * fraction_burn
	log_debug("velocity_to_modify: [velocity]")
	should_update_orbit = TRUE
	/*
	predict_and_update_orbit(list(
		VELOCITY_STRING = velocity_to_modify,
		POSITION_STRING = position_to_copy,
		DISTANCE_STRING = position_to_copy.size))//should_update_orbit = TRUE

	log_debug("RETURN perform_burn: new velocity: [velocity_to_modify]")
	*/
	//return velocity_to_modify

////////////////////////////////////////
// MARK: handle_maneuvers
////////////////////////////////////////
/datum/orbit_data/proc/handle_maneuvers()
	for(var/datum/maneuver_data/maneuver in planned_maneuvers)
		if(maneuver.world_time_at_maneuver > world.time)
			continue

		if(!maneuver.magnitude)
			planned_maneuvers -= maneuver
			continue

		//var/burn =
		perform_burn(maneuver, stats)//, position, velocity)
		//log_debug("burn result: [burn]")
		//velocity = burn


////////////////////////////////////////
// MARK: add_maneuver
////////////////////////////////////////
/// Adds a manuever to the orbit
/// * `prograde` - can be negative. Affects the size of the orbit
/// * `normal` - can be negative. Affects how tilted the orbit is
/// * `time_to_maneuver` - deciseconds until the maneuver
/// * `burn_time` - how many ticks this should be done
/datum/orbit_data/proc/add_maneuver(prograde, normal, time_to_maneuver, burn_time, radial = 0)
	if(!has_been_launched)
		return

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
// MARK: stats procs
////////////////////////////////////////

/datum/satellite_stats/proc/update_fuel_usage()
	if(!fuel_efficiency)
		return
	fuel_usage = (weight + current_fuel) / fuel_efficiency

/datum/satellite_stats/proc/add_power(amount)
	current_power = min(current_power + amount, power_capacity)

/// removes power from the stats, returns a fraction if `current_power` is less than `amount`
/datum/satellite_stats/proc/remove_power(amount)
	if(!amount)
		return
	var/power_fraction = 1
	if(amount > current_power)
		power_fraction = current_power / amount
	current_power = max(current_power - amount, 0)
	return power_fraction

/// Returns true if the satellites power is greater than the components use
/datum/satellite_stats/proc/enough_power_for_component_use(obj/item/satellite_component/component)
	return (component.component_stats.power_consumption <= current_power)

////////////////////////////////////////
// MARK: Chassis stats (base)
////////////////////////////////////////

/datum/satellite_stats/base_stats
	science_multiplier = 1 // we set this to 1 here so that the satellites all start at "100% science" while the other parts might not give any multiplier

////////////////////////////////////////
// MARK: Computers
////////////////////////////////////////

/datum/satellite_stats/computer/basic
	weight = 60
	science_multiplier = 0.50 // additive as a percent
	power_capacity = 10000

/datum/satellite_stats/computer/science
	weight = 100
	science_multiplier = 1.00 // additive as a percent
	power_capacity = 25000

/datum/satellite_stats/computer/efficient
	weight = 40
	science_multiplier = 0.25 // additive as a percent
	power_capacity = 10000

////////////////////////////////////////
// MARK: Engines
////////////////////////////////////////

/datum/satellite_stats/engine/basic_engine
	weight = 100
	fuel_capacity = 600
	fuel_efficiency = 500
	active_power_generation = 2500

/datum/satellite_stats/engine/small_engine
	weight = 50
	fuel_capacity = 200
	fuel_efficiency = 400
	active_power_generation = 1000

/datum/satellite_stats/engine/ion_engine
	weight = 100
	fuel_capacity = 40
	fuel_efficiency = 2500
	power_consumption = 1000
	capabilities = list(SCIENCE_SATELLITE_NEEDS_VACUUM, SCIENCE_SATELLITE_USES_POWER_ON_THRUST)

////////////////////////////////////////
// MARK: Science instruments
////////////////////////////////////////

/datum/satellite_stats/science_instrument/meteorological_surveyor
	weight = 200
	power_consumption = 10000
	capabilities = list(SCIENCE_SATELLITE_HAS_METEOROLOGY)

/datum/satellite_stats/science_instrument/plasma_lab
	weight = 200
	power_consumption = 10000
	capabilities = list(SCIENCE_SATELLITE_HAS_PLASMA_LAB)

/datum/satellite_stats/science_instrument/magnetometer
	weight = 200
	power_consumption = 10000
	capabilities = list(SCIENCE_SATELLITE_HAS_MAGNETOMETER)


////////////////////////////////////////
// MARK: Misc parts
////////////////////////////////////////

/datum/satellite_stats/misc_part/solar_panel
	weight = 8
	passive_power_generation = 100

/datum/satellite_stats/misc_part/electric_generator
	weight = 20
	active_power_generation = 7500

/datum/satellite_stats/misc_part/power_cell
	weight = 20
	power_capacity = 20000

#undef VELOCITY_STRING
#undef POSITION_STRING
#undef DISTANCE_STRING
#undef APOAPSIS_STRING
#undef PERIAPSIS_STRING
#undef APOAPSIS_POSITION_STRING
#undef PERIAPSIS_POSITION_STRING
#undef PREDICTED_ORBIT_STRING
