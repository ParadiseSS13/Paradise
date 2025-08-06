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

/area/centcom/docks
	name = "\improper Central Command Docks"

// Admin areas

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

//EXTRA

/area/tdome
	name = "\improper Thunderdome"
	icon_state = "thunder"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	hide_attacklogs = TRUE


/area/tdome/arena_source
	name = "\improper Thunderdome Arena Template"

/area/tdome/arena
	name = "\improper Thunderdome Arena"

/area/tdome/tdomeadmin
	name = "\improper Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "\improper Thunderdome (Observer.)"
	icon_state = "purple"

// Other Areas on centcom z level

/area/abductor_ship
	name = "\improper Abductor Ship"
	icon_state = "yellow"
	requires_power = FALSE

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
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/ninja/outpost
	name = "\improper SpiderClan Outpost"

/area/ninja/holding
	name = "\improper SpiderClan Holding Facility"

/area/trader_station
	name = "Trade Base"
	icon_state = "yellow"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/trader_station/sol
	name = "Trading Satellite"

/area/ghost_bar
	name = "Ghost Bar"
	icon_state = "observatory"
	requires_power = FALSE
	hide_attacklogs = TRUE

/area/backrooms
	name = "Backrooms"
	icon_state = "yellow"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
