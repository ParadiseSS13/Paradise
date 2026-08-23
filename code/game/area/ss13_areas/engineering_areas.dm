// Atmos
/area/station/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	area_icon_text = "ATMOS"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/engineering/atmos/control
	name = "Atmospherics Control Room"
	icon_state = "atmosctrl"
	area_icon_text = "ATMOS\nCTRL"
	request_console_name = "Atmospherics"

/area/station/engineering/atmos/distribution
	name = "Atmospherics Distribution Loop"

/area/station/engineering/atmos/storage
	name = "Atmospherics Hardsuit Storage"
	icon_state = "atmos_suits"
	area_icon_text = "ATMOS\nSUITS"

/area/station/engineering/atmos/transit
	name = "Atmospherics Transit Tube"
	icon_state = "atmos_transit"
	area_icon_text = "ATMOS\nTUBE"

/area/station/engineering/atmos/asteroid
	name = "Asteroid"
	icon_state = "asteroid"
	area_icon_text = "ASTER\nOID"
	area_icon_color = AREA_COLOR_ENGI_ASTEROID
	sound_environment = SOUND_AREA_SPACE
	apc_starts_off = TRUE

/area/station/engineering/atmos/asteroid_filtering
	name = "Asteroid Filtering"
	icon_state = "asteroid_atmos"
	area_icon_text = "ASTER\nOID\nATMOS"
	area_icon_color = AREA_COLOR_ENGI_ASTEROID

/area/station/engineering/atmos/asteroid_core
	name = "Asteroid Molten Core"
	icon_state = "asteroid_core"
	area_icon_text = "CORE"
	area_icon_color = AREA_COLOR_ENGI_ASTEROID_ATMOS
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	sound_environment = SOUND_AREA_ASTEROID

// general engineering
/area/station/engineering
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	airlock_wires = /datum/wires/airlock/engineering
	area_icon_color = AREA_COLOR_ENGINEERING
	area_light_color = LIGHT_COLOR_STATION_WORK
	area_nightlight_color = LIGHT_COLOR_STATION_WORK_NIGHT

/area/station/engineering/smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"
	area_icon_text = "ENGINE\nSMES"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/station/engineering/control
	name = "Engineering"
	icon_state = "engine_control"
	area_icon_text = "ENGINE\nCTRL"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/engineering/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engibreak"
	area_icon_text = "ENGI\nBREAK"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Engineering"

/area/station/engineering/break_room/secondary
	name = "\improper Secondary Engineering Foyer"

/area/station/engineering/equipmentstorage
	name = "Engineering Equipment Storage"
	icon_state = "engilocker"
	area_icon_text = "ENGI\nLOCKER"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Engineering"

/area/station/engineering/hardsuitstorage
	name = "\improper Engineering Hardsuit Storage"
	icon_state = "engi"
	area_icon_text = "ENGI"
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Engineering"

/area/station/engineering/controlroom
	name = "\improper Engineering Control Room"
	icon_state = "engine_monitoring"
	area_icon_text = "ENGINE\nMNTR"

/area/station/engineering/gravitygenerator
	name = "\improper Gravity Generator"
	icon_state = "gravgen"
	area_icon_text = "GRAV\nGEN"

/area/station/engineering/transmission_laser
	name = "\improper Power Transmission Laser"
	icon_state = "ptl"
	area_icon_text = "POWER\nLASER"

/area/station/engineering/ai_transit_tube
	name = "\improper AI Minisat Tranit Tube"
	icon_state = "ai"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/engine_foyer
	name = "Engine foyer"
	icon_state = "engine_hallway"
	area_icon_text = "ENGINE\nHALL"

// engine areas

/area/station/engineering/engine
	name = "\improper Engine"
	icon_state = "engine"
	area_icon_text = "ENGINE"

/area/station/engineering/engine/supermatter
	name = "\improper Supermatter Engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/engine/reactor
	name = "\improper Fission Reactor"

//Solars

/area/station/engineering/solar
	name = "\improper Solar Array"
	icon_state = "general_solars"
	area_icon_text = "SOLARS"
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE

/area/station/engineering/solar/fore
	name = "\improper Fore Solar Array"
	icon_state = "fore_solars"
	area_icon_text = "FORE\nSOLARS"

/area/station/engineering/solar/fore_starboard
	name = "\improper Fore-Starboard Solar Array"
	icon_state = "fore_starboard_solars"
	area_icon_text = "FORE\nSTBD\nSOLARS"

/area/station/engineering/solar/fore_port
	name = "\improper Fore-Port Solar Array"
	icon_state = "fore_port_solars"
	area_icon_text = "FORE\nPORT\nSOLARS"

/area/station/engineering/solar/aft
	name = "\improper Aft Solar Array"
	icon_state = "aft_solars"
	area_icon_text = "AFT\nSOLARS"

/area/station/engineering/solar/aft_starboard
	name = "\improper Aft-Starboard Solar Array"
	icon_state = "aft_starboard_solars"
	area_icon_text = "AFT\nSTBD\nSOLARS"

/area/station/engineering/solar/aft_port
	name = "\improper Aft-Port Solar Array"
	icon_state = "aft_port_solars"
	area_icon_text = "AFT\nPORT\nSOLARS"

/area/station/engineering/solar/starboard
	name = "\improper Starboard Solar Array"
	icon_state = "starboard_solars"
	area_icon_text = "STBD\nSOLARS"

/area/station/engineering/solar/port
	name = "\improper Port Solar Array"
	icon_state = "port_solars"
	area_icon_text = "PORT\nSOLARS"

// Other

/area/station/engineering/secure_storage
	name = "Engineering Secure Storage"
	icon_state = "engine_storage"
	area_icon_text = "ENGINE\nSTORE"

/area/station/engineering/tech_storage
	name = "Technical Storage"
	icon_state = "techstorage"
	area_icon_text = "TECH\nSTORE"
	request_console_name = "Tech Storage"
