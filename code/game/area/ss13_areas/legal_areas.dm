/area/station/legal
	airlock_wires = /datum/wires/airlock/security

/area/station/legal/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/legal/courtroom/gallery
	name = "\improper Courtroom Gallery"
	request_console_name = "Courtroom"

/area/station/legal/lawoffice
	name = "\improper Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	request_console_name = "Internal Affairs Office"

/area/station/legal/magistrate
	name = "\improper Magistrate's Office"
	icon_state = "magistrate"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Magistrate"
