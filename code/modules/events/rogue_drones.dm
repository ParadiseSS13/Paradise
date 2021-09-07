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
		msg = "A combat drone wing operating out of the NSV Icarus has failed to return from a sweep of this sector, if any are sighted approach with caution."
	else if(prob(50))
		msg = "Contact has been lost with a combat drone wing operating out of the NSV Icarus. If any are sighted in the area, approach with caution."
	else
		msg = "Unidentified hackers have targetted a combat drone wing deployed from the NSV Icarus. If any are sighted in the area, approach with caution."
	GLOB.event_announcement.Announce(msg, "Rogue drone alert")

/datum/event/rogue_drone/tick()
	return

/datum/event/rogue_drone/end()
	var/num_recovered = 0
	for(var/mob/living/simple_animal/hostile/malf_drone/D in drones_list)
		do_sparks(3, 0, D.loc)
		qdel(D)
		num_recovered++

	if(num_recovered > drones_list.len * 0.75)
		GLOB.event_announcement.Announce("Icarus drone control reports the malfunctioning wing has been recovered safely.", "Rogue drone alert")
	else
		GLOB.event_announcement.Announce("Icarus drone control registers disappointment at the loss of the drones, but the survivors have been recovered.", "Rogue drone alert")
