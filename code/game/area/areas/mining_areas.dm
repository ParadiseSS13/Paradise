/**********************Mine areas**************************/

/area/mine
	icon_state = "mining"
	has_gravity = TRUE

/area/mine/explored
	name = "Mine"
	icon_state = "explored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	apc_starts_off = TRUE
	outdoors = TRUE
	ambientsounds = MINING_SOUNDS
	flags = NONE
	sound_environment = SOUND_AREA_STANDARD_STATION
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/mine/dangerous/explored/golem
	name = "Small Asteroid"

/area/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	apc_starts_off = TRUE
	outdoors = TRUE
	ambientsounds = MINING_SOUNDS
	sound_environment = SOUND_AREA_ASTEROID
	flags = NONE
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/mine/unexplored/cere/ai
	name = "AI Asteroid"

/area/mine/unexplored/cere/cargo
	name = "Cargo Asteroid"

/area/mine/unexplored/cere/civilian
	name = "Civilian Asteroid"

/area/mine/unexplored/cere/command
	name = "Command Asteroid"

/area/mine/unexplored/cere/docking
	name = "Docking Asteroid"

/area/mine/unexplored/cere/engineering
	name = "Engineering Asteroid"

/area/mine/unexplored/cere/medical
	name = "Medical Asteroid"

/area/mine/unexplored/cere/research
	name = "Research Asteroid"

/area/mine/unexplored/cere/orbiting
	name = "Near Station Asteroids"

/**********************Outpost areas**************************/

/area/mine/outpost
	name = "Mining Station"
	icon_state = "mining"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/mine/outpost/airlock
	name = "Mining Station Airlock"
	icon_state = "mining_eva"

/area/mine/outpost/cafeteria
	name = "Mining Station Cafeteria"
	icon_state = "mining_living"

/// subtype of /surface so storms hit there
/area/lavaland/surface/outdoors/outpost/catwalk
	name = "Mining Station Catwalk"
	icon_state = "mining"

/area/mine/outpost/comms
	name = "Mining Station Communications"
	icon_state = "tcomms"

/area/mine/outpost/custodial
	name = "Mining Station Custodial Storage"
	icon_state = "janitor"

/// basically engi and atmos combined. I'm keeping it as "engineering" code wise, but "Life Support" sounds cooler in-game
/area/mine/outpost/engineering
	name = "Mining Station Life Support"
	icon_state = "engi"

/area/mine/outpost/hallway
	name = "Mining Station Central Wing"
	icon_state = "hallC"

/area/mine/outpost/hallway/east
	name = "Mining Station East Wing"
	icon_state = "hallS"

/area/mine/outpost/hallway/west
	name = "Mining Station West Wing"
	icon_state = "hallP"

/area/mine/outpost/lockers
	name = "Mining Station Locker Room"
	icon_state = "locker"

/area/mine/outpost/storage
	name = "Mining Station Storage"
	icon_state = "storage"

/area/mine/outpost/maintenance
	name = "Mining Station Maintenance"
	icon_state = "maintcentral"

/area/mine/outpost/maintenance/south
	name = "Mining Station South Maintenance"
	icon_state = "amaint"

/area/mine/outpost/maintenance/east
	name = "Mining Station East Maintenance"
	icon_state = "smaint"

/area/mine/outpost/medbay
	name = "Mining Station Infirmary"
	icon_state = "medbay"

/area/mine/outpost/mechbay
	name = "Mining Station Mechbay"
	icon_state = "mechbay"

/area/mine/outpost/production
	name = "Mining Station Production Room"
	icon_state = "mining_production"

/area/mine/outpost/quartermaster
	name = "Mining Station Quartermaster's Office"
	icon_state = "qm"

/area/mine/laborcamp
	name = "Labor Camp"
	icon_state = "brig"

/area/mine/laborcamp/security
	name = "Labor Camp Security"
	icon_state = "security"
	ambientsounds = HIGHSEC_SOUNDS


/**********************Lavaland Areas**************************/

/area/lavaland
	icon_state = "mining"
	has_gravity = TRUE
	sound_environment = SOUND_AREA_LAVALAND

/area/lavaland/surface
	name = "Lavaland"
	icon_state = "explored"
	always_unpowered = TRUE
	poweralm = FALSE
	apc_starts_off = TRUE
	requires_power = TRUE
	ambientsounds = MINING_SOUNDS
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/lavaland/underground
	name = "Lavaland Caves"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	apc_starts_off = TRUE
	ambientsounds = MINING_SOUNDS
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/lavaland/surface/outdoors
	name = "Lavaland Wastes"
	outdoors = TRUE

/// monsters and ruins spawn here
/area/lavaland/surface/outdoors/unexplored
	icon_state = "unexplored"

/// megafauna will also spawn here
/area/lavaland/surface/outdoors/unexplored/danger
	icon_state = "danger"

/area/lavaland/surface/outdoors/explored
	name = "Lavaland Labor Camp"
