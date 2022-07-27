/datum/event/abductor

/datum/event/abductor/start()
	INVOKE_ASYNC(src, .proc/try_makeAbductorTeam)

/datum/event/abductor/proc/try_makeAbductorTeam()
	if(!makeAbductorTeam())
		message_admins("Abductor event failed to find players. Retrying in 30s.")
		addtimer(CALLBACK(src, .proc/makeAbductorTeam), 30 SECONDS)

/datum/event/abductor/proc/makeAbductorTeam()
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for an Abductor Team?", ROLE_ABDUCTOR, TRUE)

	if(candidates.len >= 2)
		//Oh god why we can't have static functions

		var/agent_mind = pick(candidates)
		candidates -= agent_mind
		var/scientist_mind = pick(candidates)

		var/mob/living/carbon/human/agent = makeBody(agent_mind)
		var/mob/living/carbon/human/scientist = makeBody(scientist_mind)

		agent_mind = agent.mind
		scientist_mind = scientist.mind

		var/datum/team/abductor_team/T = new
		if(T.team_number > ABDUCTOR_MAX_TEAMS)
			message_admins("Abductor event fired but the maximum amount of abductor team is already reached. Event cancelled.")
			return TRUE
		
		log_game("[key_name(scientist)] has been selected as [T.name] abductor scientist.")
		log_game("[key_name(agent)] has been selected as [T.name] abductor agent.")

		scientist.mind.add_antag_datum(/datum/antagonist/abductor/scientist, T)
		agent.mind.add_antag_datum(/datum/antagonist/abductor/agent, T)
		return TRUE
	else
		return FALSE
