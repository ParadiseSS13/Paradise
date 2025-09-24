/area/station/service
	airlock_wires = /datum/wires/airlock/service

/area/station/service/cafeteria
	name = "\improper Cafe"
	icon_state = "cafeteria"


/area/station/service/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"
	request_console_flags = RC_SUPPLY

/area/station/service/bar
	name = "\improper Bar"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR
	request_console_flags = RC_SUPPLY

/area/station/service/theatre
	name = "\improper Theatre"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR


/area/station/service/library
	name = "\improper Library"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	request_console_flags = RC_SUPPLY

/area/station/service/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	ambientsounds = HOLY_SOUNDS
	is_haunted = TRUE
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	valid_territory = FALSE
	request_console_flags = RC_SUPPLY

/area/station/service/chapel/funeral
	name = "\improper Funeral Services"
	sound_environment = SOUND_AREA_STANDARD_STATION
	valid_territory = TRUE

/area/station/service/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"
	request_console_name = "Chapel"

/area/station/service/clown
	name = "\improper Clown's Office"
	icon_state = "clown_office"

/area/station/service/clown/secret
	name = "\improper Top Secret Clown HQ"

/area/station/service/mime
	name = "\improper Mime's Office"
	icon_state = "mime_office"

/area/station/service/barber
	name = "\improper Barber Shop"
	icon_state = "barber"

/area/station/service/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST
	request_console_name = "Janitorial"

/area/station/service/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION
	request_console_flags = RC_SUPPLY
