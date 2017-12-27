//Cortical borer spawn event - care of RobRichards1997 with minor editing by Zuhayr.

/datum/event/borer_infestation
	announceWhen = 400

	var/spawncount = 5
	var/successSpawn = FALSE        //So we don't make a command report if nothing gets spawned.

/datum/event/borer_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(2, 3)

/datum/event/borer_infestation/announce()
	if(successSpawn)
		command_announcement.Announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')

/datum/event/borer_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			//Stops cortical borers getting stuck in small networks. See: Security, Virology
			if(temp_vent.parent.other_atmosmch.len > 50)
				vents += temp_vent

	while(spawncount >= 1 && vents.len)
		var/obj/vent = pick_n_take(vents)
		new /mob/living/simple_animal/borer(vent.loc)
		successSpawn = TRUE
		spawncount--
