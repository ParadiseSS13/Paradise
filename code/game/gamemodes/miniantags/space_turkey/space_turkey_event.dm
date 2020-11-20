//Space turkey spawn event - Based off borer spawn event, created by RobRichards1997 and Zuhayr, modified by DaveKorhal

/datum/event/turkey_infestation
	announceWhen = 60

	var/spawncount = 3
	var/successSpawn = FALSE        //So we don't make a command report if nothing gets spawned.

/datum/event/turkey_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 30)
	var/players_per_turkey = 30
	var/minimumTurkeys = round(num_players()/players_per_turkey, 1)+1
	spawncount = rand(minimumTurkeys, minimumTurkeys+2)

/datum/event/turkey_infestation/announce()
	if(successSpawn)
		GLOB.command_announcement.Announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Turkey Infestation")

/datum/event/turkey_infestation/start()
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	while(spawncount && length(vents))
		var/obj/vent = pick_n_take(vents)
		new /mob/living/simple_animal/turkey/space_turkey(vent.loc)
		successSpawn = TRUE
		spawncount--
