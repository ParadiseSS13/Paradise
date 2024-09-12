/* Station */
/area/station/security/checkpoint/south
	name = "Южный Контрольно-Пропускной Пункт Службы Безопасности"
	request_console_name = "Security"

/area/station/security/podpilot
	name = "Гараж Под-пилота Службы Безопасности"
	icon_state = "security"
	request_console_name = "Security"

/area/station/security/interrogation/observation
	name = "Просматриваемая Допросная"
	request_console_name = "Security"

/area/station/security/processing
	request_console_name = "Security"

/area/mine/laborcamp
	request_console_name = "Labor Camp"

/area/mine/laborcamp/security
	request_console_name = "Security"

/area/station/command/bridge
	request_console_name = "Bridge"

/area/station/command/bridge/checkpoint
	name = "Контрольно-Пропускной Пункт Командования"

/area/station/command/bridge/checkpoint/north
	name = "Северный Контрольно-Пропускной Пункт Командования"

/area/station/command/bridge/checkpoint/south
	name = "Южный Контрольно-Пропускной Пункт Командования"

/area/station/telecomms
	request_console_name = "Bridge"

/area/station/engineering/hallway
	name = "Коридор Инженерного Отдела"
	icon_state = "engine_hallway"
	request_console_name = "Engineering"

/area/station/engineering/control
	request_console_name = "Engineering"

/area/station/engineering/controlroom
	request_console_name = "Engineering"
	
/area/station/engineering/dronefabricator
	name = "Комната Изготовления Дронов"
	icon_state = "engi"
	request_console_name = "Engineering"

/area/station/engineering/emergency
	name = "Аварийные Запасы Инженерного Отдела"
	icon_state = "emergencystorage"
	request_console_name = "Engineering"

/area/station/engineering/atmos
	request_console_name = "Atmospherics"

/area/station/engineering/supermatter_room
	name = "Комната Суперматерии"
	icon_state = "engi"
	request_console_name = "Atmospherics"

/area/station/engineering/utility
	name = "Инженерная Подсобка"
	icon_state = "engimaint"
	request_console_name = "Engineering"

/area/station/engineering/mechanic
	name = "Гараж Под Механика"
	icon_state = "engi"
	request_console_name = "Engineering"

/area/station/engineering/atmos/storage
	name = "Хранилище Атмосферного Отдела"
	icon_state = "atmos"
	request_console_name = "Atmospherics"

/area/station/supply/abandoned_boxroom
	name = "Заброшенное Складское Помещение"
	icon_state = "cargobay"
	request_console_name = "Cargo Bay"

/area/station/supply/expedition/gate
	name = "Гейт"
	request_console_name = "Expedition"

/area/station/supply/storage
	request_console_name = "Cargo Bay"

/area/station/medical/sleeper
	request_console_name = "Medbay"

/area/station/medical/virology
	request_console_name = "Virology"

/area/station/medical/chemistry
	request_console_name = "Chemistry"

/area/station/medical/paramedic
	request_console_name = "Paramedic"

/area/station/medical/morgue
	request_console_name = "Morgue"

/area/station/public/pool
	name = "Бассейн"
	icon_state = "dorms"
	request_console_name = "Crew Quarters"

/area/station/public/vacant_store
	name = "Вакантный Магазин"
	icon = 'modular_ss220/maps220/icons/areas.dmi'
	icon_state = "vacantstore"
	request_console_name = "Crew Quarters"

/area/station/public/sleep_male
	name = "Мужские Дормитории"
	icon_state = "Sleep"
	request_console_name = "Crew Quarters"

/area/station/public/sleep_female
	name = "Женские Дормитории"
	icon_state = "Sleep"
	request_console_name = "Crew Quarters"

/area/station/public/toilet/male
	name = "Мужские Туалеты"
	request_console_name = "Crew Quarters"

/area/station/public/toilet/female
	name = "Женские Туалеты"
	request_console_name = "Crew Quarters"

/area/station/service/bar/atrium
	name = "Атриум"
	icon_state = "bar"
	request_console_name = "Crew Quarters"

/area/station/public/vacant_office/secondary
	request_console_name = "Crew Quarters"

/area/station/service/chapel/bedroom
	name = "Каюта Священника"
	icon_state = "chapeloffice"
	request_console_name = "Chapel"

/area/station/service/chapel/study
	name = "Рабочий Кабинет Священника"
	icon_state = "chapeloffice"
	request_console_name = "Chapel"

/area/station/service/bar
	request_console_name = "Bar"

/area/station/service/kitchen
	request_console_name = "Kitchen"

/area/station/service/hydroponics
	request_console_name = "Hydroponics"

