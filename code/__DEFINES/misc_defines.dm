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
#define INFECTION_LEVEL_FOUR	1500

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

/// Emoji icon set
#define EMOJI_SET 'icons/ui_icons/emoji.dmi'

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
#define AI_SHUTTLE_HACK		4 //Malfunctioning AI hijacking shuttle

//singularity defines
#define STAGE_ONE 1
#define STAGE_TWO 3
#define STAGE_THREE 5
#define STAGE_FOUR 7
#define STAGE_FIVE 9
#define STAGE_SIX 11 //From supermatter shard

#define STAGE_TWO_THRESHOLD 200
#define STAGE_THREE_THRESHOLD 500
#define STAGE_FOUR_THRESHOLD 1000
#define STAGE_FIVE_THRESHOLD 2000
#define STAGE_SIX_THRESHOLD 3000

/// A define for the center of the coordinate map of big machinery
#define MACH_CENTER 2

#define in_range(source, user)		(get_dist(source, user) <= 1)

#define RANGE_TURFS(RADIUS, CENTER) \
	RECT_TURFS(RADIUS, RADIUS, CENTER)

#define RECT_TURFS(H_RADIUS, V_RADIUS, CENTER) \
	block( \
	max(CENTER.x - (H_RADIUS), 1),          max(CENTER.y - (V_RADIUS), 1),          CENTER.z, \
	min(CENTER.x + (H_RADIUS), world.maxx), min(CENTER.y + (V_RADIUS), world.maxy), CENTER.z \
	)

/// Returns the turfs on the edge of a square with CENTER in the middle and with the given RADIUS. If used near the edge of the map, will still work fine.
// order of the additions: top edge + bottom edge + left edge + right edge
#define RANGE_EDGE_TURFS(RADIUS, CENTER)\
	(CENTER.y + RADIUS < world.maxy ? 	block(max(CENTER.x - RADIUS, 1), 			min(CENTER.y + RADIUS, world.maxy), 	CENTER.z, min(CENTER.x + RADIUS, world.maxx), 	min(CENTER.y + RADIUS, world.maxy), CENTER.z) : list()) +\
	(CENTER.y - RADIUS > 1 ? 			block(max(CENTER.x - RADIUS, 1), 			max(CENTER.y - RADIUS, 1), 				CENTER.z, min(CENTER.x + RADIUS, world.maxx), 	max(CENTER.y - RADIUS, 1), 			CENTER.z) : list()) +\
	(CENTER.x - RADIUS > 1 ? 			block(max(CENTER.x - RADIUS, 1), 			min(CENTER.y + RADIUS - 1, world.maxy), CENTER.z, max(CENTER.x - RADIUS, 1), 			max(CENTER.y - RADIUS + 1, 1), 		CENTER.z) : list()) +\
	(CENTER.x + RADIUS < world.maxx ? 	block(min(CENTER.x + RADIUS, world.maxx), 	min(CENTER.y + RADIUS - 1, world.maxy), CENTER.z, min(CENTER.x + RADIUS, world.maxx), 	max(CENTER.y - RADIUS + 1, 1), 		CENTER.z) : list())

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

/// Grabs the area of a supplied object. Passing an area in to this will result in an error
#define get_area(T) ((get_step(T, 0)?.loc))

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
#define METAL_FOAM_ALUMINUM 	1
#define METAL_FOAM_IRON 		2

// Defines for foam

/// The chemicals in the foam (if any) will never react.
#define FOAM_REACT_NEVER			(1<<0)
/// Chemicals in the foam will only react when the foam dissipates.
#define FOAM_REACT_ON_DISSIPATE		(1<<1)
/// Chemicals in the foam will react while the foam is still processing.
#define FOAM_REACT_DURING_SPREAD	(1<<2)
/// Chemicals in the foam will react when the foam first reaches a tile.
#define FOAM_REACT_BEFORE_SPREAD	(1<<3)

