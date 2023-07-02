#define SPACE_DRAGON_SPAWN_THRESHOLD 25

/datum/event/space_dragon
	announceWhen = 45
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/space_dragon/start()
	// It is necessary to wrap this to avoid the event triggering repeatedly.
	INVOKE_ASYNC(src, PROC_REF(wrapped_start))

/datum/event/space_dragon/announce()
	if(successSpawn)
		GLOB.command_announcement.Announce("Зафиксирован большой поток органической энергии вблизи станции [station_name()]. Пожалуйста, ожидайте.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ.")
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Space Dragon")

/datum/event/space_dragon/proc/wrapped_start()
	if(length(GLOB.clients) < SPACE_DRAGON_SPAWN_THRESHOLD)
		log_and_message_admins("Random event attempted to spawn a space dragon, but there were only [length(GLOB.clients)]/[SPACE_DRAGON_SPAWN_THRESHOLD] players.")
		return
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Космического Дракона?", ROLE_SPACE_DRAGON, TRUE, source = /mob/living/simple_animal/hostile/space_dragon)
	if(!length(candidates))
		log_and_message_admins("Warning: nobody volunteered to become a Space Dragon!")
		return
	var/mob/living/simple_animal/hostile/space_dragon/space_dragon = new (pick(GLOB.carplist))
	var/mob/candidate = pick(candidates)
	space_dragon.key = candidate.key
	space_dragon.mind.assigned_role = ROLE_SPACE_DRAGON
	space_dragon.mind.special_role = ROLE_SPACE_DRAGON
	space_dragon.mind.make_space_dragon()
	playsound(space_dragon, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	log_and_message_admins("[ADMIN_LOOKUPFLW(space_dragon)] has been made into a Space Dragon by an event.")
	log_game("[space_dragon.key] was spawned as a Space Dragon by an event.")
	successSpawn = TRUE

#undef SPACE_DRAGON_SPAWN_THRESHOLD
