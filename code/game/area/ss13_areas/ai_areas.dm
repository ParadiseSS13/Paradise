
/area/station/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

/area/station/turret_protected/ai_upload
	name = "Аплоуд ИИ"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/turret_protected/ai
	name = "Зона Содержания ИИ"
	icon_state = "ai_chamber"
	ambientsounds = list('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "AI"

/area/station/turret_protected/aisat
	name = "Спутник ИИ"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/station/aisat
	name = "Внешняя Комната Спутника ИИ"
	icon_state = "ai"

/area/station/aisat/atmos
	name = "Атмос Спутника ИИ"

/area/station/aisat/hall
	name = "Коридор Спутника ИИ"

/area/station/aisat/breakroom
	name = "\improper AI Satellite Break Room Hallway"

/area/station/aisat/service
	name = "Сервисная Комната Спутника ИИ"

/area/station/turret_protected/aisat/interior
	name = "Фойе Спутника ИИ"
	icon_state = "ai"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/turret_protected/aisat/interior/secondary
	name = "Дополнительное Фойе Спутника ИИ"

// Telecommunications Satellite

/area/station/telecomms
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')

/area/station/telecomms/chamber
	name = "Центральное Отделение Телекоммуникаций"
	icon_state = "tcomms"

// These areas are needed for MetaStation's AI sat
/area/station/telecomms/computer
	name = "Комната Управления Телекоммуникациями"
	icon_state = "tcomms"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
