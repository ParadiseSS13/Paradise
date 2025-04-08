/**********************Mine areas**************************/

/area/mine
	icon_state = "mining"
	has_gravity = TRUE

/area/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	apc_starts_off = TRUE
	outdoors = TRUE
	ambientsounds = MINING_SOUNDS
	sound_environment = SOUND_AREA_ASTEROID
	flags = NONE
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/mine/unexplored/cere/ai
	name = "AI Asteroid"

/area/mine/unexplored/cere/cargo
	name = "Cargo Asteroid"

/area/mine/unexplored/cere/civilian
	name = "Civilian Asteroid"

/area/mine/unexplored/cere/command
	name = "Command Asteroid"

/area/mine/unexplored/cere/engineering
	name = "Engineering Asteroid"

/area/mine/unexplored/cere/medical
	name = "Medical Asteroid"

/area/mine/unexplored/cere/research
	name = "Research Asteroid"

/area/mine/unexplored/cere/orbiting
	name = "Near Station Asteroids"

/**********************Outpost areas**************************/

/area/mine/outpost
	name = "Шахтерский Аванпост"
	icon_state = "mining"
	sound_environment = SOUND_AREA_STANDARD_STATION
	request_console_name = "Mining Outpost"
	request_console_flags = RC_SUPPLY

/area/mine/outpost/airlock
	name = "Шлюз Шахтерского Аванпоста"
	icon_state = "mining_eva"

/area/mine/outpost/cafeteria
	name = "Кафетерий Шахтерского Аванпоста"
	icon_state = "mining_living"

/// subtype of /surface so storms hit there
/area/lavaland/surface/outdoors/outpost/catwalk
	name = "Площадка вне Шахтерского Аванпоста"
	icon_state = "mining"

/area/mine/outpost/comms
	name = "Отделение Телекоммуникаций Шахтерского Аванпоста"
	icon_state = "tcomms"

/area/mine/outpost/custodial
	name = "Подсобка Шахтерского Аванпоста"
	icon_state = "janitor"

/// basically engi and atmos combined. I'm keeping it as "engineering" code wise, but "Life Support" sounds cooler in-game
/area/mine/outpost/engineering
	name = "Комната Жизнеобеспечения Шахтерского Аванпоста"
	icon_state = "engi"

/area/mine/outpost/hallway
	name = "Центральное Крыло Шахтерского Аванпоста"
	icon_state = "hallC"

/area/mine/outpost/hallway/east
	name = "Восточное Крыло Шахтерского Аванпоста"
	icon_state = "hallS"

/area/mine/outpost/hallway/west
	name = "Западное Крыло Шахтерского Аванпоста"
	icon_state = "hallP"

/area/mine/outpost/lockers
	name = "Раздевалка Шахтерского Аванпоста"
	icon_state = "locker"

/area/mine/outpost/storage
	name = "Хранилище Шахтерского Аванпоста"
	icon_state = "storage"

/area/mine/outpost/smith_workshop
	name = "Smith's Workshop"
	icon_state = "smith"

/area/mine/outpost/maintenance
	name = "Технические Тоннели Шахтерского Аванпоста"
	icon_state = "maintcentral"

/area/mine/outpost/maintenance/south
	name = "Южные Технические Тоннели Шахтерского Аванпоста"
	icon_state = "amaint"

/area/mine/outpost/maintenance/east
	name = "Восточные Технические Тоннели Шахтерского Аванпоста"
	icon_state = "smaint"

/area/mine/outpost/medbay
	name = "Лазарет Шахтерского Аванпоста"
	icon_state = "medbay"

/area/mine/outpost/mechbay
	name = "Мех. Отсек Шахтерского Аванпоста"
	icon_state = "mechbay"

/area/mine/outpost/production
	name = "Производственная Комната Шахтерского Аванпоста"
	icon_state = "mining_production"

/area/mine/outpost/quartermaster
	name = "Офис Квартирмейстера Шахтерского Аванпоста"
	icon_state = "qm"
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Quartermaster's Desk"
	request_console_announces = TRUE

/area/mine/laborcamp
	name = "Трудовой Лагерь"
	icon_state = "brig"

/area/mine/laborcamp/security
	name = "Комната Охраны Трудового Лагеря"
	icon_state = "security"
	ambientsounds = HIGHSEC_SOUNDS


/**********************Lavaland Areas**************************/

/area/lavaland
	icon_state = "mining"
	has_gravity = TRUE
	sound_environment = SOUND_AREA_LAVALAND

/area/lavaland/surface
	name = "Лаваленд"
	icon_state = "explored"
	always_unpowered = TRUE
	poweralm = FALSE
	apc_starts_off = TRUE
	requires_power = TRUE
	ambientsounds = MINING_SOUNDS
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/lavaland/surface/gulag_rock
	name = "Lavaland Wastes"
	outdoors = TRUE

/area/lavaland/surface/outdoors
	name = "Пустоши Лаваленда"
	outdoors = TRUE

/area/lavaland/surface/outdoors/legion_arena
	name = "Legion Arena"

/// monsters and ruins spawn here
/area/lavaland/surface/outdoors/unexplored
	icon_state = "unexplored"

/// megafauna will also spawn here
/area/lavaland/surface/outdoors/unexplored/danger
	icon_state = "danger"

/area/lavaland/surface/outdoors/explored

/area/lavaland/surface/outdoors/targetable
