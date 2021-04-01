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


/area/admin
	name = "\improper Admin Room"
	icon_state = "start"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	hide_attacklogs = TRUE


/area/adminconstruction
	name = "\improper Admin Testing Area"
	icon_state = "start"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	hide_attacklogs = TRUE

/area/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	valid_territory = FALSE
	outdoors = TRUE
	ambientsounds = SPACE_SOUNDS
	sound_environment = SOUND_AREA_SPACE

/area/space/nearstation
	icon_state = "space_near"
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT

/area/space/atmosalert()
	return

/area/space/firealert(obj/source)
	return

/area/space/firereset(obj/source)
	return

//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle
	no_teleportlocs = TRUE
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	parallax_movedir = NORTH
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/shuttle/arrival
	name = "\improper Arrival Shuttle"
	parallax_movedir = EAST

/area/shuttle/arrival/pre_game
	icon_state = "shuttle2"

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/auxillary_base
	icon_state = "shuttle"

/area/shuttle/escape
	name = "\improper Emergency Shuttle"
	icon_state = "shuttle2"
	nad_allowed = TRUE

/area/shuttle/pod_1
	name = "\improper Escape Pod One"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_2
	name = "\improper Escape Pod Two"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_3
	name = "\improper Escape Pod Three"
	icon_state = "shuttle"
	nad_allowed = TRUE
	parallax_movedir = EAST

/area/shuttle/pod_4
	name = "\improper Escape Pod Four"
	icon_state = "shuttle"
	nad_allowed = TRUE
	parallax_movedir = EAST

/area/shuttle/escape_pod1
	name = "\improper Escape Pod One"
	nad_allowed = TRUE

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod2
	name = "\improper Escape Pod Two"
	nad_allowed = TRUE

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod3
	name = "\improper Escape Pod Three"
	nad_allowed = TRUE

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod5 //Pod 4 was lost to meteors
	name = "\improper Escape Pod Five"
	nad_allowed = TRUE

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"

/area/shuttle/mining
	name = "\improper Mining Shuttle"
	icon_state = "shuttle"

/area/shuttle/transport
	icon_state = "shuttle"
	name = "\improper Transport Shuttle"
	parallax_movedir = EAST

/area/shuttle/transport1
	icon_state = "shuttle"
	name = "\improper Transport Shuttle"

/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Base"
	requires_power = 1

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Mine"
	requires_power = 1

/area/shuttle/gamma/space
	icon_state = "shuttle"
	name = "\improper Gamma Armory"

/area/shuttle/gamma/station
	icon_state = "shuttle"
	name = "\improper Gamma Armory Station"

/area/shuttle/prison/
	name = "\improper Prison Shuttle"

/area/shuttle/prison/station
	icon_state = "shuttle"

/area/shuttle/prison/prison
	icon_state = "shuttle2"

/area/shuttle/siberia
	name = "\improper Labor Camp Shuttle"
	icon_state = "shuttle"

/area/shuttle/specops
	name = "\improper Special Ops Shuttle"
	icon_state = "shuttlered"
	parallax_movedir = EAST

/area/shuttle/specops/centcom
	name = "\improper Special Ops Shuttle"
	icon_state = "shuttlered"

/area/shuttle/specops/station
	name = "\improper Special Ops Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite
	name = "\improper Syndicate Elite Shuttle"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_movedir = SOUTH

/area/shuttle/syndicate_elite/mothership
	name = "\improper Syndicate Elite Shuttle"
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	name = "\improper Syndicate Elite Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_sit
	name = "\improper Syndicate SIT Shuttle"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_movedir = SOUTH

/area/shuttle/assault_pod
	name = "Steel Rain"
	icon_state = "shuttle"

/area/shuttle/administration
	name = "\improper Nanotrasen Vessel"
	icon_state = "shuttlered"
	parallax_movedir = EAST

/area/shuttle/administration/centcom
	name = "\improper Nanotrasen Vessel Centcom"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "\improper Nanotrasen Vessel"
	icon_state = "shuttlered2"

/area/shuttle/thunderdome
	name = "honk"

/area/shuttle/thunderdome/grnshuttle
	name = "\improper Thunderdome GRN Shuttle"
	icon_state = "green"

/area/shuttle/thunderdome/grnshuttle/dome
	name = "\improper GRN Shuttle"
	icon_state = "shuttlegrn"

/area/shuttle/thunderdome/grnshuttle/station
	name = "\improper GRN Station"
	icon_state = "shuttlegrn2"

/area/shuttle/thunderdome/redshuttle
	name = "\improper Thunderdome RED Shuttle"
	icon_state = "red"

/area/shuttle/thunderdome/redshuttle/dome
	name = "\improper RED Shuttle"
	icon_state = "shuttlered"

/area/shuttle/thunderdome/redshuttle/station
	name = "\improper RED Station"
	icon_state = "shuttlered2"
// === Trying to remove these areas:

/area/shuttle/research
	name = "\improper Research Shuttle"
	icon_state = "shuttle"

/area/shuttle/research/station
	icon_state = "shuttle2"

/area/shuttle/research/outpost
	icon_state = "shuttle"

/area/shuttle/vox
	name = "\improper Vox Skipjack"
	icon_state = "shuttle"

/area/shuttle/vox/station
	name = "\improper Vox Skipjack"
	icon_state = "yellow"

/area/shuttle/salvage
	name = "\improper Salvage Ship"
	icon_state = "yellow"

/area/shuttle/salvage/start
	name = "\improper Middle of Nowhere"
	icon_state = "yellow"

/area/shuttle/salvage/arrivals
	name = "\improper Space Station Auxiliary Docking"
	icon_state = "yellow"

