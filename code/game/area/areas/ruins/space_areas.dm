//Space Ruins

/area/ruin/space
	var/baseturf = /turf/space

/area/ruin/space/powered
	requires_power = FALSE

/area/ruin/space/unpowered
	always_unpowered = FALSE

/area/ruin/space/unpowered/no_grav
	has_gravity = FALSE

/area/ruin/space/abandtele
	name = "Заброшенный Телепорт"
	icon_state = "teleporter"
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/signal.ogg')

/area/ruin/space/unpowered/no_grav/way_home
	name = "Распутье"

// Old tcommsat
/area/ruin/space/tcommsat
	name = "Телекоммуникационный Спутник"
	icon_state = "tcomms"

// Ruins of "onehalf" ship
/area/ruin/space/onehalf/hallway
	name = "Коридор Экскаватора DK 453"
	icon_state = "hallC"

/area/ruin/space/onehalf/drone_bay
	name = "Шахтный Док Экскаватора DK 453"
	icon_state = "engine"

/area/ruin/space/onehalf/dorms_med
	name = "Каюты Экипажа Экскаватора DK 453"
	icon_state = "Sleep"

/area/ruin/space/onehalf/abandonedbridge
	name = "Мостик Экскаватора DK 453"
	icon_state = "bridge"

// Ruins of the Unathi Breacher ship
/area/ruin/space/unathi_breacher/engineering
	name = "Двигательный Отсек Скифа"

/area/ruin/space/unathi_breacher/dorms
	name = "Каюты Экипажа Скифа"

/area/ruin/space/unathi_breacher/bar
	name = "Бар Скифа"

/area/ruin/space/unathi_breacher/bridge
	name = "Мостик Скифа"

/area/ruin/space/unathi_breacher/hold
	name = "Хранилище Скифа"

//DJSTATION
/area/ruin/space/djstation
	name = "Советская Радиостанция"
	icon_state = "DJ"

/area/ruin/space/djstation/solars
	name = "Солнечные Панели Советской Радиостанции"
	icon_state = "DJ"

//Methlab
/area/ruin/space/methlab
	name = "Заброшенная Нарколаборатория"
	icon_state = "green"

// Space Bar
/area/ruin/space/powered/bar
	name = "Космический Бар"

//DERELICT (USSP station and USSP Teleporter)
/area/ruin/space/derelict
	name = "Заброшенная Станция"
	icon_state = "storage"

/area/ruin/space/derelict/hallway/primary
	name = "Основной Коридор Заброшенной Станции"
	icon_state = "hallP"

/area/ruin/space/derelict/hallway/secondary
	name = "Вспомогательный Коридор Заброшенной Станции"
	icon_state = "hallS"

/area/ruin/space/derelict/arrival
	name = "Зал Прибытия Заброшенной Станции"
	icon_state = "yellow"

/area/ruin/space/derelict/storage/equipment
	name = "Техническое Хранилище Заброшенной Станции"

/area/ruin/space/derelict/storage/storage_access
	name = "Коридор Технического Хранилища Заброшенной Станции"

/area/ruin/space/derelict/storage/engine_storage
	name = "Инженерное Хранилище Заброшенной Станции"
	icon_state = "green"

/area/ruin/space/derelict/bridge
	name = "Мостик Заброшенной Станции"
	icon_state = "bridge"

/area/ruin/space/derelict/secret
	name = "Потайная Комната Заброшенной Станции"
	icon_state = "library"

/area/ruin/space/derelict/bridge/access
	name = "Коридор Мостика Заброшенной Станции"
	icon_state = "auxstorage"

/area/ruin/space/derelict/bridge/ai_upload
	name = "Аплоуд ИИ Заброшенной Станции"
	icon_state = "ai"

/area/ruin/space/derelict/solar_control
	name = "Солнечные Панели Заброшенной Станции"
	icon_state = "general_solar_control"

/area/ruin/space/derelict/se_solar
	name = "Юго-Восточные Солнечные Панели Заброшенной Станции"
	icon_state = "general_solars"

/area/ruin/space/derelict/crew_quarters
	name = "Дормитории Заброшенной Станции"
	icon_state = "fitness"

/area/ruin/space/derelict/medical
	name = "Медицинский Отдел Заброшенной Станции"
	icon_state = "medbay"

/area/ruin/space/derelict/medical/morgue
	name = "Морг Заброшенной Станции"
	icon_state = "morgue"
	is_haunted = TRUE

/area/ruin/space/derelict/medical/chapel
	name = "Церковь Заброшенной Станции"
	icon_state = "chapel"
	is_haunted = TRUE

/area/ruin/space/derelict/teleporter
	name = "Телепортерная Заброшенной Станции"
	icon_state = "teleporter"

/area/ruin/space/derelict/eva
	name = "Хранилище ВКД Заброшенной Станции"
	icon_state = "eva"

/area/ruin/space/syndicate_druglab
	name = "Подозрительная Станция"
	icon_state = "red"

/area/ruin/space/syndicate_druglab/asteroid
	name = "Подозрительный Астероид"
	icon_state = "dark"
	requires_power = FALSE

/area/ruin/space/bubblegum_arena
	name = "Арена Бубльгума"

