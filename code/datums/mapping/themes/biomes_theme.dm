/*
Biome template idea
	rock_type
		base wall type
	flora_list
		plant whitelist to spawn in
	fauna_list
		mobs whitelist to spawn in
	megafauna_list
		megafauna whitelist to spawn in
	generation_flags (?)
		additional generation, caves?, river?, lake? probably implemented as like a
		list of generation datum procs iteratively ran over to successively change the
		biome area, cave and lake could be noise but river would be carving water between lakes etc etc
	ambient_light
		colour of the (weak) ambient light
	weather_immunity
		which weather types are supressed in the biome
	ambient_sound
		list of sounds that could play
	ore_list
		ore spawn and weights

Biomes:
	Ashlands
		base lavaland

	 Industrial wastes
        Ashlands affected by the mining industry, rivers and lakes of sulphur,
        ruins of previous mining corporations litter the place, along with their
        legioned workers. lots of legions, vetus and BDM maybe unexploded mining munitions
        abouts? maybe like sickly yellow looking floor and rock tiles, terrible ore here maybe,
        mostly mined out, occasional yellow lighting for atmosphere and rumble sfx
	Sulphur springs (find a name that doesnt alliterate)
		the above without the structures, transition biome

    Obsidian sand desert
		open desert with jagged obsidian spikes, sand could vary in colour from black to orange to yellow
		maybe sand worm megafauna

    Fracture caverns
        Tight caves, long diagonal chasms like scars but rich in plasma and diamond ores,
		lotsa goliath and watchers here, maybe seams of ancient rock i.e. pickaxe only, dim environment
	probably doesnt need a transition biome, very similar to ashlands

    Blooming oasis
        Plant filled oasis, weak kudzu here, lots of jungle plants and kudzu mobs are
        common here, small water puddles here, maybe enclosed fully by ancient rock,
        regular lavaland mobs dont spawn here jungle tiles of course, green colours for
        atmosphere and idk for sfx
	Ashen forest, outer blooming
		looks like a fresh wildfire

    Magma core
        Large lakes of lava with islands rich in metal, titanium, silver, gold,
        lotsa drakes however and magma wing watchers

    Bloodied boneyard
        Outcrops of large bones litter the area, fleshy weaker rock walls still have
        some ore, bubblegum and the cancerous tumour thing can be found here,
        dim red lighting and gurgles sfx

	Ancient city
		could be cool

	lavaland will have 2 z levels, maybe 3 and some biomes are maybe not allowed to be together! just a thought
 */

#define BORDER_PADDING 10
#define MAX_OVERLAP 5

/datum/biome_theme
	var/name = "backrooms"
	#warn TODO: AUTODOC!!!!!!!!
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
	) // add megafauna stuff here too
	var/list/generation_steps = list(
		/datum/worldgen_modifier/noise/biome,
		/datum/worldgen_modifier/noise/ore,
		/datum/worldgen_modifier/noise/humidity,
		/datum/worldgen_modifier/flora,
		/datum/worldgen_modifier/fauna
	)
	var/temp_location_x
	var/temp_location_y
	var/temp_location_z
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
			temp_location_z
		)
		// trimming off some acceptable overlap, look at the block of what our biome will occupy
		for(var/turf/check in block(placement_attempt.x + MAX_OVERLAP, placement_attempt.y + MAX_OVERLAP, temp_location_z, placement_attempt.x + size - MAX_OVERLAP, placement_attempt.y + size - MAX_OVERLAP, temp_location_z))
			if(istype(get_area(check), /area/lavaland/surface/biome))
				valid = FALSE
		// while placement_attempt is still in scope :)
		if(valid)
			temp_location_x = placement_attempt.x
			temp_location_y = placement_attempt.y
			return TRUE
	// failed
	return FALSE


/// Create a new instance of a biome
/datum/biome_theme/New(var/zlevel)
	size = rand(80, 100)
	temp_location_z = zlevel
	var/success = suitable_placement()
	if(!success)
		qdel(src)

/// Handles calling and coordinating the worldgen_modifiers to generate the biome
/datum/biome_theme/proc/setup()
	for(var/step in generation_steps)
		var/datum/worldgen_modifier/my_worldgen = new step(generation_data) // Initialise and give it its data
		my_worldgen.location_x = temp_location_x
		my_worldgen.location_y = temp_location_y
		my_worldgen.location_z = temp_location_z
		my_worldgen.size = size
		generation_data += my_worldgen.generate() // Run it and push the generated data to the list



/datum/biome_theme/test_biome
	name = "mmm test biome"
