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
#define CLICK_CD_HANDCUFFED 10
#define CLICK_CD_TKSTRANGLE 10
#define CLICK_CD_POINT 10
#define CLICK_CD_RESIST 8
#define CLICK_CD_PARRY 8
#define CLICK_CD_CLICK_ABILITY 6
#define CLICK_CD_RAPID 2

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
	RECT_TURFS(RADIUS, RADIUS, CENTER)

#define RECT_TURFS(H_RADIUS, V_RADIUS, CENTER) \
	block( \
	locate(max(CENTER.x-(H_RADIUS),1),          max(CENTER.y-(V_RADIUS),1),          CENTER.z), \
	locate(min(CENTER.x+(H_RADIUS),world.maxx), min(CENTER.y+(V_RADIUS),world.maxy), CENTER.z) \
	)

/// Returns the turfs on the edge of a square with CENTER in the middle and with the given RADIUS. If used near the edge of the map, will still work fine.
// order of the additions: top edge + bottom edge + left edge + right edge
#define RANGE_EDGE_TURFS(RADIUS, CENTER)\
	(CENTER.y + RADIUS < world.maxy ? block(locate(max(CENTER.x - RADIUS, 1), min(CENTER.y + RADIUS, world.maxy), CENTER.z), locate(min(CENTER.x + RADIUS, world.maxx), min(CENTER.y + RADIUS, world.maxy), CENTER.z)) : list()) +\
	(CENTER.y - RADIUS > 1 ? block(locate(max(CENTER.x - RADIUS, 1), max(CENTER.y - RADIUS, 1), CENTER.z), locate(min(CENTER.x + RADIUS, world.maxx), max(CENTER.y - RADIUS, 1), CENTER.z)) : list()) +\
	(CENTER.x - RADIUS > 1 ? block(locate(max(CENTER.x - RADIUS, 1), min(CENTER.y + RADIUS - 1, world.maxy), CENTER.z), locate(max(CENTER.x - RADIUS, 1), max(CENTER.y - RADIUS + 1, 1), CENTER.z)) : list()) +\
	(CENTER.x + RADIUS < world.maxx ? block(locate(min(CENTER.x + RADIUS, world.maxx), min(CENTER.y + RADIUS - 1, world.maxy), CENTER.z), locate(min(CENTER.x + RADIUS, world.maxx), max(CENTER.y - RADIUS + 1, 1), CENTER.z)) : list())


#define FOR_DVIEW(type, range, center, invis_flags) \
	GLOB.dview_mob.loc = center; \
	GLOB.dview_mob.see_invisible = invis_flags; \
	for(type in view(range, GLOB.dview_mob))
#define END_FOR_DVIEW GLOB.dview_mob.loc = null

//Turf locational stuff
#define get_turf(A) (get_step(A, 0))
#define NORTH_OF_TURF(T)	locate(T.x, T.y + 1, T.z)
#define EAST_OF_TURF(T)		locate(T.x + 1, T.y, T.z)
#define SOUTH_OF_TURF(T)	locate(T.x, T.y - 1, T.z)
#define WEST_OF_TURF(T)		locate(T.x - 1, T.y, T.z)

#define ATOM_COORDS(A) list(A.x, A.y, A.z)

#define MIN_SUPPLIED_LAW_NUMBER 15
#define MAX_SUPPLIED_LAW_NUMBER 50

//check_target_facings() return defines
#define FACING_FAILED											0
#define FACING_SAME_DIR											1
#define FACING_EACHOTHER										2
#define FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR	3 //Do I win the most informative but also most stupid define award?

#define MIDNIGHT_ROLLOVER	864000 //number of deciseconds in a day

