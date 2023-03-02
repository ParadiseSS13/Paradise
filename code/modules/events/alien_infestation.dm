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
		GLOB.event_announcement.Announce("Обнаружены неопознанные формы жизни на борту станции [station_name()]. Обезопасьте все наружные входы и выходы, включая вентиляцию и вытяжки.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ.", new_sound = 'sound/AI/aliens.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Alien Infestation")

/datum/event/alien_infestation/start()
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	playercount = length(GLOB.clients)//grab playercount when event starts not when game starts
	if(playercount >= highpop_trigger) //spawn with 4 if highpop
		spawncount = 4

	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за Чужого?", ROLE_ALIEN, TRUE, source = /mob/living/carbon/alien/larva)
		while(spawncount && length(vents) && length(candidates))
			var/obj/vent = pick_n_take(vents)
			var/mob/C = pick_n_take(candidates)
			if(C)
				GLOB.respawnable_list -= C.client
				var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
				new_xeno.amount_grown += (0.75 * new_xeno.max_grown)	//event spawned larva start off almost ready to evolve.
				new_xeno.key = C.key
				if(SSticker && SSticker.mode)
					SSticker.mode.xenos += new_xeno.mind

				spawncount--
				successSpawn = TRUE
