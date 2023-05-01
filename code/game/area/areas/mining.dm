/**********************Mine areas**************************/

/area/mine
	icon_state = "mining"
	has_gravity = TRUE
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/mine/explored
	name = "Mine"
	icon_state = "explored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	ambientsounds = MINING_SOUNDS
	flags = NONE

/area/mine/dangerous/explored/golem
	name = "Small Asteroid"

/area/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	ambientsounds = MINING_SOUNDS
	flags = NONE

/area/mine/unexplored/cere
	sound_environment = SOUND_AREA_ASTEROID

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

/area/mine/lobby
	name = "Mining Station"

/area/mine/storage
	name = "Mining Station Storage"

/area/mine/production
	name = "Mining Station Production Wing"
	icon_state = "mining_production"

/area/mine/abandoned
	name = "Abandoned Mining Station"

/area/mine/living_quarters
	name = "Mining Station Living Wing"
	icon_state = "mining_living"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

/area/mine/maintenance
	name = "Mining Station Communications"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/mine/cafeteria
	name = "Mining station Cafeteria"

/area/mine/hydroponics
	name = "Mining station Hydroponics"

/area/mine/sleeper
	name = "Mining station Emergency Sleeper"

/area/mine/north_outpost
	name = "North Mining Outpost"

/area/mine/west_outpost
	name = "West Mining Outpost"

/area/mine/laborcamp
	name = "Labor Camp"

/area/mine/laborcamp/security
	name = "Labor Camp Security"
	icon_state = "security"
	ambientsounds = HIGHSEC_SOUNDS

/area/mine/podbay
	name = "Mining Podbay"



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
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	ambientsounds = MINING_SOUNDS

/area/lavaland/underground
	name = "Lavaland Caves"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	ambientsounds = MINING_SOUNDS

/area/lavaland/surface/outdoors
	name = "Lavaland Wastes"
	outdoors = TRUE

/area/lavaland/surface/outdoors/unexplored //monsters and ruins spawn here
	icon_state = "unexplored"

/area/lavaland/surface/outdoors/unexplored/danger //megafauna will also spawn here
	icon_state = "cave"

/area/lavaland/surface/outdoors/explored
	name = "Lavaland Labor Camp"

/area/lavaland/surface/outdoors/necropolis
	name = "Necropolis"
	icon_state = "unexplored"
	tele_proof = TRUE
