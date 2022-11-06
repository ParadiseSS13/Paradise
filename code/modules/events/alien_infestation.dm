/datum/event/alien_infestation
	announceWhen	= 400
	var/highpop_trigger = 80
	var/spawncount = 2
	var/list/playercount
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/event/alien_infestation/announce()
	if(successSpawn)
		GLOB.event_announcement.Announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Alien Infestation")

/datum/event/alien_infestation/start()
	playercount = length(GLOB.clients)//grab playercount when event starts not when game starts
	if(playercount >= highpop_trigger) //spawn with 4 if highpop
		spawncount = 4
	INVOKE_ASYNC(src, .proc/spawn_aliens)

/datum/event/alien_infestation/proc/spawn_aliens()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as an alien?", ROLE_ALIEN, TRUE, source = /mob/living/carbon/alien/larva)
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	if(!length(vents))
		message_admins("Warning: No suitable vents detected for spawning aliens. Force picking from station vents regardless of state!")
		vents = get_valid_vent_spawns(unwelded_only = FALSE, min_network_size = 0)
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			C.remove_from_respawnable_list()
			var/mob/living/carbon/alien/larva/new_alien = new(vent.loc)
			new_alien.amount_grown += (0.75 * new_alien.max_grown)	//event spawned larva start off almost ready to evolve.
			new_alien.key = C.key
			new_alien.forceMove(vent)
			new_alien.add_ventcrawl(vent)
			if(SSticker && SSticker.mode)
				SSticker.mode.aliens += new_alien.mind

			spawncount--
			successSpawn = TRUE
