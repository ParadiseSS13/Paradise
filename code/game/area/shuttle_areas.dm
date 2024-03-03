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

/area/shuttle/arrival/pre_game
	icon_state = "shuttle2"

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

/area/shuttle/escape_pod1
	name = "\improper Escape Pod One"
	nad_allowed = TRUE

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod2
	name = "\improper Escape Pod Two"
	nad_allowed = TRUE

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod3
	name = "\improper Escape Pod Three"
	nad_allowed = TRUE

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"

/// Pod 4 was lost to meteors
/area/shuttle/escape_pod5
	name = "\improper Escape Pod Five"
	nad_allowed = TRUE

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"

/area/shuttle/mining
	name = "\improper Mining Shuttle"
	icon_state = "shuttle"

/area/shuttle/transport
	icon_state = "shuttle"
	name = "\improper Transport Shuttle"
	parallax_move_direction = EAST

/area/shuttle/transport1
	icon_state = "shuttle"
	name = "\improper Transport Shuttle"

/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Base"
	requires_power = 1

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Mine"
	requires_power = 1

/area/shuttle/gamma/space
	icon_state = "shuttle"
	name = "\improper Gamma Armory"

/area/shuttle/gamma/station
	icon_state = "shuttle"
	name = "\improper Gamma Armory Station"

/area/shuttle/prison/
	name = "\improper Prison Shuttle"

/area/shuttle/prison/station
	icon_state = "shuttle"

/area/shuttle/prison/prison
	icon_state = "shuttle2"

/area/shuttle/siberia
	name = "\improper Labor Camp Shuttle"
	icon_state = "shuttle"

/area/shuttle/specops
	name = "\improper Special Ops Shuttle"
	icon_state = "shuttlered"
	parallax_move_direction = EAST

/area/shuttle/specops/centcom
	name = "\improper Special Ops Shuttle"
	icon_state = "shuttlered"

/area/shuttle/specops/station
	name = "\improper Special Ops Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite
	name = "\improper Syndicate Elite Shuttle"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_move_direction = SOUTH

/area/shuttle/syndicate_elite/mothership
	name = "\improper Syndicate Elite Shuttle"
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	name = "\improper Syndicate Elite Shuttle"
	icon_state = "shuttlered2"

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
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "\improper Nanotrasen Vessel"
	icon_state = "shuttlered2"

/area/shuttle/thunderdome
	name = "honk"

/area/shuttle/thunderdome/grnshuttle
	name = "\improper Thunderdome GRN Shuttle"
	icon_state = "green"

/area/shuttle/thunderdome/grnshuttle/dome
	name = "\improper GRN Shuttle"
	icon_state = "shuttlegrn"

/area/shuttle/thunderdome/grnshuttle/station
	name = "\improper GRN Station"
	icon_state = "shuttlegrn2"

/area/shuttle/thunderdome/redshuttle
	name = "\improper Thunderdome RED Shuttle"
	icon_state = "red"

/area/shuttle/thunderdome/redshuttle/dome
	name = "\improper RED Shuttle"
	icon_state = "shuttlered"

/area/shuttle/thunderdome/redshuttle/station
	name = "\improper RED Station"
	icon_state = "shuttlered2"
// === Trying to remove these areas:

/area/shuttle/research
	name = "\improper Research Shuttle"
	icon_state = "shuttle"

/area/shuttle/research/station
	icon_state = "shuttle2"

/area/shuttle/research/outpost
	icon_state = "shuttle"

/area/shuttle/supply
	name = "Supply Shuttle"
	icon_state = "shuttle3"

/area/shuttle/abandoned
	name = "Abandoned Ship"
	icon_state = "shuttle"

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

/area/shuttle/derelict/ship/start
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/shuttle/derelict/ship/transit
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/shuttle/derelict/ship/engipost
	name = "\improper Engineering Outpost"
	icon_state = "yellow"

/area/shuttle/derelict/ship/station
	name = "\improper North of SS13"
	icon_state = "yellow"
