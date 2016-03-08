/proc/alien_infestation(var/spawncount = 1) // -- TLE
	//command_announcement.Announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in machines)
		if((temp_vent.loc.z in config.station_levels) && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 50) // Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	spawn()
		var/list/candidates = pollCandidates("Do you want to play as an alien?", ROLE_ALIEN, 1)

		if(prob(40)) spawncount++ //sometimes, have two larvae spawn instead of one
		while((spawncount >= 1) && vents.len && candidates.len)

			var/obj/vent = pick(vents)
			var/mob/candidate = pick(candidates)
			var/client/C = candidate.client
			if(C)
				var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
				new_xeno.key = C
				respawnable_list -= C
				candidates -= C
				vents -= vent
				spawncount--

		spawn(rand(5000, 6000)) //Delayed announcements to keep the crew on their toes.
			command_announcement.Announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')
			for(var/mob/M in player_list)
				M << sound('sound/AI/aliens.ogg')

/proc/lightsout(isEvent = 0, lightsoutAmount = 1,lightsoutRange = 25) //leave lightsoutAmount as 0 to break ALL lights
	if(isEvent)
		command_announcement.Announce("An Electrical storm has been detected in your area, please repair potential electronic overloads.","Electrical Storm Alert")

	if(lightsoutAmount)
		var/list/epicentreList = list()

		for(var/i=1,i<=lightsoutAmount,i++)
			var/list/possibleEpicentres = list()
			for(var/obj/effect/landmark/newEpicentre in landmarks_list)
				if(newEpicentre.name == "lightsout" && !(newEpicentre in epicentreList))
					possibleEpicentres += newEpicentre
			if(possibleEpicentres.len)
				epicentreList += pick(possibleEpicentres)
			else
				break

		if(!epicentreList.len)
			return

		for(var/obj/effect/landmark/epicentre in epicentreList)
			for(var/obj/machinery/power/apc/apc in range(epicentre,lightsoutRange))
				apc.overload_lighting()

	else
		for(var/obj/machinery/power/apc/apc in machines)
			apc.overload_lighting()

	return
