/datum/event/spider_infestation
	announceWhen	= 400
	var/spawncount = 1
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = round(num_players() * 0.8)

/datum/event/spider_infestation/announce(false_alarm)
	if(successSpawn || false_alarm)
		GLOB.minor_announcement.Announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Spider Infestation")

/datum/event/spider_infestation/start()
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	while(spawncount && length(vents))
		var/obj/vent = pick_n_take(vents)
		var/obj/structure/spider/spiderling/S = new(vent.loc)
		if(prob(66))
			S.grow_as = /mob/living/basic/giant_spider/nurse
		spawncount--
		successSpawn = TRUE
