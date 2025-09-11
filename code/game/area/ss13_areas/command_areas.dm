
//Command

/area/station/command/bridge
	name = "Мостик"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_STANDARD_STATION
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_announces = TRUE

/area/station/command/meeting_room
	name = "Конференц-Зал Командования"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Bridge"
	request_console_announces = TRUE

/area/station/command/office/captain
	name = "Офис Капитана"
	icon_state = "captainoffice"
	sound_environment = SOUND_AREA_WOODFLOOR
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Captain's Desk"
	request_console_announces = TRUE

/area/station/command/office/captain/bedroom
	name = "Каюта Капитана"
	icon_state = "captain"

/area/station/command/office/hop
	name = "Кабинет Главы Персонала"
	icon_state = "hop"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Head of Personnel's Desk"
	request_console_announces = TRUE

/area/station/command/office/rd
	name = "Кабинет Директора Исследований"
	icon_state = "rd"
	request_console_flags = RC_ASSIST | RC_SUPPLY | RC_INFO
	request_console_name = "Research Director's Desk"
	request_console_announces = TRUE

/area/station/command/office/ce
	name = "Кабинет Главного Инженера"
	icon_state = "ce"
	request_console_flags = RC_ASSIST | RC_SUPPLY | RC_INFO
	request_console_name = "Chief Engineer's Desk"
	request_console_announces = TRUE

/area/station/command/office/hos
	name = "Кабинет Главы Службы Безопасности"
	icon_state = "hos"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Head of Security's Desk"
	request_console_announces = TRUE

/area/station/command/office/cmo
	name = "Кабинет Главного Врача"
	icon_state = "CMO"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Chief Medical Officer's Desk"
	request_console_announces = TRUE

/area/station/command/office/ntrep
	name = "Кабинет Представителя НТ"
	icon_state = "ntrep"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "NT Representative"
	request_console_announces = TRUE

/area/station/command/office/blueshield
	name = "Кабинет Синего Щита"
	icon_state = "blueshield"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Blueshield"
	request_console_announces = TRUE

/area/station/command/teleporter
	name = "Телепортерная"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS

/area/station/command/vault
	name = "Хранилище"
	icon_state = "nuke_storage"

/area/station/command/server
	name = "Серверная Комната Обработки Сообщений"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/command/customs
	name = "Контрольно-Пропускной Пункт Командования"
	icon_state = "checkpoint1"