/area/shuttle/salvage/derelict
	name = "\improper Derelict Station"
	icon_state = "yellow"

/area/shuttle/salvage/djstation
	name = "\improper Ruskie DJ Station"
	icon_state = "yellow"

/area/shuttle/salvage/north
	name = "\improper North of the Station"
	icon_state = "yellow"

/area/shuttle/salvage/east
	name = "\improper East of the Station"
	icon_state = "yellow"

/area/shuttle/salvage/south
	name = "\improper South of the Station"
	icon_state = "yellow"

/area/shuttle/salvage/commssat
	name = "\improper The Communications Satellite"
	icon_state = "yellow"

/area/shuttle/salvage/mining
	name = "\improper South-West of the Mining Asteroid"
	icon_state = "yellow"

/area/shuttle/salvage/abandoned_ship
	name = "\improper Abandoned Ship"
	icon_state = "yellow"
	parallax_movedir = WEST

/area/shuttle/salvage/clown_asteroid
	name = "\improper Clown Asteroid"
	icon_state = "yellow"

/area/shuttle/salvage/trading_post
	name = "\improper Trading Post"
	icon_state = "yellow"

/area/shuttle/salvage/transit
	name = "\improper hyperspace"
	icon_state = "shuttle"

/area/shuttle/supply
	name = "Supply Shuttle"
	icon_state = "shuttle3"

/area/shuttle/abandoned
	name = "Abandoned Ship"
	icon_state = "shuttle"

/area/shuttle/syndicate
	name = "Syndicate Nuclear Team Shuttle"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/trade
	name = "Trade Shuttle"
	icon_state = "shuttle"

/area/shuttle/trade/sol
	name = "Sol Freighter"
	parallax_movedir = EAST

/area/shuttle/freegolem
	name = "Free Golem Ship"
	icon_state = "purple"
	xenobiology_compatible = TRUE

/area/airtunnel1/      // referenced in airtunnel.dm:759

/area/dummy/           // Referenced in engine.dm:261

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = TRUE
	ambientsounds = null // No ambient sounds in the lobby

// === end remove

// CENTCOM

/area/centcom
	name = "\improper Centcom"
	icon_state = "centcom"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	nad_allowed = TRUE

/area/centcom/control
	name = "\improper Centcom Control"
	icon_state = "centcom_ctrl"

/area/centcom/evac
	name = "\improper Centcom Emergency Shuttle"
	icon_state = "centcom_evac"

/area/centcom/suppy
	name = "\improper Centcom Supply Shuttle"
	icon_state = "centcom_supply"

/area/centcom/ferry
	name = "\improper Centcom Transport Shuttle"
	icon_state = "centcom_ferry"

/area/centcom/shuttle
	name = "\improper Centcom Administration Shuttle"

/area/centcom/test
	name = "\improper Centcom Testing Facility"

/area/centcom/living
	name = "\improper Centcom Living Quarters"

/area/centcom/specops
	name = "\improper Centcom Special Ops"
	icon_state = "centcom_specops"

/area/centcom/gamma
	name = "\improper Centcom Gamma Armory"
	icon_state = "centcom_gamma"

/area/centcom/holding
	name = "\improper Holding Facility"

/area/centcom/bathroom
	name = "\improper Centcom Emergency Shuttle Bathrooms"

//SYNDICATES

/area/syndicate_mothership
	name = "\improper Syndicate Forward Base"
	icon_state = "syndie-ship"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	nad_allowed = TRUE
	ambientsounds = HIGHSEC_SOUNDS

/area/syndicate_mothership/control
	name = "\improper Syndicate Control Room"
	icon_state = "syndie-control"

/area/syndicate_mothership/elite_squad
	name = "\improper Syndicate Elite Squad"
	icon_state = "syndie-elite"

/area/syndicate_mothership/infteam
	name = "\improper Syndicate Infiltrators"
	icon_state = "syndie-elite"

/area/syndicate_mothership/jail
	name = "\improper Syndicate Jail"

//EXTRA

/area/asteroid					// -- TLE
	name = "\improper Asteroid"
	icon_state = "asteroid"
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambientsounds = MINING_SOUNDS
	sound_environment = SOUND_AREA_ASTEROID
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/asteroid/cave				// -- TLE
	name = "\improper Asteroid - Underground"
	icon_state = "cave"
	requires_power = FALSE
	outdoors = TRUE

/area/asteroid/artifactroom
	name = "\improper Asteroid - Artifact"
	icon_state = "cave"

/area/tdome
	name = "\improper Thunderdome"
	icon_state = "thunder"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	hide_attacklogs = TRUE


/area/tdome/arena_source
	name = "\improper Thunderdome Arena Template"
	icon_state = "thunder"

/area/tdome/arena_source2
	name = "\improper Thunderdome Arena Template 2"
	icon_state = "thunder"

/area/tdome/arena_source3
	name = "\improper Thunderdome Arena Template 3"
	icon_state = "thunder"

/area/tdome/arena_source4
	name = "\improper Thunderdome Arena Template 4"
	icon_state = "thunder"

/area/tdome/arena
	name = "\improper Thunderdome Arena"
	icon_state = "thunder"

/area/tdome/tdome1
	name = "\improper Thunderdome (Team 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "\improper Thunderdome (Team 2)"
	icon_state = "yellow"

/area/tdome/tdomeadmin
	name = "\improper Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "\improper Thunderdome (Observer.)"
	icon_state = "purple"

/area/exploration/methlab
	name = "\improper Abandoned Drug Lab"
	icon_state = "green"
	there_can_be_many = TRUE

//Abductors
/area/abductor_ship
	name = "\improper Abductor Ship"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = TRUE

