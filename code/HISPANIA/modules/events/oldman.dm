#define SPECIAL_ROLE_OLD_MAN "Old Man"

/datum/event/spawn_oldman
	announceWhen = 120
	var/key_of_oldman

/datum/event/spawn_oldman/announce()
	GLOB.event_announcement.Announce("Unknown entity detected aboard [station_name()]. Please report any sightings to local authority.", "Bioscan Alert", 'sound/hispania/effects/oldman/alert.ogg')

/datum/event/spawn_oldman/proc/get_oldman(var/end_if_fail = 0)
	spawn()
		var/list/candidates = pollCandidatesWithVeto("Do you want to play as the old man?", ROLE_DEMON, 1)
		if(!candidates.len)
			key_of_oldman = null
			return kill()
		var/mob/C = pick(candidates)
		key_of_oldman = C.key

		if(!key_of_oldman)
			return kill()
		var/datum/mind/player_mind = new /datum/mind(key_of_oldman)
		player_mind.active = 1
		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/L in GLOB.landmarks_list)
			if(isturf(L.loc))
				switch(L.name)
					if("revenantspawn")
						spawn_locs += L.loc
		if(!spawn_locs) //If we can't find any revenant spawns, try the carp spawns
			for(var/obj/effect/landmark/L in GLOB.landmarks_list)
				if(isturf(L.loc))
					switch(L.name)
						if("carpspawn")
							spawn_locs += L.loc
		if(!spawn_locs) //If we can't find either, just spawn the oldman at the player's location
			spawn_locs += get_turf(player_mind.current)
		if(!spawn_locs) //If we can't find THAT, then just retry
			return kill()
		var /mob/living/simple_animal/hostile/oldman/SCP = new /mob/living/simple_animal/hostile/oldman/(pick(spawn_locs))
		player_mind.transfer_to(SCP)
		player_mind.assigned_role = SPECIAL_ROLE_OLD_MAN
		player_mind.special_role = SPECIAL_ROLE_OLD_MAN
		message_admins("[key_name_admin(SCP)] has been made into the Old Man by an event.")
		log_game("[key_name_admin(SCP)] was spawned as the Old Man by an event.")
		return TRUE

/datum/event/spawn_oldman/start()
	get_oldman()
