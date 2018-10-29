/datum/event/alien_infestation
	announceWhen	= 400
	var/spawncount = 2
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.

/datum/event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/event/alien_infestation/announce()
	if(successSpawn)
		event_announcement.Announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')

/datum/event/alien_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 50)	//Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	spawn()
		var/list/candidates = pollCandidates("Do you want to play as an alien?", ROLE_ALIEN, 1)

		while(spawncount > 0 && vents.len && candidates.len)
			var/obj/vent = pick_n_take(vents)
			var/mob/C = pick_n_take(candidates)
			if(C)
				GLOB.respawnable_list -= C.client
				var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
				new_xeno.key = C.key
				if(ticker && ticker.mode)
					ticker.mode.xenos += new_xeno.mind

				spawncount--
				successSpawn = 1
