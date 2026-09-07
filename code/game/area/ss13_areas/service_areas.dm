/area/station/service
	airlock_wires = /datum/wires/airlock/service
	area_icon_color = AREA_COLOR_SERVICE
	area_light_color = LIGHT_COLOR_STATION_WORK
	area_nightlight_color = LIGHT_COLOR_STATION_WORK_NIGHT

/area/station/service/cafeteria
	name = "\improper Cafe"
	icon_state = "cafeteria"
	area_icon_text = "CAFE"

/area/station/service/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"
	area_icon_text = "KITCHEN"
	request_console_flags = RC_SUPPLY

/area/station/service/break_room
	name = "\improper Service Break Room"
	icon_state = "servbreak"
	area_icon_text = "SERV\nBREAK"
	request_console_flags = RC_SUPPLY

/area/station/service/kitchen/freezer
	name = "\improper Kitchen Freezer"
	icon_state = "kitchen_freezer"
	area_icon_text = "KITCHEN\nFREEZER"

/area/station/service/kitchen/storage
	name = "\improper Kitchen Storage"
	icon_state = "kitchen_store"
	area_icon_text = "KITCHEN\nSTORE"

/area/station/service/pasture
	name = "\improper Pasture"
	icon_state = "pasture"
	area_icon_text = "PASTURE"

/area/station/service/bar
	name = "\improper Bar"
	icon_state = "bar"
	area_icon_text = "BAR"
	sound_environment = SOUND_AREA_WOODFLOOR
	request_console_flags = RC_SUPPLY

/area/station/service/theatre
	name = "\improper Theatre"
	icon_state = "Theatre"
	area_icon_text = "THEATRE"
	sound_environment = SOUND_AREA_WOODFLOOR


/area/station/service/library
	name = "\improper Library"
	icon_state = "library"
	area_icon_text = "LIBRARY"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	request_console_flags = RC_SUPPLY

/area/station/service/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	area_icon_text = "CHAPEL"
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
	area_icon_text = "CHAPEL\nOFFICE"
	request_console_name = "Chapel"

/area/station/service/clown
	name = "\improper Clown's Office"
	icon_state = "clown_office"
	area_icon_text = "CLOWN"

/area/station/service/clown/secret
	name = "\improper Top Secret Clown HQ"

/area/station/service/mime
	name = "\improper Mime's Office"
	icon_state = "mime_office"
	area_icon_text = "MIME"

/area/station/service/barber
	name = "\improper Barber Shop"
	icon_state = "barber"
	area_icon_text = "BARBER"

/area/station/service/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"
	area_icon_text = "JANI"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST
	request_console_name = "Janitorial"

/area/station/service/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	area_icon_text = "BOTANY"
	sound_environment = SOUND_AREA_STANDARD_STATION
	request_console_flags = RC_SUPPLY
