/// Station side

/area/station/cargo/bitrunning
	name = "Bitrunning"

/area/station/cargo/bitrunning/den
	name = "Bitrunning Den"
	desc = "Office of bitrunners, houses their equipment."
	icon_state = "bit_den"

/// VDOM

/area/virtual_domain
	name = "Virtual Domain Ruins"
	icon_state = "bit_ruin"
	icon = 'icons/area/areas_station.dmi'
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING
	default_gravity = STANDARD_GRAVITY
	requires_power = FALSE

/area/virtual_domain/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/// Safehouse

/area/virtual_domain/safehouse
	name = "Virtual Domain Safehouse"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | VIRTUAL_SAFE_AREA | UNLIMITED_FISHING
	icon_state = "bit_safe"
	requires_power = FALSE
	sound_environment = SOUND_ENVIRONMENT_ROOM

/// Custom subtypes

/area/lavaland/surface/outdoors/virtual_domain
	name = "Virtual Domain Lava Ruins"
	icon_state = "bit_ruin"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING

/area/icemoon/underground/explored/virtual_domain
	name = "Virtual Domain Ice Ruins"
	icon_state = "bit_ice"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING

/area/ruin/space/virtual_domain
	name = "Virtual Domain Unexplored Location"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "bit_ruin"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING

/area/space/virtual_domain
	name = "Virtual Domain Space"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "bit_space"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING

///Areas that virtual entities should not be in

/area/virtual_domain/protected_space
	name = "Virtual Domain Safe Zone"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | VIRTUAL_SAFE_AREA | UNLIMITED_FISHING
	icon_state = "bit_safe"

/area/virtual_domain/protected_space/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255
