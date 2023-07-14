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

//Security

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
