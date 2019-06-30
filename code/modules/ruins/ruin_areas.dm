//Parent types

/area/ruin
	name = "\improper Unexplored Location"
	icon_state = "away"
	has_gravity = TRUE
	there_can_be_many = TRUE
	ambientsounds = list('sound/ambience/ambimine.ogg')
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

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
	name = "Bridge"
	icon_state = "bridge"
