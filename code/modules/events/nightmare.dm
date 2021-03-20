/datum/event/nightmare
	var/key_of_nightmare

/datum/event/nightmare/proc/get_nightmare()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a nightmare?", ROLE_NIGHTMARE, TRUE, source = /mob/living/carbon/human/nightmare)
	if(!length(candidates))
		kill()
		return

	var/mob/C = pick(candidates)
	key_of_nightmare = C.key

	if(!key_of_nightmare)
		kill()
		return

	var/datum/mind/player_mind = new /datum/mind(key_of_nightmare)
	player_mind.active = TRUE
	var/list/spawn_locs = list()
	for(var/X in GLOB.xeno_spawn)
		var/turf/T = X
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += T

	if(!length(spawn_locs))
		message_admins("No valid spawn locations found for nightmare, aborting...")
		kill()
		return
	var/mob/living/carbon/human/nightmare/N = new((pick(spawn_locs)))
	player_mind.transfer_to(N)
	player_mind.assigned_role = SPECIAL_ROLE_NIGHTMARE
	player_mind.special_role = SPECIAL_ROLE_NIGHTMARE
	playsound(N, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(N)] has been made into a Nightmare by an event.")
	log_game("[key_name(N)] was spawned as a Nightmare by an event.")

/datum/event/nightmare/start()
	INVOKE_ASYNC(src, .proc/get_nightmare)
