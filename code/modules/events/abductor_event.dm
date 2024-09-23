/datum/event/abductor

/datum/event/abductor/start()
	INVOKE_ASYNC(src, PROC_REF(try_makeAbductorTeam))

/datum/event/abductor/proc/try_makeAbductorTeam()
	if(!makeAbductorTeam())
		message_admins("Abductor event failed to find players. Retrying in 30s.")
		addtimer(CALLBACK(src, PROC_REF(makeAbductorTeam)), 30 SECONDS)

/datum/event/abductor/proc/makeAbductorTeam()
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for an Abductor Team?", ROLE_ABDUCTOR, TRUE)

	if(length(candidates) >= 2)
		//Oh god why we can't have static functions
		var/number =  SSticker.mode.abductor_teams + 1

		var/datum/game_mode/abduction/temp
		if(SSticker.mode.config_tag == "abduction")
			temp = SSticker.mode
		else
			temp = new

		var/mob/agent_mind = pick(candidates)
		candidates -= agent_mind
		var/mob/scientist_mind = pick(candidates)

		var/mob/living/carbon/human/agent=makeBody(agent_mind)
		var/mob/living/carbon/human/scientist=makeBody(scientist_mind)

		agent_mind = agent.mind
		scientist_mind = scientist.mind

		temp.scientists.len = number
		temp.agents.len = number
		temp.abductors.len = 2*number
		temp.team_objectives.len = number
		temp.team_names.len = number
		temp.scientists[number] = scientist_mind
		temp.agents[number] = agent_mind
		temp.abductors |= list(agent_mind,scientist_mind)
		temp.make_abductor_team(number,preset_scientist=scientist_mind,preset_agent=agent_mind)
		temp.post_setup_team(number)
		dust_if_respawnable(agent_mind)
		dust_if_respawnable(scientist)

		SSticker.mode.abductor_teams++

		if(SSticker.mode.config_tag != "abduction")
			SSticker.mode.abductors |= temp.abductors
		return 1
	else
		return 0
