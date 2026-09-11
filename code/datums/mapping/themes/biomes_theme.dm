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
			/obj/item/stack/ore/bananium = 50,
			/obj/item/stack/ore/iron = 20,
			/obj/item/stack/ore/tranquillite = 30
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
		"area_type" = null
	) // add megafauna stuff here too
	var/list/generation_steps = list(
		/datum/worldgen_modifier/noise/biome,
		/datum/worldgen_modifier/noise/ore,
		/datum/worldgen_modifier/noise/humidity,
		/datum/worldgen_modifier/flora,
		/datum/worldgen_modifier/fauna
	)

	#warn TODO: pull from global list instead
	var/size = 96
	var/temp_location_x = 10
	var/temp_location_y = 10
	var/temp_location_z = null


/// Create a new instance of a biome
/datum/biome_theme/New()
	#warn TODO: get location to place from calling proc on lavaland generation
	var/valid_zs = levels_by_trait(ORE_LEVEL)
	#warn TODO: have SSmapping choose the biome lmao
	var/datum/biome_theme/chosen_biome = new /datum/biome_theme
	#warn TODO: gotta change this later
	chosen_biome.temp_location_z = pick(valid_zs)

/// Handles calling and coordinating the worldgen_modifiers to generate the biome
/datum/biome_theme/proc/setup()
	for(var/datum/worldgen_modifier/step in generation_steps)
		var/datum/worldgen_modifier/my_worldgen = new step(generation_data) // Initialise and give it its data
		my_worldgen.location_x = temp_location_x
		my_worldgen.location_y = temp_location_y
		my_worldgen.location_z = temp_location_z
		my_worldgen.size = size
		generation_data += my_worldgen.generate() // Run it and push the generated data to the list



/datum/biome_theme/test_biome
	name = "mmm test biome"

/datum/biome_theme/test_biome/setup()
	var/turf/simulated/mineral/T
	var/c = "1"
	T.should_reset_color = FALSE

	if(c == "0")
		T.color = COLOR_RED
	if(c == "1")
		T.color = COLOR_DARK_ORANGE
	if(c == "2")
		T.color = COLOR_ORANGE
	if(c == "3")
		T.color = COLOR_YELLOW
	if(c == "4")
		T.color = COLOR_LIME
	if(c == "5")
		T.color = COLOR_GREEN
	if(c == "6")
		T.color = COLOR_BLUE_LIGHT
	if(c == "7")
		T.color = COLOR_BLUE
	if(c == "8")
		T.color = COLOR_DARK_BLUE_GRAY
	if(c == "9")
		T.color = COLOR_INDIGO

	//T.ChangeTurf(rock_type)
	return
