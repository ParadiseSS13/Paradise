/datum/event/spawn_slaughter
	var/key_of_slaughter

/datum/event/spawn_slaughter/proc/get_slaughter(var/end_if_fail = 0)
	var/time_passed = world.time
	key_of_slaughter = null
	if(!key_of_slaughter)
		var/list/candidates = get_candidates(BE_ALIEN)
		if(!candidates.len)
			if(end_if_fail)
				return 0
			return find_slaughter()
		var/client/C = pick(candidates)
		var/input = alert(C,"Do you want to spawn in as a Slaughter Demon?","Please answer in thirty seconds!","Yes","No")
		if(input == "Yes")
			if((world.time-time_passed)>300)
				return
			key_of_slaughter = C.key
	if(!key_of_slaughter)
		if(end_if_fail)
			return 0
		return find_slaughter()
	var/datum/mind/player_mind = new /datum/mind(key_of_slaughter)
	player_mind.active = 1
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/L in landmarks_list)
		if(isturf(L.loc))
			switch(L.name)
				if("carpspawn")
					spawn_locs += L.loc
	if(!spawn_locs)
		return find_slaughter()
	var /obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(pick(spawn_locs))
	var/mob/living/simple_animal/slaughter/S = new /mob/living/simple_animal/slaughter/(holder)
	var/datum/objective/new_objective = new /datum/objective
	S.phased = TRUE
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Slaughter Demon"
	player_mind.special_role = "Slaughter Demon"
	ticker.mode.traitors |= player_mind
	new_objective.owner = player_mind
	new_objective.explanation_text = "Kill or Toy with the rest of the crew. Make them know fear!"
	player_mind.objectives += new_objective
	S << S.playstyle_string
	S << "<B>You are not currently in the same plane of existence as the station. Ctrl+Click a blood pool to manifest.</B>"
	S << "<B>Objective #[1]</B>: [new_objective.explanation_text]"
	message_admins("[key_of_slaughter] has been made into a Slaughter Demon by an event.")
	log_game("[key_of_slaughter] was spawned as a Slaughter Demon by an event.")
	return 1



/datum/event/spawn_slaughter/start()
	get_slaughter()



/datum/event/spawn_slaughter/proc/find_slaughter()
	message_admins("Attempted to spawn a Slaughter Demon but there was no players available. Will try again momentarily.")
	spawn(50)
		if(get_slaughter(1))
			message_admins("Situation has been resolved, [key_of_slaughter] has been spawned as a Slaughter Demon.")
			log_game("[key_of_slaughter] was spawned as a Slaughter Demon by an event.")
			return 0
		message_admins("Unfortunately, no candidates were available for becoming a Slaugter Demon. Shutting down.")
	kill()
	return
