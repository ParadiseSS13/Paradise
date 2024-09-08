// Atmos
/area/station/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/engineering/atmos/control
	name = "Atmospherics Control Room"
	icon_state = "atmosctrl"
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Atmospherics"

/area/station/engineering/atmos/distribution
	name = "Atmospherics Distribution Loop"
	icon_state = "atmos"

// general engineering
/area/station/engineering
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/engineering/smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/station/engineering/control
	name = "Engineering"
	icon_state = "engine_control"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/engineering/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engibreak"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Engineering"

/area/station/engineering/break_room/secondary
	name = "\improper Secondary Engineering Foyer"

/area/station/engineering/equipmentstorage
	name = "Engineering Equipment Storage"
	icon_state = "engilocker"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Engineering"

/area/station/engineering/hardsuitstorage
	name = "\improper Engineering Hardsuit Storage"
	icon_state = "engi"
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Engineering"

/area/station/engineering/controlroom
	name = "\improper Engineering Control Room"
	icon_state = "engine_monitoring"

/area/station/engineering/gravitygenerator
	name = "\improper Gravity Generator"
	icon_state = "gravgen"

/area/station/engineering/ai_transit_tube
	name = "\improper AI Minisat Tranit Tube"
	icon_state = "ai"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

// engine areas

/area/station/engineering/engine
	name = "\improper Engine"
	icon_state = "engine"

/area/station/engineering/engine/supermatter
	name = "\improper Supermatter Engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

//Solars

/area/station/engineering/solar
	name = "\improper Solar Array"
	icon_state = "general_solars"
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE

/area/station/engineering/solar/fore
	name = "\improper Fore Solar Array"
	icon_state = "fore_solars"

/area/station/engineering/solar/fore_starboard
	name = "\improper Fore-Starboard Solar Array"
	icon_state = "fore_starboard_solars"

/area/station/engineering/solar/fore_port
	name = "\improper Fore-Port Solar Array"
	icon_state = "fore_port_solars"

/area/station/engineering/solar/aft
	name = "\improper Aft Solar Array"
	icon_state = "aft_solars"

/area/station/engineering/solar/aft_starboard
	name = "\improper Aft-Starboard Solar Array"
	icon_state = "aft_starboard_solars"

/area/station/engineering/solar/aft_port
	name = "\improper Aft-Port Solar Array"
	icon_state = "aft_port_solars"

/area/station/engineering/solar/starboard
	name = "\improper Starboard Solar Array"
	icon_state = "starboard_solars"

/area/station/engineering/solar/port
	name = "\improper Port Solar Array"
	icon_state = "port_solars"

// Other

/area/station/engineering/secure_storage
	name = "Engineering Secure Storage"
	icon_state = "engine_storage"

/area/station/engineering/tech_storage
	name = "Technical Storage"
	icon_state = "techstorage"
	request_console_name = "Tech Storage"
