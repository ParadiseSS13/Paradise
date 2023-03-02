/datum/event/electrical_storm
	var/lightsoutAmount	= 1
	var/lightsoutRange	= 25

/datum/event/electrical_storm/announce()
	GLOB.event_announcement.Announce("На борту станции зафиксирован электрический шторм. Пожалуйста, устраните потенциальные перегрузки электросетей.", "ВНИМАНИЕ: ЭЛЕКТРИЧЕСКИЙ ШТОРМ.")

/datum/event/electrical_storm/start()
	var/list/epicentreList = list()

	for(var/i=1, i <= lightsoutAmount, i++)
		var/list/possibleEpicentres = list()
		for(var/thing in GLOB.landmarks_list)
			var/obj/effect/landmark/newEpicentre = thing
			if(newEpicentre.name == "lightsout" && !(newEpicentre in epicentreList))
				possibleEpicentres += newEpicentre
		if(possibleEpicentres.len)
			epicentreList += pick(possibleEpicentres)
		else
			break

	if(!epicentreList.len)
		return

	for(var/thing in epicentreList)
		var/obj/effect/landmark/epicentre = thing
		for(var/obj/machinery/power/apc/apc in range(epicentre, lightsoutRange))
			INVOKE_ASYNC(apc, /obj/machinery/power/apc.proc/overload_lighting)

