// Asteroids

/// -- TLE
/area/asteroid
	name = "\improper Asteroid"
	icon_state = "asteroid"
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambientsounds = MINING_SOUNDS
	sound_environment = SOUND_AREA_ASTEROID
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/// -- TLE
/area/asteroid/cave
	name = "\improper Asteroid - Underground"
	icon_state = "cave"
	requires_power = FALSE
	outdoors = TRUE

/area/asteroid/artifactroom
	name = "\improper Asteroid - Artifact"
	icon_state = "cave"

//Labor camp
/area/mine/laborcamp
	name = "Labor Camp"
	icon_state = "brig"

/area/mine/laborcamp/security
	name = "Labor Camp Security"
	icon_state = "security"
