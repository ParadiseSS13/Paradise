/datum/event/spawn_morph
	var/key_of_morph

/datum/event/spawn_morph/proc/get_morph(end_if_fail = 0)
	key_of_morph = null
	if(!key_of_morph)
		var/list/candidates = get_candidates(ROLE_MORPH)
		if(!candidates.len)
			if(end_if_fail)
				return 0
			return find_morph()
		var/client/C = pick(candidates)
		key_of_morph = C.key
	if(!key_of_morph)
		if(end_if_fail)
			return 0
		return find_morph()
	var/datum/mind/player_mind = new /datum/mind(key_of_morph)
	player_mind.active = 1
	if(!xeno_spawn)
		return find_morph()
	var/mob/living/simple_animal/hostile/morph/S = new /mob/living/simple_animal/hostile/morph(pick(xeno_spawn))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Morph"
	player_mind.special_role = "Morph"
	ticker.mode.traitors |= player_mind
	S << S.playstyle_string
	S << 'sound/magic/Mutate.ogg'
	message_admins("[key_of_morph] has been made into morph by an event.")
	log_game("[key_of_morph] was spawned as a morph by an event.")
	return 1

/datum/event/spawn_morph/start()
	get_morph()


/datum/event/spawn_morph/proc/find_morph()
	message_admins("Attempted to spawn a morph but there was no players available. Will try again momentarily.")
	spawn(50)
		if(get_morph(1))
			message_admins("Situation has been resolved, [key_of_morph] has been spawned as a morph.")
			log_game("[key_of_morph] was spawned as a morph by an event.")
			return 0
		message_admins("Unfortunately, no candidates were available for becoming a morph. Shutting down.")
	return kill()
