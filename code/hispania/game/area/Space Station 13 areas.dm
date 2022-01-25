/*
### Here you'll find the list of custom areas from hispania:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make has many divisions as you want)
	name = "NICE NAME" 				(name that appears on the GPS when you're there)
	icon = "ICON FILENAME" 			(here if you have a custom icon for the area, optional)
	icon_state = "NAME OF ICON" 	(name of the icon)
	requires_power = FALSE 			(TRUE by default)
	music = "music/music.ogg"		(music when you enter this section)
*/

/area/shuttle/tsf
	name = "TSF Discovery"
	icon_state = "shuttle"

/area/centcom/bar
	name = "Centcom Bar"

/area/engine/singularity
	name = "Singularity Engine"
	icon_state = "engine"

/area/snowland
	icon_state = "Naga"
	has_gravity = TRUE
	ambientsounds = MINING_SOUNDS
	sound_environment = SOUND_AREA_LAVALAND
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/snowland/explored
	name = "Naga Surface"
	icon_state = "explored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	flags = NONE

/area/snowland/unexplored
	name = "Naga Surface"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	flags = NONE

/area/TSF_Outpost
	name = "TSF Outpost"
	icon_state = "mining"
	has_gravity = TRUE
	ambientsounds = ENGINEERING_SOUNDS


/area/TSF_Outpost/Docking
	name = "TSF Outpost Docking Area"
	icon_state = "yellow"

/area/TSF_Outpost/Kitchen
	name = "TSF Outpost Kitchen"
	icon_state = "kitchen"

/area/TSF_Outpost/Chapel
	name = "TSF Outpost Chapel"
	icon_state = "chapel"

/area/TSF_Outpost/Hallway
	name = "TSF Outpost Central Hallway"
	icon_state = "escape"

/area/TSF_Outpost/Medbay
	name = "TSF Outpost Medbay"
	icon_state = "medbay"

/area/TSF_Outpost/Exterior
	name = "TSF Outpost Exterior Access"
	icon_state = "storage"

/area/TSF_Outpost/CrewDorms
	name = "TSF Outpost Crew Dorms"
	icon_state = "dorms"

/area/TSF_Outpost/CrewShower
	name = "TSF Outpost Crew Showers"
	icon_state = "toilet"

/area/NT_Polar_Outpost
	name = "NT Naga Research Facility"
	icon_state = "DJ"
	has_gravity = TRUE
	ambientsounds = SPOOKY_SOUNDS

/area/NT_Polar_Outpost/mining
	name = "RO Naga Mining"
	icon_state = "mining"

/area/NT_Polar_Outpost/crew
	name = "RO Naga Crew Quarters"
	icon_state = "fitness"

/area/NT_Polar_Outpost/engineering
	name = "RO Naga Engineering"
	icon_state = "construction"

/area/NT_Polar_Outpost/centrall_hall
	name = "RO Central Hall"
	icon_state = "interrogationhall"

/area/NT_Polar_Outpost/research
	name = "RO Research"
	icon_state = "medresearch"

/area/NT_Polar_Outpost/gate_failure
	name = "RO Gateway Prototype"
	icon_state = "teleporter"

/area/dababyruin
	name = "DaBaBy Ruin"
	icon = 'icons/hispania/turf/areas.dmi'
	icon_state = "dababy"
	ambientsounds = MAINTENANCE_SOUNDS
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	always_unpowered = TRUE

/area/dababybigzone
	name = "DaBaBy Principal Ruin"
	icon = 'icons/hispania/turf/areas.dmi'
	icon_state = "dababybig"
	ambientsounds = RUINS_SOUNDS
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/maintenance/spacepost
	name = "DaBaby SpacePost - ONE"
	icon = 'icons/hispania/turf/areas.dmi'
	icon_state = "spacepost"

/area/maintenance/spacepost/two
	name = "DaBaby SpacePost - TWO"

/area/maintenance/spacepost/third
	name = "DaBaby SpacePost - THIRD"

/area/engine/mechanic_workshop
	name = "\improper Mechanic Workshop"
	icon_state = "engine"

/area/engine/mechanic_workshop/hanger
	name = "\improper Hanger Bay"
	icon_state = "engine"

/area/security/podbay
	name = "\improper Security Podbay"
	icon_state = "securitypodbay"
