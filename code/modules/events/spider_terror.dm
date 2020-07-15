
/datum/event/spider_terror
	announceWhen = 240
	var/spawncount = 1
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/spider_terror/setup()
	announceWhen = rand(announceWhen, announceWhen + 30)
	spawncount = 1

/datum/event/spider_terror/announce()
	if(successSpawn)
		GLOB.command_announcement.Announce("Confirmed outbreak of level 3 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/effects/siren-spooky.ogg')
	else
		var/text = "Warning: Could not spawn any mobs for event Terror Spiders"
		message_admins(text)
		log_adminwarn(text)

/datum/event/spider_terror/start()
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
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
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/princess
			spawncount = 2
	while(spawncount && length(vents))
		var/obj/vent = pick_n_take(vents)
		new spider_type(vent.loc)
		spawncount--
		successSpawn = TRUE

