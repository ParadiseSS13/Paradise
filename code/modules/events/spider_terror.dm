
/datum/event/spider_terror
	announceWhen = 240
	var/spawncount = 1

/datum/event/spider_terror/setup()
	announceWhen = rand(announceWhen, announceWhen + 30)
	spawncount = 1

/datum/event/spider_terror/announce()
	command_announcement.Announce("Confirmed outbreak of level 3 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/effects/siren-spooky.ogg')

/datum/event/spider_terror/start()

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in all_vent_pumps)
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 50)
				vents += temp_vent
	var/spider_type
	var/infestation_type = pick(1, 2, 3, 4, 5)
	switch(infestation_type)
		if(1)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/green
			spawncount = 5
		if(2)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/white
			spawncount = 2
		if(3)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/prince
			spawncount = 1
		if(4)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen
			spawncount = 1
		if(5)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/mother
			spawncount = 1
	while(spawncount >= 1 && vents.len)
		var/obj/vent = pick(vents)
		var/obj/structure/spider/spiderling/terror_spiderling/S = new(vent.loc)
		S.grow_as = spider_type
		S.amount_grown = 90
		vents -= vent
		spawncount--