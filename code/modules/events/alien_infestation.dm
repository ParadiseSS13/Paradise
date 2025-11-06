/datum/event/alien_infestation
	announceWhen	= 400
	var/highpop_trigger = 80
	var/spawncount = 2
	var/list/playercount
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/event/alien_infestation/announce(false_alarm)
	if(successSpawn || false_alarm)
		GLOB.major_announcement.Announce("Xenomorph infestation detected aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/effects/siren-spooky.ogg', new_sound2 = 'sound/AI/outbreak_xeno.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Alien Infestation")

/datum/event/alien_infestation/start()
	playercount = length(GLOB.clients)//grab playercount when event starts not when game starts
	if(playercount >= highpop_trigger) //spawn with 4 if highpop
		spawncount = 4
	if(length(GLOB.crew_list) < 50) // manifest must have 50 crew to roll
		// if xenos dont roll due to pop, try again to roll for a major in 60 seconds
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		EC.next_event_time = world.time + 1 MINUTES
		return
	INVOKE_ASYNC(src, PROC_REF(spawn_xenos))

/datum/event/alien_infestation/proc/spawn_xenos()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as an alien?", ROLE_ALIEN, TRUE, source = /mob/living/carbon/alien/larva)
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	if(!length(vents))
		message_admins("Warning: No suitable vents detected for spawning xenomorphs. Force picking from station vents regardless of state!")
		vents = get_valid_vent_spawns(unwelded_only = FALSE, min_network_size = 0)
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
			new_xeno.amount_grown += (0.75 * new_xeno.max_grown)	//event spawned larva start off almost ready to evolve.
			new_xeno.key = C.key
			dust_if_respawnable(C)
			new_xeno.forceMove(vent)
			new_xeno.add_ventcrawl(vent)
			if(SSticker && SSticker.mode)
				SSticker.mode.xenos += new_xeno.mind

			spawncount--
			successSpawn = TRUE
	SSticker.record_biohazard_start(BIOHAZARD_XENO)
	SSevents.biohazards_this_round += BIOHAZARD_XENO
