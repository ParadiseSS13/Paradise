/datum/event/electrical_storm
	var/lightsoutAmount	= 1
	var/lightsoutRange	= 25

/datum/event/electrical_storm/announce()
	GLOB.minor_announcement.Announce("An electrical storm has been detected in your area, please repair potential electronic overloads.", "Electrical Storm Alert", 'sound/AI/elec_storm.ogg')

/datum/event/electrical_storm/start()
	var/list/epicentreList = list()

	for(var/i=1, i <= lightsoutAmount, i++)
		var/list/possibleEpicentres = list()
		for(var/obj/effect/landmark/lightsout/newEpicentre in GLOB.landmarks_list)
			if(!(newEpicentre in epicentreList))
				possibleEpicentres += newEpicentre
		if(length(possibleEpicentres))
			epicentreList += pick(possibleEpicentres)
		else
			break

	if(!length(epicentreList))
		return

	for(var/thing in epicentreList)
		var/obj/effect/landmark/epicentre = thing
		for(var/obj/machinery/power/apc/apc in range(epicentre, lightsoutRange))
			INVOKE_ASYNC(apc, TYPE_PROC_REF(/obj/machinery/power/apc, overload_lighting))
