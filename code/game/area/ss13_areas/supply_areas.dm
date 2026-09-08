
/area/station/supply
	name = "\improper Quartermasters"
	icon_state = "quart"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_wires = /datum/wires/airlock/cargo
	area_icon_color = AREA_COLOR_SUPPLY
	area_light_color = LIGHT_COLOR_STATION_WORK
	area_nightlight_color = LIGHT_COLOR_STATION_WORK_NIGHT

/area/station/supply/lobby
	name = "\improper Cargo Lobby"
	icon_state = "cargolobby"
	area_icon_text = "CARGO\nLOBBY"

/area/station/supply/sorting
	name = "\improper Delivery Office"
	icon_state = "cargomail"
	area_icon_text = "MAIL\nROOM"
	request_console_flags = RC_SUPPLY
	request_console_name = "Cargo Bay"

/area/station/supply/office
	name = "\improper Cargo Office"
	icon_state = "cargooffice"
	area_icon_text = "CARGO\nOFFICE"
	request_console_flags = RC_SUPPLY
	request_console_name = "Cargo Bay"

/area/station/supply/warehouse
	name = "\improper Cargo Warehouse"
	icon_state = "cargowarehouse"
	area_icon_text = "CARGO\nWARE\nHOUSE"

/area/station/supply/break_room
	name = "\improper Cargo Breakroom"
	icon_state = "cargobreak"
	area_icon_text = "CARGO\nBREAK"

/area/station/supply/storage
	name = "\improper Cargo Bay"
	icon_state = "cargobay"
	area_icon_text = "CARGO\nBAY"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	request_console_flags = RC_SUPPLY

/area/station/supply/smith_office
	name = "Smith's Office"
	icon_state = "smith"
	area_icon_text = "SMITH"

// this should really be command/office/cmo
/area/station/supply/qm
	name = "\improper Quartermaster's Office"
	icon_state = "qm"
	area_icon_text = "QM"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Quartermaster's Desk"
	request_console_announces = TRUE
	airlock_wires = /datum/wires/airlock/command

/area/station/supply/miningdock
	name = "\improper Mining Dock"
	icon_state = "mining"
	area_icon_text = "MINING"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Mining"

/area/station/supply/expedition
	name = "\improper Expedition Room"
	icon_state = "expedition"
	area_icon_text = "EXPEDI\nTIONS"
	ambientsounds = list('sound/ambience/ambiexp.ogg')
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Expedition"
