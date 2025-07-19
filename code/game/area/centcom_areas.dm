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
	icon_state = "centcom"

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
	name = "Тандердом"
	icon_state = "thunder"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	hide_attacklogs = TRUE


/area/tdome/arena_source
	name = "Тандердом - Шаблон Арены"
	icon_state = "thunder"

/area/tdome/arena
	name = "Тандердом - Арена"
	icon_state = "thunder"

/area/tdome/tdomeadmin
	name = "Тандердом - Комната Управления"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "Тандердом - Трибуны"
	icon_state = "purple"

// Other Areas on centcom z level

/area/abductor_ship
	name = "Корабль Абдукторов"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = TRUE

/area/wizard_station
	name = "Логово Волшебника"
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
	name = "Аванпост Клана Паука"

/area/ninja/holding
	name = "Убежище Клана Паука"

/area/trader_station
	name = "Торговая Станция"
	icon_state = "yellow"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/trader_station/sol
	name = "Торговая Станция ТСФ"

/area/ghost_bar
	name = "Призрачный Бар"
	icon_state = "observatory"
	requires_power = FALSE
	has_gravity = TRUE
	hide_attacklogs = TRUE

/area/backrooms
	name = "Закулисье"
	icon_state = "yellow"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
