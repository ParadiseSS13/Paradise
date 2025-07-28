//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle
	no_teleportlocs = TRUE
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	parallax_move_direction = NORTH
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/shuttle/arrival
	name = "\improper Arrival Shuttle"
	parallax_move_direction = EAST

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/auxillary_base
	icon_state = "shuttle"

/area/shuttle/escape
	name = "\improper Emergency Shuttle"
	icon_state = "shuttle2"
	nad_allowed = TRUE

/area/shuttle/pod_1
	name = "\improper Escape Pod One"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_2
	name = "\improper Escape Pod Two"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_3
	name = "\improper Escape Pod Three"
	icon_state = "shuttle"
	nad_allowed = TRUE
	parallax_move_direction = EAST

/area/shuttle/pod_4
	name = "\improper Escape Pod Four"
	icon_state = "shuttle"
	nad_allowed = TRUE
	parallax_move_direction = EAST

/area/shuttle/mining
	name = "\improper Mining Shuttle"
	icon_state = "shuttle"

/area/shuttle/transport
	icon_state = "shuttle"
	name = "\improper Transport Shuttle"
	parallax_move_direction = EAST

/area/shuttle/gamma/space
	icon_state = "shuttle"
	name = "\improper Gamma Armory"

/area/shuttle/gamma/station
	icon_state = "shuttle"
	name = "\improper Gamma Armory Station"

/area/shuttle/siberia
	name = "\improper Labor Camp Shuttle"
	icon_state = "shuttle"

/area/shuttle/specops
	name = "\improper Special Ops Shuttle"
	icon_state = "shuttlered"
	parallax_move_direction = EAST

/area/shuttle/syndicate_elite
	name = "\improper Syndicate Elite Shuttle"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_move_direction = SOUTH

/area/shuttle/syndicate_sit
	name = "\improper Syndicate SIT Shuttle"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_move_direction = SOUTH

/area/shuttle/assault_pod
	name = "Steel Rain"
	icon_state = "shuttle"

/area/shuttle/administration
	name = "\improper Nanotrasen Vessel"
	icon_state = "shuttlered"
	parallax_move_direction = EAST

/area/shuttle/administration/centcom
	name = "\improper Nanotrasen Vessel Centcom"

/area/shuttle/administration/station
	icon_state = "shuttlered2"

// === Trying to remove these areas:

/area/shuttle/supply
	name = "Supply Shuttle"
	icon_state = "shuttle3"

/area/shuttle/abandoned
	name = "Abandoned Ship"
	icon_state = "shuttle"
	parallax_move_direction = WEST

/area/shuttle/syndicate
	name = "Syndicate Nuclear Team Shuttle"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/trade
	name = "Trade Shuttle"
	icon_state = "shuttle"

/area/shuttle/trade/sol
	name = "Sol Freighter"
	parallax_move_direction = EAST

/area/shuttle/freegolem
	name = "Free Golem Ship"
	icon_state = "purple"
	xenobiology_compatible = TRUE
	parallax_move_direction = WEST

/// Currently disabled as our shuttle system does not support TG-shuttle areas yet
// /area/shuttle/transit
// 	name = "Hyperspace"
// 	desc = "Weeeeee"
// 	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
// 	there_can_be_many = TRUE
