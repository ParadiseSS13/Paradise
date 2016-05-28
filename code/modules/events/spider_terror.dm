/var/global/sent_terror_spiders_to_station = 0

/datum/event/spider_terror
	announceWhen	= 400
	var/spawncount = 1

/datum/event/spider_terror/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = 1 //round(num_players() * 0.8)
	sent_terror_spiders_to_station = 1

/datum/event/spider_infestation/announce()
	command_announcement.Announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')

/datum/event/spider_terror/start()

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in all_vent_pumps)
		if((temp_vent.loc.z in config.station_levels) && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 50)
				vents += temp_vent

	while((spawncount >= 1) && vents.len)
		var/obj/vent = pick(vents)
		var/obj/effect/spider/spiderling/S = new(vent.loc)
		S.name = "evil-looking spiderling"
		S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/white,/mob/living/simple_animal/hostile/poison/terror_spider/mother,/mob/living/simple_animal/hostile/poison/terror_spider/prince,/mob/living/simple_animal/hostile/poison/terror_spider/queen)
		S.amount_grown = 50 // double-speed growth
		vents -= vent
		spawncount--