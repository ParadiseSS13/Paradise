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

//Areas

/area/ruin/unpowered/no_grav/way_home
	name = "\improper Salvation"
	icon_state = "away"

/area/ruin/powered/snow_biodome

/area/ruin/powered/golem_ship
	name = "Free Golem Ship"

/area/ruin/powered/space_bar
	name = "Space Bar"

/area/ruin/powered/shuttle
	name = "Shuttle"

// Ruins of "onehalf" ship
/area/ruin/onehalf/hallway
	name = "Hallway"
	icon_state = "hallC"

/area/ruin/onehalf/drone_bay
	name = "Mining Drone Bay"
	icon_state = "engine"

/area/ruin/onehalf/dorms_med
	name = "Crew Quarters"
	icon_state = "Sleep"

/area/ruin/onehalf/bridge
	name = "Old Mining Bay Bridge"
	icon_state = "bridge"

// Old tcommsat
/area/ruin/tcommsat
	name = "Telecommunications Satellite"
	icon_state = "tcomsatcham"
