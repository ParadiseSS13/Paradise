#define TS_HIGHPOP_TRIGGER 90
#define TS_MIDPOP_TRIGGER 55

/datum/event/spider_terror
	announceWhen = 240
	var/spawncount = 1
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/spider_terror/setup()
	announceWhen = rand(announceWhen, announceWhen + 30)
	spawncount = 1

/datum/event/spider_terror/announce()
	if(successSpawn)
		GLOB.command_announcement.Announce("Вспышка биологической угрозы 3-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать ее распространение любой ценой!", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА", 'sound/effects/siren-spooky.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Terror Spiders")

/datum/event/spider_terror/start()
	// It is necessary to wrap this to avoid the event triggering repeatedly.
	INVOKE_ASYNC(src, .proc/wrappedstart)

/datum/event/spider_terror/proc/wrappedstart()
	var/spider_type
	var/infestation_type
	if((length(GLOB.clients)) <= TS_MIDPOP_TRIGGER)
		infestation_type = 1
	else if((length(GLOB.clients)) >= TS_HIGHPOP_TRIGGER)
		infestation_type = pick(3, 4)
	else
		infestation_type = 2
	switch(infestation_type)
		if(1)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen/princess
			spawncount = 2
		if(2)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen/princess
			spawncount = 3
		if(3)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen
			spawncount = 1
		if(4)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen/princess
			spawncount = 4
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Паука Террора?", null, TRUE, source = spider_type)
	if(length(candidates) < spawncount)
		message_admins("Warning: not enough players volunteered to be terrors. Could only spawn [length(candidates)] out of [spawncount]!")
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/living/simple_animal/hostile/poison/terror_spider/S = new spider_type(vent.loc)
		var/mob/M = pick_n_take(candidates)
		S.key = M.key
		S.give_intro_text()
		spawncount--
		successSpawn = TRUE

#undef TS_HIGHPOP_TRIGGER

