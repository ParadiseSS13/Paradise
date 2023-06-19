/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = FALSE 			(defaults to TRUE)
	music = "music/music.ogg"		(defaults to "music/music.ogg")

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/

/*-----------------------------------------------------------------------------*/

/area/station/New(loc, ...)
	. = ..()
	if(!(type in GLOB.the_station_areas))
		GLOB.the_station_areas.Add(type)

//Security

// /area/station/command/customs
// 	name = "Customs"
// 	icon_state = "checkpoint1"

// /area/station/command/customs2
// 	name = "Customs"
// 	icon_state = "security"

// /area/station/engineering/solar/derelict_starboard
// 	name = "\improper Derelict Starboard Solar Array"
// 	icon_state = "GENsolar"

// /area/station/engineering/solar/derelict_aft
// 	name = "\improper Derelict Aft Solar Array"
// 	icon_state = "GENsolar"

// /area/derelict/singularity_engine
// 	name = "\improper Derelict Singularity Engine"
// 	icon_state = "engine"

// /area/derelict/gravity_generator
// 	name = "\improper Derelict Gravity Generator Room"
// 	icon_state = "red"

// /area/derelict/atmospherics
// 	name = "Derelict Atmospherics"
// 	icon_state = "red"

//Construction

/area/station/public/construction
	name = "\improper Construction Area"
	icon_state = "construction"
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

// /area/mining_construction
// 	name = "Auxillary Base Construction"
// 	icon_state = "yellow"

/area/station/public/construction/hallway
	name = "\improper Hallway"
	icon_state = "yellow"

//GAYBAR
/area/secret/gaybar
	name = "\improper Dance Bar"
	icon_state = "dancebar"


// //Traitor Station
// /area/traitor
// 	name = "\improper Syndicate Base"
// 	icon_state = "syndie_hall"
// 	report_alerts = FALSE

// /area/traitor/rnd
// 	name = "\improper Syndicate Research and Development"
// 	icon_state = "syndie_rnd"

// /area/traitor/chem
// 	name = "\improper Syndicate Chemistry"
// 	icon_state = "syndie_chem"

// /area/traitor/tox
// 	name = "\improper Syndicate Toxins"
// 	icon_state = "syndie_tox"

// /area/traitor/atmos
// 	name = "\improper Syndicate Atmos"
// 	icon_state = "syndie_atmo"

// /area/traitor/inter
// 	name = "\improper Syndicate Interrogation"
// 	icon_state = "syndie_inter"

// /area/traitor/radio
// 	name = "\improper Syndicate Eavesdropping Booth"
// 	icon_state = "syndie_radio"

// /area/traitor/surgery
// 	name = "\improper Syndicate Surgery Theatre"
// 	icon_state = "syndie_surgery"

// /area/traitor/hall
// 	name = "\improper Syndicate Station"
// 	icon_state = "syndie_hall"

// /area/traitor/kitchen
// 	name = "\improper Syndicate Kitchen"
// 	icon_state = "syndie_kitchen"

// /area/traitor/empty
// 	name = "\improper Syndicate Project Room"
// 	icon_state = "syndie_empty"



/////////////////////////////////////////////////////////////////////
/*
 Lists of areas to be used with is_type_in_list.
 Used in gamemodes code at the moment. --rastaf0
*/

// CENTCOM
GLOBAL_LIST_INIT(centcom_areas, list(
	/area/centcom,
	/area/shuttle/escape_pod1/centcom,
	/area/shuttle/escape_pod2/centcom,
	/area/shuttle/escape_pod3/centcom,
	/area/shuttle/escape_pod5/centcom,
	/area/shuttle/transport1,
	/area/shuttle/administration/centcom,
	/area/shuttle/specops/centcom,
))

//SPACE STATION 13
GLOBAL_LIST_INIT(the_station_areas, list(
	/area/shuttle/arrival,
	/area/shuttle/escape,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/shuttle/prison/station,
	/area/shuttle/administration/station,
	/area/shuttle/specops/station,
	typesof(/area/station) // TODO: wip
	// /area/station/maintenance,
	// /area/station/hallway,
	// /area/station/hallway/primary/fore,
	// /area/station/hallway/primary/starboard,
	// /area/station/hallway/primary/aft,
	// /area/station/hallway/primary/port,
	// /area/station/hallway/primary/central,
	// /area/station/bridge,
	// /area/station/public,
	// /area/civilian,
	// /area/holodeck,
	// /area/library,
	// /area/station/service/chapel,
	// /area/lawoffice,
	// /area/magistrateoffice,
	// /area/clownoffice,
	// /area/mimeoffice,
	// /area/engine,
	// /area/station/engineering/solar,
	// /area/stationassembly,
	// /area/teleporter,
	// /area/station/medical,
	// /area/station/security,
	// /area/station/supply,
	// /area/station/service/janitor,
	// /area/station/service/hydroponics,
	// /area/station/science,
	// /area/station/public/storage,
	// /area/station/public/construction,
	// /area/station/ai_monitored/storage/eva, //do not try to simplify to "/area/station/ai_monitored" --rastaf0
	// /area/station/ai_monitored/storage/secure,
	// /area/station/turret_protected/ai_upload, //do not try to simplify to "/area/turret_protected" --rastaf0
	// /area/station/turret_protected/ai_upload_foyer,
	// /area/station/turret_protected/ai,
))
