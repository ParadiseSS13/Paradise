/datum/event/rogue_drone
	startWhen = 10
	endWhen = 1000
	var/list/drones_list = list()

/datum/event/rogue_drone/start()
	//spawn them at the same place as carp
	var/list/possible_spawns = list()
	for(var/obj/effect/landmark/C in GLOB.landmarks_list)
		if(C.name == "carpspawn")
			possible_spawns.Add(C)

	//25% chance for this to be a false alarm
	var/num
	if(prob(25))
		num = 0
	else
		num = rand(2,6)
	for(var/i=0, i<num, i++)
		var/mob/living/simple_animal/hostile/retaliate/malf_drone/D = new(get_turf(pick(possible_spawns)))
		drones_list.Add(D)
		if(prob(25))
			D.disabled = rand(15, 60)

/datum/event/rogue_drone/announce()
	var/msg
	if(prob(33))
		msg = "Un ala de drones no tripulados de combate que opera desde el NSV Icarus no ha podido regresar luego de un barrido en este sector, si ve alguno acerquese con precaucion."
	else if(prob(50))
		msg = "Se ha perdido el contacto con un ala de drones de combate que opera desde el NSV Icarus. Si se observa alguno en el area, acerquese con precaucion."
	else
		msg = "Piratas informaticos no identificados han hackeado un ala de aviones no tripulados de combate desplegado desde el NSV Icarus. Si se observa alguno en el area, acerquese con precaucion."
	GLOB.event_announcement.Announce(msg, "Rogue drone alert")

/datum/event/rogue_drone/tick()
	return

/datum/event/rogue_drone/end()
	var/num_recovered = 0
	for(var/mob/living/simple_animal/hostile/retaliate/malf_drone/D in drones_list)
		do_sparks(3, 0, D.loc)
		D.z = level_name_to_num(CENTCOMM)
		D.has_loot = 0

		qdel(D)
		num_recovered++

	if(num_recovered > drones_list.len * 0.75)
		GLOB.event_announcement.Announce("El control de drones Icarus informa que el ala que funcionaba mal se ha recuperado de manera segura.", "Alerta de drone renegado")
	else
		GLOB.event_announcement.Announce("El control de drones Icarus registra desilusion por la perdida de los drones, pero los sobrevivientes han sido recuperados.", "Alerta de drone renegado")
