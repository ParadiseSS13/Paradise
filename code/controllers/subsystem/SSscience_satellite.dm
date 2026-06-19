SUBSYSTEM_DEF(science_satellite)
	name = "Science Satellite"
	init_order = INIT_ORDER_SCIENCE_SATELLTIE
	priority = FIRE_PRIORITY_SCIENCE_SATELLITE
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING
	offline_implications = "The game will no longer update satellite positions, or generate new points to gather science from. Data science will be impossible."
	cpu_display = SS_CPUDISPLAY_LOW
	var/list/satellites = list()
	var/weather_nodes_to_spawn = 10
	var/planet_radius = 128
	var/list/active_weather_nodes = list()

/datum/controller/subsystem/science_satellite/Initialize()
	for(var/i = 0; i < weather_nodes_to_spawn; i++)
		spawn_weather_node()

	spawn_weather_node(vector(0, planet_radius, 1), /datum/weather_node/pole)
	spawn_weather_node(vector(0, -planet_radius, 1), /datum/weather_node/pole)
	return

/datum/controller/subsystem/science_satellite/proc/spawn_weather_node(vector/forced_location = null, datum/forced_node = null)
	var/datum/weather_node/weather_node_choice
	if(forced_node)
		weather_node_choice = new forced_node
	else
		weather_node_choice = pick(
		40; new /datum/weather_node/wind,
		30; new /datum/weather_node/ash_storm,
		20; new /datum/weather_node/acid_rain,
		10; new /datum/weather_node/volcanism)

	var/vector/position_vector
	if(forced_location)
		position_vector = forced_location
	else
		var/random_distance = planet_radius * (rand(0,1000)/1000) ** 0.5
		var/theta = (rand(0,1000)/1000) * 2 * PI // we divide here to get a random number with decimals

		position_vector = vector(random_distance * cos(theta), random_distance * sin(theta), 1) // set the z component here, as we dont care about it other than it beign positive (its positive so weather nodes will be visible to players)

	weather_node_choice.position = position_vector
	active_weather_nodes += weather_node_choice

/datum/controller/subsystem/science_satellite/fire()
	for(var/obj/machinery/science_satellite/satellite in satellites)
		satellite.orbit_data.heartbeat(wait)

	for(var/datum/weather_node/weather_node in active_weather_nodes)
		for(var/obj/machinery/science_satellite/satellite in satellites)
			if (!satellite.orbit_data.position)
				continue

			// TODO: Check cooldown

			if(!weather_node.position)
				continue
			// calculate the square distance, ignoring the z axis
			var/square_2D_dist = (satellite.orbit_data.position.x - weather_node.position.x) ** 2 +\
			(satellite.orbit_data.position.y - weather_node.position.y) ** 2

			if(square_2D_dist < weather_node.square_detection_range)
				satellite.orbit_data.process_weather_node(weather_node)

/datum/weather_node
	var/vector/position
	var/square_detection_range = 256
	var/node_type = "NULL_WEATHER"
	var/science_yield = 1

/datum/weather_node/pole
	node_type = SCIENCE_SATELLITE_WEATHER_NODE_POLE
	science_yield = 20

/datum/weather_node/wind
	node_type = SCIENCE_SATELLITE_WEATHER_NODE_WIND
	science_yield = 20


/datum/weather_node/ash_storm
	node_type = SCIENCE_SATELLITE_WEATHER_NODE_ASH_STORM
	science_yield = 40


/datum/weather_node/acid_rain
	node_type = SCIENCE_SATELLITE_WEATHER_NODE_ACID_RAIN
	science_yield = 60


/datum/weather_node/volcanism
	node_type = SCIENCE_SATELLITE_WEATHER_NODE_ASH_STORM
	science_yield = 160
