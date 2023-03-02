//Cortical borer spawn event - care of RobRichards1997 with minor editing by Zuhayr.

/datum/event/borer_infestation
	announceWhen = 400

	var/spawncount = 5
	var/successSpawn = FALSE        //So we don't make a command report if nothing gets spawned.

/datum/event/borer_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(2, 3)

/datum/event/borer_infestation/announce()
	if(successSpawn)
		GLOB.command_announcement.Announce("Обнаружены неопознанные формы жизни на борту [station_name()]. Обезопасьте все наружные входы и выходы, включая вентиляцию и вытяжки.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ.", new_sound = 'sound/AI/aliens.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Borer Infestation")

/datum/event/borer_infestation/start()
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	while(spawncount && length(vents))
		var/obj/vent = pick_n_take(vents)
		new /mob/living/simple_animal/borer(vent.loc)
		successSpawn = TRUE
		spawncount--
