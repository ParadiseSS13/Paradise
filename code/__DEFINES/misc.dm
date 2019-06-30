//Object specific defines
#define CANDLE_LUM 3 //For how bright candles are

//Directions (already defined on BYOND natively, purely here for reference)
//#define NORTH		1
//#define SOUTH		2
//#define EAST		4
//#define WEST		8
//#define NORTHEAST	5
//#define SOUTHEAST 6
//#define NORTHWEST 9
//#define SOUTHWEST 10

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
#define CLICK_CD_CLICK_ABILITY 6
#define CLICK_CD_RAPID 2

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

//Colors
#define COLOR_RED 			   "#FF0000"
#define COLOR_GREEN 		   "#00FF00"
#define COLOR_BLUE 			   "#0000FF"
#define COLOR_CYAN 			   "#00FFFF"
#define COLOR_PINK 			   "#FF00FF"
#define COLOR_YELLOW 		   "#FFFF00"
#define COLOR_ORANGE 		   "#FF9900"
#define COLOR_WHITE 		   "#FFFFFF"
#define COLOR_GRAY      	   "#808080"
#define COLOR_BLACK            "#000000"
#define COLOR_NAVY_BLUE        "#000080"
#define COLOR_LIGHT_GREEN      "#008000"
#define COLOR_DARK_GRAY        "#404040"
#define COLOR_MAROON           "#800000"
#define COLOR_PURPLE           "#800080"
#define COLOR_VIOLET           "#9933ff"
#define COLOR_OLIVE            "#808000"
#define COLOR_BROWN_ORANGE     "#824b28"
#define COLOR_DARK_ORANGE      "#b95a00"
#define COLOR_GRAY40           "#666666"
#define COLOR_GRAY20           "#333333"
#define COLOR_GRAY15           "#151515"
#define COLOR_SEDONA           "#cc6600"
#define COLOR_DARK_BROWN       "#917448"
#define COLOR_DEEP_SKY_BLUE    "#00e1ff"
#define COLOR_LIME             "#00ff00"
#define COLOR_TEAL             "#33cccc"
#define COLOR_PALE_PINK        "#bf89ba"
#define COLOR_YELLOW_GRAY      "#c9a344"
#define COLOR_PALE_YELLOW      "#c1bb7a"
#define COLOR_WARM_YELLOW      "#b3863c"
#define COLOR_RED_GRAY         "#aa5f61"
#define COLOR_BROWN            "#b19664"
#define COLOR_GREEN_GRAY       "#8daf6a"
#define COLOR_DARK_GREEN_GRAY  "#54654c"
#define COLOR_BLUE_GRAY        "#6a97b0"
#define COLOR_DARK_BLUE_GRAY   "#3e4855"
#define COLOR_SUN              "#ec8b2f"
#define COLOR_PURPLE_GRAY      "#a2819e"
#define COLOR_BLUE_LIGHT       "#33ccff"
#define COLOR_RED_LIGHT        "#ff3333"
#define COLOR_BEIGE            "#ceb689"
#define COLOR_BABY_BLUE        "#89cff0"
#define COLOR_PALE_GREEN_GRAY  "#aed18b"
#define COLOR_PALE_RED_GRAY    "#cc9090"
#define COLOR_PALE_PURPLE_GRAY "#bda2ba"
#define COLOR_PALE_BLUE_GRAY   "#8bbbd5"
#define COLOR_LUMINOL          "#66ffff"
#define COLOR_SILVER           "#c0c0c0"
#define COLOR_GRAY80           "#cccccc"
#define COLOR_OFF_WHITE        "#eeeeee"
#define COLOR_GOLD             "#6d6133"
#define COLOR_NT_RED           "#9d2300"
#define COLOR_BOTTLE_GREEN     "#1f6b4f"
#define COLOR_PALE_BTL_GREEN   "#57967f"
#define COLOR_GUNMETAL         "#545c68"
#define COLOR_WALL_GUNMETAL    "#353a42"
#define COLOR_STEEL            "#a8b0b2"
#define COLOR_MUZZLE_FLASH     "#ffffb2"
#define COLOR_CHESTNUT         "#996633"
#define COLOR_BEASTY_BROWN     "#663300"
#define COLOR_WHEAT            "#ffff99"
#define COLOR_CYAN_BLUE        "#3366cc"
#define COLOR_LIGHT_CYAN       "#66ccff"
#define COLOR_PAKISTAN_GREEN   "#006600"
#define COLOR_HULL             "#436b8e"
#define COLOR_AMBER            "#ffbf00"
#define COLOR_COMMAND_BLUE     "#46698c"
#define COLOR_SKY_BLUE         "#5ca1cc"
#define COLOR_PALE_ORANGE      "#b88a3b"
#define COLOR_CIVIE_GREEN      "#b7f27d"
#define COLOR_TITANIUM         "#d1e6e3"
#define COLOR_DARK_GUNMETAL    "#4c535b"
#define COLOR_BRONZE           "#8c7853"
#define COLOR_BRASS            "#b99d71"
#define COLOR_INDIGO           "#4b0082"
#define COLOR_ALUMINIUM        "#bbbbbb"
#define COLOR_CRYSTAL          "#00c8a5"
#define COLOR_ASTEROID_ROCK    "#735555"
#define COLOR_NULLGLASS        "#ff6088"
#define COLOR_DIAMOND          "#d8d4ea"