/area/wizard_station
	name = "\improper Wizard's Den"
	icon_state = "yellow"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/ninja
	name = "\improper Ninja Area Parent"
	icon_state = "ninjabase"
	requires_power = FALSE
	no_teleportlocs = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/ninja/outpost
	name = "\improper SpiderClan Outpost"

/area/ninja/holding
	name = "\improper SpiderClan Holding Facility"

/area/vox_station
	name = "\improper Vox Base"
	icon_state = "yellow"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	no_teleportlocs = TRUE

/area/trader_station
	name = "Trade Base"
	icon_state = "yellow"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/trader_station/sol
	name = "Jupiter Station 6"

//Labor camp
/area/mine/laborcamp
	name = "Labor Camp"
	icon_state = "brig"

/area/mine/laborcamp/security
	name = "Labor Camp Security"
	icon_state = "security"

//STATION13

/area/atmos
 	name = "Atmospherics"
 	icon_state = "atmos"

/area/atmos/control
 	name = "Atmospherics Control Room"
 	icon_state = "atmos"

/area/atmos/distribution
 	name = "Atmospherics Distribution Loop"
 	icon_state = "atmos"

//Maintenance
/area/maintenance
	ambientsounds = MAINTENANCE_SOUNDS
	valid_territory = FALSE
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/maintenance/atmos_control
	name = "Atmospherics Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint
	name = "EVA Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint2
	name = "Arrivals North Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fsmaint
	name = "Dormitory Maintenance"
	icon_state = "fsmaint"

/area/maintenance/fsmaint2
	name = "Bar Maintenance"
	icon_state = "fsmaint"

/area/maintenance/asmaint
	name = "Medbay Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint2
	name = "Science Maintenance"
	icon_state = "asmaint"

/area/maintenance/apmaint
	name = "Cargo Maintenance"
	icon_state = "apmaint"

/area/maintenance/maintcentral
	name = "Bridge Maintenance"
	icon_state = "maintcentral"

/area/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "fmaint"

/area/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/port
	name = "Locker Room Maintenance"
	icon_state = "pmaint"

/area/maintenance/aft
	name = "Engineering Maintenance"
	icon_state = "amaint"

/area/maintenance/storage
	name = "Atmospherics Maintenance"
	icon_state = "green"

/area/maintenance/incinerator
	name = "\improper Incinerator"
	icon_state = "disposal"

/area/maintenance/turbine
	name = "\improper Turbine"
	icon_state = "disposal"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/maintenance/genetics
	name = "Genetics Maintenance"
	icon_state = "asmaint"


/area/maintenance/electrical
	name = "Electrical Maintenance"
	icon_state = "yellow"

/area/maintenance/abandonedbar
	name = "Maintenance Bar"
	icon_state = "yellow"
	power_equip = 0
	power_light = 0
	power_environ = 0

/area/maintenance/electrical_shop
	name ="Electronics Den"
	icon_state = "yellow"

/area/maintenance/gambling_den
	name = "Gambling Den"
	icon_state = "yellow"

/area/maintenance/consarea
	name = "Alternate Construction Area"
	icon_state = "yellow"


//Hallway

/area/hallway
	valid_territory = FALSE //too many areas with similar/same names, also not very interesting summon spots
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/starboard/west
/area/hallway/primary/starboard/east

/area/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "hallA"


/area/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/port/west
	name = "\improper Port West Hallway"

/area/hallway/primary/port/east
	name = "\improper Port East Hallway"

/area/hallway/primary/central
	name = "\improper Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/primary/central/north
/area/hallway/primary/central/south
/area/hallway/primary/central/west
/area/hallway/primary/central/east
/area/hallway/primary/central/nw
/area/hallway/primary/central/ne
/area/hallway/primary/central/sw
/area/hallway/primary/central/se

/area/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/construction
	name = "\improper Construction Area"
	icon_state = "construction"

/area/hallway/secondary/entry
	name = "\improper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/hallway/secondary/entry/north

/area/hallway/secondary/entry/south

/area/hallway/secondary/entry/louge
	name = "\improper Arrivals Lounge"


//Command

/area/bridge
	name = "\improper Bridge"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/bridge/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/crew_quarters/captain
	name = "\improper Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/captain/bedroom
	name = "\improper Captain's Bedroom"
	icon_state = "captain"

/area/crew_quarters/recruit
	name = "\improper Recruitment Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hop
	name = "\improper Head of Personnel's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hor
	name = "\improper Research Director's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/chief
	name = "\improper Chief Engineer's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hos
	name = "\improper Head of Security's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/cmo
	name = "\improper Chief Medical Officer's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"

/area/crew_quarters/heads
	name = "\improper Head of Personnel's Office"
	icon_state = "head_quarters"

/area/crew_quarters/hor
	name = "\improper Research Director's Office"
	icon_state = "head_quarters"

/area/crew_quarters/hos
	name = "\improper Head of Security's Office"
	icon_state = "head_quarters"

/area/crew_quarters/chief
	name = "\improper Chief Engineer's Office"
	icon_state = "head_quarters"

/area/mint
	name = "\improper Mint"
	icon_state = "green"

/area/comms
	name = "\improper Communications Relay"
	icon_state = "tcomsatcham"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/server
	name = "\improper Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ntrep
	name = "\improper Nanotrasen Representative's Office"
	icon_state = "bluenew"

/area/blueshield
	name = "\improper Blueshield's Office"
	icon_state = "blueold"

/area/centcomdocks
	name = "\improper Central Command Docks"
	icon_state = "centcom"

//Crew

/area/crew_quarters
	name = "\improper Dormitories"
	icon_state = "Sleep"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/crew_quarters/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/sleep
	name = "\improper Dormitories"
	icon_state = "Sleep"
	valid_territory = FALSE

