/area/station/service/cafeteria
	name = "Кафетерий"
	icon_state = "cafeteria"


/area/station/service/kitchen
	name = "Кухня"
	icon_state = "kitchen"
	request_console_flags = RC_SUPPLY

/area/station/service/bar
	name = "Бар"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR
	request_console_flags = RC_SUPPLY

/area/station/service/theatre
	name = "Театр"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR


/area/station/service/library
	name = "Библиотека"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	request_console_flags = RC_SUPPLY

/area/station/service/chapel
	name = "Церковь"
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
	name = "Офис Священника"
	icon_state = "chapeloffice"
	request_console_flags = RC_SUPPLY
	request_console_name = "Chapel"

/area/station/service/clown
	name = "Офис Клоуна"
	icon_state = "clown_office"

/area/station/service/clown/secret
	name = "Сверхсекретная Штаб-Квартира Клоуна"

/area/station/service/mime
	name = "Офис Мима"
	icon_state = "mime_office"

/area/station/service/barber
	name = "Парикмахерская"
	icon_state = "barber"

/area/station/service/janitor
	name = "Каморка Уборщика"
	icon_state = "janitor"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST
	request_console_name = "Janitorial"

/area/station/service/hydroponics
	name = "Гидропоника"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION
	request_console_flags = RC_SUPPLY