#define CAMERA_VIEW_DISTANCE 7
#define CAMERA_CHUNK_SIZE 16 // Only chunk sizes that are to the power of 2. E.g: 2, 4, 8, 16, etc..


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
#define EYES_OVERLAY_LAYER		42
#define WING_LAYER				41
#define WING_UNDERLIMBS_LAYER	40
#define MUTANTRACE_LAYER		39
#define TAIL_UNDERLIMBS_LAYER	38	//Tail split-rendering.
#define LIMBS_LAYER				37
#define INTORGAN_LAYER			36
#define MARKINGS_LAYER			35
#define UNDERWEAR_LAYER			34
#define MUTATIONS_LAYER			33
#define H_DAMAGE_LAYER			32
#define UNIFORM_LAYER			31
#define ID_LAYER				30
#define HANDS_LAYER				29	//Exists to overlay hands over jumpsuits
#define SHOES_LAYER				28
#define GLOVES_LAYER			27
#define EARS_LAYER				26
#define SUIT_LAYER				25
#define BELT_LAYER				24	//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		23
#define BACK_LAYER				22
#define HEAD_ACCESSORY_LAYER	21
#define FHAIR_LAYER				20
#define GLASSES_LAYER			19
#define HAIR_LAYER				18	//TODO: make part of head layer?
#define HEAD_ACC_OVER_LAYER		17	//Select-layer rendering.
#define FHAIR_OVER_LAYER		16	//Select-layer rendering.
#define GLASSES_OVER_LAYER		15	//Select-layer rendering.
#define TAIL_LAYER				14	//bs12 specific. this hack is probably gonna come back to haunt me
#define FACEMASK_LAYER			13
#define OVER_MASK_LAYER			12	//Select-layer rendering.
#define HEAD_LAYER				11
#define COLLAR_LAYER			10
#define HANDCUFF_LAYER			9
#define LEGCUFF_LAYER			8
#define L_HAND_LAYER			7
#define R_HAND_LAYER			6
#define TARGETED_LAYER			5	//BS12: Layer for the target overlay from weapon targeting system
#define HALO_LAYER				4	//blood cult ascended halo, because there's currently no better solution for adding/removing
#define FIRE_LAYER				3	//If you're on fire
#define MISC_LAYER				2
#define FROZEN_LAYER			1
#define TOTAL_LAYERS			42

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

/*
	Used for wire name appearances. Replaces the color name on the left with the one on the right.
	The color on the left is the one used as the actual color of the wire, but it doesn't look good when written.
	So, we need to replace the name to something that looks better.
*/
#define LIST_COLOR_RENAME 				\
	list(								\
		"rebeccapurple" = "dark purple",\
		"darkslategrey" = "dark grey",	\
		"darkolivegreen"= "dark green",	\
		"darkslateblue" = "dark blue",	\
		"darkkhaki" 	= "khaki",		\
		"darkseagreen" 	= "light green",\
		"midnightblue" 	= "blue",		\
		"lightgrey" 	= "light grey",	\
		"darkgrey" 		= "dark grey",	\
		"steelblue" 	= "blue",		\
		"goldenrod"	 	= "gold"		\
	)

/// Pure Black and white colorblindness. Every species except Vulpkanins and Tajarans will have this.
#define GREYSCALE_COLOR_REPLACE		\
	list(							\
		"red"		= "grey",		\
		"blue"		= "grey",		\
		"green"		= "grey",		\
		"orange"	= "light grey",	\
		"brown"		= "grey",		\
		"gold"		= "light grey",	\
		"cyan"		= "silver",		\
		"magenta"	= "grey",		\
		"purple"	= "grey",		\
		"pink"		= "light grey"	\
	)

/// Red colorblindness. Vulpkanins/Wolpins have this.
#define PROTANOPIA_COLOR_REPLACE		\
	list(								\
		"red"		= "darkolivegreen",	\
		"green"		= "darkslategrey",	\
		"orange"	= "goldenrod",		\
		"gold"		= "goldenrod", 		\
		"brown"		= "darkolivegreen",	\
		"cyan"		= "steelblue",		\
		"magenta"	= "blue",			\
		"purple"	= "darkslategrey",	\
		"pink"		= "beige"			\
	)

/// Yellow-Blue colorblindness. Tajarans/Farwas have this.
#define TRITANOPIA_COLOR_REPLACE		\
	list(								\
		"red"		= "rebeccapurple",	\
		"blue"		= "darkslateblue",	\
		"green"		= "darkolivegreen",	\
		"orange"	= "darkkhaki",		\
		"gold"		= "darkkhaki",		\
		"brown"		= "rebeccapurple",	\
		"cyan"		= "darkseagreen",	\
		"magenta"	= "darkslateblue",	\
		"purple"	= "darkslateblue",	\
		"pink"		= "lightgrey"		\
	)

