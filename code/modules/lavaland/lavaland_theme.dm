/// Approximate lower bound of the walkable land area on Lavaland, north of the southern lava border.
#define LAVALAND_MIN_CAVE_Y 10
/// Approximate upper bound of the walkable land area on Lavaland, south of the Legion entrance.
#define LAVALAND_MAX_CAVE_Y 222

/datum/lavaland_theme
	/// Name of lavaland theme
	var/name = "Not Specified"
	/// Typepath of turf the `/turf/simulated/floor/lava/mapping_lava` will be changed to on Late Initialization
	var/turf/simulated/floor/primary_turf_type
	/// Icon state of planet present on background of station Z-level
	var/planet_icon_state

/datum/lavaland_theme/New()
	if(!primary_turf_type)
		stack_trace("Turf type is `null` in `[type]` lavaland theme")
	else if(!ispath(primary_turf_type))
		stack_trace("Wrong turf type `[primary_turf_type.type]` in `[type]` lavaland theme")

/datum/lavaland_theme/proc/setup_caves()
	var/max_attempts = 100
	var/max_cave_spawns = 40
	var/z = level_name_to_num(MINING)
	while(max_attempts > 0 && max_cave_spawns > 0)
		var/x = rand(1, world.maxx)
		var/y = rand(LAVALAND_MIN_CAVE_Y, LAVALAND_MAX_CAVE_Y)
		var/turf/next_turf = locate(x, y, z)
		var/area/next_area = get_area(next_turf)
		if(istype(next_turf, /turf/simulated/mineral/random/volcanic) && istype(next_area, /area/lavaland/surface/outdoors/unexplored/danger))
			next_turf.ChangeTurf(/turf/simulated/floor/plating/asteroid/airless/cave/volcanic, FALSE, TRUE, TRUE)
			max_cave_spawns--
		max_attempts--

/**
 * This proc should do all theme specific thing.
 * Now it only generates rivers, but it can do all stuff you desire.
 */
/datum/lavaland_theme/proc/setup()
	return

/datum/lavaland_theme/lava
	name = "lava"
	primary_turf_type = /turf/simulated/floor/lava/lava_land_surface
	planet_icon_state = "planet_lava"

/datum/lavaland_theme/lava/setup()
	var/datum/river_spawner/lava_spawner = new(level_name_to_num(MINING))
	lava_spawner.generate()

/datum/lavaland_theme/plasma
	name = "plasma"
	primary_turf_type = /turf/simulated/floor/lava/lava_land_surface/plasma
	planet_icon_state = "planet_plasma"

/datum/lavaland_theme/plasma/setup()
	var/datum/river_spawner/spawner = new(level_name_to_num(MINING))
	spawner.generate(nodes = 2)
	spawner.generate(nodes = 2) // twice

/datum/lavaland_theme/chasm
	name = "chasm"
	primary_turf_type = /turf/simulated/floor/chasm/straight_down/lava_land_surface
	planet_icon_state = "planet_chasm"

/datum/lavaland_theme/chasm/setup()
	var/datum/river_spawner/spawner = new(level_name_to_num(MINING), spread_prob_ = 10, spread_prob_loss_ = 5)
	spawner.generate(nodes = 6, min_x = 50, min_y = 7, max_x = 250, max_y = 225)

#undef LAVALAND_MIN_CAVE_Y
#undef LAVALAND_MAX_CAVE_Y
