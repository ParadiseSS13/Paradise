#define Z_NORTH 1
#define Z_EAST 2
#define Z_SOUTH 3
#define Z_WEST 4

var/list/cardinal = list( NORTH, SOUTH, EAST, WEST )
var/list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
var/list/diagonals = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

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

var/list/wizardstart = list()
var/list/newplayer_start = list()
var/list/latejoin = list()
var/list/latejoin_gateway = list()
var/list/latejoin_cryo = list()
var/list/latejoin_cyborg = list()
var/list/prisonwarp = list()	//prisoners go to these
var/list/xeno_spawn = list()//Aliens spawn at these.
var/list/ertdirector = list()
var/list/emergencyresponseteamspawn  = list()
var/list/tdome1 = list()
var/list/tdome2 = list()
var/list/team_alpha = list()
var/list/team_bravo = list()
var/list/tdomeobserve = list()
var/list/tdomeadmin = list()
var/list/aroomwarp = list()
var/list/prisonsecuritywarp = list()	//prison security goes to these
var/list/prisonwarped = list()	//list of players already warped
var/list/blobstart = list()
var/list/ninjastart = list()
var/list/carplist = list() //list of all carp-spawn landmarks
var/list/avatarspawn = list()
var/list/syndicateofficer = list()

//away missions
var/list/awaydestinations = list()	//a list of landmarks that the warpgate can take you to

//List of preloaded templates
var/list/datum/map_template/map_templates = list()

var/list/datum/map_template/ruins_templates = list()
var/list/datum/map_template/space_ruins_templates = list()
var/list/datum/map_template/lava_ruins_templates = list()
var/list/datum/map_template/shelter_templates = list()
var/list/datum/map_template/shuttle_templates = list()
var/list/datum/map_template/vr_templates = list()