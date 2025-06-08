// Atmos
/area/station/engineering/atmos
	name = "Атмосферный Отдел"
	icon_state = "atmos"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/engineering/atmos/control
	name = "Комната Контроля Атмосферы"
	icon_state = "atmosctrl"
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Atmospherics"

/area/station/engineering/atmos/distribution
	name = "Атмосферный Распределительный Контур"
	icon_state = "atmos"

/area/station/engineering/atmos/storage
	name = "Атмосферный Склад ВКД"
	icon_state = "atmos_suits"

/area/station/engineering/atmos/transit
	name = "Транзитная Труба Атмосферного Отдела"
	icon_state = "atmos_transit"

/area/station/engineering/atmos/asteroid
	name = "Астероид"
	icon_state = "asteroid"
	sound_environment = SOUND_AREA_SPACE
	apc_starts_off = TRUE

/area/station/engineering/atmos/asteroid_filtering
	name = "Атмосферный Отсек Астероида"
	icon_state = "asteroid_atmos"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/engineering/atmos/asteroid_core
	name = "Расплавленное Ядро Астероида"
	icon_state = "asteroid_core"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	sound_environment = SOUND_AREA_ASTEROID

// general engineering
/area/station/engineering
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/engineering/smes
	name = "Инженерные СМЕСы"
	icon_state = "engine_smes"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/station/engineering/control
	name = "Инженерный Отдел"
	icon_state = "engine_control"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/engineering/break_room
	name = "Фойе Инженерного Отдела"
	icon_state = "engibreak"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Engineering"

/area/station/engineering/break_room/secondary
	name = "Дополнительное Фойе Инженерного Отдела"

/area/station/engineering/equipmentstorage
	name = "Инженерный Склад Снаряжения"
	icon_state = "engilocker"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Engineering"

/area/station/engineering/hardsuitstorage
	name = "Инженерный Склад ВКД"
	icon_state = "engi"
	request_console_flags = RC_ASSIST | RC_SUPPLY
	request_console_name = "Engineering"

/area/station/engineering/controlroom
	name = "Инженерная Комната Управления"
	icon_state = "engine_monitoring"

/area/station/engineering/gravitygenerator
	name = "Генератор Гравитации"
	icon_state = "gravgen"

/area/station/engineering/transmission_laser
	name = "Лазер Энергопередачи"
	icon_state = "engi"

/area/station/engineering/ai_transit_tube
	name = "Транзитная Труба Спутника ИИ"
	icon_state = "ai"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/engine_foyer
	name = "Фойе Двигателя"
	icon_state = "engine_hallway"

// engine areas

/area/station/engineering/engine
	name = "Двигатель"
	icon_state = "engine"

/area/station/engineering/engine/supermatter
	name = "Двигатель Суперматерии"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

//Solars

/area/station/engineering/solar
	name = "Солнечные Панели"
	icon_state = "general_solars"
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE

/area/station/engineering/solar/fore
	name = "Северные Солнечные Панели"
	icon_state = "fore_solars"

/area/station/engineering/solar/fore_starboard
	name = "Северо-Восточные Солнечные Панели"
	icon_state = "fore_starboard_solars"

/area/station/engineering/solar/fore_port
	name = "Северо-Западные Солнечные Панели"
	icon_state = "fore_port_solars"

/area/station/engineering/solar/aft
	name = "Южные Солнечные Панели"
	icon_state = "aft_solars"

/area/station/engineering/solar/aft_starboard
	name = "Юго-Восточные Солнечные Панели"
	icon_state = "aft_starboard_solars"

/area/station/engineering/solar/aft_port
	name = "Юго-Западные Солнечные Панели"
	icon_state = "aft_port_solars"

/area/station/engineering/solar/starboard
	name = "Восточные Солнечные Панели"
	icon_state = "starboard_solars"

/area/station/engineering/solar/port
	name = "Западные Солнечные Панели"
	icon_state = "port_solars"

// Other

/area/station/engineering/secure_storage
	name = "Инженерное Защищенное Хранилище"
	icon_state = "engine_storage"

/area/station/engineering/tech_storage
	name = "Техническое Хранилище"
	icon_state = "techstorage"
	request_console_name = "Tech Storage"
