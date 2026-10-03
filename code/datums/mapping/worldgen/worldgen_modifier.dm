// Where world/map generation modifiers lives, things such as cave noise maps, ore distribution map, river generation and other
// various fun things that will occur during world generation, mostly used by biome generation but kept as a seperate system
// so that other systems could perchance use it
/datum/worldgen_modifier
	var/name = "worldgen modifier"
	/// List of generation data for certain generators like flora placement requiring a humidity map or fauna weights
	var/list/generation_data = list()
	/// What generation_data flags are we expecting?
	var/list/generation_data_expected = list()
	/// Size, width and height of the affected area
	var/size = 0
	/// X location offset
	var/location_x = 0
	/// Y location offset
	var/location_y = 0
	/// Z level its occuring on
	var/location_z

/datum/worldgen_modifier/New(list/data)
	generation_data = data


/// Called from external source
/datum/worldgen_modifier/proc/generate()
#warn TODO: make this actually check for the valid gen data flags
	if(!isemptylist(generation_data_expected) && isnull(generation_data))
		error("[name] found no generation data, expected [generation_data_expected]")
		return
	apply()

/// Where the tilewise magic occurs
/datum/worldgen_modifier/proc/apply()
	return

/// Helper function to return a value from a 2D offset list
/datum/worldgen_modifier/proc/coord2value(x, y, list/longlist)
	return text2num(longlist[((size * y) + (x + 1))])


/// Default noise subtype for generating some noise over a section of map
/datum/worldgen_modifier/noise
	/// Lower limit exclusion, anything at or below is rejected
	var/lower_range = 0
	/// Upper limit exclusion, anything at or above is rejected
	var/upper_range = 9
	/// Perlin noise frequency, how 'big' the noise blobs are
	var/frequency = 0.1

	var/divisor = 1
	/// How many noise maps at different frequencies to overlay, makes the noise 'rougher'
	var/octaves = 2
	/// Seed for generation, if unset random 1,999999 number used
	var/seed = -1
	/// A size * size list of 0-9 chars corresponding to the noise at each tile
	var/list/result_map = list()

/// Called from outside, returns a result_map
/datum/worldgen_modifier/noise/generate()
	if(seed == -1)
		seed = rand(1, 999999)
	generate_noise()
	..()
	. = list("map" = result_map)
	apply()
	return

/// Handles calling the rustlib noise generation
/datum/worldgen_modifier/noise/proc/generate_noise()
	result_map = rustlibs_perlin_generate_advanced("[seed]", "[size]", "[frequency]", "[divisor]", "[octaves]")
	return

/// Iterate over the map subsection and if a tile matches lower/upper range send to apply_value()
/datum/worldgen_modifier/noise/apply()
	for(var/turf/T in block(location_x, location_y, location_z, (size + location_x) - 1, (size + location_y) - 1, location_z))
		var/c = coord2value(T.x - location_x, T.y - location_y, result_map)
		if(c >= lower_range && c <= upper_range)
			apply_value(T)
	return

/// Most of tile modification and tile specific rejection occurs here
/datum/worldgen_modifier/noise/proc/apply_value(turf/T)
	return


/// World generation modifier for ore generation
/datum/worldgen_modifier/noise/ore
	name = "worldgen ore"
	lower_range = 2
	upper_range = 5
	frequency = 10
	octaves = 1
	generation_data_expected = list("ore_weights", "biome", "ore_chance")

#warn TODO dont do this                             vvvvvvvvvvvvvvvvv
/datum/worldgen_modifier/noise/ore/apply_value(turf/simulated/mineral/T)
	if(!ismineralturf(T)) // minerals only!
		return
	// multiply our base ore chance by how biome our biome is * 2
	if(prob(generation_data["ore_chance"] * coord2value(T.x - location_x, T.y - location_y, generation_data["biome"]) * 2))
		T.set_ore(pickweight(generation_data["ore_weights"]))
		T.color = COLOR_RED
	return


/// World generation modifier for lakes, be it sulpherous or lavapherous
/datum/worldgen_modifier/noise/humidity
	name = "worldgen humidity"
	// uses a noise map to help with river generation later on
	lower_range = 7
	upper_range = 9 // only the wettest areas!
	frequency = 1
	octaves = 2
	generation_data_expected = list("liquid_type")

/datum/worldgen_modifier/noise/humidity/generate()
	..()
	. = list("humidity" = result_map)

/datum/worldgen_modifier/noise/humidity/apply_value(turf/T)
	//if(0 == 1) // various importanta checks go here
	//	return
	T.ChangeTurf(generation_data["liquid_type"])
	return


/// World generation modifier for biome influence maps
/datum/worldgen_modifier/noise/biome
	name = "worldgen biome"
	lower_range = 3
	upper_range = 9
	size = 96
	frequency = 0.02
	octaves = 2
	var/mix = 0.5
	generation_data_expected = list("rock_type", "ambient_light")

/datum/worldgen_modifier/noise/biome/generate_noise()
	result_map = rustlibs_perlin_generate_advanced_dlerp("[seed]", "[size]", "[frequency]", "[divisor]", "[octaves]", "[mix]")

/datum/worldgen_modifier/noise/biome/generate()
	..()
	. = list("biome" = result_map)

/datum/worldgen_modifier/noise/biome/apply_value(turf/T)
	if(!istype(get_area(T), /area/lavaland/surface/outdoors/unexplored))
		return
	T.ChangeTurf(generation_data["rock_type"])
	var/area/old_area = T.loc
	T.change_area(old_area, generation_data["biome_area"])


/// World generation modifier for fauna, small random chance per tile, more at centre of biome
/datum/worldgen_modifier/fauna
	name = "worldgen fauna"
	generation_data_expected = list("fauna_chance", "fauna_weights", "biome")

/datum/worldgen_modifier/fauna/apply()
	for(var/turf/T in block(location_x, location_y, location_z, (size + location_x) - 1, (size + location_y) - 1, location_z))
		if(prob(generation_data["fauna_chance"]) * coord2value(T.x - location_x, T.y - location_y, generation_data["biome"]) * 2)
			var/chosen_fauna = pickweight(generation_data["fauna_weights"])
			new chosen_fauna(T) // go on! be free! kill people!


/// World generation modifier for flora, small random chance per tile, more at higher humidity areas
/datum/worldgen_modifier/flora
	name = "worldgen flora"
	generation_data_expected = list("flora_chance", "flora_weights")

/datum/worldgen_modifier/flora/apply()
	for(var/turf/T in block(location_x, location_y, location_z, (size + location_x) - 1, (size + location_y) - 1, location_z))
		if(prob(generation_data["flora_chance"]) * coord2value(T.x - location_x, T.y - location_y, generation_data["biome"]) * 2)
			var/chosen_flora = pickweight(generation_data["flora_weights"])
			new chosen_flora(T)

#warn TODO: river gen
#warn TODO: mineshaft gen
