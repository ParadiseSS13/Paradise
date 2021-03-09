
// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list
// note: if you add more HUDs, even for non-human atoms, make sure to use unique numbers for the defines!
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists
#define HEALTH_HUD		"1" // dead, alive, sick, health status
#define STATUS_HUD		"2" // a simple line rounding the mob's number health
#define ID_HUD			"3" // the job asigned to your ID
#define WANTED_HUD		"4" // wanted, released, parroled, security status
#define IMPMINDSHIELD_HUD	"5" // mindshield implant
#define IMPCHEM_HUD		"6" // chemical implant
#define IMPTRACK_HUD	"7" // tracking implant
#define DIAG_STAT_HUD	"8" // Silicon/Mech Status
#define DIAG_HUD		"9" // Silicon health bar
#define DIAG_BATT_HUD	"10"// Borg/Mech power meter
#define DIAG_MECH_HUD	"11"// Mech health bar
#define STATUS_HUD_OOC	"12"// STATUS_HUD without virus db check for someone being ill.
#define SPECIALROLE_HUD "13" //for antag huds. these are used at the /mob level
#define DIAG_BOT_HUD	"14"// Bot HUDS
#define PLANT_NUTRIENT_HUD	"15"// Plant nutrient level
#define PLANT_WATER_HUD		"16"// Plant water level
#define PLANT_STATUS_HUD	"17"// Plant harvest/dead
#define PLANT_HEALTH_HUD	"18"// Plant health
#define PLANT_TOXIN_HUD		"19"// Toxin level
#define PLANT_PEST_HUD		"20"// Pest level
#define PLANT_WEED_HUD		"21"// Weed level
#define DIAG_TRACK_HUD		"22"// Mech tracking beacon
#define DIAG_PATH_HUD 		"23"//Bot path indicators
#define GLAND_HUD 			"24"//Gland indicators for abductors

//by default everything in the hud_list of an atom is an image
//a value in hud_list with one of these will change that behavior
#define HUD_LIST_LIST 1

//data HUD (medhud, sechud) defines
//Don't forget to update human/New() if you change these!
#define DATA_HUD_SECURITY_BASIC		1
#define DATA_HUD_SECURITY_ADVANCED	2
#define DATA_HUD_MEDICAL_BASIC		3
#define DATA_HUD_MEDICAL_ADVANCED	4
#define DATA_HUD_DIAGNOSTIC			5
#define DATA_HUD_DIAGNOSTIC_ADVANCED	6
#define DATA_HUD_HYDROPONIC			7
//antag HUD defines
#define ANTAG_HUD_CULT		8
#define ANTAG_HUD_REV		9
#define ANTAG_HUD_OPS		10
#define ANTAG_HUD_WIZ		11
#define ANTAG_HUD_SHADOW    12
#define ANTAG_HUD_TRAITOR 13
#define ANTAG_HUD_NINJA 14
#define ANTAG_HUD_CHANGELING 15
#define ANTAG_HUD_VAMPIRE 16
#define ANTAG_HUD_ABDUCTOR 17
#define DATA_HUD_ABDUCTOR	18
#define ANTAG_HUD_DEVIL 19
#define ANTAG_HUD_EVENTMISC 20
#define ANTAG_HUD_BLOB 21

// Notification action types
#define NOTIFY_JUMP "jump"
#define NOTIFY_ATTACK "attack"
#define NOTIFY_FOLLOW "orbit"


// The kind of things granted by HUD items in game, that do not manifest as
// on-screen icons, but rather go to examine text.
#define EXAMINE_HUD_SECURITY_READ "security_read"
#define EXAMINE_HUD_SECURITY_WRITE "security_write"
#define EXAMINE_HUD_MEDICAL "medical"
#define EXAMINE_HUD_SKILLS "skills"