/area/crew_quarters/sleep_male
	name = "\improper Male Dorm"
	icon_state = "Sleep"

/area/crew_quarters/sleep_male/toilet_male
	name = "\improper Male Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep_female
	name = "\improper Female Dorm"
	icon_state = "Sleep"

/area/crew_quarters/sleep_female/toilet_female
	name = "\improper Female Toilets"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/crew_quarters/locker/locker_toilet
	name = "\improper Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/dorms
	name = "\improper Dorms"
	icon_state = "dorms"

/area/crew_quarters/arcade
	name = "\improper Arcade"
	icon_state = "arcade"

/area/crew_quarters/cafeteria
	name = "\improper Cafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/crew_quarters/bar
	name = "\improper Bar"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/bar/atrium
	name = "Atrium"
	icon_state = "bar"

/area/crew_quarters/theatre
	name = "\improper Theatre"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/mrchangs
	name = "\improper Mr Chang's"
	icon_state = "Theatre"

/area/library
	name = "\improper Library"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/library/abandoned
	name = "\improper Abandoned Library"
	icon_state = "library"

/area/chapel
	icon_state = "chapel"
	ambientsounds = HOLY_SOUNDS
	is_haunted = TRUE
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/chapel/main
	name = "\improper Chapel"

/area/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/escapepodbay
	name = "\improper Escape Shuttle Hallway Podbay"
	icon_state = "escape"

/area/lawoffice
	name = "\improper Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/magistrateoffice
	name = "\improper Magistrate's Office"
	icon_state = "magistrate"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/clownoffice
	name = "\improper Clown's Office"
	icon_state = "clown_office"

/area/mimeoffice
	name = "\improper Mime's Office"
	icon_state = "mime_office"

/area/civilian/barber
	name = "\improper Barber Shop"
	icon_state = "barber"

/area/civilian/clothing
	name = "\improper Clothing Shop"
	icon_state = "Theatre"

/area/civilian/pet_store
	name = "\improper Pet Store"
	icon_state = "pet_store"

/area/holodeck
	name = "\improper Holodeck"
	icon_state = "Holodeck"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL

/area/holodeck/alphadeck
	name = "\improper Holodeck Alpha"


/area/holodeck/source_plating
	name = "\improper Holodeck - Off"
	icon_state = "Holodeck"

/area/holodeck/source_emptycourt
	name = "\improper Holodeck - Empty Court"

/area/holodeck/source_boxingcourt
	name = "\improper Holodeck - Boxing Court"

/area/holodeck/source_basketball
	name = "\improper Holodeck - Basketball Court"

/area/holodeck/source_thunderdomecourt
	name = "\improper Holodeck - Thunderdome Court"

/area/holodeck/source_beach
	name = "\improper Holodeck - Beach"
	icon_state = "Holodeck" // Lazy.

/area/holodeck/source_burntest
	name = "\improper Holodeck - Atmospheric Burn Test"

/area/holodeck/source_wildlife
	name = "\improper Holodeck - Wildlife Simulation"

/area/holodeck/source_meetinghall
	name = "\improper Holodeck - Meeting Hall"

/area/holodeck/source_theatre
	name = "\improper Holodeck - Theatre"

/area/holodeck/source_picnicarea
	name = "\improper Holodeck - Picnic Area"

/area/holodeck/source_snowfield
	name = "\improper Holodeck - Snow Field"

/area/holodeck/source_desert
	name = "\improper Holodeck - Desert"

/area/holodeck/source_space
	name = "\improper Holodeck - Space"

/area/holodeck/source_knightarena
	name = "\improper Holodeck - Knight Arena"


//Embassies
/area/embassy/
	name = "\improper Embassy Hallway"

/area/embassy/tajaran
	name = "\improper Tajaran Embassy"
	icon_state = "tajaran"

/area/embassy/skrell
	name = "\improper Skrell Embassy"
	icon_state = "skrell"

/area/embassy/unathi
	name = "\improper Unathi Embassy"
	icon_state = "unathi"

/area/embassy/kidan
	name = "\improper Kidan Embassy"
	icon_state = "kidan"

/area/embassy/diona
	name = "\improper Diona Embassy"
	icon_state = "diona"

/area/embassy/slime
	name = "\improper Slime Person Embassy"
	icon_state = "slime"

/area/embassy/grey
	name = "\improper Grey Embassy"
	icon_state = "grey"

/area/embassy/vox
	name = "\improper Vox Embassy"
	icon_state = "vox"



//Engineering
/area/engine
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/engine/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"
	requires_power = FALSE //This area only covers the batteries and they deal with their own power
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/engine/engineering
	name = "Engineering"
	icon_state = "engine_smes"

/area/engine/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/equipmentstorage
	name = "\improper Engineering Equipment Storage"
	icon_state = "storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/hardsuitstorage
	name = "\improper Engineering Hardsuit Storage"
	icon_state = "storage"

/area/engine/controlroom
	name = "\improper Engineering Control Room"
	icon_state = "engine_control"

/area/engine/gravitygenerator
	name = "\improper Gravity Generator"
	icon_state = "engine"

/area/engine/chiefs_office
	name = "\improper Chief Engineer's office"
	icon_state = "engine_control"

/area/engine/mechanic_workshop
	name = "\improper Mechanic Workshop"
	icon_state = "engine"

/area/engine/mechanic_workshop/hanger
	name = "\improper Hanger Bay"
	icon_state = "engine"

/area/engine/supermatter
	name = "\improper Supermatter Engine"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

//Solars

/area/solar
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE

/area/solar/auxport
	name = "\improper Fore Port Solar Array"
	icon_state = "panelsA"