//FONTS:
// Used by Paper and PhotoCopier (and PaperBin once a year).
// Used by PDA's Notekeeper.
// Used by NewsCaster and NewsPaper.
// Used by Modular Computers
#define PEN_FONT "Verdana"
#define CRAYON_FONT "Comic Sans MS"
#define PRINTER_FONT "Times New Roman"
#define SIGNFONT "Times New Roman"

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

#define LIGHT_COLOR_BLUE       "#6496FA" //Cold, diluted blue. rgb(100, 150, 250)
#define LIGHT_COLOR_LIGHTBLUE	"#0099FF"
#define LIGHT_COLOR_DARKBLUE	"#315AB4"
#define LIGHT_COLOR_PURE_BLUE	"#0000FF"

#define LIGHT_COLOR_FADEDPURPLE	"#A97FAA"
#define LIGHT_COLOR_PURPLE		"#CD00CD"
#define LIGHT_COLOR_PINK		"#FF33CC"

#define LIGHT_COLOR_YELLOW     "#E1E17D" //Dimmed yellow, leaning kaki. rgb(225, 225, 125)

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
#define TURF_WET_PERMAFROST 4

#define APPEARANCE_UI_IGNORE_ALPHA			RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|RESET_ALPHA

// Metal foam states
// teehee no one will find these here
#define MFOAM_ALUMINUM 	1
#define MFOAM_IRON 		2

//Human Overlays Indexes/////////
#define BODY_LAYER				37
#define MUTANTRACE_LAYER		36
#define TAIL_UNDERLIMBS_LAYER	35	//Tail split-rendering.
#define LIMBS_LAYER				34
#define INTORGAN_LAYER			33
#define MARKINGS_LAYER			32
#define UNDERWEAR_LAYER			31
#define MUTATIONS_LAYER			30
#define H_DAMAGE_LAYER			29
#define UNIFORM_LAYER			28
#define ID_LAYER				27
#define SHOES_LAYER				26
#define GLOVES_LAYER			25
#define EARS_LAYER				24
#define SUIT_LAYER				23
#define BELT_LAYER				22	//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		21
#define BACK_LAYER				20
#define HEAD_ACCESSORY_LAYER	19
#define FHAIR_LAYER				18
#define GLASSES_LAYER			17
#define HAIR_LAYER				16	//TODO: make part of head layer?
#define HEAD_ACC_OVER_LAYER		15	//Select-layer rendering.
#define FHAIR_OVER_LAYER		14	//Select-layer rendering.
#define GLASSES_OVER_LAYER		13	//Select-layer rendering.
#define TAIL_LAYER				12	//bs12 specific. this hack is probably gonna come back to haunt me
#define FACEMASK_LAYER			11
#define HEAD_LAYER				10
#define COLLAR_LAYER			9
#define HANDCUFF_LAYER			8
#define LEGCUFF_LAYER			7
#define L_HAND_LAYER			6
#define R_HAND_LAYER			5
#define TARGETED_LAYER			4	//BS12: Layer for the target overlay from weapon targeting system
#define FIRE_LAYER				3	//If you're on fire
#define MISC_LAYER				2
#define FROZEN_LAYER			1
#define TOTAL_LAYERS			37

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

//Just space
#define SPACE_ICON_STATE	"[((x + y) ^ ~(x * y) + z) % 25]"

//used for maploader
#define MAP_MINX 1
#define MAP_MINY 2
#define MAP_MINZ 3
#define MAP_MAXX 4
#define MAP_MAXY 5
#define MAP_MAXZ 6

//Matricies
#define MATRIX_GREYSCALE list(0.33, 0.33, 0.33,\
                              0.33, 0.33, 0.33,\
                              0.33, 0.33, 0.33)

#define MATRIX_VULP_CBLIND list(0.5,0.4,0.1,\
                                0.5,0.4,0.1,\
                                0.0,0.2,0.8)

#define MATRIX_TAJ_CBLIND list(0.4,0.2,0.4,\
                               0.4,0.6,0.0,\
                               0.2,0.2,0.6)