//Gun trigger guards
#define TRIGGER_GUARD_ALLOW_ALL -1
#define TRIGGER_GUARD_NONE 0
#define TRIGGER_GUARD_NORMAL 1

// Macro to get the current elapsed round time, rather than total world runtime
#define ROUND_TIME (SSticker.time_game_started ? (world.time - SSticker.time_game_started) : 0)

// Macro that returns true if it's too early in a round to freely ghost out
#define TOO_EARLY_TO_GHOST (ROUND_TIME < GLOB.configuration.general.cryo_penalty_period MINUTES)

// Used by radios to indicate that they have sent a message via something other than subspace
#define RADIO_CONNECTION_FAIL 0
#define RADIO_CONNECTION_NON_SUBSPACE 1

// Bluespace shelter deploy checks
#define SHELTER_DEPLOY_ALLOWED "allowed"
#define SHELTER_DEPLOY_BAD_TURFS "bad turfs"
#define SHELTER_DEPLOY_BAD_AREA "bad area"
#define SHELTER_DEPLOY_ANCHORED_OBJECTS "anchored objects"

// transit_tube stuff
#define TRANSIT_TUBE_OPENING 0
#define TRANSIT_TUBE_OPEN 1
#define TRANSIT_TUBE_CLOSING 2
#define TRANSIT_TUBE_CLOSED 3

// Maximum donation level
#define DONATOR_LEVEL_MAX 4

// The cooldown on OOC messages such as OOC, LOOC, praying and adminhelps
#define OOC_COOLDOWN 5

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
#define BLOOD_LOSS_IN_SPREAD		20
#define BLOOD_AMOUNT_PER_DECAL		20

//Blood smears
#define BLOOD_SPLATTER_ALPHA_SLIME 150

//Bloody shoe blood states
#define BLOOD_STATE_HUMAN			"blood"
#define BLOOD_STATE_XENO			"xeno"
#define BLOOD_STATE_NOT_BLOODY		"no blood whatsoever"
#define BLOOD_BASE_ALPHA			"blood_alpha"

//for obj explosion block calculation
#define EXPLOSION_BLOCK_PROC -1

// Defines for investigate to prevent typos and for styling
#define INVESTIGATE_RENAME "renames"

#define INVESTIGATE_BOMB "bombs"

// The SQL version required by this version of the code
#define SQL_VERSION 49

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
/// Past this much time the patient is unrecoverable (in deciseconds).
#define DEFIB_TIME_LIMIT (300 SECONDS)
/// Brain damage starts setting in on the patient after some time left rotting.
#define DEFIB_TIME_LOSS (60 SECONDS)

//different types of atom colorations
#define ADMIN_COLOUR_PRIORITY 		1 //only used by rare effects like greentext coloring mobs and when admins varedit color
#define TEMPORARY_COLOUR_PRIORITY 	2 //e.g. purple effect of the revenant on a mob, black effect when mob electrocuted
#define WASHABLE_COLOUR_PRIORITY 	3 //color splashed onto an atom (e.g. paint on turf)
#define FIXED_COLOUR_PRIORITY 		4 //color inherent to the atom (e.g. blob color)
#define COLOUR_PRIORITY_AMOUNT 4 //how many priority levels there are.

//Ruin Generation

#define SPACERUIN_MAP_EDGE_PAD 15
#define PLACEMENT_TRIES 100 //How many times we try to fit the ruin somewhere until giving up (really should just swap to some packing algo)

#define PLACE_DEFAULT "random"
#define PLACE_SAME_Z "same"
#define PLACE_SPACE_RUIN "space"
#define PLACE_LAVA_RUIN "lavaland"

//Cleaning tool strength
// 1 is also a valid cleaning strength but completely unused so left undefined
#define CLEAN_WEAK 			2
#define CLEAN_MEDIUM		3 // Acceptable tools
#define CLEAN_STRONG		4 // Industrial strength
#define CLEAN_IMPRESSIVE	5 // Cleaning strong enough your granny would be proud
#define CLEAN_GOD			6 // Cleans things spotless down to the atomic structure

//Ghost orbit types:
#define GHOST_ORBIT_CIRCLE		"circle"
#define GHOST_ORBIT_TRIANGLE	"triangle"
#define GHOST_ORBIT_HEXAGON		"hexagon"
#define GHOST_ORBIT_SQUARE		"square"
#define GHOST_ORBIT_PENTAGON	"pentagon"