/area/solar/auxstarboard
	name = "\improper Fore Starboard Solar Array"
	icon_state = "panelsA"

/area/solar/fore
	name = "\improper Fore Solar Array"
	icon_state = "yellow"

/area/solar/aft
	name = "\improper Aft Solar Array"
	icon_state = "aft"

/area/solar/starboard
	name = "\improper Aft Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/port
	name = "\improper Aft Port Solar Array"
	icon_state = "panelsP"

/area/maintenance/auxsolarport
	name = "\improper Fore Port Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/starboardsolar
	name = "\improper Aft Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/portsolar
	name = "\improper Aft Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/auxsolarstarboard
	name = "\improper Fore Starboard Solar Maintenance"
	icon_state = "SolarcontrolA"


/area/assembly/chargebay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/assembly/showroom
	name = "\improper Robotics Showroom"
	icon_state = "showroom"

/area/assembly/robotics
	name = "\improper Robotics Lab"
	icon_state = "ass_line"

/area/assembly/assembly_line //Derelict Assembly Line
	name = "\improper Assembly Line"
	icon_state = "ass_line"
	power_equip = 0
	power_light = 0
	power_environ = 0

//Teleporter

/area/teleporter
	name = "\improper Teleporter"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS

/area/gateway
	name = "\improper Gateway"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/AIsattele
	name = "\improper Abandoned Teleporter"
	icon_state = "teleporter"
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/signal.ogg')
	there_can_be_many = TRUE

/area/toxins/explab
	name = "\improper E.X.P.E.R.I-MENTOR Lab"
	icon_state = "toxmisc"

/area/toxins/explab_chamber
	name = "\improper E.X.P.E.R.I-MENTOR Chamber"
	icon_state = "toxmisc"

//MedBay

/area/medical
	ambientsounds = MEDICAL_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	min_ambience_cooldown = 90 SECONDS
	max_ambience_cooldown = 180 SECONDS

/area/medical/medbay
	name = "\improper Medbay"
	icon_state = "medbay"

//Medbay is a large area, these additional areas help level out APC load.
/area/medical/medbay2
	name = "\improper Medbay"
	icon_state = "medbay2"

/area/medical/medbay3
	name = "\improper Medbay"
	icon_state = "medbay3"


/area/medical/biostorage
	name = "\improper Medical Storage"
	icon_state = "medbaysecstorage"

/area/medical/reception
	name = "\improper Medbay Reception"
	icon_state = "medbay"

/area/medical/psych
	name = "\improper Psych Room"
	icon_state = "medbaypsych"

/area/medical/medbreak
	name = "\improper Break Room"
	icon_state = "medbaybreak"

/area/medical/patients_rooms
	name = "\improper Patient's Rooms"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/medical/ward
	name = "\improper Medbay Patient Ward"
	icon_state = "patientsward"

/area/medical/patient_a
	name = "\improper Isolation A"
	icon_state = "medbayisoa"

/area/medical/patient_b
	name = "\improper Isolation B"
	icon_state = "medbayisob"

/area/medical/patient_c
	name = "\improper Isolation C"
	icon_state = "medbayisoc"

/area/medical/iso_access
	name = "\improper Isolation Access"
	icon_state = "medbayisoaccess"

/area/medical/cmo
	name = "\improper Chief Medical Officer's office"
	icon_state = "CMO"

/area/medical/cmostore
	name = "\improper Medical Secondary Storage"
	icon_state = "medbaysecstorage"

/area/medical/robotics
	name = "\improper Robotics"
	icon_state = "medresearch"

/area/medical/research
	name = "\improper Medical Research"
	icon_state = "medresearch"

/area/medical/research_shuttle_dock
	name = "\improper Research Shuttle Dock"
	icon_state = "medresearch"

/area/medical/virology
	name = "\improper Virology"
	icon_state = "virology"

/area/medical/virology/lab
	name = "\improper Virology Laboratory"
	icon_state = "virology"

/area/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambientsounds = SPOOKY_SOUNDS
	is_haunted = TRUE
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/medical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/medical/surgery
	name = "\improper Surgery"
	icon_state = "surgery"

/area/medical/surgery1
	name = "\improper Surgery 1"
	icon_state = "surgery1"

/area/medical/surgery2
	name = "\improper Surgery 2"
	icon_state = "surgery2"

/area/medical/surgeryobs
	name = "\improper Surgery Observation"
	icon_state = "surgery"

/area/medical/cryo
	name = "\improper Cryogenics"
	icon_state = "cryo"

/area/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "\improper Genetics Lab"
	icon_state = "genetics"

/area/medical/genetics_cloning
	name = "\improper Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "\improper Medical Treatment Center"
	icon_state = "exam_room"

/area/medical/paramedic
	name = "\improper Paramedic"
	icon_state = "medbay"

//Security

/area/security
	ambientsounds = HIGHSEC_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/security/main
	name = "\improper Security Office"
	icon_state = "securityoffice"

/area/security/lobby
	name = "\improper Security Lobby"
	icon_state = "securitylobby"

/area/security/brig
	name = "\improper Brig"
	icon_state = "brig"

/area/security/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.icon_state = temp_closet.icon_closed
	for(var/obj/machinery/door_timer/temp_timer in src)
		temp_timer.releasetime = 1
	..()

/area/security/permabrig
	name = "\improper Prison Wing"
	icon_state = "sec_prison_perma"
	fast_despawn = TRUE
	can_get_auto_cryod = FALSE

/area/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"
	can_get_auto_cryod = FALSE

/area/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.icon_state = temp_closet.icon_closed
	for(var/obj/machinery/door_timer/temp_timer in src)
		temp_timer.releasetime = 1
	..()

