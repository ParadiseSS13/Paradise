
/area/station/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

/area/station/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	ambientsounds = list('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

/area/station/turret_protected/aisat
	name = "\improper AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/station/aisat
	name = "\improper AI Satellite Exterior"
	icon_state = "ai"

/area/station/aisat/entrance
	name = "\improper AI Satellite Entrance"
	icon_state = "ai"

/area/station/aisat/maintenance
	name = "\improper AI Satellite Maintenance"
	icon_state = "ai"

/area/station/aisat/atmos
	name = "\improper AI Satellite Atmospherics"

/area/station/aisat/hall
	name = "\improper AI Satellite Hallway"

/area/station/aisat/service
	name = "\improper AI Satellite Service"

/area/station/turret_protected/aisat/interior
	name = "\improper AI Satellite Antechamber"
	icon_state = "ai"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/turret_protected/aisat/interior/secondary
	name = "\improper AI Satellite Secondary Antechamber"

// Telecommunications Satellite

/area/station/telecomms
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')

/area/station/telecomms/chamber
	name = "\improper Telecoms Central Compartment"
	icon_state = "tcomms"

// These areas are needed for MetaStation's AI sat
/area/station/turret_protected/tcomfoyer
	name = "\improper Telecoms Foyer"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/station/turret_protected/tcomeast
	name = "\improper Telecoms East Wing"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/station/telecomms/computer
	name = "\improper Telecoms Control Room"
	icon_state = "tcomms"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/telecomms/server
	name = "\improper Telecoms Server Room"
	icon_state = "tcomms"
