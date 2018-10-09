/**********************Mine areas**************************/

/area/mine
	icon_state = "mining"

/area/mine/dangerous/explored
	name = "Mine"
	icon_state = "explored"
	music = null
	always_unpowered = TRUE
	requires_power = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	ambientsounds = MINING

/area/mine/dangerous/unexplored
	name = "Mine"
	icon_state = "unexplored"
	music = null
	always_unpowered = TRUE
	requires_power = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	ambientsounds = MINING

/area/mine/lobby
	name = "Mining Station"

/area/mine/storage
	name = "Mining Station Storage"

/area/mine/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"

/area/mine/abandoned
	name = "Abandoned Mining Station"

/area/mine/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

/area/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

/area/mine/maintenance
	name = "Mining Station Communications"

/area/mine/cafeteria
	name = "Mining Station Cafeteria"

/area/mine/hydroponics
	name = "Mining Station Hydroponics"

/area/mine/sleeper
	name = "Mining Station Emergency Sleeper"

/area/mine/north_outpost
	name = "North Mining Outpost"

/area/mine/west_outpost
	name = "West Mining Outpost"

/area/mine/podbay
	name = "Mining Podbay"
