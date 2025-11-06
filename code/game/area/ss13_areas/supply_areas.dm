
/area/station/supply
	name = "\improper Quartermasters"
	icon_state = "quart"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_wires = /datum/wires/airlock/cargo

/area/station/supply/lobby
	name = "\improper Cargo Lobby"
	icon_state = "cargolobby"

/area/station/supply/sorting
	name = "\improper Delivery Office"
	icon_state = "cargomail"
	request_console_flags = RC_SUPPLY
	request_console_name = "Cargo Bay"

/area/station/supply/office
	name = "\improper Cargo Office"
	icon_state = "cargooffice"
	request_console_flags = RC_SUPPLY
	request_console_name = "Cargo Bay"

/area/station/supply/warehouse
	name = "\improper Cargo Warehouse"
	icon_state = "cargowarehouse"

/area/station/supply/break_room
	name = "\improper Cargo Breakroom"
	icon_state = "cargobreak"

/area/station/supply/storage
	name = "\improper Cargo Bay"
	icon_state = "cargobay"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	request_console_flags = RC_SUPPLY

/area/station/supply/smith_office
	name = "Smith's Office"
	icon_state = "smith"

// this should really be command/office/cmo
/area/station/supply/qm
	name = "\improper Quartermaster's Office"
	icon_state = "qm"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Quartermaster's Desk"
	request_console_announces = TRUE
	airlock_wires = /datum/wires/airlock/command

/area/station/supply/miningdock
	name = "\improper Mining Dock"
	icon_state = "mining"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Mining"

/area/station/supply/expedition
	name = "\improper Expedition Room"
	icon_state = "expedition"
	ambientsounds = list('sound/ambience/ambiexp.ogg')
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Expedition"
