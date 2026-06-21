GLOBAL_LIST_INIT(ruin_prototypes, list(/area/ruin,
										/area/ruin/unpowered,
										/area/ruin/powered,
										/area/ruin/space,
										/area/ruin/space/powered,
										/area/ruin/space/unpowered,
										/area/ruin/space/unpowered/no_grav))

//Parent types

/area/ruin
	name = "\improper Unexplored Location"
	icon_state = "away"
	there_can_be_many = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambientsounds = RUINS_SOUNDS
	sound_environment = SOUND_ENVIRONMENT_STONEROOM
	airlock_wires = ZLVL_BASED_WIRES

/area/ruin/unpowered

/area/ruin/powered
	requires_power = FALSE

