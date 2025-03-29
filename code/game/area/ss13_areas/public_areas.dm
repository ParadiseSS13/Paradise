// Contains the public areas of the station, such has hallways and dorms


// Hallways

/area/station/hallway
	valid_territory = FALSE //too many areas with similar/same names, also not very interesting summon spots
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/hallway/primary/fore
	name = "Основной Северный Коридор"
	icon_state = "hallF"

/area/station/hallway/primary/fore/west
	name = "Северо-Западный Коридор"

/area/station/hallway/primary/fore/east
	name = "Северо-Восточный Коридор"

/area/station/hallway/primary/fore/north
	name = "Северный Коридор"

/area/station/hallway/primary/fore/south
	name = "Северо-Южный Коридор"

/area/station/hallway/primary/starboard
	name = "Основной Восточный Коридор"
	icon_state = "hallS"

/area/station/hallway/primary/starboard/west
	name = "Восточно-Западный Коридор"

/area/station/hallway/primary/starboard/east
	name = "Восточный Коридор"

/area/station/hallway/primary/starboard/north
	name = "Восточно-Северный Коридор"

/area/station/hallway/primary/starboard/south
	name = "Восточно-Южный Коридор"

/area/station/hallway/primary/aft
	name = "Основной Южный Коридор"
	icon_state = "hallA"

/area/station/hallway/primary/aft/west
	name = "Юго-Западный Коридор"

/area/station/hallway/primary/aft/east
	name = "Юго-Восточный Коридор"

/area/station/hallway/primary/aft/north
	name = "Юго-Северный Коридор"

/area/station/hallway/primary/aft/south
	name = "Южный Коридор"


/area/station/hallway/primary/port
	name = "Основной Западный Коридор"
	icon_state = "hallP"

/area/station/hallway/primary/port/west
	name = "Западный Коридор"

/area/station/hallway/primary/port/east
	name = "Западно-Восточный Коридор"

/area/station/hallway/primary/port/north
	name = "Западно-Северный Коридор"

/area/station/hallway/primary/port/south
	name = "Западно-Южный Коридор"

/area/station/hallway/primary/central
	name = "Центральный Основной Коридор"
	icon_state = "hallC"

/area/station/hallway/primary/central/north
/area/station/hallway/primary/central/south
/area/station/hallway/primary/central/west
/area/station/hallway/primary/central/east
/area/station/hallway/primary/central/nw
/area/station/hallway/primary/central/ne
/area/station/hallway/primary/central/sw
/area/station/hallway/primary/central/se

/area/station/hallway/spacebridge
	icon_state = "hall_space"

/area/station/hallway/spacebridge/security
	icon_state = "hall_space"
	name = "\improper Security Space Bridge"

/area/station/hallway/spacebridge/security/west
	icon_state = "hall_space"
	name = "\improper Security West Space Bridge"

/area/station/hallway/spacebridge/security/south
	icon_state = "hall_space"
	name = "\improper Security South Space Bridge"

/area/station/hallway/spacebridge/dockmed
	name = "Docking-Medical Bridge"

/area/station/hallway/spacebridge/scidock
	name = "Science-Docking Bridge"

/area/station/hallway/spacebridge/servsci
	name = "Service-Science Bridge"

/area/station/hallway/spacebridge/serveng
	name = "Service-Engineering Bridge"

/area/station/hallway/spacebridge/engmed
	name = "Engineering-Medical Bridge"

/area/station/hallway/spacebridge/medcargo
	name = "Medical-Cargo Bridge"

/area/station/hallway/spacebridge/cargocom
	name = "Cargo-AI-Command Bridge"

/area/station/hallway/spacebridge/sercom
	name = "Command-Service Bridge"

/area/station/hallway/spacebridge/comeng
	name = "Command-Engineering Bridge"

/area/station/hallway/secondary/exit
	name = "Коридор Эвакуационного Шаттла"
	icon_state = "escape"

/area/station/hallway/secondary/garden
	name = "Сад"
	icon_state = "garden"

/area/station/hallway/secondary/entry
	name = "Коридор Шаттла Прибытия"
	icon_state = "entry"

/area/station/hallway/secondary/entry/north

/area/station/hallway/secondary/entry/south

/area/station/hallway/secondary/entry/east

/area/station/hallway/secondary/entry/west

/area/station/hallway/secondary/entry/lounge
	name = "Зал Прибытия"

/area/station/hallway/secondary/bridge
	name = "Коридор Командования"
	icon_state = "hallC"
// Other public areas


/area/station/public/dorms
	name = "Дормитории"
	icon_state = "dorms"
	sound_environment = SOUND_AREA_STANDARD_STATION
	request_console_name = "Crew Quarters"

/area/station/public/sleep
	name = "Криохранилище Дормитория"
	icon_state = "Sleep"
	valid_territory = FALSE

/area/station/public/sleep/secondary
	name = "Вторичное Криохранилище Дормитория"
	icon_state = "Sleep"

/area/station/public/locker
	name = "Бытовое Помещение"
	icon_state = "locker"
	request_console_name = "Crew Quarters"

/area/station/public/toilet
	name = "Туалеты Дормиторий"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/public/toilet/unisex
	name = "Общие Туалеты"

/area/station/public/toilet/lockerroom
	name = "Бытовые Туалеты"

/area/station/public/fitness
	name = "Фитнес-Зал"
	icon_state = "fitness"
	request_console_name = "Crew Quarters"

/area/station/public/arcade
	name = "Аркаданый Зал"
	icon_state = "arcade"

/area/station/public/mrchangs
	name = "Забегаловка Мистера Чанга"
	icon_state = "changs"

/area/station/public/pet_store
	name = "Зоомагазин"
	icon_state = "pet_store"

/area/station/public/vacant_office
	name = "Свободный Офис"
	icon_state = "vacantoffice"

/area/station/public/storefront
	name = "\improper Storefront"
	icon_state = "vacantoffice"

//Storage
/area/station/public/storage
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/public/storage/tools/auxiliary
	name = "Вспомогательное Хранилище Инструментов"
	icon_state = "auxstorage"

/area/station/public/storage/tools
	name = "Основное Хранилище Инструментов"
	icon_state = "primarystorage"
	request_console_name = "Tool Storage"

/area/station/public/storage/art
	name = "Хранилище Художественных Принадлежностей"
	icon_state = "storage"

/area/station/public/storage/emergency
	name = "Восточное Аварийное Хранилище"
	icon_state = "emergencystorage"

/area/station/public/storage/emergency/port
	name = "Западное Аварийное Хранилище"
	icon_state = "emergencystorage"

/area/station/public/storage/office
	name = "Комната Канцелярских Принадлежностей"
	icon_state = "office_supplies"

/area/station/public/construction
	name = "Зона Для Строительства"
	icon_state = "construction"
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/public/quantum/security
	name = "Security Quantum Pad"

/area/station/public/quantum/docking
	name = "Docking Quantum Pad"

/area/station/public/quantum/science
	name = "Science Quantum Pad"

/area/station/public/quantum/cargo
	name = "Cargo Quantum Pad"

/area/station/public/quantum/service
	name = "Service Quantum Pad"

/area/station/public/quantum/medbay
	name = "Medbay Quantum Pad"

/area/station/public/park
	name = "Public Nature Reserve"
	icon_state = "park"

/area/station/public/shops
	name = "Dorms Public Storefront"
	icon_state = "shop"
