GLOBAL_LIST_EMPTY(bluespace_rifts_list)
GLOBAL_LIST_EMPTY(bluespace_rifts_server_list)
GLOBAL_LIST_EMPTY(bluespace_rifts_scanner_list)


// BRS - Bluespace Rift Scan
// The goal is to research the anomalous bluespace rift.
/datum/station_goal/bluespace_rift
	name = "Сканирование блюспейс разлома"
	var/target_research_points = 25000
	var/reward_given = FALSE
	var/datum/bluespace_rift/rift

/datum/station_goal/bluespace_rift/Destroy()

	for(var/obj/machinery/brs_server/server as anything in GLOB.bluespace_rifts_server_list)
		server.remove_rift_data(UID())

	QDEL_NULL(rift)
	. = ..()

/datum/station_goal/bluespace_rift/get_report()
	return {"<b>Сканирование блюспейс разлома</b>
	<br><br>
	По нашим данным, в непосредственной близости от станции образовалось редкое аномальное явление — блюспейс разлом.
	Порождённые им объекты в настоящий момент дрейфуют по отсекам станции.
	<br><br>
	Обнаруженный разлом был классифицирован как [rift.name],<br>
	индексы его объектов:<br>
	[get_rift_object_names()]<br>
	Такие аномальные образования невозможно заметить невооруженным глазом, однако последние теоретические изыскания позволяют предположить,
	что некоторые проявления блюспейс-активности могут быть обнаружены при помощи инженерных T-ray сканеров.
	Постарайтесь усовершенствовать данные приборы, у научного отдела станции должны быть все необходимые для этого технологии.
	<br><br>
	Получите экспериментальные проекты сканеров в отделе карго и соберите как можно больше данных о разломе.
	Собранные данные отправятся на изучение в центральный научно-исследовательский отдел Нанотрейзен.
	<br><br>
	Разлом не представляет опасности для структурной целостности станции. Тем не менее, сканирующая аппаратура может вызвать колебания его стабильности.
	Соблюдайте осторожность при проведении исследований, вы ответственны за любой ущерб имуществу корпорации.
	<br><br>"}

/datum/station_goal/bluespace_rift/on_report()
	spawn_rift()

	var/datum/supply_packs/misc/station_goal/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/bluespace_rift]"]
	P.special_enabled = TRUE
	supply_list.Add(P)

/datum/station_goal/bluespace_rift/check_completion()
	if(..())
		return TRUE
	var/is_research_complete = (get_current_research_points() >= target_research_points)
	return is_research_complete

/datum/station_goal/bluespace_rift/proc/get_current_research_points()
	var/max_points = 0
	for(var/obj/machinery/brs_server/server as anything in GLOB.bluespace_rifts_server_list)
		max_points = max(max_points, server.get_goal_points(UID()))
	return max_points

/datum/station_goal/bluespace_rift/proc/spawn_rift()
	if(rift)
		return
	var/rift_types = list(
		/datum/bluespace_rift,
		/datum/bluespace_rift/big,
		/datum/bluespace_rift/fog,
		/datum/bluespace_rift/twin,
		/datum/bluespace_rift/crack,
		/datum/bluespace_rift/hunter,
	)
	var/rand_rift_type = pick(rift_types)
	rift = new rand_rift_type(goal_uid = UID())

/datum/station_goal/bluespace_rift/proc/get_rift_object_names()
	if(!length(rift.rift_objects))
		return "Объекты не найдены <br>"

	var/result = ""
	for (var/obj/effect/abstract/bluespace_rift/rift_obj as anything in rift.rift_objects)
		result += "[rift_obj.name] <br>"
	return result
