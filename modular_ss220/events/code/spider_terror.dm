#define TS_POINTS_GREEN 9
#define TS_POINTS_WHITE 17
#define TS_POINTS_PRINCESS 19
#define TS_POINTS_PRINCE 30
#define TS_POINTS_QUEEN 42


/datum/event/spider_terror
	announceWhen = 240
	var/population_factor = 0.7 // higher - more spawnpoints
	spawncount = 0 // amount of spawned spiders
	var/spawnpoints = TS_POINTS_GREEN // weight points
	/// lists for matching spiders and their weights

	var/list/spider_types = list(
		"TERROR_GREEN" = /mob/living/simple_animal/hostile/poison/terror_spider/green,
		"TERROR_WHITE" = /mob/living/simple_animal/hostile/poison/terror_spider/white,
		"TERROR_PRINCESS" = /mob/living/simple_animal/hostile/poison/terror_spider/queen/princess,
		"TERROR_PRINCE" = /mob/living/simple_animal/hostile/poison/terror_spider/prince,
		"TERROR_QUEEN" = /mob/living/simple_animal/hostile/poison/terror_spider/queen
	)

	var/list/spider_costs = list(
		"TERROR_GREEN" = TS_POINTS_GREEN,
		"TERROR_WHITE" = TS_POINTS_WHITE,
		"TERROR_PRINCESS" = TS_POINTS_PRINCESS,
		"TERROR_PRINCE" = TS_POINTS_PRINCE,
		"TERROR_QUEEN" = TS_POINTS_QUEEN
	)

	var/list/spider_counts = list(
		"TERROR_GREEN" = 0,
		"TERROR_WHITE" = 0,
		"TERROR_PRINCESS" = 0,
		"TERROR_PRINCE" = 0,
		"TERROR_QUEEN" = 0
	)

/datum/event/spider_terror/start()
	spawncount = 0 // yeah, still not 0
	// It is necessary to wrap this to avoid the event triggering repeatedly.
	INVOKE_ASYNC(src, PROC_REF(wrappedstart_new))

/datum/event/spider_terror/proc/wrappedstart_new()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a terror spider?", null, TRUE, source = /mob/living/simple_animal/hostile/poison/terror_spider) // questionable
	var/max_spiders = length(candidates)
	log_debug("where is [max_spiders] candidates")
	spawnpoints += round(population_factor * length(GLOB.clients)) // server population sensitivity
	log_debug("where is [spawnpoints] available spawnpoints")
	spawn_terror_spiders(count_spawn_spiders(max_spiders), candidates)
	SSevents.biohazards_this_round += 1

/datum/event/spider_terror/proc/count_spawn_spiders(max_spiders)
	while(spawnpoints >= TS_POINTS_GREEN && spawncount < max_spiders)
		var/chosen_spider_id = pick(spider_costs) // random spider type choose
		var/cost = spider_costs[chosen_spider_id]

		if(spawnpoints - cost >= 0)
			spider_counts[chosen_spider_id] += 1
			spawnpoints -= cost
			spawncount += 1
			log_debug("spider added into pool: [chosen_spider_id]")
			log_debug("where is [spawnpoints] available spawnpoints now")

		if(spawnpoints < TS_POINTS_GREEN || spawncount >= max_spiders)
			break

	log_debug("selected [spawncount] spider(s)")
	return spider_counts

/datum/event/spider_terror/proc/spawn_terror_spiders(list/spider_counts, candidates)
	log_debug("begin spiders spawning")
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	if(!length(vents))
		message_admins("Warning: No suitable vents detected for spawning terrors. Force picking from station vents regardless of state!")
		vents = get_valid_vent_spawns(unwelded_only = FALSE, min_network_size = 0)

	log_debug("where is awailible [length(vents)] vents")
	log_debug("spawncount is:  [spawncount] vents")
	while(spawncount && length(vents) && length(candidates))
		for(var/spider_id in spider_counts)
			var/spider_type = spider_types[spider_id]
			var/spider_count = spider_counts[spider_id]
			log_debug("entering inner while cycle")
			while(spider_count > 0 && length(candidates))
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

				spider_count--

			if(spawncount <= 0)
				break

			spider_counts[spider_type] = 0

	log_and_message_admins("spiders spawned successfully")

#undef TS_POINTS_GREEN
#undef TS_POINTS_WHITE
#undef TS_POINTS_PRINCESS
#undef TS_POINTS_PRINCE
#undef TS_POINTS_QUEEN
