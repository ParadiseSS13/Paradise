//#define TESTING
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/obj/effect/datacore/data_core = null
var/global/obj/effect/overlay/plmaster = null
var/global/obj/effect/overlay/slmaster = null


var/global/list/active_areas = list()
var/global/list/all_areas = list()
var/global/list/machines = list()
var/global/list/processing_objects = list()
var/global/list/active_diseases = list()
var/global/list/med_hud_users = list()
var/global/list/sec_hud_users = list()
		//items that ask to be called every cycle

var/global/defer_powernet_rebuild = 0		// true if net rebuild will be called manually after an event

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


	//////////////
var/list/paper_tag_whitelist = list("center","p","div","span","h1","h2","h3","h4","h5","h6","hr","pre",	\
	"big","small","font","i","u","b","s","sub","sup","tt","br","hr","ol","ul","li","caption","col",	\
	"table","td","th","tr")
var/list/paper_blacklist = list("java","onblur","onchange","onclick","ondblclick","onfocus","onkeydown",	\
	"onkeypress","onkeyup","onload","onmousedown","onmousemove","onmouseout","onmouseover",	\
	"onmouseup","onreset","onselect","onsubmit","onunload")

var/BLINDBLOCK = 0
var/DEAFBLOCK = 0
var/HULKBLOCK = 0
var/TELEBLOCK = 0
var/FIREBLOCK = 0
var/XRAYBLOCK = 0
var/CLUMSYBLOCK = 0
var/FAKEBLOCK = 0
var/COUGHBLOCK = 0
var/GLASSESBLOCK = 0
var/EPILEPSYBLOCK = 0
var/TWITCHBLOCK = 0
var/NERVOUSBLOCK = 0
var/MONKEYBLOCK = 50 // Monkey block will always be the DNA_SE_LENGTH

var/BLOCKADD = 0
var/DIFFMUT = 0

var/NOBREATHBLOCK = 0
var/REMOTEVIEWBLOCK = 0
var/REGENERATEBLOCK = 0
var/INCREASERUNBLOCK = 0
var/REMOTETALKBLOCK = 0
var/MORPHBLOCK = 0
var/COLDBLOCK = 0
var/HALLUCINATIONBLOCK = 0
var/NOPRINTSBLOCK = 0
var/SHOCKIMMUNITYBLOCK = 0
var/SMALLSIZEBLOCK = 0

///////////////////////////////
// Goon Stuff
///////////////////////////////
// Disabilities
var/LISPBLOCK = 0
var/MUTEBLOCK = 0
var/RADBLOCK = 0
var/FATBLOCK = 0
var/CHAVBLOCK = 0
var/SWEDEBLOCK = 0
var/SCRAMBLEBLOCK = 0
var/TOXICFARTBLOCK = 0
var/STRONGBLOCK = 0
var/HORNSBLOCK = 0
var/COMICBLOCK = 0

// Powers
var/SOBERBLOCK = 0
var/PSYRESISTBLOCK = 0
var/SHADOWBLOCK = 0
var/CHAMELEONBLOCK = 0
var/CRYOBLOCK = 0
var/EATBLOCK = 0
var/JUMPBLOCK = 0
//var/MELTBLOCK = 0
var/EMPATHBLOCK = 0
var/SUPERFARTBLOCK = 0
var/IMMOLATEBLOCK = 0
var/POLYMORPHBLOCK = 0

///////////////////////////////
// /vg/ Mutations
///////////////////////////////
var/LOUDBLOCK = 0
//var/WHISPERBLOCK = 0
var/DIZZYBLOCK = 0




var/skipupdate = 0
	///////////////
var/eventchance = 10 //% per 5 mins
var/event = 0
var/hadevent = 0
var/blobevent = 0
	///////////////
var/starticon = null
var/midicon = null
var/endicon = null
var/diary = null
var/diaryofmeanpeople = null
var/href_logfile = null
var/station_name = "NSS Cyberiad"
var/game_version = "Custom ParaCode"
var/changelog_hash = ""
var/game_year = (text2num(time2text(world.realtime, "YYYY")) + 544)

var/datum/air_tunnel/air_tunnel1/SS13_airtunnel = null
var/going = 1.0
var/master_mode = "extended"//"extended"
var/secret_force_mode = "secret" // if this is anything but "secret", the secret rotation will forceably choose this mode

var/datum/engine_eject/engine_eject_control = null
var/host = null
var/aliens_allowed = 1
var/ooc_allowed = 1
var/dsay_allowed = 1
var/dooc_allowed = 1
var/traitor_scaling = 1
//var/goonsay_allowed = 0
var/dna_ident = 1
var/abandon_allowed = 0
var/enter_allowed = 1
var/guests_allowed = 1
var/shuttle_frozen = 0
var/shuttle_left = 0
var/tinted_weldhelh = 1

var/list/jobMax = list()
var/list/bombers = list(  )
var/list/admin_log = list (  )
var/list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
var/list/lawchanges = list(  ) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
var/list/reg_dna = list(  )
//	list/traitobj = list(  )

var/mouse_respawn_time = 5 //Amount of time that must pass between a player dying as a mouse and repawning as a mouse. In minutes.

var/CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
var/CHARGELEVEL = 0.0005 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

