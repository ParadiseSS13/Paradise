GLOBAL_VAR_INIT(sent_spiders_to_station, 0)

/datum/event/spider_infestation
	announceWhen	= 400
	var/spawncount = 1
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = round(num_players() * 0.8)
	GLOB.sent_spiders_to_station = 1

/datum/event/spider_infestation/announce()
	if(successSpawn)
		GLOB.event_announcement.Announce("Обнаружены неопознанные формы жизни на борту станции [station_name()]. Обезопасьте все наружные входы и выходы, включая вентиляцию и вытяжки.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ.", new_sound = 'sound/AI/aliens.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Spider Infestation")

/datum/event/spider_infestation/start()
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	while(spawncount && length(vents))
		var/obj/vent = pick_n_take(vents)
		var/obj/structure/spider/spiderling/S = new(vent.loc)
		if(prob(66))
			S.grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/nurse
		spawncount--
		successSpawn = TRUE
