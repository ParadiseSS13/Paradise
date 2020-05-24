#define Z_NORTH 1
#define Z_EAST 2
#define Z_SOUTH 3
#define Z_WEST 4

GLOBAL_LIST_INIT(cardinal, list( NORTH, SOUTH, EAST, WEST ))
GLOBAL_LIST_INIT(alldirs, list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
GLOBAL_LIST_INIT(diagonals, list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))

// This must exist early on or shit breaks bad
GLOBAL_DATUM_INIT(using_map, /datum/map, new USING_MAP_DATUM)

GLOBAL_LIST(global_map) // This is the array of zlevels | list(list(1,5),list(4,3)) | becomes a 2D array of zlevels
	//Resulting sector map looks like
	//|_1_|_4_|
	//|_5_|_3_|
	//
	//1 - SS13
	//4 - Derelict
	//3 - AI satellite
	//5 - empty space

GLOBAL_LIST_EMPTY(wizardstart)
GLOBAL_LIST_EMPTY(newplayer_start)
GLOBAL_LIST_EMPTY(latejoin)
GLOBAL_LIST_EMPTY(latejoin_gateway)
GLOBAL_LIST_EMPTY(latejoin_cryo)
GLOBAL_LIST_EMPTY(latejoin_cyborg)
GLOBAL_LIST_EMPTY(prisonwarp)	//prisoners go to these
GLOBAL_LIST_EMPTY(xeno_spawn)//Aliens spawn at these.
GLOBAL_LIST_EMPTY(ertdirector)
GLOBAL_LIST_EMPTY(emergencyresponseteamspawn)
GLOBAL_LIST_EMPTY(tdome1)
GLOBAL_LIST_EMPTY(tdome2)
GLOBAL_LIST_EMPTY(team_alpha)
GLOBAL_LIST_EMPTY(team_bravo)
GLOBAL_LIST_EMPTY(tdomeobserve)
GLOBAL_LIST_EMPTY(tdomeadmin)
GLOBAL_LIST_EMPTY(aroomwarp)
GLOBAL_LIST_EMPTY(prisonsecuritywarp)	//prison security goes to these
GLOBAL_LIST_EMPTY(prisonwarped)	//list of players already warped
GLOBAL_LIST_EMPTY(blobstart)
GLOBAL_LIST_EMPTY(ninjastart)
GLOBAL_LIST_EMPTY(carplist) //list of all carp-spawn landmarks
GLOBAL_LIST_EMPTY(syndicateofficer)

//away missions
GLOBAL_LIST_EMPTY(awaydestinations)	//a list of landmarks that the warpgate can take you to

//List of preloaded templates
GLOBAL_LIST_EMPTY(map_templates)
GLOBAL_LIST_EMPTY(ruins_templates)
GLOBAL_LIST_EMPTY(space_ruins_templates)
GLOBAL_LIST_EMPTY(lava_ruins_templates)
GLOBAL_LIST_EMPTY(shelter_templates)
GLOBAL_LIST_EMPTY(shuttle_templates)
