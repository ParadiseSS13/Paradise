SUBSYSTEM_DEF(science_satellite)
	name = "Science Satellite"
	init_order = INIT_ORDER_SCIENCE_SATELLTIE
	priority = FIRE_PRIORITY_SCIENCE_SATELLITE
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING
	offline_implications = "The game will no longer update satellite positions, or generate new points to gather science from. Data science will be impossible."
	cpu_display = SS_CPUDISPLAY_LOW
	var/list/satellites = list()
	var/weather_nodes_to_spawn = 15

	var/planet_radius = 128
	var/atmosphere_start = 150
	var/light_airdrag = 0.999
	var/atmosphere_thick = 130
	var/thick_airdrag = 0.99

	var/list/active_weather_nodes = list()
	var/max_spawn_radius = 110 // smaller than the planet radius in order to not have nodes at the edge of the planet
	var/square_distance_between_nodes = 20 ** 2
	var/distance_tries = 10 // how many times the distance check for each node will be tried

/datum/controller/subsystem/science_satellite/Initialize()
	// spawn 2 pole nodes at the actual edge of the planet, instead of the stricter `max_spawn_radius`
	spawn_weather_node(0, vector(0, planet_radius, 1), /datum/weather_node/pole)
	spawn_weather_node(0, vector(0, -planet_radius, 1), /datum/weather_node/pole/south)

	var/volcanism_to_spawn = pick(
		70; 1,
		20; 2,
		10; 3)
	var/acid_rain_to_spawn = pick(
		60; 2,
		30; 3,
		10; 4)
	var/ash_storms_to_spawn = pick(
		50; 5,
		40; 6,
		10; 7)

	var/winds_to_spawn = weather_nodes_to_spawn - volcanism_to_spawn - acid_rain_to_spawn - ash_storms_to_spawn

	for(var/i = 0; i < volcanism_to_spawn; i++)
		spawn_weather_node(forced_node = /datum/weather_node/volcanism)

	for(var/i = 0; i < acid_rain_to_spawn; i++)
		spawn_weather_node(forced_node = /datum/weather_node/acid_rain)

	for(var/i = 0; i < ash_storms_to_spawn; i++)
		spawn_weather_node(forced_node = /datum/weather_node/ash_storm)

	for(var/i = 0; i < winds_to_spawn; i++)
		spawn_weather_node(forced_node = /datum/weather_node/wind)

	return

/// Adds a weather node to SSscience_satellite
/// * `minimum_distance_to_others` - How far away from other nodes does this have to be. Overridden by `forced_loacation`.
/// * `forced_location` - Select the location of the node, should be within `planet_radius` otherwise you'll have nodes floating in space
/// * `forced_node` - Select a specific node to spawn
/datum/controller/subsystem/science_satellite/proc/spawn_weather_node(square_minimum_distance_to_others = square_distance_between_nodes, vector/forced_location = null, datum/forced_node = null)
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
		position_vector = weather_node_choice.get_random_circular_vector(max_spawn_radius)

		// try to place the node away from other nodes, still places it if this fails
		for(var/i = 0; i < distance_tries; i++)
			var/success = TRUE
			for(var/datum/weather_node/weather_node in active_weather_nodes)
				if(weather_node.get_2D_square_distance(weather_node.position, position_vector) < square_minimum_distance_to_others)
					position_vector = weather_node_choice.get_random_circular_vector(max_spawn_radius)
					success = FALSE
					weather_node.distance_tries = i + 2 // this run is i + 1, but we failed already, so i + 2
					break;
			if(success) // if none of the weather nodes were close to this one, we can place it there
				break;


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
			var/square_2D_dist = weather_node.get_2D_square_distance(satellite.orbit_data.position, weather_node.position)

			// if the square distance is smaller than the detection range, check if the satellite can process the node
			if(square_2D_dist < weather_node.square_detection_range)
				satellite.try_collecting_data_from_all_components(weather_node.detection_requirement, weather_node.science_yield, weather_node)

/datum/weather_node
	var/vector/position
	var/square_detection_range = 24 ** 2
	var/node_type = "NULL_WEATHER"
	var/detection_requirement
	/// how much science does this node give
	var/science_yield = 1
	/// a percentage that is the new science yield after this has been processed once
	var/science_depletion_rate = 0.97
	/// the png listed in `asset_science_satellite.dm`
	var/asset_icon
	var/distance_tries = 0 // used for debugging

/datum/weather_node/proc/get_2D_square_distance(vector/vector_a, vector/vector_b)
	return (vector_a.x - vector_b.x) ** 2 +	(vector_a.y - vector_b.y) ** 2


/datum/weather_node/proc/get_random_circular_vector(max_distance)
	var/random_distance = max_distance * (rand(0,1000)/1000) ** 0.5 // we divide here to get a random number with decimals
	var/theta = rand(0, 360) // get a random angle

	var/vector/random_circular_vector = vector(random_distance * cos(theta), random_distance * sin(theta), 1) // set the z component here, as we dont care about it other than it beign positive (its positive so weather nodes will be visible to players)
	return random_circular_vector

/datum/weather_node/pole
	node_type = SCIENCE_SATELLITE_WEATHER_NODE_POLE
	detection_requirement = SCIENCE_SATELLITE_HAS_MAGNETOMETER
	science_yield = 10
	asset_icon = "north_pole.png"

/datum/weather_node/pole/south
	asset_icon = "south_pole.png"

/datum/weather_node/wind
	node_type = SCIENCE_SATELLITE_WEATHER_NODE_WIND
	detection_requirement = SCIENCE_SATELLITE_HAS_METEOROLOGY
	science_yield = 10
	asset_icon = "wind_storm.png"


/datum/weather_node/ash_storm
	node_type = SCIENCE_SATELLITE_WEATHER_NODE_ASH_STORM
	detection_requirement = SCIENCE_SATELLITE_HAS_METEOROLOGY
	science_yield = 20
	asset_icon = "ash_storm.png"


/datum/weather_node/acid_rain
	node_type = SCIENCE_SATELLITE_WEATHER_NODE_ACID_RAIN
	detection_requirement = SCIENCE_SATELLITE_HAS_METEOROLOGY
	science_yield = 30
	asset_icon = "acid_rain.png"


/datum/weather_node/volcanism
	node_type = SCIENCE_SATELLITE_WEATHER_NODE_ASH_STORM
	detection_requirement = SCIENCE_SATELLITE_HAS_MAGNETOMETER
	science_yield = 80
	asset_icon = "eruption.png"
