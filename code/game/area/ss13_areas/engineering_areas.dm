// Atmos
/area/station/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/station/engineering/atmos/control
	name = "Atmospherics Control Room"
	icon_state = "atmosctrl"

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

/area/station/engineering/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engibreak"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/equipmentstorage
	name = "Engineering Equipment Storage"
	icon_state = "engilocker"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/hardsuitstorage
	name = "\improper Engineering Hardsuit Storage"
	icon_state = "engi"

/area/station/engineering/controlroom
	name = "\improper Engineering Control Room"
	icon_state = "engine_monitoring"

/area/station/engineering/gravitygenerator
	name = "\improper Gravity Generator"
	icon_state = "gravgen"

// engine areas

/area/station/engineering/engine
	name = "\improper Engine"
	icon_state = "engine"

/area/station/engineering/engine/supermatter
	name = "\improper Supermatter Engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

//Solars

/area/station/engineering/solar
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE

/area/station/engineering/solar/auxport
	name = "\improper Fore Port Solar Array"
	icon_state = "FPsolars"

/area/station/engineering/solar/auxstarboard
	name = "\improper Fore Starboard Solar Array"
	icon_state = "FSsolars"

/area/station/engineering/solar/fore
	name = "\improper Fore Solar Array"
	icon_state = "yellow"

/area/station/engineering/solar/aft
	name = "\improper Aft Solar Array"
	icon_state = "aft"

/area/station/engineering/solar/starboard
	name = "\improper Starboard Solar Array"
	icon_state = "ASsolars"

/area/station/engineering/solar/starboard/aft
	name = "\improper Aft Starboard Solar Array"
	icon_state = "ASsolars"

/area/station/engineering/solar/port
	name = "\improper Aft Port Solar Array"
	icon_state = "APsolars"

/area/station/engineering/secure_storage
	name = "Engineering Secure Storage"
	icon_state = "engine_storage"

/area/station/engineering/tech_storage
	name = "Technical Storage"
	icon_state = "techstorage"
