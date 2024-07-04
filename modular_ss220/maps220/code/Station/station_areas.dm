/* Station */
/area/station/security/checkpoint/south
	name = "Южный Контрольно-Пропускной Пункт Службы Безопасности"

/area/station/security/podpilot
	name = "Гараж Под-пилота Службы Безопасности"
	icon_state = "security"

/area/station/bridge/checkpoint
	name = "Контрольно-Пропускной Пункт Командования"

/area/station/bridge/checkpoint/north
	name = "Северный Контрольно-Пропускной Пункт Командования"

/area/station/bridge/checkpoint/south
	name = "Южный Контрольно-Пропускной Пункт Командования"

/area/station/engineering/hallway
	name = "Коридор Инженерного Отдела"
	icon_state = "engine_hallway"

/area/station/engineering/dronefabricator
	name = "Комната Изготовления Дронов"
	icon_state = "engi"

/area/station/engineering/emergency
	name = "Аварийные Запасы Инженерного Отдела"
	icon_state = "emergencystorage"

/area/station/engineering/supermatter_room
	name = "Комната Суперматерии"
	icon_state = "engi"

/area/station/engineering/utility
	name = "Инженерная Подсобка"
	icon_state = "engimaint"

/area/station/engineering/mechanic
	name = "Гараж Под Механика"
	icon_state = "engi"

/area/station/engineering/atmos/storage
	name = "Хранилище Атмосферного Отдела"
	icon_state = "atmos"

/area/station/supply/abandoned_boxroom
	name = "Заброшенное Складское Помещение"
	icon_state = "cargobay"

/area/station/supply/expedition/gate
	name = "Гейт"

/area/station/public/pool
	name = "Бассейн"
	icon_state = "dorms"

/area/station/public/vacant_store
	name = "Вакантный Магазин"
	icon = 'modular_ss220/maps220/icons/areas.dmi'
	icon_state = "vacantstore"

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

/area/station/public/sleep_male
	name = "Мужские Дормитории"
	icon_state = "Sleep"

/area/station/public/sleep_female
	name = "Женские Дормитории"
	icon_state = "Sleep"

/area/station/public/toilet/male
	name = "Мужские Туалеты"

/area/station/public/toilet/female
	name = "Женские Туалеты"

/area/station/security/interrogation/observation
	name = "Просматриваемая Допросная"

/area/station/service/bar/atrium
	name = "Атриум"
	icon_state = "bar"

/area/station/public/vacant_office/secondary

/area/station/service/chapel/bedroom
	name = "Каюта Священника"
	icon_state = "chapeloffice"

/area/station/service/chapel/study
	name = "Рабочий Кабинет Священника"
	icon_state = "chapeloffice"

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

/* Misc */
/area/holodeck
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
