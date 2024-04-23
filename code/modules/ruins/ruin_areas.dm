//Parent types

/area/ruin
	name = "\improper Unexplored Location"
	icon_state = "away"
	has_gravity = TRUE
	there_can_be_many = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambientsounds = RUINS_SOUNDS
	sound_environment = SOUND_ENVIRONMENT_STONEROOM

/area/ruin/unpowered
	always_unpowered = FALSE

/area/ruin/unpowered/no_grav
	has_gravity = FALSE

/area/ruin/powered
	requires_power = FALSE