//Human Overlays Indexes/////////
#define EYES_OVERLAY_LAYER		51
#define MISC_LAYER				50 // Handles eye_shine() -> cybernetic eyes, specific eye traits.
#define WING_LAYER				49
#define WING_UNDERLIMBS_LAYER	48
#define MUTANTRACE_LAYER		47
#define TAIL_UNDERLIMBS_LAYER	46	//Tail split-rendering.
#define LIMBS_LAYER				45
#define MARKINGS_LAYER			44
#define INTORGAN_LAYER			43
#define UNDERWEAR_LAYER			42
#define MUTATIONS_LAYER			41
#define H_DAMAGE_LAYER			40
#define UNIFORM_LAYER			39
#define ID_LAYER				38
#define HANDS_LAYER				37	//Exists to overlay hands over jumpsuits
#define SHOES_LAYER				36
#define L_FOOT_BLOOD_LAYER		35	// Blood overlay separation Left-Foot
#define R_FOOT_BLOOD_LAYER		34	// Blood overlay separation Right-Foot
#define HAND_INTORGAN_LAYER		33
#define GLOVES_LAYER			32
#define L_HAND_BLOOD_LAYER		31	// Blood overlay separation Left-Hand
#define R_HAND_BLOOD_LAYER		30	// Blood overlay separation Right-Hand
#define LEFT_EAR_LAYER			29
#define RIGHT_EAR_LAYER			28
#define BELT_LAYER				27	//Possible make this an overlay of something required to wear a belt?
#define SPECIAL_NECK_LAYER		26
#define SUIT_LAYER				25
#define SPECIAL_BELT_LAYER		24
#define NECK_LAYER				23
#define SUIT_STORE_LAYER		22
#define BACK_LAYER				21
#define HEAD_ACCESSORY_LAYER	20
#define FHAIR_LAYER				19
#define GLASSES_LAYER			18
#define HAIR_LAYER				17	//TODO: make part of head layer?
#define HEAD_ACC_OVER_LAYER		16	//Select-layer rendering.
#define FHAIR_OVER_LAYER		15	//Select-layer rendering.
#define GLASSES_OVER_LAYER		14	//Select-layer rendering.
#define TAIL_LAYER				13	//bs12 specific. this hack is probably gonna come back to haunt me
#define FACEMASK_LAYER			12
#define OVER_MASK_LAYER			11	//Select-layer rendering.
#define HEAD_LAYER				10
#define COLLAR_LAYER			9
#define HANDCUFF_LAYER			8
#define LEGCUFF_LAYER			7
#define L_HAND_LAYER			6
#define R_HAND_LAYER			5
#define TARGETED_LAYER			4	//BS12: Layer for the target overlay from weapon targeting system
#define HALO_LAYER				3	//blood cult ascended halo, because there's currently no better solution for adding/removing
#define FIRE_LAYER				2	//If you're on fire
#define FROZEN_LAYER			1
#define TOTAL_LAYERS			51

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
#define REGION_MISC			9

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

#define MATRIX_STANDARD list(1.0,0.0,0.0,\
							0.0,1.0,0.0,\
							0.0,0.0,1.0)

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

// These comments mirror the below define in the order of operations to help you understand what it is doing
		// Check if datum I is a mob
		// If I is a mob, return the client of mob I
		// Else, check to see if I is a client
			// If I is a client, return I
			// Else, check to see if I is a mind
				// If I is a mind, try and return the mind's current mob's client

/// Return a Client
#define CLIENT_FROM_VAR(I) (ismob(I)			\
		? I:client								\
		: istype(I, /client)					\
				? I								\
				: istype(I, /datum/mind			\
						? I:current?:client		\
						: null))

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
#define INVESTIGATE_ATMOS "atmos"
#define INVESTIGATE_BOMB "bombs"
#define INVESTIGATE_CARGO "cargo"
#define INVESTIGATE_GRAVITY "gravity"
#define INVESTIGATE_HOTMIC "hotmic"
#define INVESTIGATE_RADIATION "radiation"
#define INVESTIGATE_RENAME "renames"
#define INVESTIGATE_SINGULO "singulo"
#define INVESTIGATE_SUPERMATTER "supermatter"
#define INVESTIGATE_WIRES "wires"
#define INVESTIGATE_DEATHS "deaths"

// The SQL version required by this version of the code
#define SQL_VERSION 70

// Vending machine stuff
#define CAT_NORMAL (1<<0)
#define CAT_HIDDEN (1<<1)
#define CAT_COIN   (1<<2)

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

