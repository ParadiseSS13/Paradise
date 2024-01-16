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
		stack_trace("Wrong turf type `[initial(primary_turf_type.type)]` in `[type]` lavaland theme")

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
	spawn_rivers(level_name_to_num(MINING))

/datum/lavaland_theme/plasma
	name = "plasma"
	primary_turf_type = /turf/simulated/floor/lava/lava_land_surface/plasma
	planet_icon_state = "planet_plasma"

/datum/lavaland_theme/plasma/setup()
	spawn_rivers(level_name_to_num(MINING), nodes = 2)
	spawn_rivers(level_name_to_num(MINING), nodes = 2)

/datum/lavaland_theme/chasm
	name = "chasm"
	primary_turf_type = /turf/simulated/floor/chasm/straight_down/lava_land_surface
	planet_icon_state = "planet_chasm"

/datum/lavaland_theme/chasm/setup()
	spawn_rivers(
		level_name_to_num(MINING),
		nodes = 6,
		turf_type = /turf/simulated/floor/lava/mapping_lava,
		whitelist_area = /area/lavaland/surface/outdoors,
		min_x = 50,
		min_y = 7,
		max_x = 250,
		max_y = 225,
		prob = 10,
		prob_loss = 5
	)
