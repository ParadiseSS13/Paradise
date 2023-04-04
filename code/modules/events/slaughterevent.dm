/datum/event/spawn_slaughter
	var/key_of_slaughter
	var/demon = /mob/living/simple_animal/slaughter/lesser

/datum/event/spawn_slaughter/proc/get_slaughter()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a slaughter demon?", ROLE_DEMON, TRUE, source = /mob/living/simple_animal/slaughter)
	if(!length(candidates))
		kill()
		return

	var/mob/C = pick(candidates)
	key_of_slaughter = C.key

	if(!key_of_slaughter)
		kill()
		return

	var/datum/mind/player_mind = new /datum/mind(key_of_slaughter)
	player_mind.active = TRUE
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/spawner/rev/L in GLOB.landmarks_list)
		spawn_locs += get_turf(L)
	if(!spawn_locs) //If we can't find a good place, just spawn the revenant at the player's location
		spawn_locs += get_turf(player_mind.current)
	if(!spawn_locs) //If we can't find THAT, then give up
		kill()
		return
	var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(pick(spawn_locs))
	var/mob/living/simple_animal/slaughter/S = new demon(holder)
	S.holder = holder
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Slaughter Demon"
	player_mind.special_role = SPECIAL_ROLE_SLAUGHTER_DEMON
	message_admins("[key_name_admin(S)] has been made into a Slaughter Demon by an event.")
	log_game("[key_name_admin(S)] was spawned as a Slaughter Demon by an event.")

/datum/event/spawn_slaughter/start()
	INVOKE_ASYNC(src, .proc/get_slaughter)

/datum/event/spawn_slaughter/greater
	demon = /mob/living/simple_animal/slaughter