// Defib stats
/// Past this much time the patient is unrecoverable (in deciseconds).
#define BASE_DEFIB_TIME_LIMIT (300 SECONDS)
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
#define MAPTEXT_SMALL(text) {"<span style='font-family: \"Small Fonts\"; font-size: 12pt; line-height: 0.75; -dm-text-outline: 1px black'>[##text]</span>"}

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
/// About 0.05 Seconds of delay
#define PARALLAX_DELAY_DEFAULT	world.tick_lag
#define PARALLAX_DELAY_MED		0.1 SECONDS
#define PARALLAX_DELAY_LOW		0.2 SECONDS
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
#define LINDA_SPAWN_HEAT 		(1<<0)
#define LINDA_SPAWN_20C 		(1<<1)
#define LINDA_SPAWN_TOXINS 		(1<<2)
#define LINDA_SPAWN_OXYGEN 		(1<<3)
#define LINDA_SPAWN_CO2 		(1<<4)
#define LINDA_SPAWN_NITROGEN 	(1<<5)
#define LINDA_SPAWN_N2O 		(1<<6)
#define LINDA_SPAWN_AGENT_B 	(1<<7)
#define LINDA_SPAWN_AIR 		(1<<8)
#define LINDA_SPAWN_COLD 		(1<<9)

#define MAPROTATION_MODE_NORMAL_VOTE "Vote"
#define MAPROTATION_MODE_NO_DUPLICATES "Nodupes"
#define MAPROTATION_MODE_FULL_RANDOM "Random"
#define MAPROTATION_MODE_HYBRID_FPTP_NO_DUPLICATES "FPTP"

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
#define RUNECHAT_SYMBOL_LOOC 2
#define RUNECHAT_SYMBOL_DEAD 3

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

///Sleep check QDEL. Like sleep check death, but checks deleting. Good for non mobs.
#define SLEEP_CHECK_QDEL(X) sleep(X); if(QDELETED(src)) return;
// Request console message priority defines

#define RQ_NONEW_MESSAGES 0 	// RQ_NONEWMESSAGES = no new message
#define RQ_LOWPRIORITY 1		// RQ_LOWPRIORITY = low priority
#define RQ_NORMALPRIORITY 2		// RQ_NORMALPRIORITY = normal priority
#define RQ_HIGHPRIORITY 3		// RQ_HIGHPRIORITY = high priority

/**
 * Reading books can help with brain damage!
 * These are seperate times so that a user gains more benefits by reading more books,
 * but also cant infinitely switch between 1000 books.
 */
/// The amount of time needed to pass to let a single book be read again for brain benefits
#define BRAIN_DAMAGE_BOOK_TIME 45 SECONDS
/// The amount of time a mob needs to wait between any book reading
#define BRAIN_DAMAGE_MOB_TIME 10 SECONDS

/// Takes a datum as input, returns its ref string, or a cached version of it
/// This allows us to cache \ref creation, which ensures it'll only ever happen once per datum, saving string tree time
/// It is slightly less optimal then a []'d datum, but the cost is massively outweighed by the potential savings
/// It will only work for datums mind, for datum reasons
/// : because of the embedded typecheck
#define text_ref(datum) (isdatum(datum) ? (datum:cached_ref ||= "\ref[datum]") : ("\ref[datum]"))

#define ROUND_END_NUCLEAR 1
#define ROUND_END_CREW_TRANSFER 2
#define ROUND_END_FORCED 3

// These used to be integer values but they were never used numerically or even
// stored in SSblackbox using their numeric values, and constantly converting
// them to the actual terror name was redundant and annoying
#define TS_INFESTATION_GREEN_SPIDER		"Green Terrors"
#define TS_INFESTATION_PRINCE_SPIDER	"Prince Terror"
#define TS_INFESTATION_WHITE_SPIDER		"White Terrors"
#define TS_INFESTATION_PRINCESS_SPIDER	"Princess Terrors"
#define TS_INFESTATION_QUEEN_SPIDER		"Queen Terrors"

#define BIOHAZARD_BLOB	"Blob"
#define BIOHAZARD_XENO	"Xenomorphs"
#define INCURSION_DEMONS "Demon Incursion"

#define MAX_ALLOWED_TELEPORTS_PER_PROCESS 20

