#define TS_HIGHPOP_TRIGGER 80

/datum/event/spider_terror
	announceWhen = 240
	var/spawncount = 1
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/spider_terror/setup()
	announceWhen = rand(announceWhen, announceWhen + 30)
	spawncount = 1

/datum/event/spider_terror/announce(false_alarm)
	if(successSpawn || false_alarm)
		GLOB.major_announcement.Announce("Terror Spider infestation detected aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/effects/siren-spooky.ogg', new_sound2 = 'sound/AI/outbreak_terror.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Terror Spiders")

/datum/event/spider_terror/start()
	// It is necessary to wrap this to avoid the event triggering repeatedly.
	INVOKE_ASYNC(src, PROC_REF(wrappedstart))

/datum/event/spider_terror/proc/wrappedstart()
	var/spider_type
	var/infestation_type
	if((length(GLOB.clients)) < TS_HIGHPOP_TRIGGER)
		infestation_type = pick(TS_INFESTATION_GREEN_SPIDER, TS_INFESTATION_PRINCE_SPIDER, TS_INFESTATION_WHITE_SPIDER, TS_INFESTATION_PRINCESS_SPIDER)
	else
		infestation_type = pick(TS_INFESTATION_PRINCE_SPIDER, TS_INFESTATION_WHITE_SPIDER, TS_INFESTATION_PRINCESS_SPIDER, TS_INFESTATION_QUEEN_SPIDER)
	switch(infestation_type)
		if(TS_INFESTATION_GREEN_SPIDER)
			// Weakest, only used during lowpop.
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/green
			spawncount = 5
		if(TS_INFESTATION_PRINCE_SPIDER)
			// Fairly weak. Dangerous in single combat but has little staying power. Always gets whittled down.
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/prince
			spawncount = 1
		if(TS_INFESTATION_WHITE_SPIDER)
			// Variable. Depends how many they infect.
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/white
			spawncount = 2
		if(TS_INFESTATION_PRINCESS_SPIDER)
			// Pretty strong.
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen/princess
			spawncount = 3
		if(TS_INFESTATION_QUEEN_SPIDER)
			// Strongest, only used during highpop.
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen
			spawncount = 1
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a terror spider?", null, TRUE, source = spider_type)
	if(length(candidates) < spawncount)
		message_admins("Warning: not enough players volunteered to be terrors. Could only spawn [length(candidates)] out of [spawncount]!")
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	if(!length(vents))
		message_admins("Warning: No suitable vents detected for spawning terrors. Force picking from station vents regardless of state!")
		vents = get_valid_vent_spawns(unwelded_only = FALSE, min_network_size = 0)
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/living/simple_animal/hostile/poison/terror_spider/S = new spider_type(vent.loc)
		var/mob/M = pick_n_take(candidates)
		S.key = M.key
		dust_if_respawnable(M)
		S.forceMove(vent)
		S.add_ventcrawl(vent)
		SEND_SOUND(S, sound('sound/ambience/antag/terrorspider.ogg'))
		S.give_intro_text()
		spawncount--
		successSpawn = TRUE
	SSticker.record_biohazard_start(infestation_type)
	SSevents.biohazards_this_round += infestation_type

#undef TS_HIGHPOP_TRIGGER
