/datum/event/solar_flare
	startWhen = 10
	endWhen = 500 // = ~500x2 seconds or ~16m40s

/datum/event/solar_flare/announce()
	GLOB.event_announcement.Announce("A solar flare has been detected on collision course with the station.", "Flare Alert", new_sound = 'sound/AI/attention.ogg')

/datum/event/solar_flare/start()
	// Solars produce 40x as much power. 240KW becomes 9.6MW. Enough to cause APCs to arc all over the station if >=2 solars are hotwired.
	SSsun.solar_gen_rate = 1500 * 40

/datum/event/solar_flare/tick()
	// Constant burn damage to anyone in space on the station zlevel.
	// Not instantly fatal (5dmg/10s = 0.5damage/second) but you should go find shelter.
	if(activeFor % 5 == 0)
		for(var/mob/living/L in GLOB.alive_mob_list)
			var/turf/T = get_turf(L)
			if(!istype(T))
				continue
			if(!isspaceturf(T))
				continue
			if(!is_station_level(T.z))
				continue
			L.adjustFireLoss(5)
			to_chat(L, "<span class='warning'>The solar flare burns you! Seek shelter!")

/datum/event/solar_flare/end()
	SSsun.solar_gen_rate = 1500
	GLOB.event_announcement.Announce("The solar flare has ended.", "Flare Alert", new_sound = 'sound/AI/attention.ogg')
