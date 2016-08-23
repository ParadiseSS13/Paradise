//Object specific defines
#define CANDLE_LUM 3 //For how bright candles are

//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_GAMMA	3
#define SEC_LEVEL_EPSILON	4
#define SEC_LEVEL_DELTA	5

//Click cooldowns, in tenths of a second
#define CLICK_CD_MELEE 8
#define CLICK_CD_RANGE 4
#define CLICK_CD_BREAKOUT 100
#define CLICK_CD_HANDCUFFED 10
#define CLICK_CD_TKSTRANGLE 10
#define CLICK_CD_POINT 10
#define CLICK_CD_RESIST 20

//Sizes of mobs, used by mob/living/var/mob_size
#define MOB_SIZE_TINY 0
#define MOB_SIZE_SMALL 1
#define MOB_SIZE_HUMAN 2
#define MOB_SIZE_LARGE 3
///
#define ROUNDSTART_LOGOUT_REPORT_TIME 6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

// DOOR CRUSHING DAMAGE!
#define DOOR_CRUSH_DAMAGE 10

////////////GERMS AND INFECTIONS////////////
#define GERM_LEVEL_AMBIENT		110		//maximum germ level you can reach by standing still
#define GERM_LEVEL_MOVE_CAP		200		//maximum germ level you can reach by running around

#define INFECTION_LEVEL_ONE		100
#define INFECTION_LEVEL_TWO		500
#define INFECTION_LEVEL_THREE	1000

// Damage above this value must be repaired with surgery.
#define ROBOLIMB_SELF_REPAIR_CAP 60

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL	50
#define MAX_STACK_AMOUNT_GLASS	50
#define MAX_STACK_AMOUNT_RODS	60

//some colors
#define COLOR_RED 		"#FF0000"
#define COLOR_GREEN 	"#00FF00"
#define COLOR_BLUE 		"#0000FF"
#define COLOR_CYAN 		"#00FFFF"
#define COLOR_PINK 		"#FF00FF"
#define COLOR_YELLOW 	"#FFFF00"
#define COLOR_ORANGE 	"#FF9900"
#define COLOR_WHITE 	"#FFFFFF"
#define COLOR_GRAY      "#808080"

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

//Flags for zone sleeping
#define ZONE_ACTIVE 1
#define ZONE_SLEEPING 0

#define shuttle_time_in_station 1800 // 3 minutes in the station
#define shuttle_time_to_arrive 6000 // 10 minutes to arrive

#define EVENT_LEVEL_MUNDANE 1
#define EVENT_LEVEL_MODERATE 2
#define EVENT_LEVEL_MAJOR 3

#define JANUARY		1
#define FEBRUARY	2
#define MARCH		3
#define APRIL		4
#define MAY			5
#define JUNE		6
#define JULY		7
#define AUGUST		8
#define SEPTEMBER	9
#define OCTOBER		10
#define NOVEMBER	11
#define DECEMBER	12

//Select holiday names -- If you test for a holiday in the code, make the holiday's name a define and test for that instead
#define NEW_YEAR				"New Year"
#define VALENTINES				"Valentine's Day"
#define APRIL_FOOLS				"April Fool's Day"
#define EASTER					"Easter"
#define HALLOWEEN				"Halloween"
#define CHRISTMAS				"Christmas"
#define FRIDAY_13TH				"Friday the 13th"

//Light color defs, for light-emitting things
//Some defs may be pure color- this is for neatness, and configurability. Changing #define COLOR_ is a bad idea.
#define LIGHT_COLOR_CYAN		"#7BF9FF"
#define LIGHT_COLOR_PURE_CYAN	"#00FFFF"

#define LIGHT_COLOR_RED			"#B40000"
#define LIGHT_COLOR_ORANGE		"#FF9933"
#define LIGHT_COLOR_DARKRED		"#A91515"
#define LIGHT_COLOR_PURE_RED	"#FF0000"

#define LIGHT_COLOR_GREEN		"#00CC00"
#define LIGHT_COLOR_DARKGREEN	"#50AB00"
#define LIGHT_COLOR_PURE_GREEN	"#00FF00"

#define LIGHT_COLOR_LIGHTBLUE	"#0099FF"
#define LIGHT_COLOR_DARKBLUE	"#315AB4"
#define LIGHT_COLOR_PURE_BLUE	"#0000FF"

#define LIGHT_COLOR_FADEDPURPLE	"#A97FAA"
#define LIGHT_COLOR_PURPLE		"#CD00CD"
#define LIGHT_COLOR_PINK		"#FF33CC"

#define LIGHT_COLOR_WHITE		"#FFFFFF"

#define RESIZE_DEFAULT_SIZE 1

//transfer_ai() defines. Main proc in ai_core.dm
#define AI_TRANS_TO_CARD	1 //Downloading AI to InteliCard.
#define AI_TRANS_FROM_CARD	2 //Uploading AI from InteliCard
#define AI_MECH_HACK		3 //Malfunctioning AI hijacking mecha

//singularity defines
#define STAGE_ONE 1
#define STAGE_TWO 3
#define STAGE_THREE 5
#define STAGE_FOUR 7
#define STAGE_FIVE 9
#define STAGE_SIX 11 //From supermatter shard

#define in_range(source, user)		(get_dist(source, user) <= 1)

#define RANGE_TURFS(RADIUS, CENTER) \
  block( \
	locate(max(CENTER.x-(RADIUS),1),		  max(CENTER.y-(RADIUS),1),		  CENTER.z), \
	locate(min(CENTER.x+(RADIUS),world.maxx), min(CENTER.y+(RADIUS),world.maxy), CENTER.z) \
  )