/area/security/prison/cell_block
	name = "\improper Prison Cell Block"
	icon_state = "brig"

/area/security/prison/cell_block/A
	name = "\improper Prison Cell Block A"
	icon_state = "brigcella"

/area/security/prison/cell_block/B
	name = "\improper Prison Cell Block B"
	icon_state = "brigcellb"

/area/security/prison/cell_block/C
	name = "\improper Prison Cell Block C"
	icon_state = "brig"

/area/security/execution
	name = "\improper Execution"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/security/processing
	name = "\improper Prisoner Processing"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/security/interrogation
	name = "\improper Interrogation"
	icon_state = "interrogation"
	can_get_auto_cryod = FALSE

/area/security/seceqstorage
	name = "\improper Security Equipment Storage"
	icon_state = "securityequipmentstorage"

/area/security/interrogationhallway
	name = "\improper Interrogation Hallway"
	icon_state = "interrogationhall"

/area/security/courtroomdandp
	name = "\improper Courtroom Defense and Prosecution"
	icon_state = "seccourt"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/security/interrogationobs
	name = "\improper Interrogation Observation"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/security/evidence
	name = "\improper Evidence Room"
	icon_state = "evidence"

/area/security/prisonlockers
	name = "\improper Prisoner Lockers"
	icon_state = "sec_prison_lockers"
	can_get_auto_cryod = FALSE

/area/security/medbay
	name = "\improper Security Medbay"
	icon_state = "security_medbay"

/area/security/prisonershuttle
	name = "\improper Security Prisoner Shuttle"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/security/warden
	name = "\improper Warden's Office"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/armoury
	name = "\improper Armory"
	icon_state = "armory"

/area/security/securearmoury
	name = "\improper Secure Armory"
	icon_state = "secarmory"

/area/security/securehallway
	name = "\improper Security Secure Hallway"
	icon_state = "securehall"

/area/security/hos
	name = "\improper Head of Security's Office"
	icon_state = "sec_hos"

/area/security/podbay
	name = "\improper Security Podbay"
	icon_state = "securitypodbay"

/area/security/detectives_office
	name = "\improper Detective's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg', 'sound/ambience/ambidet2.ogg')

/area/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"

/area/security/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"

/area/security/customs
	name = "\improper Customs"
	icon_state = "checkpoint1"

/area/security/customs2
	name = "\improper Customs"
	icon_state = "security"

/area/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint2
	name = "\improper Security Checkpoint"
	icon_state = "security"

/area/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint1"

/area/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint1"

/area/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint1"

/area/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint1"

/area/security/vacantoffice
	name = "\improper Vacant Office"
	icon_state = "security"

/area/security/vacantoffice2
	name = "\improper Vacant Office"
	icon_state = "security"

/area/quartermaster
	name = "\improper Quartermasters"
	icon_state = "quart"
	sound_environment = SOUND_AREA_STANDARD_STATION

///////////WORK IN PROGRESS//////////

/area/quartermaster/sorting
	name = "\improper Delivery Office"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_STANDARD_STATION

////////////WORK IN PROGRESS//////////

/area/quartermaster/office
	name = "\improper Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "\improper Cargo Bay"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/quartermaster/qm
	name = "\improper Quartermaster's Office"
	icon_state = "quart"

/area/quartermaster/miningdock
	name = "\improper Mining Dock"
	icon_state = "mining"

/area/quartermaster/miningstorage
	name = "\improper Mining Storage"
	icon_state = "green"

/area/quartermaster/mechbay
	name = "\improper Mech Bay"
	icon_state = "yellow"

/area/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/hydroponics
	name = "\improper Hydroponics"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/hydroponics/abandoned_garden
	name = "\improper Abandoned Garden"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

//Toxins

/area/toxins
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/toxins/lab
	name = "\improper Research and Development"
	icon_state = "toxlab"

/area/toxins/hallway
	name = "\improper Research Lab"
	icon_state = "toxlab"

/area/toxins/rdoffice
	name = "\improper Research Director's Office"
	icon_state = "head_quarters"

/area/toxins/supermatter
	name = "\improper Supermatter Lab"
	icon_state = "toxlab"

/area/toxins/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "toxmix"
	xenobiology_compatible = TRUE

/area/toxins/xenobiology/xenoflora_storage
	name = "\improper Xenoflora Storage"
	icon_state = "toxlab"

/area/toxins/xenobiology/xenoflora
	name = "\improper Xenoflora Lab"
	icon_state = "toxlab"

/area/toxins/storage
	name = "\improper Toxins Storage"
	icon_state = "toxstorage"

/area/toxins/test_area
	name = "\improper Toxins Test Area"
	icon_state = "toxtest"
	valid_territory = FALSE

/area/toxins/mixing
	name = "\improper Toxins Mixing Room"
	icon_state = "toxmix"

/area/toxins/launch
	name = "Toxins Launch Room"
	icon_state = "toxlaunch"

/area/toxins/misc_lab
	name = "\improper Research Testing Lab"
	icon_state = "toxmisc"

/area/toxins/test_chamber
	name = "\improper Research Testing Chamber"
	icon_state = "toxtest"

/area/toxins/server
	name = "\improper Server Room"
	icon_state = "server"

/area/toxins/server_coldroom
	name = "\improper Server Coldroom"
	icon_state = "servercold"

/area/toxins/explab
	name = "\improper Experimentation Lab"
	icon_state = "toxmisc"

//Storage
/area/storage
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "storage"

/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/autolathe
	name = "Autolathe Storage"
	icon_state = "storage"

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/storage/auxillary
	name = "Auxillary Storage"
	icon_state = "auxstorage"

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/storage/office
	name = "\improper Office Supplies"
	icon_state = "office_supplies"