//Explosive wall groups
#define EXPLOSIVE_WALL_GROUP_SYNDICATE_BASE "syndicate_base"

/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}
#define MAPTEXT_CENTER(text) {"<span class='maptext' style='text-align: center'>[##text]</span>"}

//Fullscreen overlay resolution in tiles.
#define FULLSCREEN_OVERLAY_RESOLUTION_X 15
#define FULLSCREEN_OVERLAY_RESOLUTION_Y 15

//suit sensors: sensor_mode defines
#define SENSOR_OFF 0
#define SENSOR_LIVING 1
#define SENSOR_VITALS 2
#define SENSOR_COORDS 3

// Dice rigged options.
#define DICE_NOT_RIGGED 1
#define DICE_BASICALLY_RIGGED 2
#define DICE_TOTALLY_RIGGED 3

// Water temperature
#define COLD_WATER_TEMPERATURE 283.15 // 10 degrees celsius

// Parallax
#define PARALLAX_DELAY_DEFAULT	world.tick_lag
#define PARALLAX_DELAY_MED		1
#define PARALLAX_DELAY_LOW		2
#define PARALLAX_LOOP_TIME		25

// Engine types
#define ENGTYPE_SING 		"Singularity"
#define ENGTYPE_SM		"Supermatter"
#define ENGTYPE_TESLA		"Tesla"

#define SUMMON_GUNS "guns"
#define SUMMON_MAGIC "magic"

// Medical stuff
#define SYMPTOM_ACTIVATION_PROB 3

// Atmos stuff that fucking terrifies me
#define LINDA_SPAWN_HEAT 1
#define LINDA_SPAWN_20C 2
#define LINDA_SPAWN_TOXINS 4
#define LINDA_SPAWN_OXYGEN 8
#define LINDA_SPAWN_CO2 16
#define LINDA_SPAWN_NITROGEN 32
#define LINDA_SPAWN_N2O 64
#define LINDA_SPAWN_AGENT_B 128
#define LINDA_SPAWN_AIR 256
#define LINDA_SPAWN_COLD 512

// Throwing these defines here for the TM to minimise conflicts
#define MAPROTATION_MODE_NORMAL_VOTE "Vote"
#define MAPROTATION_MODE_NO_DUPLICATES "Nodupes"
#define MAPROTATION_MODE_FULL_RANDOM "Random"


/// Send to the primary Discord webhook
#define DISCORD_WEBHOOK_PRIMARY "PRIMARY"

/// Send to the admin Discord webhook
#define DISCORD_WEBHOOK_ADMIN "ADMIN"

/// Send to the mentor Discord webhook
#define DISCORD_WEBHOOK_MENTOR "MENTOR"

// Hallucination severities
#define HALLUCINATE_MINOR 1
#define HALLUCINATE_MODERATE 2
#define HALLUCINATE_MAJOR 3

// Runechat symbol types
#define RUNECHAT_SYMBOL_EMOTE 1

/// Waits at a line of code until X is true
#define UNTIL(X) while(!(X)) sleep(world.tick_lag)

/proc/client_from_var(I)
	if(ismob(I))
		var/mob/A = I
		return A.client
	if(isclient(I))
		return I
	if(istype(I, /datum/mind))
		var/datum/mind/B = I
		return B.current.client

#define SERVER_MESSAGES_REDIS_CHANNEL "byond.servermessages"

/// Projectile reflectability defines
#define REFLECTABILITY_NEVER 0
#define REFLECTABILITY_PHYSICAL 1
#define REFLECTABILITY_ENERGY 2

// This isnt in client_defines due to scoping issues
#define DEFAULT_CLIENT_VIEWSIZE "19x15"

// Deadchat control defines

/// Will execute a single command after the cooldown based on player votes.
#define DEADCHAT_DEMOCRACY_MODE (1<<0)
/// Allows each player to do a single command every cooldown.
#define DEADCHAT_ANARCHY_MODE (1<<1)
/// Mutes the democracy mode messages send to orbiters at the end of each cycle. Useful for when the cooldown is so low it'd get spammy.
#define MUTE_DEADCHAT_DEMOCRACY_MESSAGES (1<<2)
