/obj/structure/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	max_integrity = 500
	armor = list(MELEE = 100, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 70) //default + ignores melee

/obj/structure/shuttle/engine
	name = "engine"
	density = TRUE
	anchored = TRUE

/obj/structure/shuttle/engine/heater
	name = "heater"
	icon_state = "heater"

/obj/structure/shuttle/engine/platform
	name = "platform"
	icon_state = "platform"

/obj/structure/shuttle/engine/propulsion
	name = "propulsion"
	icon_state = "propulsion"
	opacity = TRUE

/obj/structure/shuttle/engine/propulsion/burst

/obj/structure/shuttle/engine/propulsion/burst/left
	icon_state = "burst_l"

/obj/structure/shuttle/engine/propulsion/burst/right
	icon_state = "burst_r"

/obj/structure/shuttle/engine/router
	name = "router"
	icon_state = "router"