#define FOR_DVIEW(type, range, center, invis_flags) \
	dview_mob.loc = center; \
	dview_mob.see_invisible = invis_flags; \
	for(type in view(range, dview_mob))
#define END_FOR_DVIEW dview_mob.loc = null

#define get_turf(A) (get_step(A, 0))

#define MIN_SUPPLIED_LAW_NUMBER 15
#define MAX_SUPPLIED_LAW_NUMBER 50

//Material defines
#define MAT_METAL			"$metal"
#define MAT_GLASS			"$glass"
#define MAT_SILVER			"$silver"
#define MAT_GOLD			"$gold"
#define MAT_DIAMOND			"$diamond"
#define MAT_URANIUM			"$uranium"
#define MAT_PLASMA			"$plasma"
#define MAT_BANANIUM		"$bananium"
#define MAT_TRANQUILLITE	"$tranquillite"

#define MAX_STACK_SIZE 50

//check_target_facings() return defines
#define FACING_FAILED											0
#define FACING_SAME_DIR											1
#define FACING_EACHOTHER										2
#define FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR	3 //Do I win the most informative but also most stupid define award?

//unmagic-strings for types of polls
#define POLLTYPE_OPTION		"OPTION"
#define POLLTYPE_TEXT		"TEXT"
#define POLLTYPE_RATING		"NUMVAL"
#define POLLTYPE_MULTI		"MULTICHOICE"

#define MIDNIGHT_ROLLOVER	864000 //number of deciseconds in a day

#define MANIFEST_ERROR_NAME		1
#define MANIFEST_ERROR_COUNT	2
#define MANIFEST_ERROR_ITEM		4

//Turf wet states
#define TURF_DRY		0
#define TURF_WET_WATER	1
#define TURF_WET_LUBE	2
#define TURF_WET_ICE	3

#define APPEARANCE_UI_IGNORE_ALPHA			RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|RESET_ALPHA

// Metal foam states
// teehee no one will find these here
#define MFOAM_ALUMINUM 	1
#define MFOAM_IRON 		2

//Human Overlays Indexes/////////
#define MUTANTRACE_LAYER		1
#define TAIL_UNDERLIMBS_LAYER	2
#define LIMBS_LAYER				3
#define MARKINGS_LAYER			4
#define UNDERWEAR_LAYER			5
#define MUTATIONS_LAYER			6
#define DAMAGE_LAYER			7
#define UNIFORM_LAYER			8
#define ID_LAYER				9
#define SHOES_LAYER				10
#define GLOVES_LAYER			11
#define EARS_LAYER				12
#define SUIT_LAYER				13
#define GLASSES_LAYER			14
#define BELT_LAYER				15	//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		16
#define BACK_LAYER				17
#define TAIL_LAYER				18	//bs12 specific. this hack is probably gonna come back to haunt me
#define HAIR_LAYER				19	//TODO: make part of head layer?
#define HEAD_ACCESSORY_LAYER	20
#define FHAIR_LAYER				21
#define FACEMASK_LAYER			22
#define HEAD_LAYER				23
#define COLLAR_LAYER			24
#define HANDCUFF_LAYER			25
#define LEGCUFF_LAYER			26
#define L_HAND_LAYER			27
#define R_HAND_LAYER			28
#define TARGETED_LAYER			29	//BS12: Layer for the target overlay from weapon targeting system
#define FIRE_LAYER				30	//If you're on fire
#define TOTAL_LAYERS			30

///Access Region Codes///
#define REGION_ALL			0
#define REGION_GENERAL		1
#define REGION_SECURITY		2
#define REGION_MEDBAY		3
#define REGION_RESEARCH		4
#define REGION_ENGINEERING	5
#define REGION_SUPPLY		6
#define REGION_COMMAND		7
#define REGION_CENTCOMM		8

//used for maploader
#define MAP_MINX 1
#define MAP_MINY 2
#define MAP_MINZ 3
#define MAP_MAXX 4
#define MAP_MAXY 5
#define MAP_MAXZ 6

//Matricies
#define MATRIX_DEFAULT list(1, 0, 0, 0,\
                            0, 1, 0, 0,\
                            0, 0, 1, 0,\
                            0, 0, 0, 1)

#define MATRIX_GREYSCALE list(0.3, 0.3, 0.3, 0,\
                              0.3, 0.3, 0.3, 0,\
                              0.3, 0.3, 0.3, 0,\
                              0,   0,   0,   1)
//Gun trigger guards
#define TRIGGER_GUARD_ALLOW_ALL -1
#define TRIGGER_GUARD_NONE 0
#define TRIGGER_GUARD_NORMAL 1

// Macro to get the current elapsed round time, rather than total world runtime
#define ROUND_TIME (round_start_time ? (world.time - round_start_time) : 0)

// Macro that returns true if it's too early in a round to freely ghost out
#define TOO_EARLY_TO_GHOST (config && (ROUND_TIME < (config.round_abandon_penalty_period)))

// Used by radios to indicate that they have sent a message via something other than subspace
#define RADIO_CONNECTION_FAIL 0
#define RADIO_CONNECTION_NON_SUBSPACE 1

//Fire stuff, for burn_state
#define LAVA_PROOF -2
#define FIRE_PROOF -1
#define FLAMMABLE 0
#define ON_FIRE 1

// Sound
#define SOUND_MINIMUM_PRESSURE 10
#define FALLOFF_SOUNDS 0.5


// Bluespace shelter deploy checks
#define SHELTER_DEPLOY_ALLOWED "allowed"
#define SHELTER_DEPLOY_BAD_TURFS "bad turfs"
#define SHELTER_DEPLOY_BAD_AREA "bad area"
#define SHELTER_DEPLOY_ANCHORED_OBJECTS "anchored objects"
