
//Command

/area/station/command
	airlock_wires = /datum/wires/airlock/command

/area/station/command/bridge
	name = "\improper Bridge"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_STANDARD_STATION
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_announces = TRUE

/area/station/command/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Bridge"
	request_console_announces = TRUE

/area/station/command/office/captain
	name = "\improper Captain's Office"
	icon_state = "captainoffice"
	sound_environment = SOUND_AREA_WOODFLOOR
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Captain's Desk"
	request_console_announces = TRUE

/area/station/command/office/captain/bedroom
	name = "\improper Captain's Bedroom"
	icon_state = "captain"

/area/station/command/office/hop
	name = "\improper Head of Personnel's Quarters"
	icon_state = "hop"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Head of Personnel's Desk"
	request_console_announces = TRUE

/area/station/command/office/rd
	name = "\improper Research Director's Quarters"
	icon_state = "rd"
	request_console_flags = RC_ASSIST | RC_SUPPLY | RC_INFO
	request_console_name = "Research Director's Desk"
	request_console_announces = TRUE

/area/station/command/office/ce
	name = "\improper Chief Engineer's Quarters"
	icon_state = "ce"
	request_console_flags = RC_ASSIST | RC_SUPPLY | RC_INFO
	request_console_name = "Chief Engineer's Desk"
	request_console_announces = TRUE

/area/station/command/office/hos
	name = "\improper Head of Security's Quarters"
	icon_state = "hos"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Head of Security's Desk"
	request_console_announces = TRUE

/area/station/command/office/cmo
	name = "\improper Chief Medical Officer's Quarters"
	icon_state = "CMO"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Chief Medical Officer's Desk"
	request_console_announces = TRUE

/area/station/command/office/ntrep
	name = "\improper Nanotrasen Representative's Office"
	icon_state = "ntrep"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "NT Representative"
	request_console_announces = TRUE

/area/station/command/office/blueshield
	name = "\improper Blueshield's Office"
	icon_state = "blueshield"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Blueshield"
	request_console_announces = TRUE

/area/station/command/teleporter
	name = "\improper Teleporter"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS

/area/station/command/vault
	name = "\improper Vault"
	icon_state = "nuke_storage"

/area/station/command/server
	name = "\improper Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/command/customs
	name = "Customs"
	icon_state = "checkpoint1"
