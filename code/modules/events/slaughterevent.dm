/datum/event/spawn_slaughter
	var/key_of_slaughter

/datum/event/spawn_slaughter/proc/get_slaughter(var/end_if_fail = 0)
	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Демона Резни?", ROLE_DEMON, TRUE, source = /mob/living/simple_animal/slaughter)
		if(!candidates.len)
			key_of_slaughter = null
			kill()
			return
		var/mob/C = pick(candidates)
		key_of_slaughter = C.key

		if(!key_of_slaughter)
			kill()
			return

		var/datum/mind/player_mind = new /datum/mind(key_of_slaughter)
		player_mind.active = 1
		var/list/spawn_locs = list()
		for(var/thing in GLOB.landmarks_list)
			var/obj/effect/landmark/L = thing
			if(isturf(L.loc))
				switch(L.name)
					if("revenantspawn")
						spawn_locs += L.loc
		if(!spawn_locs) //If we can't find any revenant spawns, try the carp spawns
			for(var/thing in GLOB.landmarks_list)
				var/obj/effect/landmark/L = thing
				if(isturf(L.loc))
					switch(L.name)
						if("carpspawn")
							spawn_locs += L.loc
		if(!spawn_locs) //If we can't find either, just spawn the revenant at the player's location
			spawn_locs += get_turf(player_mind.current)
		if(!spawn_locs) //If we can't find THAT, then just retry
			kill()
			return
		var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(pick(spawn_locs))
		var/mob/living/simple_animal/slaughter/S = new /mob/living/simple_animal/slaughter/(holder)
		S.holder = holder
		player_mind.transfer_to(S)
		player_mind.assigned_role = "Slaughter Demon"
		player_mind.special_role = SPECIAL_ROLE_SLAUGHTER_DEMON
		message_admins("[key_name_admin(S)] выбран на роль Демона Резни по событию.")
		add_game_logs("выбран на роль Демона Резни по событию.", S)

/datum/event/spawn_slaughter/start()
	get_slaughter()