#define CONSTRUCTION_PATH_FORWARDS -1
#define CONSTRUCTION_PATH_BACKWARDS 1
#define CONSTRUCTION_TOOL_BEHAVIOURS list(TOOL_CROWBAR, TOOL_SCREWDRIVER, TOOL_WELDER, TOOL_WRENCH)

#define WEATHER_STARTUP_STAGE 1
#define WEATHER_MAIN_STAGE 2
#define WEATHER_WIND_DOWN_STAGE 3
#define WEATHER_END_STAGE 4

/**
 * I dont recommend touching these map generator defines unless you know what you're doing with maze generators.
 */
#define LOG_MAZE_PROGRESS(proc2run, opname) \
do { \
	var/timer = start_watch(); \
	proc2run ;\
	log_debug("\[MAZE] Operation '[opname]' on maze at [x],[y],[z] took [stop_watch(timer)]s"); \
} while(FALSE)

//clusterCheckFlags defines
//All based on clusterMin and clusterMax as guides

//Individual defines
#define MAP_GENERATOR_CLUSTER_CHECK_NONE				0  //No checks are done, cluster as much as possible
#define MAP_GENERATOR_CLUSTER_CHECK_DIFFERENT_TURFS	(1<<1)  //Don't let turfs of DIFFERENT types cluster
#define MAP_GENERATOR_CLUSTER_CHECK_DIFFERENT_ATOMS	(1<<2)  //Don't let atoms of DIFFERENT types cluster
#define MAP_GENERATOR_CLUSTER_CHECK_SAME_TURFS		(1<<3)  //Don't let turfs of the SAME type cluster
#define MAP_GENERATOR_CLUSTER_CHECK_SAME_ATOMS		(1<<4) //Don't let atoms of the SAME type cluster

//Combined defines
#define MAP_GENERATOR_CLUSTER_CHECK_SAMES				(MAP_GENERATOR_CLUSTER_CHECK_SAME_TURFS | MAP_GENERATOR_CLUSTER_CHECK_SAME_ATOMS) //Don't let any of the same type cluster
#define MAP_GENERATOR_CLUSTER_CHECK_DIFFERENTS		(MAP_GENERATOR_CLUSTER_CHECK_DIFFERENT_TURFS | MAP_GENERATOR_CLUSTER_CHECK_DIFFERENT_ATOMS) //Don't let any of different types cluster
#define MAP_GENERATOR_CLUSTER_CHECK_ALL_TURFS			(MAP_GENERATOR_CLUSTER_CHECK_DIFFERENT_TURFS | MAP_GENERATOR_CLUSTER_CHECK_SAME_TURFS) //Don't let ANY turfs cluster same and different types
#define MAP_GENERATOR_CLUSTER_CHECK_ALL_ATOMS			(MAP_GENERATOR_CLUSTER_CHECK_DIFFERENT_ATOMS | MAP_GENERATOR_CLUSTER_CHECK_SAME_ATOMS) //Don't let ANY atoms cluster same and different types

//All
#define MAP_GENERATOR_CLUSTER_CHECK_ALL				((1<<4) - 2) //Don't let anything cluster, like, at all.  -2 because we skipped <<1 for some odd reason.

// Buffer datatype flags.
#define DNA2_BUF_UI (1<<0)
#define DNA2_BUF_UE (1<<1)
#define DNA2_BUF_SE (1<<2)

#define CLONER_BIOMASS_REQUIRED 150

#define SOLAR_MACHINERY_MAX_DIST 40

#define AMMO_BOX_MULTI_SPRITE_STEP_NONE null
#define AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF -1

/// Detective's mode on pinpointers
#define PINPOINTER_MODE_DET 7

/// How frequently disposals can make sounds, to prevent huge sound stacking
#define DISPOSAL_SOUND_COOLDOWN (0.1 SECONDS)

/// The different kinds of voting
#define VOTE_RESULT_TYPE_MAJORITY "Majority"

#define HOLOPAD_MAX_DIAL_TIME 200

#define PROJECTILE_IMPACT_WALL_DENT_HIT 1
#define PROJECTILE_IMPACT_WALL_DENT_SHOT 2

