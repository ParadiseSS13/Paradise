#define BORDER_PADDING 10
#define MAX_OVERLAP 5

/datum/biome_theme
	var/name = "clown planet"
	/// List of contextual data passed in whole to worldgen_modifier
	var/list/generation_data = list(
		"rock_type" = /turf/simulated/wall/indestructible/backrooms,
		"floor_type" = /turf/simulated/floor/backrooms_carpet,
		"liquid_type" = /turf/simulated/floor/lava/lava_land_surface/plasma,
		"ambient_light" = COLOR_AMBER,
		"ore_chance" = 10,
		"ore_weights" = list(
			/datum/ore/bananium = 50,
			/datum/ore/iron = 20,
			/datum/ore/tranquillite = 30
	),
		"fauna_chance" = 1,
		"fauna_weights" = list(
			/mob/living/basic/clown = 50,
			/mob/living/basic/clown/goblin = 50
		),
		"flora_chance" = 2,
		"flora_weights" = list(
			/obj/structure/flora/corn_stalk/alt_1 = 50,
			/obj/structure/flora/corn_stalk/alt_2 = 50
		),
		"area_type" = /area/lavaland/surface/biome
	)
	#warn TOOD: add megafauna data here
	/// Ordered worldgen_modifier steps to perform on the biome area
	var/list/generation_steps = list(
		/datum/worldgen_modifier/noise/biome,
		/datum/worldgen_modifier/noise/ore,
		/datum/worldgen_modifier/noise/humidity,
		/datum/worldgen_modifier/flora,
		/datum/worldgen_modifier/fauna
	)
	/// X position of the biome placement
	var/x
	/// X position of the biome placement
	var/y
	/// Z position of the biome placement
	var/z
	/// Size of the placement, x and y
	var/size


/// Finds suitable coordinates to place the biome, with minimal overlap
/datum/biome_theme/proc/suitable_placement()
	var/valid = TRUE
	var/placement_attempts = 3
	while(placement_attempts > 0)
		valid = TRUE // can never be too sure
		var/turf/placement_attempt = locate(
			rand(BORDER_PADDING, world.maxx - (BORDER_PADDING + size)),
			rand(BORDER_PADDING, world.maxy - (BORDER_PADDING + size)),
			z
		)
		// trimming off some acceptable overlap, look at the block of what our biome will occupy
		for(var/turf/check in block(placement_attempt.x + MAX_OVERLAP, placement_attempt.y + MAX_OVERLAP, z, placement_attempt.x + size - MAX_OVERLAP, placement_attempt.y + size - MAX_OVERLAP, z))
			if(istype(get_area(check), /area/lavaland/surface/biome))
				valid = FALSE
		// while placement_attempt is still in scope :)
		if(valid)
			x = placement_attempt.x
			y = placement_attempt.y
			return TRUE
	// failed
	return FALSE


/// Create a new instance of a biome
/datum/biome_theme/New(zlevel)
	size = rand(80, 100)
	z = zlevel
	var/success = suitable_placement()
	if(!success)
		qdel(src)

/// Handles calling and coordinating the worldgen_modifiers to generate the biome
/datum/biome_theme/proc/setup()
	for(var/step in generation_steps)
		var/datum/worldgen_modifier/my_worldgen = new step(generation_data) // Initialise and give it its data
		my_worldgen.location_x = x
		my_worldgen.location_y = y
		my_worldgen.location_z = z
		my_worldgen.size = size
		generation_data += my_worldgen.generate() // Run it and push the generated data to the list



/datum/biome_theme/test_biome
	name = "mmm test biome"