// ENGIE OUTPOST

/area/engiestation
	name = "\improper Engineering Outpost"
	icon_state = "construction"

/area/engiestation/solars
	name = "\improper Engineering Outpost Solars"
	icon_state = "panelsP"

//DJSTATION

/area/djstation
	name = "\improper Ruskie DJ Station"
	icon_state = "DJ"
	there_can_be_many = TRUE

/area/djstation/solars
	name = "\improper Ruskie DJ Station Solars"
	icon_state = "DJ"

//DERELICT

/area/derelict
	name = "\improper Derelict Station"
	icon_state = "storage"

/area/derelict/hallway/primary
	name = "\improper Derelict Primary Hallway"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "\improper Derelict Secondary Hallway"
	icon_state = "hallS"

/area/derelict/arrival
	name = "\improper Derelict Arrival Centre"
	icon_state = "yellow"

/area/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/derelict/bridge
	name = "\improper Derelict Control Room"
	icon_state = "bridge"

/area/derelict/secret
	name = "\improper Derelict Secret Room"
	icon_state = "library"

/area/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "\improper Derelict Computer Core"
	icon_state = "ai"

/area/derelict/solar_control
	name = "\improper Derelict Solar Control"
	icon_state = "engine"

/area/derelict/se_solar
	name = "South East Solars"
	icon_state = "engine"

/area/derelict/crew_quarters
	name = "\improper Derelict Crew Quarters"
	icon_state = "fitness"

/area/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/medical/morgue
	name = "\improper Derelict Morgue"
	icon_state = "morgue"
	is_haunted = TRUE

/area/derelict/medical/chapel
	name = "\improper Derelict Chapel"
	icon_state = "chapel"
	is_haunted = TRUE

/area/derelict/teleporter
	name = "\improper Derelict Teleporter"
	icon_state = "teleporter"
	there_can_be_many = TRUE

/area/derelict/eva
	name = "Derelict EVA Storage"
	icon_state = "eva"

/area/shuttle/derelict/ship/start
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/shuttle/derelict/ship/transit
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/shuttle/derelict/ship/engipost
	name = "\improper Engineering Outpost"
	icon_state = "yellow"

/area/shuttle/derelict/ship/station
	name = "\improper North of SS13"
	icon_state = "yellow"

/area/solar/derelict_starboard
	name = "\improper Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "\improper Derelict Aft Solar Array"
	icon_state = "aft"

/area/derelict/singularity_engine
	name = "\improper Derelict Singularity Engine"
	icon_state = "engine"

/area/derelict/gravity_generator
	name = "\improper Derelict Gravity Generator Room"
	icon_state = "red"

/area/derelict/atmospherics
	name = "Derelict Atmospherics"
	icon_state = "red"

//Construction

/area/construction
	name = "\improper Construction Area"
	icon_state = "yellow"
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/mining_construction
	name = "Auxillary Base Construction"
	icon_state = "yellow"

/area/construction/supplyshuttle
	name = "\improper Supply Shuttle"
	icon_state = "yellow"

/area/construction/quarters
	name = "\improper Engineer's Quarters"
	icon_state = "yellow"

/area/construction/qmaint
	name = "Maintenance"
	icon_state = "yellow"

/area/construction/hallway
	name = "\improper Hallway"
	icon_state = "yellow"

/area/construction/solars
	name = "\improper Solar Panels"
	icon_state = "yellow"

/area/construction/solarscontrol
	name = "\improper Solar Panel Control"
	icon_state = "yellow"

/area/construction/Storage
	name = "Construction Site Storage"
	icon_state = "yellow"


//GAYBAR
/area/secret/gaybar
	name = "\improper Dance Bar"
	icon_state = "dancebar"


//Traitor Station
/area/traitor
	name = "\improper Syndicate Base"
	icon_state = "syndie_hall"
	report_alerts = FALSE

/area/traitor/rnd
	name = "\improper Syndicate Research and Development"
	icon_state = "syndie_rnd"

/area/traitor/chem
	name = "\improper Syndicate Chemistry"
	icon_state = "syndie_chem"

/area/traitor/tox
	name = "\improper Syndicate Toxins"
	icon_state = "syndie_tox"

/area/traitor/atmos
	name = "\improper Syndicate Atmos"
	icon_state = "syndie_atmo"

/area/traitor/inter
	name = "\improper Syndicate Interrogation"
	icon_state = "syndie_inter"

/area/traitor/radio
	name = "\improper Syndicate Eavesdropping Booth"
	icon_state = "syndie_radio"

/area/traitor/surgery
	name = "\improper Syndicate Surgery Theatre"
	icon_state = "syndie_surgery"

/area/traitor/hall
	name = "\improper Syndicate Station"
	icon_state = "syndie_hall"

/area/traitor/kitchen
	name = "\improper Syndicate Kitchen"
	icon_state = "syndie_kitchen"

/area/traitor/empty
	name = "\improper Syndicate Project Room"
	icon_state = "syndie_empty"


//AI
/area/ai_monitored
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambientsounds = HIGHSEC_SOUNDS

/area/ai_monitored/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/ai_monitored/storage/emergency
	name = "Emergency Storage"
	icon_state = "storage"

/area/turret_protected/
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

/area/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/turret_protected/ai_upload_foyer
	name = "AI Upload Access"
	icon_state = "ai_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"

/area/turret_protected/aisat
	name = "\improper AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/aisat
	name = "\improper AI Satellite Exterior"
	icon_state = "yellow"

/area/aisat/entrance
	name = "\improper AI Satellite Entrance"
	icon_state = "ai_foyer"

/area/aisat/maintenance
	name = "\improper AI Satellite Maintenance"
	icon_state = "storage"

