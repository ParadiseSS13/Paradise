
/area/station/supply
	name = "Квартирмейстер"
	icon_state = "quart"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/supply/lobby
	name = "Лобби Карго"
	icon_state = "cargolobby"

/area/station/supply/sorting
	name = "Офис Доставки"
	icon_state = "cargomail"
	sound_environment = SOUND_AREA_STANDARD_STATION
	request_console_flags = RC_SUPPLY
	request_console_name = "Cargo Bay"

/area/station/supply/office
	name = "Офис Карго"
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
	name = "Грузовой Отсек"
	icon_state = "cargobay"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	request_console_flags = RC_SUPPLY

/area/station/supply/qm
	name = "Офис Квартирмейстера"
	icon_state = "qm"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Quartermaster's Desk"
	request_console_announces = TRUE

/area/station/supply/miningdock
	name = "Шахтный Док"
	icon_state = "mining"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Mining"

/area/station/supply/expedition
	name = "Комната Экспедиции"
	icon_state = "expedition"
	ambientsounds = list('sound/ambience/ambiexp.ogg')
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Expedition"
