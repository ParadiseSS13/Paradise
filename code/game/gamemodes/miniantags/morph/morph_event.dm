/datum/event/spawn_morph
	var/key_of_morph

/datum/event/spawn_morph/proc/get_morph()
	spawn()
		var/list/candidates = pollCandidates("Do you want to play as a morph?", ROLE_MORPH, 1)
		if(!candidates.len)
			key_of_morph = null
			return kill()
		var/mob/C = pick(candidates)
		key_of_morph = C.key

		if(!key_of_morph)
			return kill()

		var/datum/mind/player_mind = new /datum/mind(key_of_morph)
		player_mind.active = 1
		if(!xeno_spawn)
			return kill()
		var/mob/living/simple_animal/hostile/morph/S = new /mob/living/simple_animal/hostile/morph(pick(xeno_spawn))
		player_mind.transfer_to(S)
		player_mind.assigned_role = "Morph"
		player_mind.special_role = SPECIAL_ROLE_MORPH
		ticker.mode.traitors |= player_mind
		to_chat(S, S.playstyle_string)
		S << 'sound/magic/Mutate.ogg'
		message_admins("[key_of_morph] has been made into morph by an event.")
		log_game("[key_of_morph] was spawned as a morph by an event.")
		return 1

/datum/event/spawn_morph/start()
	get_morph()