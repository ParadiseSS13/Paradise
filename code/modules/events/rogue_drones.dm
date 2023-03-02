/datum/event/rogue_drone
	startWhen = 10
	endWhen = 1000
	var/list/drones_list = list()

/datum/event/rogue_drone/start()
	var/list/possible_spawns = list()
	for(var/thing in GLOB.landmarks_list)
		var/obj/effect/landmark/C = thing
		if(C.name == "carpspawn") //spawn them at the same place as carp
			possible_spawns.Add(C)

	var/num = rand(2, 12)
	for(var/i = 0, i < num, i++)
		var/mob/living/simple_animal/hostile/malf_drone/D = new(get_turf(pick(possible_spawns)))
		drones_list.Add(D)

/datum/event/rogue_drone/announce()
	var/msg
	if(prob(33))
		msg = "Группа боевых дронов, оперируемых с борта ИКН «Икар», не вернулась с зачистки сектора. В случае контакта с дронами проявляйте осторожность."
	else if(prob(50))
		msg = "Потеряна связь с группой боевых дронов, оперируемых с борта ИКН «Икар». В случае контакта с дронами проявляйте осторожность."
	else
		msg = "Неопознанные хакеры взломали систему контроля боевых дронов, оперируемых с борта ИКН «Икар». В случае контакта с дронами проявляйте осторожность."
	GLOB.event_announcement.Announce(msg, "ВНИМАНИЕ: СБОЙНЫЕ ДРОНЫ.")

/datum/event/rogue_drone/tick()
	return

/datum/event/rogue_drone/end()
	var/num_recovered = 0
	for(var/mob/living/simple_animal/hostile/malf_drone/D in drones_list)
		do_sparks(3, 0, D.loc)
		qdel(D)
		num_recovered++

	if(num_recovered > drones_list.len * 0.75)
		GLOB.event_announcement.Announce("Система контроля боевых дронов сообщает, что все единицы успешно вернулись на борт «Икара».", "ВНИМАНИЕ: СБОЙНЫЕ ДРОНЫ.")
	else
		GLOB.event_announcement.Announce("Система контроля боевых дронов сообщает о потере всех боевых единиц, однако жертв не зарегистрировано.", "ВНИМАНИЕ: СБОЙНЫЕ ДРОНЫ.")