#define LIST_REPLACE_RENAME list("rebeccapurple" = "dark purple", "darkslategrey" = "dark grey", "darkolivegreen" = "dark green", "darkslateblue" = "dark blue",\
								 "darkkhaki" = "khaki", "darkseagreen" = "light green", "midnightblue" = "blue", "lightgrey" = "light grey", "darkgrey" = "dark grey",\
								 "steelblue" = "blue", "goldenrod" = "gold")

#define LIST_GREYSCALE_REPLACE list("red" = "lightgrey", "blue" = "grey", "green" = "grey", "orange" = "lightgrey", "brown" = "grey",\
									"gold" = "lightgrey", "cyan" = "lightgrey", "navy" = "grey", "purple" = "grey", "pink"= "lightgrey")

#define LIST_VULP_REPLACE list("pink" = "beige", "orange" = "goldenrod", "gold" = "goldenrod", "red" = "darkolivegreen", "brown" = "darkolivegreen",\
									 "green" = "darkslategrey", "cyan" = "steelblue", "purple" = "darkslategrey", "navy" = "midnightblue")

#define LIST_TAJ_REPLACE list("red" = "rebeccapurple", "brown" = "rebeccapurple", "purple" = "darkslateblue", "blue" = "darkslateblue",\
									 "green" = "darkolivegreen", "orange" = "darkkhaki", "gold" = "darkkhaki", "cyan" = "darkseagreen", \
									 "navy" = "midnightblue", "pink" = "lightgrey")


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

// Bluespace shelter deploy checks
#define SHELTER_DEPLOY_ALLOWED "allowed"
#define SHELTER_DEPLOY_BAD_TURFS "bad turfs"
#define SHELTER_DEPLOY_BAD_AREA "bad area"
#define SHELTER_DEPLOY_ANCHORED_OBJECTS "anchored objects"

// Client donator levels
#define DONATOR_LEVEL_NONE 0
#define DONATOR_LEVEL_ONE 1
#define DONATOR_LEVEL_TWO 2

// The cooldown on OOC messages such as OOC, LOOC, praying and adminhelps
#define OOC_COOLDOWN 5

// Medal names
#define BOSS_KILL_MEDAL "Killer"
#define ALL_KILL_MEDAL "Exterminator"	//Killing all of x type

// Score names
#define LEGION_SCORE "Legion Killed"
#define COLOSSUS_SCORE "Colossus Killed"
#define BUBBLEGUM_SCORE "Bubblegum Killed"
#define DRAKE_SCORE "Drakes Killed"
#define BIRD_SCORE "Hierophants Killed"
#define BOSS_SCORE "Bosses Killed"
#define TENDRIL_CLEAR_SCORE "Tendrils Killed"

// The number of station goals generated each round.
#define STATION_GOAL_BUDGET 1

#define FIRST_DIAG_STEP 1
#define SECOND_DIAG_STEP 2

#define ARBITRARY_VIEWRANGE_NOHUD 2

//Bloody shoes/footprints
#define MAX_SHOE_BLOODINESS			100
#define BLOODY_FOOTPRINT_BASE_ALPHA	150
#define BLOOD_GAIN_PER_STEP			100
#define BLOOD_LOSS_PER_STEP			5

//Bloody shoe blood states
#define BLOOD_STATE_HUMAN			"blood"
#define BLOOD_STATE_XENO			"xeno"
#define BLOOD_STATE_NOT_BLOODY		"no blood whatsoever"

//for obj explosion block calculation
#define EXPLOSION_BLOCK_PROC -1

// Defines for investigate to prevent typos and for styling
#define INVESTIGATE_LABEL "labels"

#define INVESTIGATE_BOMB "bombs"

// The SQL version required by this version of the code
#define SQL_VERSION 5

// Vending machine stuff
#define CAT_NORMAL 1
#define CAT_HIDDEN 2
#define CAT_COIN   4

// Jobs
// used for alternate_option
#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2

//Melting Temperatures for various specific objects
#define GIRDER_MELTING_TEMP 5000

// Area selection defines
#define AREASELECT_CORNERA "corner A"
#define AREASELECT_CORNERB "corner B"

//https://secure.byond.com/docs/ref/info.html#/atom/var/mouse_opacity
#define MOUSE_OPACITY_TRANSPARENT 0
#define MOUSE_OPACITY_ICON 1
#define MOUSE_OPACITY_OPAQUE 2

// Defib stats
#define DEFIB_TIME_LIMIT 120
#define DEFIB_TIME_LOSS 60

//Ghost orbit types:
#define GHOST_ORBIT_CIRCLE		"circle"
#define GHOST_ORBIT_TRIANGLE	"triangle"
#define GHOST_ORBIT_HEXAGON		"hexagon"
#define GHOST_ORBIT_SQUARE		"square"
#define GHOST_ORBIT_PENTAGON	"pentagon"