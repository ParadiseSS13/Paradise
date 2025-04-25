//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle
	no_teleportlocs = TRUE
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	parallax_move_direction = NORTH
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/shuttle/arrival
	name = "\improper Arrival Shuttle"
	parallax_move_direction = EAST

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/auxillary_base
	icon_state = "shuttle"

/area/shuttle/escape
	name = "Эвакуационный Шаттл"
	icon_state = "shuttle2"
	nad_allowed = TRUE

/area/shuttle/pod_1
	name = "Эвакуационная Капсула Один"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_2
	name = "Эвакуационная Капсула Два"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_3
	name = "Эвакуационная Капсула Три"
	icon_state = "shuttle"
	nad_allowed = TRUE
	parallax_move_direction = EAST

/area/shuttle/pod_4
	name = "Эвакуационная Капсула Четыре"
	icon_state = "shuttle"
	nad_allowed = TRUE
	parallax_move_direction = EAST

/area/shuttle/mining
	name = "Шахтерский Шаттл"
	icon_state = "shuttle"

/area/shuttle/transport
	icon_state = "shuttle"
	name = "Транспортный Шаттл"
	parallax_move_direction = EAST

/area/shuttle/gamma/space
	icon_state = "shuttle"
	name = "Гамма-Оружейная"

/area/shuttle/gamma/station
	icon_state = "shuttle"
	name = "Станционная Гамма-Оружейная"

/area/shuttle/siberia
	name = "Шаттл Трудового Лагеря"
	icon_state = "shuttle"

/area/shuttle/specops
	name = "Шаттл Специальных Операций"
	icon_state = "shuttlered"
	parallax_move_direction = EAST

/area/shuttle/syndicate_elite
	name = "Элитный Шаттл Синдиката"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_move_direction = SOUTH

/area/shuttle/syndicate_sit
	name = "Шаттл Внедрения Синдиката"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_move_direction = SOUTH

/area/shuttle/assault_pod
	name = "Свинцовый Шторм"
	icon_state = "shuttle"

/area/shuttle/administration
	name = "Корпоративное Судно НТ"
	icon_state = "shuttlered"
	parallax_move_direction = EAST

/area/shuttle/administration/centcom
	name = "Корпоративное Судно ЦК НТ"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "Корпоративное Судно НТ"
	icon_state = "shuttlered2"

// === Trying to remove these areas:

/area/shuttle/supply
	name = "Шаттл Карго"
	icon_state = "shuttle3"

/area/shuttle/abandoned
	name = "Заброшенный Корабль"
	icon_state = "shuttle"
	parallax_move_direction = WEST

/area/shuttle/syndicate
	name = "Шаттл Ядерных Оперативников"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/trade
	name = "Торговый Шаттл"
	icon_state = "shuttle"

/area/shuttle/trade/sol
	name = "Фрегат ТСФ"
	parallax_move_direction = EAST

/area/shuttle/freegolem
	name = "Корабль Свободных Големов"
	icon_state = "purple"
	xenobiology_compatible = TRUE
	parallax_move_direction = WEST

/// Currently disabled as our shuttle system does not support TG-shuttle areas yet
// /area/shuttle/transit
// 	name = "Hyperspace"
// 	desc = "Weeeeee"
// 	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
// 	there_can_be_many = TRUE