/area/turret_protected/aisat_interior
	name = "\improper AI Satellite Antechamber"
	icon_state = "ai"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED


//Misc

/area/wreck/ai
	name = "\improper AI Chamber"
	icon_state = "ai"

/area/wreck/main
	name = "\improper Wreck"
	icon_state = "storage"

/area/wreck/engineering
	name = "\improper Power Room"
	icon_state = "engine"

/area/wreck/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/generic
	name = "Unknown"
	icon_state = "storage"



// Telecommunications Satellite

/area/tcommsat
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')

/area/tcommsat/chamber
	name = "\improper Telecoms Central Compartment"
	icon_state = "tcomsatcham"

// These areas are needed for MetaStation's AI sat
/area/turret_protected/tcomsat
	name = "\improper Telecoms Satellite"
	icon_state = "tcomsatlob"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomfoyer
	name = "\improper Telecoms Foyer"
	icon_state = "tcomsatentrance"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomwest
	name = "\improper Telecoms West Wing"
	icon_state = "tcomsatwest"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomeast
	name = "\improper Telecoms East Wing"
	icon_state = "tcomsateast"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/tcommsat/computer
	name = "\improper Telecoms Control Room"
	icon_state = "tcomsatcomp"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/tcommsat/server
	name = "\improper Telecoms Server Room"
	icon_state = "tcomsatcham"

/area/tcommsat/lounge
	name = "\improper Telecoms Lounge"
	icon_state = "tcomsatlounge"

/area/tcommsat/powercontrol
	name = "\improper Telecoms Power Control"
	icon_state = "tcomsatwest"

// Away Missions
/area/awaymission
	name = "\improper Strange Location"
	icon_state = "away"
	report_alerts = FALSE
	ambientsounds = AWAY_MISSION_SOUNDS
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/example
	name = "\improper Strange Station"
	icon_state = "away"

/area/awaymission/desert
	name = "Mars"
	icon_state = "away"

/area/awaymission/beach
	name = "Beach"
	icon_state = "beach"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	requires_power = FALSE
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/ambiodd.ogg', 'sound/ambience/ambinice.ogg')

/area/awaymission/undersea
	name = "Undersea"
	icon_state = "undersea"


////////////////////////AWAY AREAS///////////////////////////////////

/area/awaycontent
	name = "space"
	report_alerts = FALSE

/area/awaycontent/a1
	icon_state = "awaycontent1"

/area/awaycontent/a2
	icon_state = "awaycontent2"

/area/awaycontent/a3
	icon_state = "awaycontent3"

/area/awaycontent/a4
	icon_state = "awaycontent4"

/area/awaycontent/a5
	icon_state = "awaycontent5"

/area/awaycontent/a6
	icon_state = "awaycontent6"

/area/awaycontent/a7
	icon_state = "awaycontent7"

/area/awaycontent/a8
	icon_state = "awaycontent8"

/area/awaycontent/a9
	icon_state = "awaycontent9"

/area/awaycontent/a10
	icon_state = "awaycontent10"

/area/awaycontent/a11
	icon_state = "awaycontent11"

/area/awaycontent/a11
	icon_state = "awaycontent12"

/area/awaycontent/a12
	icon_state = "awaycontent13"

/area/awaycontent/a13
	icon_state = "awaycontent14"

/area/awaycontent/a14
	icon_state = "awaycontent14"

/area/awaycontent/a15
	icon_state = "awaycontent15"

/area/awaycontent/a16
	icon_state = "awaycontent16"

/area/awaycontent/a17
	icon_state = "awaycontent17"

/area/awaycontent/a18
	icon_state = "awaycontent18"

/area/awaycontent/a19
	icon_state = "awaycontent19"

/area/awaycontent/a20
	icon_state = "awaycontent20"

/area/awaycontent/a21
	icon_state = "awaycontent21"

/area/awaycontent/a22
	icon_state = "awaycontent22"

/area/awaycontent/a23
	icon_state = "awaycontent23"

/area/awaycontent/a24
	icon_state = "awaycontent24"

/area/awaycontent/a25
	icon_state = "awaycontent25"

/area/awaycontent/a26
	icon_state = "awaycontent26"

/area/awaycontent/a27
	icon_state = "awaycontent27"

/area/awaycontent/a28
	icon_state = "awaycontent28"

/area/awaycontent/a29
	icon_state = "awaycontent29"

/area/awaycontent/a30
	icon_state = "awaycontent30"

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
	/area/atmos,
	/area/maintenance,
	/area/hallway,
	/area/hallway/primary/fore,
	/area/hallway/primary/starboard,
	/area/hallway/primary/aft,
	/area/hallway/primary/port,
	/area/hallway/primary/central,
	/area/bridge,
	/area/crew_quarters,
	/area/civilian,
	/area/holodeck,
	/area/library,
	/area/chapel,
	/area/escapepodbay,
	/area/lawoffice,
	/area/magistrateoffice,
	/area/clownoffice,
	/area/mimeoffice,
	/area/engine,
	/area/solar,
	/area/assembly,
	/area/teleporter,
	/area/medical,
	/area/security,
	/area/quartermaster,
	/area/janitor,
	/area/hydroponics,
	/area/toxins,
	/area/storage,
	/area/construction,
	/area/ai_monitored/storage/eva, //do not try to simplify to "/area/ai_monitored" --rastaf0
	/area/ai_monitored/storage/secure,
	/area/ai_monitored/storage/emergency,
	/area/turret_protected/ai_upload, //do not try to simplify to "/area/turret_protected" --rastaf0
	/area/turret_protected/ai_upload_foyer,
	/area/turret_protected/ai,
	))
