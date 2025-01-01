/datum/event/abductor

/datum/event/abductor/start()
	INVOKE_ASYNC(src, PROC_REF(try_makeAbductorTeam))

/datum/event/abductor/proc/try_makeAbductorTeam()
	if(!makeAbductorTeam())
		message_admins("Abductor event failed to find players. Retrying in 30s.")
		addtimer(CALLBACK(src, PROC_REF(makeAbductorTeam)), 30 SECONDS)

/datum/event/abductor/proc/makeAbductorTeam()
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for an Abductor Team?", ROLE_ABDUCTOR, TRUE)
	if(length(candidates) < 2)
		return FALSE

	var/list/minds = list()
	for(var/i in 1 to 2)
		var/mob/ghost = pick_n_take(candidates)
		var/list/key = ghost.key
		dust_if_respawnable(ghost)

		var/datum/mind/mind = new /datum/mind(key)
		mind.active = TRUE
		minds += mind

	var/datum/team/abductor/ayys = new /datum/team/abductor(minds)
	ayys.create_agent()
	ayys.create_scientist()
	return TRUE
