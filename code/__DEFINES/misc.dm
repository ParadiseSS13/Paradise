


//zlevel defines, can be overriden for different maps in the appropriate _maps file.
#define ZLEVEL_STATION  1
#define ZLEVEL_CENTCOMM 2
#define ZLEVEL_TELECOMMS 3
#define ZLEVEL_ENGI 4
#define ZLEVEL_ASTEROID 5
#define ZLEVEL_DERELICT 6
#define ZLEVEL_SYNDIE 7
#define ZLEVEL_EMPTY 8
#define MAX_Z	8 // Used in space.dm to defince which Z-levels cannot be exited via space.
#define TRANSITIONEDGE	7 //Distance from edge to move to another z-level

///
#define ENGINE_EJECT_Z	3

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

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL	50
#define MAX_STACK_AMOUNT_GLASS	50
#define MAX_STACK_AMOUNT_RODS	60

#define CC_PER_SHEET_METAL 3750
#define CC_PER_SHEET_GLASS 3750
#define CC_PER_SHEET_MISC 2000

//some colors
#define COLOR_RED 		"#FF0000"
#define COLOR_GREEN 	"#00FF00"
#define COLOR_BLUE 		"#0000FF"
#define COLOR_CYAN 		"#00FFFF"
#define COLOR_PINK 		"#FF00FF"
#define COLOR_YELLOW 	"#FFFF00"
#define COLOR_ORANGE 	"#FF9900"
#define COLOR_WHITE 	"#FFFFFF"

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

//singularity defines
#define STAGE_ONE 1
#define STAGE_TWO 3
#define STAGE_THREE 5
#define STAGE_FOUR 7
#define STAGE_FIVE 9
#define STAGE_SIX 11 //From supermatter shard