//If anyone can think of a less shitty way to work out x,y points on a linear string of integers please tell me.
#define MAP_CELL ((y-1)*real_size)+x
#define MAP_CENTRE (((y-1)+size/2)*real_size)+(x+size/2)
#define MAP_TOP_LEFT ((y-1)*real_size)+x
#define MAP_TOP_RIGHT ((y-1)*real_size)+(x+size)
#define MAP_BOTTOM_LEFT (((y+size)-1)*real_size)+x
#define MAP_BOTTOM_RIGHT ((((y+size)-1)*real_size)+(x+size))
#define MAP_MID_TOP MAP_TOP_LEFT + (size/2)
#define MAP_MID_BOTTOM MAP_BOTTOM_LEFT + (size/2)
#define MAP_MID_LEFT (((y-1)+size/2)*real_size)+x
#define MAP_MID_RIGHT (((y-1)+size/2)*real_size)+(x+size)

#define MIN_SURFACE_COUNT 1000
#define MAX_SURFACE_COUNT 5000
#define MIN_RARE_COUNT 1000
#define MAX_RARE_COUNT 5000
#define MIN_DEEP_COUNT 100
#define MAX_DEEP_COUNT 300
#define ITERATE_BEFORE_FAIL 200

#define RESOURCE_HIGH_MAX 4
#define RESOURCE_HIGH_MIN 2
#define RESOURCE_MID_MAX 3
#define RESOURCE_MID_MIN 1
#define RESOURCE_LOW_MAX 1
#define RESOURCE_LOW_MIN 0

/*
Surface minerals:
	silicates
	iron
	gold
	silver

Rare minerals:
	uranium
	diamond

Deep minerals:
	phoron
	xerxium (adamantine)
	fulgurium (mythril)
*/

/datum/ore_distribution

	var/real_size = 65     //Overall map size ((must be power of 2)+1)
	var/chunk_size = 4     //Size each cell represents on map (like hell we're generating up to 100 256^2 grids at roundstart)
	var/list/map[4225]     //The actual map. real_size squared.
	var/range = 255        //Max random range of cells in map.

	var/random_variance_chance = 25
	var/random_element = 0.5

/datum/ore_distribution/proc/map_is_sane()
	if(!map) return 0

	var/rare_count = 0
	var/surface_count = 0
	var/deep_count = 0

	for(var/cell in map)
		if(cell>(range*0.60))
			deep_count++
		else if(cell>(range*0.40))
			rare_count++
		else
			surface_count++

	if(surface_count < MIN_SURFACE_COUNT || surface_count > MAX_SURFACE_COUNT) return 0
	if(rare_count < MIN_RARE_COUNT || rare_count > MAX_RARE_COUNT) return 0
	if(deep_count < MIN_DEEP_COUNT || deep_count > MAX_DEEP_COUNT) return 0
	return 1

//Halfassed diamond-square algorithm with some fuckery since it's a single dimension array.
/datum/ore_distribution/proc/populate_distribution_map()

	//Announce it!
	world << "<b><font color='red'>Generating resource distribution map.</b></font>"

	//Seed beginning values.
	var/x = 1
	var/y = 1
	var/size = real_size-1
	map[MAP_TOP_LEFT] =     (range/3)+rand(range/5)
	map[MAP_TOP_RIGHT] =    (range/3)+rand(range/5)
	map[MAP_BOTTOM_LEFT] =  (range/3)+rand(range/5)
	map[MAP_BOTTOM_RIGHT] = (range/3)+rand(range/5)

	//Fill in and smooth it out.
	var/attempts = 0
	do
		attempts++
		generate_distribution_map(1,1,size)
	while(attempts < ITERATE_BEFORE_FAIL && !map_is_sane())

	if(attempts >= ITERATE_BEFORE_FAIL)
		world << "<b><font color='red'>Could not generate a sane distribution map. Aborting.</font></b>"
		map = null
		return
	else
		apply_to_asteroid()

/datum/ore_distribution/proc/clear_distribution_map()
	for(var/x = 1, x <= real_size, x++)
		for(var/y = 1, y <= real_size, y++)
			map[MAP_CELL] = 0

/datum/ore_distribution/proc/print_distribution_map()
	var/line = ""
	for(var/x = 1, x <= real_size, x++)
		for(var/y = 1, y <= real_size, y++)
			line += num2text(round(map[MAP_CELL]/25.5))
		world << line
		line = ""

/datum/ore_distribution/proc/generate_distribution_map(var/x,var/y,var/input_size)

	var/size = input_size

	map[MAP_MID_TOP] =    (map[MAP_TOP_LEFT] + map[MAP_TOP_RIGHT])/2
	map[MAP_MID_RIGHT] =  (map[MAP_BOTTOM_RIGHT] + map[MAP_TOP_RIGHT])/2
	map[MAP_MID_BOTTOM] = (map[MAP_BOTTOM_LEFT] + map[MAP_BOTTOM_RIGHT])/2
	map[MAP_MID_LEFT] =   (map[MAP_TOP_LEFT] + map[MAP_BOTTOM_RIGHT])/2
	map[MAP_CENTRE] =     (map[MAP_MID_LEFT]+map[MAP_MID_RIGHT]+map[MAP_MID_BOTTOM]+map[MAP_MID_TOP])/4

	if(prob(random_variance_chance))
		map[MAP_CENTRE] *= (rand(1) ? (1.0-random_element) : (1.0+random_element))
		map[MAP_CENTRE] = max(0,min(range,map[MAP_CENTRE]))

	if(size>3)
		generate_distribution_map(x,y,input_size/2)
		generate_distribution_map(x+(input_size/2),y,input_size/2)
		generate_distribution_map(x,y+(input_size/2),input_size/2)
		generate_distribution_map(x+(input_size/2),y+(input_size/2),input_size/2)