#define ASSEMBLY_WIRE_RECEIVE		(1<<0)	//Allows pulse(0) to call Activate()
#define ASSEMBLY_WIRE_PULSE			(1<<1)	//Allows pulse(0) to act on the holder
#define ASSEMBLY_WIRE_PULSE_SPECIAL	(1<<2)	//Allows pulse(0) to act on the holders special assembly
#define ASSEMBLY_WIRE_RADIO_RECEIVE	(1<<3)	//Allows pulse(1) to call Activate()
#define ASSEMBLY_WIRE_RADIO_PULSE	(1<<4)	//Allows pulse(1) to send a radio message


//Types of usual spacevine mutations mutations
#define	SPACEVINE_MUTATION_POSITIVE 			1
#define	SPACEVINE_MUTATION_NEGATIVE			2
#define	SPACEVINE_MUTATION_MINOR_NEGATIVE		3

#define RETURN_PRECISE_POSITION(A) new /datum/position(A)
#define RETURN_PRECISE_POINT(A) new /datum/point_precise(A)

#define RETURN_POINT_VECTOR(ATOM, ANGLE, SPEED) (new /datum/point_precise/vector(ATOM, null, null, null, null, ANGLE, SPEED))
#define RETURN_POINT_VECTOR_INCREMENT(ATOM, ANGLE, SPEED, AMT) (new /datum/point_precise/vector(ATOM, null, null, null, null, ANGLE, SPEED, AMT))

#define TEAM_ADMIN_ADD_OBJ_SUCCESS				(1<<0)
#define TEAM_ADMIN_ADD_OBJ_CANCEL_LOG 			(1<<1)
#define TEAM_ADMIN_ADD_OBJ_PURPOSEFUL_CANCEL 	(1<<2)

/// A helper used by `restrict_file_types.py` to identify types to restrict in a file. Not used by byond at all.
#define RESTRICT_TYPE(type) // do nothing

#define INGREDIENT_CHECK_EXACT 1
#define INGREDIENT_CHECK_FAILURE 0
#define INGREDIENT_CHECK_SURPLUS -1

#define LAVALAND_TENDRIL_COLLAPSE_RANGE 2 //! The radius of the chasm created by killed tendrils.

#define ALPHA_VISIBLE 255 // the max alpha

///  Economy account defines
#define BANK_PIN_MIN 10000
#define BANK_PIN_MAX 99999

/// Defines for hidden organ techs
#define TECH_MATERIAL "materials"
#define TECH_ENGINEERING "engineering"
#define TECH_PLASMA "plasmatech"
#define TECH_POWER "powerstorage"
#define TECH_BLUESPACE "bluespace"
#define TECH_BIO "biotech"
#define TECH_COMBAT "combat"
#define TECH_MAGNETS "magnets"
#define TECH_PROGRAM "programming"
#define TECH_TOXINS "toxins"
#define TECH_SYNDICATE "syndicate"
#define TECH_ABDUCTOR "abductor"

//! The number of seconds between the start of the UNIX and BYOND epochs.
#define BYOND_EPOCH_UNIX 946702800

// Use this define to register something as a purchasable!
// * n — The proper name of the purchasable
// * o — The object type path of the purchasable to spawn
// * p — The price of the purchasable in mining points
#define EQUIPMENT(n, o, p) n = new /datum/data/mining_equipment(n, o, p)

#define BRIDGE_SPAWN_SUCCESS 0
#define BRIDGE_SPAWN_TOO_WIDE 1
#define BRIDGE_SPAWN_TOO_NARROW 2
#define BRIDGE_SPAWN_BAD_TERRAIN 3

#define DIRECT_EXPLOSIVE_TRAP_DEFUSE 1
#define DIRECT_EXPLOSIVE_TRAP_IGNORE 2

#define NODROP_TOGGLE "toggle"

#define DECAL_PAINTER_CATEGORY_STANDARD "Standard"
#define DECAL_PAINTER_CATEGORY_THIN "Thin Lines"
#define DECAL_PAINTER_CATEGORY_THICK "Thick Lines"
#define DECAL_PAINTER_CATEGORY_SQUARE "Square Borders"
#define DECAL_PAINTER_CATEGORY_ALPHANUM "Alphanumeric"

#define ABSTRACT_TYPE_DESC "If you see this, something broke. Please contact a coder or write a bug report on the Github."

#define DECAL_PAINTER_CATEGORY_TILES "Tiles"