/area/station/maintenance/dormitory_maintenance
	name = "Технические Тоннели Дормиториев"
	icon_state = "smaint"

/area/station/maintenance/old_kitchen
	name = "Старая Кухня"
	icon_state = "kitchen"

/area/station/maintenance/old_detective
	name = "Старый Офис Детектива"
	icon_state = "detective"

/area/station/maintenance/virology_maint
	name = "Технические Тоннели Вирусологии. Строительная Зона"
	icon_state = "smaint"

/area/station/hallway/secondary/exit/maintenance
	name = "Заброшенный Коридор Эвакуационного Шаттла"
	icon_state = "escape"

/* CentCom */
/area/centcom/ss220
	name = "ЦК"
	icon_state = "centcom"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	nad_allowed = TRUE

/area/centcom/ss220/evac
	name = "ЦК - Эвакуационный шаттл"
	icon_state = "centcom_evac"

/area/centcom/ss220/park
	name = "ЦК - Парк"
	icon_state = "centcom"

/area/centcom/ss220/bar
	name = "ЦК - Бар"
	icon_state = "centcom"

/area/centcom/ss220/general
	name = "ЦК - Зона персонала"
	icon_state = "centcom"

/area/centcom/ss220/supply
	name = "ЦК - Доставка"
	icon_state = "centcom_supply"

/area/centcom/ss220/admin1
	name = "ЦК - Коридоры ЦК"
	icon_state ="centcom"

/area/centcom/ss220/admin2
	name = "ЦК - Офисы"
	icon_state = "centcom"

/area/centcom/ss220/admin3
	name = "ЦК - ОБР"
	icon_state = "centcom_specops"

/area/centcom/ss220/medbay
	name = "ЦК - Лазарет"
	icon_state = "centcom"

/area/centcom/ss220/court
	name = "ЦК - Зал суда"
	icon_state = "centcom"

/area/centcom/ss220/library
	name = "ЦК - Библиотека"
	icon_state = "centcom"

/area/centcom/ss220/command
	name = "ЦК - Командный центр"
	icon_state = "centcom_ctrl"

/area/centcom/ss220/jail
	name = "ЦК - Тюрьма"
	icon_state = "centcom"

/area/shuttle/assault_pod/nanotrasen
	name = "Nanotrasen Drop Pod"
	icon_state = "shuttle"

/* Syndicate Base - Mothership */
/area/syndicate_mothership
	name = "Syndicate Forward Base"
	icon = 'modular_ss220/maps220/icons/areas.dmi'
	icon_state = "syndie-ship"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	nad_allowed = TRUE
	ambientsounds = HIGHSEC_SOUNDS

/area/syndicate_mothership/outside
	name = "Syndicate Controlled Territory"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	icon_state = "syndie-outside"

/area/syndicate_mothership/control
	name = "Syndicate Control Room"
	icon_state = "syndie-control"

/area/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	icon_state = "syndie-elite"

/area/syndicate_mothership/infteam
	name = "Syndicate Infiltrators"
	icon_state = "syndie-infiltrator"

/area/syndicate_mothership/jail
	name = "Syndicate Jail"
	icon_state = "syndie-jail"

/area/syndicate_mothership/cargo
	name = "Syndicate Cargo"
	icon_state = "syndie-cargo"

/* Skyrat Ghostbar */
/area/ghost_bar/outdoor
	name = "Ghost Bar - Outdoor"
	icon_state = "away"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambientsounds = list('modular_ss220/aesthetics_sounds/sound/area_ambient/jungle1.ogg', 'modular_ss220/aesthetics_sounds/sound/area_ambient/jungle2.ogg', 'modular_ss220/aesthetics_sounds/sound/area_ambient/jungle3.ogg')

/area/ghost_bar/outdoor/beach
	name = "Ghost Bar - Beach"
	icon_state = "beach"
	ambientsounds = list('modular_ss220/aesthetics_sounds/sound/area_ambient/river.ogg', 'sound/ambience/seag1.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/seag2.ogg')

/area/ghost_bar/indoor
	name = "Ghost Bar - Indoor"
	icon_state = "observatory"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/ghost_bar/indoor/cave
	name = "Ghost Bar - Cave"
	icon_state = "cave"
	ambientsounds = list('modular_ss220/aesthetics_sounds/sound/area_ambient/cave_ambient2.ogg', 'modular_ss220/aesthetics_sounds/sound/area_ambient/cave_ambient3.ogg', 'modular_ss220/aesthetics_sounds/sound/area_ambient/cave_waterdrops.ogg')

/* Misc */
/area/holodeck
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
