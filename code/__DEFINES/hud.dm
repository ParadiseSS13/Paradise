
// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list
// note: if you add more HUDs, even for non-human atoms, make sure to use unique numbers for the defines!
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists
#define HEALTH_HUD		"1" // dead, alive, sick, health status
#define STATUS_HUD		"2" // a simple line rounding the mob's number health
#define ID_HUD			"3" // the job asigned to your ID
#define WANTED_HUD		"4" // wanted, released, parroled, security status
#define IMPMINDSHIELD_HUD	"5" // mindshield bio-chip
#define IMPCHEM_HUD		"6" // chemical bio-chip
#define IMPTRACK_HUD	"7" // tracking bio-chip
#define DIAG_STAT_HUD	"8" // Silicon/Mech Status
#define DIAG_HUD		"9" // Silicon health bar
#define DIAG_BATT_HUD	"10"// Borg/Mech power meter
#define DIAG_MECH_HUD	"11"// Mech health bar
#define SPECIALROLE_HUD "12" //for antag huds. these are used at the /mob level
#define DIAG_BOT_HUD	"13"// Bot HUDS
#define PLANT_NUTRIENT_HUD	"14"// Plant nutrient level
#define PLANT_WATER_HUD		"15"// Plant water level
#define PLANT_STATUS_HUD	"16"// Plant harvest/dead
#define PLANT_HEALTH_HUD	"17"// Plant health
#define PLANT_TOXIN_HUD		"18"// Toxin level
#define PLANT_PEST_HUD		"19"// Pest level
#define PLANT_WEED_HUD		"20"// Weed level
#define DIAG_TRACK_HUD		"21"// Mech tracking beacon
#define DIAG_AIRLOCK_HUD 	"22" // Airlock shock overlay
#define GLAND_HUD 			"23"//Gland indicators for abductors
#define JANI_HUD			"24" // Sign overlay over cleanable decals
#define PRESSURE_HUD		"25" // Pressure coloring for tiles
#define MALF_AI_HUD			"26" // Malf status blips for borgs
#define ANOMALOUS_HUD			"27" // Seeing anomalous particulate

//by default everything in the hud_list of an atom is an image
//a value in hud_list with one of these will change that behavior
#define HUD_LIST_LIST 1

//data HUD (medhud, sechud) defines
//Don't forget to update human/New() if you change these!
#define DATA_HUD_SECURITY_BASIC			1
#define DATA_HUD_SECURITY_ADVANCED		2
#define DATA_HUD_MEDICAL_BASIC			3
#define DATA_HUD_MEDICAL_ADVANCED		4
#define DATA_HUD_DIAGNOSTIC_BASIC		5
#define DATA_HUD_DIAGNOSTIC_ADVANCED	6
#define DATA_HUD_HYDROPONIC				7
#define DATA_HUD_JANITOR				8
#define DATA_HUD_PRESSURE				9
#define DATA_HUD_MALF_AI				10
#define DATA_HUD_ANOMALOUS				11
//antag HUD defines
#define ANTAG_HUD_CULT					12
#define ANTAG_HUD_REV					13
#define ANTAG_HUD_OPS					14
#define ANTAG_HUD_WIZ					15
#define ANTAG_HUD_SHADOW    			16
#define ANTAG_HUD_TRAITOR 				17
#define ANTAG_HUD_NINJA 				18
#define ANTAG_HUD_CHANGELING 			19
#define ANTAG_HUD_VAMPIRE 				20
#define ANTAG_HUD_ABDUCTOR 				21
#define DATA_HUD_ABDUCTOR				22
#define ANTAG_HUD_EVENTMISC 			23
#define ANTAG_HUD_BLOB 					24
#define ANTAG_HUD_ZOMBIE 				25
#define ANTAG_HUD_MIND_FLAYER 			26

// Notification action types
#define NOTIFY_JUMP "jump"
#define NOTIFY_ATTACK "attack"
#define NOTIFY_FOLLOW "orbit"


// The kind of things granted by HUD items in game, that do not manifest as
// on-screen icons, but rather go to examine text.
#define EXAMINE_HUD_SECURITY_READ "security_read"
#define EXAMINE_HUD_SECURITY_WRITE "security_write"
#define EXAMINE_HUD_MEDICAL_READ "medical_read"
#define EXAMINE_HUD_MEDICAL_WRITE "medical_write"
#define EXAMINE_HUD_SKILLS "skills"

// MALF Hud statuses
#define EXAMINE_HUD_MALF_WRITE "malf_write"
#define EXAMINE_HUD_MALF_READ "malf_read"
#define MALF_STATUS_NONE "NULL"
#define MALF_STATUS_GREEN "ASSIST"
#define MALF_STATUS_RED "ELIMINATE"
#define MALF_STATUS_AVOID "AVOID"

/proc/ui_hand_position(i)
	// values based on old hand ui positions (CENTER:-/+16,SOUTH:5)
	var/x_off = ISODD(i) ? 0 : -1
	var/y_off = round((i-1) / 2)
	return"CENTER+[x_off]:16,SOUTH+[y_off]:5"

/proc/ui_equip_position(mob/M)
	// values based on old equip ui position (CENTER: +/-16,SOUTH+1:5)
	var/y_off = round(1 / 2)
	return "CENTER:-16,SOUTH+[y_off+1]:5"

/proc/ui_swaphand_position(mob/M, which = 1)
	// values based on old swaphand ui positions (CENTER: +/-16,SOUTH+1:5)
	var/x_off = which == 1 ? -1 : 0
	var/y_off = round(1 / 2)
	return "CENTER+[x_off]:16,SOUTH+[y_off+1]:5"


/// Takes a string or num view, and converts it to pixel width/height in a list(pixel_width, pixel_height)
/proc/view_to_pixels(view)
	if(!view)
		return list(0, 0)
	var/list/view_info = getviewsize(view)
	view_info[1] *= world.icon_size
	view_info[2] *= world.icon_size
	return view_info
