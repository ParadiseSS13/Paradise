/datum/event/spawn_morph
	name = "Morph Spawn"
	noAutoEnd = TRUE
	nominal_severity = EVENT_LEVEL_MAJOR
	role_weights = list(ASSIGNMENT_SECURITY = 3, ASSIGNMENT_CREW = 1)
	role_requirements = list(ASSIGNMENT_SECURITY = 4, ASSIGNMENT_CREW = 35)
	var/key_of_morph
	var/spawned = FALSE

/datum/event/spawn_morph/tick()
	if(!length(event_category_cost(EVENT_MORPH)) && spawned)
		kill()

// Cost is calculated independently of event
/datum/event/spawn_morph/event_resource_cost()
	return list()

/datum/event/spawn_morph/proc/get_morph()
	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a morph?", ROLE_MORPH, TRUE, source = /mob/living/simple_animal/hostile/morph)
		if(!length(candidates))
			key_of_morph = null
			kill()
			return
		var/mob/C = pick(candidates)
		key_of_morph = C.key

		if(!key_of_morph)
			kill()
			return

		var/datum/mind/player_mind = new /datum/mind(key_of_morph)
		player_mind.active = TRUE
		var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
		if(!length(vents))
			message_admins("Warning: No suitable vents detected for spawning morphs. Force picking from station vents regardless of state!")
			vents = get_valid_vent_spawns(unwelded_only = FALSE, min_network_size = 0)
			if(!length(vents))
				message_admins("Warning: No vents detected for spawning morphs at all!")
				return
		var/obj/vent = pick(vents)
		var/mob/living/simple_animal/hostile/morph/S = new /mob/living/simple_animal/hostile/morph(vent.loc)
		player_mind.transfer_to(S)
		S.make_morph_antag()
		S.forceMove(vent)
		S.add_ventcrawl(vent)
		spawned = TRUE
		dust_if_respawnable(C)
		message_admins("[key_of_morph] has been made into morph by an event.")
		log_game("[key_of_morph] was spawned as a morph by an event.")

/datum/event/spawn_morph/start()
	get_morph()
