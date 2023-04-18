/datum/event/pirate_raid
	announceWhen	= 400
	var/highpop_trigger = 80
	var/spawncount = 2
	var/list/playercount
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/pirate_raid/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/event/pirate_raid/announce()
	if(successSpawn)
		GLOB.major_announcement.Announce("Confirmed outbreak of pirate activity aboard [station_name()]. All personnel must contain the threat.", "Pirate Alert", 'sound/effects/siren-spooky.ogg', new_sound2 = 'sound/AI/outbreak3.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Pirate Infestation")

/datum/event/pirate_raid/start()
	playercount = length(GLOB.clients)//grab playercount when event starts not when game starts
	if(playercount >= highpop_trigger) //spawn with 4 if highpop
		spawncount = 4
	INVOKE_ASYNC(src, PROC_REF(spawn_pirates))

/datum/event/pirate_raid/proc/spawn_pirates()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a pirate?", ROLE_PIRATE, TRUE, source = /mob/living/carbon/human/pirate)
	var/list/spawn_locations = get_valid_pirate_spawns()
	if(!length(spawn_locations))
		message_admins("Warning: No suitable locations detected for spawning pirates!")
		return
	while(spawncount && length(spawn_locations) && length(candidates))
		var/turf/location = pick_n_take(spawn_locations)
		var/mob/C = pick_n_take(candidates)
		if(C)
			C.remove_from_respawnable_list()
			var/mob/living/carbon/human/pirate/new_pirate = new(location)
			new_pirate.key = C.key
			new_pirate.forceMove(location)

			if(SSticker && SSticker.mode)
				SSticker.mode.pirates += new_pirate.mind

			spawncount--
			successSpawn = TRUE