/area/ruin/space/wreck_cargoship
	name = "Сигнал \"SOS\""
	icon_state = "yellow"

// Syndicate Listening Station

/area/ruin/space/syndicate_listening_station
	name = "Пост Радиоразведки"
	icon_state = "red"

/area/ruin/space/syndicate_listening_station/asteroid
	name = "Астероид Поста Радиоразведки"
	icon_state = "dark"
	requires_power = FALSE

/area/ruin/space/turreted_outpost
	name = "Охраняемая Платформа Синдиката"
	icon_state = "red"

/area/ruin/space/turreted_outpost/vault
	name = "Хранилище Охраняемой Платформы Синдиката"
	icon_state = "storage"

/area/ruin/space/turreted_outpost/solars
	name = "Солнечные Панели Охраняемой Платформы Синдиката"
	icon_state = "general_solars"

/area/ruin/space/abandoned_engi_sat
	name = "Заброшенный Инженерный Спутник НТ"
	apc_starts_off = TRUE

/area/ruin/space/sieged_lab
	name = "Лаборатория X-18"
	apc_starts_off = TRUE
	tele_proof = TRUE

/area/ruin/space/moonbase19
	name = "Лунная База 19"
	apc_starts_off = TRUE

/area/ruin/space/mech_transport
	name = "Мобильная Фабрика Экзокостюмов Cybersun"
	apc_starts_off = TRUE
	there_can_be_many = FALSE

/area/ruin/space/powered/casino
	name = "Космическое Казино"
	there_can_be_many = FALSE
	requires_power = TRUE

/area/ruin/space/powered/casino/docked_ships
	name = "Эвакуационная Капсула Космического Казино"
	requires_power = FALSE

/area/ruin/space/powered/casino/arrivals
	name = "Зал Прибытия Космического Казино"

/area/ruin/space/powered/casino/kitchen
	name = "Столовая Космического Казино"

/area/ruin/space/powered/casino/floor
	name = "Бар Космического Казино"

/area/ruin/space/powered/casino/hall
	name = "Основной Коридор Космического Казино"

/area/ruin/space/powered/casino/engine
	name = "Помещение Электрооборудования Космического Казино"

/area/ruin/space/powered/casino/security
	name = "Служба Безопасности Космического Казино"

/area/ruin/space/powered/casino/teleporter
	name = "Телепортерная Космичесного Казино"

/area/ruin/space/powered/casino/maints
	name = "Технические Тоннели Космического Казино"

/// telecomms: Alternative telecomms sat
/area/ruin/space/telecomms
	name = "Телекоммуникационный Спутник"
	icon_state = "tcomms"
	tele_proof = TRUE // No patrick, you can not syndicate teleport or hand teleport instantly into or out of this ruin
	ambientsounds = list('sound/ambience/dvorak_ambience_final.ogg')
	min_ambience_cooldown = 110 SECONDS // 3 seconds longer than the length of the song
	max_ambience_cooldown = 170 SECONDS // A minute break at most

/area/ruin/space/telecomms/powercontrol
	name = "Помещение Электрооборудования Телекоммуникационного Спутника"
	icon_state = "engine_smes"

/area/ruin/space/telecomms/tele
	name = "При_УБИТЬ_ие Тел#коММуниК-К@ци0нного S-$путника" // If you teleport to it. With a name like that. Thats on you.
	icon_state = "teleporter"
	tele_proof = FALSE // Oh, right. The teleporter room. The teleporter room for Kuzco, the poison chosen especially to teleport Kuzco, Kuzco's teleporter room. That teleporter room?

/area/ruin/space/telecomms/foyer
	name = "Фойе Телекоммуникационного Спутника"
	icon_state = "entry"

/area/ruin/space/telecomms/computer
	name = "Пункт Контроля Телекоммуникационного Спутника"
	icon_state = "bridge"

/area/ruin/space/telecomms/chamber
	name = "Зона Содержания ИИ Телекоммуникационного Спутника"
	icon_state = "ai_chamber"

/area/ruin/space/deepstorage
	name = "Заброшенные Астероидные Шахты"
	apc_starts_off = TRUE

/area/ruin/space/sec_shuttle
	name = "Заброшенный Шаттл Службы Безопасности"
	apc_starts_off = TRUE

/area/ruin/space/syndicakefactory
	name = "Кондитерская Фабрика Синдиката"

/area/ruin/space/clown_mime_ruin
	name = "Заброшенное Транспортное Судно"

/area/ruin/space/clockwork_monastery
	name = "Часовой Монастырь"
	there_can_be_many = FALSE
	requires_power = FALSE
	ambientsounds = list("sound/ambience/reebe_ambience_1.ogg", "sound/ambience/reebe_ambience_2.ogg", "sound/ambience/reebe_ambience_3.ogg")

/area/ruin/space/rocky_motel
	name = "Астероидный Мотель"
	icon_state = "rocky_motel"
	there_can_be_many = FALSE

/area/ruin/space/rocky_motel/asteroid
	icon_state = "away"

/area/ruin/space/space_relay
	name = "Блюспейс Маяк НТ"
	icon_state = "space_relay"

/area/ruin/space/space_relay/Initialize(mapload)
	name = "Блюспейс Маяк НТ #[rand(1, 1000)]" //Give it a random relay name
	return ..()

