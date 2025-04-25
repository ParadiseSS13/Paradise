// Robotics areas

/area/station/science/robotics
	name = "Робототехника"
	icon_state = "robo"
	request_console_flags = RC_SUPPLY
	request_console_name = "Robotics"

/area/station/science/robotics/chargebay
	name = "Мех. Отсек РНД"
	icon_state = "mechbay"

/area/station/science/robotics/showroom
	name = "Салон Робототехники"
	icon_state = "showroom"

/area/station/science/research
	name = "Отдел Исследований"
	icon_state = "sci"

/area/station/science/lobby
	name = "Фойе Отдела Исследований"
	icon_state = "sci"

/area/station/science/testrange
	name = "Отдел Исследовательских Испытаний"
	icon_state = "sci"

/area/station/science/break_room
	name = "Комната Отдыха РНД"
	icon_state = "scibreak"

/area/station/science/genetics
	name = "Лаборатория Генетики"
	icon_state = "genetics"
	request_console_flags = RC_ASSIST
	request_console_name = "Genetics"

/area/station/science
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/science/rnd
	name = "Отдел Исследований"
	icon_state = "rnd"
	request_console_flags = RC_SUPPLY
	request_console_name = "Science"

/area/station/science/hallway
	name = "Коридор РНД"
	icon_state = "sci"

/area/station/science/xenobiology
	name = "Лаборатория Ксенобиологии"
	icon_state = "xenobio"
	xenobiology_compatible = TRUE
	request_console_flags = RC_ASSIST | RC_INFO
	request_console_name = "Xenobiology"

/area/station/science/storage
	name = "Хранилище Токсинов РНД"
	icon_state = "toxstorage"

/area/station/science/toxins/test
	name = "Тестовая Комната Токиснов РНД"
	icon_state = "toxtest"
	valid_territory = FALSE

/area/station/science/toxins/mixing
	name = "Комната Смешивания Токсинов РНД"
	icon_state = "toxmix"
	request_console_flags = RC_SUPPLY
	request_console_name = "Science"

/area/station/science/toxins/launch
	name = "Комната Запуска Токсинов РНД"
	icon_state = "toxlaunch"
	request_console_flags = RC_SUPPLY
	request_console_name = "Science"

/area/station/science/misc_lab
	name = "Лаборатория Химии РНД"
	icon_state = "scichem"
	request_console_flags = RC_SUPPLY
	request_console_name = "Science"

/area/station/science/test_chamber
	name = "Камера Химии РНД"
	icon_state = "scitest"

/area/station/science/server
	name = "Серверная Комната"
	icon_state = "server"

/area/station/science/server/coldroom
	name = "Холодильная Камера Серверной"
	icon_state = "servercold"
