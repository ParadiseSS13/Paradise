/var/global/sent_aliens_to_station = 0

/datum/event/alien_infestation
	announceWhen	= 400
	var/spawncount = 1
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.

/datum/event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 2)
	sent_aliens_to_station = 1

/datum/event/alien_infestation/announce()
	if(successSpawn)
		command_announcement.Announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')

/datum/event/alien_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if((temp_vent.loc.z in config.station_levels) && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 50)	//Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	var/list/candidates = get_candidates(BE_ALIEN,ALIEN_AFK_BRACKET)

	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)
		if(C)
			respawnable_list -= C
			var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
			new_xeno.key = C.key

			spawncount--
			successSpawn = 1
			
