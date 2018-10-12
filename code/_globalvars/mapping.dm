#define Z_NORTH 1
#define Z_EAST 2
#define Z_SOUTH 3
#define Z_WEST 4

GLOBAL_LIST_INIT(cardinal, list(NORTH, SOUTH, EAST, WEST))
GLOBAL_LIST_INIT(alldirs, list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
GLOBAL_LIST_INIT(diagonals, list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))

var/global/list/global_map = null
	//list/global_map = list(list(1,5),list(4,3))//an array of map Z levels.
	//Resulting sector map looks like
	//|_1_|_4_|
	//|_5_|_3_|
	//
	//1 - SS13
	//4 - Derelict
	//3 - AI satellite
	//5 - empty space

GLOBAL_LIST_EMPTY(landmarks_list)				//list of all landmarks created
GLOBAL_LIST_EMPTY(start_landmarks_list)			//list of all spawn points created
GLOBAL_LIST_EMPTY(generic_event_spawns)			//list of all spawns for events
GLOBAL_LIST_EMPTY(jobspawn_overrides)					//These will take precedence over normal spawnpoints if created.

GLOBAL_LIST_EMPTY(wizardstart)
GLOBAL_LIST_EMPTY(nukeop_start)
GLOBAL_LIST_EMPTY(nukeop_leader_start)
GLOBAL_LIST_EMPTY(newplayer_start)
GLOBAL_LIST_EMPTY(latejoin)
GLOBAL_LIST_EMPTY(prisonwarp)	//prisoners go to these
GLOBAL_LIST_EMPTY(xeno_spawn)//Aliens spawn at these.
GLOBAL_LIST_EMPTY(ertdirector)
GLOBAL_LIST_EMPTY(emergencyresponseteamspawn)
GLOBAL_LIST_EMPTY(tdome1)
GLOBAL_LIST_EMPTY(tdome2)
GLOBAL_LIST_EMPTY(tdomeobserve)
GLOBAL_LIST_EMPTY(tdomeadmin)
GLOBAL_LIST_EMPTY(team_alpha)
GLOBAL_LIST_EMPTY(team_bravo)
GLOBAL_LIST_EMPTY(aroomwarp)
GLOBAL_LIST_EMPTY(blobstart)
GLOBAL_LIST_EMPTY(ninjastart)
GLOBAL_LIST_EMPTY(carplist)
GLOBAL_LIST_EMPTY(avatarspawn)

//away missions
GLOBAL_LIST_EMPTY(awaydestinations)	//a list of landmarks that the warpgate can take you to

//List of preloaded templates
var/list/datum/map_template/map_templates = list()

var/list/datum/map_template/ruins_templates = list()
var/list/datum/map_template/space_ruins_templates = list()
var/list/datum/map_template/lava_ruins_templates = list()
var/list/datum/map_template/shelter_templates = list()
var/list/datum/map_template/shuttle_templates = list()
var/list/datum/map_template/vr_templates = list()