var/shuttle_z = 2	//default
var/airtunnel_start = 68 // default
var/airtunnel_stop = 68 // default
var/airtunnel_bottom = 72 // default
var/list/monkeystart = list()
var/list/wizardstart = list()
var/list/newplayer_start = list()
var/list/latejoin = list()
var/list/latejoin_gateway = list()
var/list/latejoin_cryo = list()
var/list/latejoin_cyborg = list()
var/list/prisonwarp = list()	//prisoners go to these
var/list/holdingfacility = list()	//captured people go here
var/list/xeno_spawn = list()//Aliens spawn at these.
//	list/mazewarp = list()
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
var/list/carplist = list()
//	list/traitors = list()	//traitor list
var/list/cardinal = list( NORTH, SOUTH, EAST, WEST )
var/list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
// reverse_dir[dir] = reverse of dir
var/list/reverse_dir = list(2, 1, 3, 8, 10, 9, 11, 4, 6, 5, 7, 12, 14, 13, 15, 32, 34, 33, 35, 40, 42, 41, 43, 36, 38, 37, 39, 44, 46, 45, 47, 16, 18, 17, 19, 24, 26, 25, 27, 20, 22, 21, 23, 28, 30, 29, 31, 48, 50, 49, 51, 56, 58, 57, 59, 52, 54, 53, 55, 60, 62, 61, 63)

var/datum/station_state/start_state = null
var/datum/configuration/config = null

var/list/combatlog = list()
var/list/IClog = list()
var/list/OOClog = list()
var/list/adminlog = list()


var/list/powernets = list()

var/Debug = 0	// global debug switch
var/Debug2 = 1   // enables detailed job debug file in secrets

var/datum/debug/debugobj

var/datum/moduletypes/mods = new()

var/wavesecret = 0
var/gravity_is_on = 1

var/shuttlecoming = 0

var/join_motd = null
var/forceblob = 0

// nanomanager, the manager for Nano UIs
var/datum/nanomanager/nanomanager = new()

// event manager, the manager for events
var/datum/event_manager/event_manager = new()

#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16
#define FIRE_DAMAGE_MODIFIER 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER 4.050 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
#define INFINITY 1e31 //closer then enough

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 26

#define shuttle_time_in_station 1800 // 3 minutes in the station
#define shuttle_time_to_arrive 6000 // 10 minutes to arrive

#define EVENT_LEVEL_MUNDANE 1
#define EVENT_LEVEL_MODERATE 2
#define EVENT_LEVEL_MAJOR 3

	//away missions
var/list/awaydestinations = list()	//a list of landmarks that the warpgate can take you to

	// MySQL configuration

var/sqladdress = "localhost"
var/sqlport = "3306"
var/sqldb = "paradise"
var/sqllogin = "root"
var/sqlpass = "example"

	// Feedback gathering sql connection

var/sqlfdbkdb = "paradise"
var/sqlfdbklogin = "root"
var/sqlfdbkpass = "example"

var/sqllogging = 0 // Should we log deaths, population stats, etc?



	// Forum MySQL configuration (for use with forum account/key authentication)
	// These are all default values that will load should the forumdbconfig.txt
	// file fail to read for whatever reason.

var/forumsqladdress = "localhost"
var/forumsqlport = "3306"
var/forumsqldb = "tgstation"
var/forumsqllogin = "root"
var/forumsqlpass = "bleh"
var/forum_activated_group = "2"
var/forum_authenticated_group = "10"

	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0
var/custom_event_msg = null

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
var/DBConnection/dbcon = new()	//Feedback database (New database)
var/DBConnection/dbcon_old = new()	//Tgstation database (Old database) - See the files in the SQL folder for information what goes where.


//Goonstyle scoreboard
var/score_crewscore = 0 // this is the overall var/score for the whole round
var/score_stuffshipped = 0 // how many useful items have cargo shipped out?
var/score_stuffharvested = 0 // how many harvests have hydroponics done?
var/score_oremined = 0 // obvious
var/score_researchdone = 0
var/score_eventsendured = 0 // how many random events did the station survive?
var/score_powerloss = 0 // how many APCs have poor charge?
var/score_escapees = 0 // how many people got out alive?
var/score_deadcrew = 0 // dead bodies on the station, oh no
var/score_mess = 0 // how much poo, puke, gibs, etc went uncleaned
var/score_meals = 0
var/score_disease = 0 // how many rampant, uncured diseases are on board the station
var/score_deadcommand = 0 // used during rev, how many command staff perished
var/score_arrested = 0 // how many traitors/revs/whatever are alive in the brig
var/score_traitorswon = 0 // how many traitors were successful?
var/score_allarrested = 0 // did the crew catch all the enemies alive?
var/score_opkilled = 0 // used during nuke mode, how many operatives died?
var/score_disc = 0 // is the disc safe and secure?
var/score_nuked = 0 // was the station blown into little bits?

	// these ones are mainly for the stat panel
var/score_powerbonus = 0 // if all APCs on the station are running optimally, big bonus
var/score_messbonus = 0 // if there are no messes on the station anywhere, huge bonus
var/score_deadaipenalty = 0 // is the AI dead? if so, big penalty
var/score_foodeaten = 0 // nom nom nom
var/score_clownabuse = 0 // how many times a clown was punched, struck or otherwise maligned
var/score_richestname = null // this is all stuff to show who was the richest alive on the shuttle
var/score_richestjob = null  // kinda pointless if you dont have a money system i guess
var/score_richestcash = 0
var/score_richestkey = null
var/score_dmgestname = null // who had the most damage on the shuttle (but was still alive)
var/score_dmgestjob = null
var/score_dmgestdamage = 0
var/score_dmgestkey = null


// Recall time limit:  2 hours
var/recall_time_limit=72000

// Announcer intercom, because too much stuff creates an intercom for one message then hard del()s it.
var/global/obj/item/device/radio/intercom/global_announcer = new(null)