/datum/ore_distribution/proc/apply_to_asteroid()

	// THESE VALUES DETERMINE THE AREA THAT THE DISTRIBUTION MAP IS APPLIED TO.
	// IF YOU DO NOT RUN OFFICIAL BAYCODE ASTEROID MAP YOU NEED TO CHANGE THEM.
	// ORIGIN IS THE BOTTOM LEFT CORNER OF THE SQUARE CONTAINING ALL ASTEROID
	// TILES YOU WISH TO APPLY THE DISTRIBUTION MAP TO.

	var/origin_x = 13  //We start here...
	var/origin_y = 32  //...and here...
	var/limit_x = 217  //...and iterate until here...
	var/limit_y = 223  //...and here...
	var/asteroid_z = 5 //...on this Z-level.

	var/tx = origin_x
	var/ty = origin_y

	for(var/y = 1, y <= real_size, y++)

		for(var/x = 1, x <= real_size, x++)

			var/turf/target_turf

			for(var/i=0,i<chunk_size,i++)

				for(var/j=0,j<chunk_size,j++)

					if(tx+j > limit_x || ty+i > limit_y)
						continue

					target_turf = locate(tx+j, ty+i, asteroid_z)

					if(target_turf && target_turf.has_resources)

						target_turf.resources = list()
						target_turf.resources["silicates"] = rand(3,5)
						target_turf.resources["carbonaceous rock"] = rand(3,5)

						switch(map[MAP_CELL])
							if(0 to 100)
								target_turf.resources["iron"] =       rand(RESOURCE_HIGH_MIN,RESOURCE_HIGH_MAX)
								target_turf.resources["gold"] =       rand(RESOURCE_LOW_MIN,RESOURCE_LOW_MAX)
								target_turf.resources["silver"] =     rand(RESOURCE_LOW_MIN,RESOURCE_LOW_MAX)
								target_turf.resources["uranium"] =    rand(RESOURCE_LOW_MIN,RESOURCE_LOW_MAX)
								target_turf.resources["diamond"] =    0
								target_turf.resources["phoron"] =     0
								target_turf.resources["osmium"] =     0
								target_turf.resources["hydrogen"] =   0
							if(100 to 124)
								target_turf.resources["iron"] =       0
								target_turf.resources["gold"] =       rand(RESOURCE_MID_MIN,RESOURCE_MID_MAX)
								target_turf.resources["silver"] =     rand(RESOURCE_MID_MIN,RESOURCE_MID_MAX)
								target_turf.resources["uranium"] =    rand(RESOURCE_MID_MIN,RESOURCE_MID_MAX)
								target_turf.resources["diamond"] =    0
								target_turf.resources["phoron"] =     rand(RESOURCE_MID_MIN,RESOURCE_MID_MAX)
								target_turf.resources["osmium"] =     rand(RESOURCE_MID_MIN,RESOURCE_MID_MAX)
								target_turf.resources["hydrogen"] =   0
							if(125 to 255)
								target_turf.resources["iron"] =       0
								target_turf.resources["gold"] =       0
								target_turf.resources["silver"] =     0
								target_turf.resources["uranium"] =    rand(RESOURCE_LOW_MIN,RESOURCE_LOW_MAX)
								target_turf.resources["diamond"] =    rand(RESOURCE_LOW_MIN,RESOURCE_LOW_MAX)
								target_turf.resources["phoron"] =     rand(RESOURCE_HIGH_MIN,RESOURCE_HIGH_MAX)
								target_turf.resources["osmium"] =     rand(RESOURCE_HIGH_MIN,RESOURCE_HIGH_MAX)
								target_turf.resources["hydrogen"] =   rand(RESOURCE_MID_MIN,RESOURCE_MID_MAX)

			tx += chunk_size
		tx = origin_x
		ty += chunk_size

	world << "<b><font color='red'>Resource map generation complete.</font></b>"
	return

#undef MAP_CELL
#undef MAP_CENTRE
#undef MAP_TOP_LEFT
#undef MAP_TOP_RIGHT
#undef MAP_BOTTOM_LEFT
#undef MAP_BOTTOM_RIGHT
#undef MAP_MID_TOP
#undef MAP_MID_BOTTOM
#undef MAP_MID_LEFT
#undef MAP_MID_RIGHT

#undef MIN_SURFACE_COUNT
#undef MAX_SURFACE_COUNT
#undef MIN_RARE_COUNT
#undef MAX_RARE_COUNT
#undef MIN_DEEP_COUNT
#undef MAX_DEEP_COUNT
#undef ITERATE_BEFORE_FAIL

#undef RESOURCE_HIGH_MAX
#undef RESOURCE_HIGH_MIN
#undef RESOURCE_MID_MAX
#undef RESOURCE_MID_MIN
#undef RESOURCE_LOW_MAX
#undef RESOURCE_LOW_MIN
