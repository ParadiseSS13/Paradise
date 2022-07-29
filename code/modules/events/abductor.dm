/datum/event/abductor
	var/teams_to_spawn = 1
	var/teams_spawned = 0
	var/sanity = 0
	var/max_teams_reached = FALSE
	var/datum/mind/agent_mind
	var/datum/mind/scientist_mind

/datum/event/abductor/raid

/datum/event/abductor/raid/start()
	teams_to_spawn = round(length(GLOB.player_list) / 25) //Each 25 players online spawn an abductor team
	teams_to_spawn = clamp(teams_to_spawn, 1, ABDUCTOR_MAX_TEAMS) //At least one abductor team, no more than max
	..()

/datum/event/abductor/start()
	INVOKE_ASYNC(src, .proc/PollGhosts)

/datum/event/abductor/proc/PollGhosts()
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for an Abductor Team?", ROLE_ABDUCTOR, TRUE)
	LoopAbductorTeams(candidates)
	if(teams_spawned < teams_to_spawn)
		message_admins("Abductor event failed to find players to fill all teams. Retrying once in 30s.")
		addtimer(CALLBACK(src, .proc/LastCall), 30 SECONDS) //Last chance for players that missed out to get in

/datum/event/abductor/proc/LastCall()
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for an Abductor Team?", ROLE_ABDUCTOR, TRUE)
	LoopAbductorTeams(candidates)

/datum/event/abductor/proc/LoopAbductorTeams(list/mob/dead/observer/candidates)
	while(teams_spawned < teams_to_spawn && length(candidates) >= 2 && !max_teams_reached && sanity < 50)
		agent_mind = pick(candidates)
		candidates -= agent_mind
		scientist_mind = pick(candidates)
		candidates -= scientist_mind
		if(!agent_mind || !scientist_mind)
			break
		makeAbductorTeam(agent_mind, scientist_mind)
		sanity++

/datum/event/abductor/proc/makeAbductorTeam(datum/mind/agent_mind, datum/mind/scientist_mind)
	var/mob/living/carbon/human/agent = makeBody(agent_mind)
	var/mob/living/carbon/human/scientist = makeBody(scientist_mind)

	agent_mind = agent.mind
	scientist_mind = scientist.mind

	var/datum/team/abductor_team/T = new
	if(T.team_number > ABDUCTOR_MAX_TEAMS)
		max_teams_reached = TRUE
		qdel(T)
		return FALSE
	
	log_game("[key_name(scientist)] has been selected as [T.name] abductor scientist.")
	log_game("[key_name(agent)] has been selected as [T.name] abductor agent.")

	scientist.mind.add_antag_datum(/datum/antagonist/abductor/scientist, T)
	agent.mind.add_antag_datum(/datum/antagonist/abductor/agent, T)
	teams_spawned++
	return TRUE
