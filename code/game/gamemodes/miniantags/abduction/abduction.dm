/datum/game_mode
	var/abductor_teams = 0
	var/list/datum/mind/abductors = list()
	var/list/datum/mind/abductees = list()

/datum/game_mode/abduction
	name = "abduction"
	config_tag = "abduction"
	recommended_enemies = 2
	required_players = 15
	var/max_teams = 4
	abductor_teams = 1
	var/list/datum/mind/scientists = list()
	var/list/datum/mind/agents = list()
	var/list/datum/objective/team_objectives = list()
	var/list/team_names = list()
	var/finished = 0
	var/list/datum/mind/possible_abductors = list()

/datum/game_mode/abduction/announce()
	to_chat(world, "<B>The current game mode is - Abduction!</B>")
	to_chat(world, "There are alien <b>abductors</b> sent to [world.name] to perform nefarious experiments!")
	to_chat(world, "<b>Abductors</b> - kidnap the crew and replace their organs with experimental ones.")
	to_chat(world, "<b>Crew</b> - don't get abducted and stop the abductors.")

/datum/game_mode/abduction/pre_setup()
	possible_abductors = get_players_for_role(ROLE_ABDUCTOR)

	if(!possible_abductors.len)
		return 0

	abductor_teams = max(1, min(max_teams,round(num_players()/15)))
	var/possible_teams = max(1,round(possible_abductors.len / 2))
	abductor_teams = min(abductor_teams,possible_teams)

	abductors.len = 2*abductor_teams
	scientists.len = abductor_teams
	agents.len = abductor_teams
	team_objectives.len = abductor_teams
	team_names.len = abductor_teams

	for(var/i=1,i<=abductor_teams,i++)
		if(!make_abductor_team(i))
			return 0
	..()
	return 1

/datum/game_mode/abduction/proc/make_abductor_team(team_number,preset_agent=null,preset_scientist=null)
	//Team Name
	team_names[team_number] = "Mothership [pick(possible_changeling_IDs)]" //TODO Ensure unique and actual alieny names
	//Team Objective
	var/datum/objective/experiment/team_objective = new
	team_objective.team = team_number
	team_objectives[team_number] = team_objective
	//Team Members

	if(!preset_agent || !preset_scientist)
		if(possible_abductors.len <=2)
			return 0

	var/datum/mind/scientist
	var/datum/mind/agent

	if(!preset_scientist)
		scientist = pick(possible_abductors)
		possible_abductors -= scientist
	else
		scientist = preset_scientist

	if(!preset_agent)
		agent = pick(possible_abductors)
		possible_abductors -= agent
	else
		agent = preset_agent


	scientist.assigned_role = SPECIAL_ROLE_ABDUCTOR_SCIENTIST
	scientist.special_role = SPECIAL_ROLE_ABDUCTOR_SCIENTIST
	scientist.offstation_role = TRUE
	log_game("[key_name(scientist)] has been selected as an abductor team [team_number] scientist.")

	agent.assigned_role = SPECIAL_ROLE_ABDUCTOR_AGENT
	agent.special_role = SPECIAL_ROLE_ABDUCTOR_AGENT
	agent.offstation_role = TRUE
	log_game("[key_name(agent)] has been selected as an abductor team [team_number] agent.")

	abductors |= agent
	abductors |= scientist
	scientists[team_number] = scientist
	agents[team_number] = agent
	return 1

/datum/game_mode/abduction/post_setup()
	for(var/team_number=1,team_number<=abductor_teams,team_number++)
		post_setup_team(team_number)
	return ..()

//Used for create antag buttons
/datum/game_mode/abduction/proc/post_setup_team(team_number)
	var/list/obj/effect/landmark/abductor/agent_landmarks = list()
	var/list/obj/effect/landmark/abductor/scientist_landmarks = list()
	agent_landmarks.len = max_teams
	scientist_landmarks.len = max_teams
	for(var/obj/effect/landmark/abductor/A in GLOB.landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/team_name = team_names[team_number]

	var/datum/mind/agent
	var/obj/effect/landmark/L
	var/datum/mind/scientist
	var/mob/living/carbon/human/H
	var/datum/species/abductor/S

	team_name = team_names[team_number]
	agent = agents[team_number]
	H = agent.current
	L = agent_landmarks[team_number]
	H.forceMove(get_turf(L))
	H.body_accessory = null
	H.set_species(/datum/species/abductor)
	S = H.dna.species
	S.team = team_number
	H.real_name = team_name + " Agent"
	H.cleanSE() //No fat/blind/colourblind/epileptic/whatever ayys.
	H.overeatduration = 0
	H.flavor_text = null
	H.equipOutfit(/datum/outfit/abductor/agent)
	greet_agent(agent,team_number)
	update_abductor_icons_added(agent)

	scientist = scientists[team_number]
	H = scientist.current
	L = scientist_landmarks[team_number]
	H.forceMove(get_turf(L))
	H.body_accessory = null
	H.set_species(/datum/species/abductor)
	S = H.dna.species
	S.scientist = TRUE
	S.team = team_number
	H.real_name = team_name + " Scientist"
	H.cleanSE() //No fat/blind/colourblind/epileptic/whatever ayys.
	H.overeatduration = 0
	H.flavor_text = null
	H.equipOutfit(/datum/outfit/abductor/scientist)
	greet_scientist(scientist,team_number)
	update_abductor_icons_added(scientist)

/datum/game_mode/abduction/proc/greet_agent(datum/mind/abductor,team_number)
	var/datum/objective/stay_hidden/O = new
	abductor.objectives += O
	abductor.objectives += team_objectives[team_number]
	var/team_name = team_names[team_number]

	to_chat(abductor.current, "<span class='notice'>You are an agent of [team_name]!</span>")
	to_chat(abductor.current, "<span class='notice'>With the help of your teammate, kidnap and experiment on station crew members!</span>")
	to_chat(abductor.current, "<span class='notice'>Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve.</span>")

	abductor.announce_objectives()

/datum/game_mode/abduction/proc/greet_scientist(datum/mind/abductor,team_number)
	var/datum/objective/stay_hidden/O = new
	abductor.objectives += O
	abductor.objectives += team_objectives[team_number]
	var/team_name = team_names[team_number]

	to_chat(abductor.current, "<span class='notice'>You are a scientist of [team_name]!</span>")
	to_chat(abductor.current, "<span class='notice'>With the help of your teammate, kidnap and experiment on station crew members!</span>")
	to_chat(abductor.current, "<span class='notice'>Use your tool and ship consoles to support the agent and retrieve human specimens.</span>")

	abductor.announce_objectives()

/datum/game_mode/abduction/proc/get_team_console(team_number)
	for(var/obj/machinery/abductor/console/C in GLOB.machines)
		if(C.team == team_number)
			return C

/datum/game_mode/abduction/check_finished()
	if(!finished)
		for(var/team_number=1,team_number<=abductor_teams,team_number++)
			var/obj/machinery/abductor/console/con = get_team_console(team_number)
			var/datum/objective/objective = team_objectives[team_number]
			if(con.experiment.points >= objective.target_amount)
				SSshuttle.emergency.request(null, 0.5, reason = "Large amount of abnormal thought patterns detected. All crew are recalled for mandatory evaluation and reconditioning.")
				SSshuttle.emergency.canRecall = FALSE
				finished = 1
				return ..()
	return ..()

/datum/game_mode/abduction/declare_completion()
	for(var/team_number=1,team_number<=abductor_teams,team_number++)
		var/obj/machinery/abductor/console/console = get_team_console(team_number)
		var/datum/objective/objective = team_objectives[team_number]
		var/team_name = team_names[team_number]
		if(console.experiment.points >= objective.target_amount)
			to_chat(world, "<span class='greenannounce'>[team_name] team fulfilled its mission!</span>")
		else
			to_chat(world, "<span class='boldannounce'>[team_name] team failed its mission.</span>")
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_abduction()
	var/text = ""
	if(abductors.len)
		text += "<br><span class='big'><b>The abductors were:</b></span><br>"
		for(var/datum/mind/abductor_mind in abductors)
			text += printplayer(abductor_mind)
			text += printobjectives(abductor_mind)
			text += "<br>"
		if(abductees.len)
			text += "<br><span class='big'><b>The abductees were:</b></span><br>"
			for(var/datum/mind/abductee_mind in abductees)
				text += printplayer(abductee_mind)
				text += printobjectives(abductee_mind)
				text += "<br>"
	to_chat(world, text)

//Landmarks
// TODO: Split into seperate landmarks for prettier ships
/obj/effect/landmark/abductor
	var/team = 1

/obj/effect/landmark/abductor/agent
/obj/effect/landmark/abductor/scientist


// OBJECTIVES
/datum/objective/experiment
	target_amount = 6
	var/team

/datum/objective/stay_hidden

/datum/objective/stay_hidden/New()
	explanation_text = "Limit contact with your targets outside of conducting your experiments and abduction."
	completed = TRUE
//No check completion, it defaults to being completed unless an admin sets it to failed.

/datum/objective/experiment/New()
	explanation_text = "Experiment on [target_amount] humans."

/datum/objective/experiment/check_completion()
	var/ab_team = team
	if(owner)
		if(!owner.current || !ishuman(owner.current))
			return FALSE
		var/mob/living/carbon/human/H = owner.current
		if(!isabductor(H))
			return FALSE
		var/datum/species/abductor/S = H.dna.species
		ab_team = S.team
	for(var/obj/machinery/abductor/experiment/E in GLOB.machines)
		if(E.team == ab_team)
			if(E.points >= target_amount)
				return TRUE
			else
				return FALSE
	return FALSE

/datum/game_mode/proc/remove_abductor(datum/mind/abductor_mind)
	if(abductor_mind in abductors)
		SSticker.mode.abductors -= abductor_mind
		abductor_mind.special_role = null
		abductor_mind.current.create_attack_log("<span class='danger'>No longer abductor</span>")
		if(issilicon(abductor_mind.current))
			to_chat(abductor_mind.current, "<span class='userdanger'>You have been turned into a robot! You are no longer an abductor.</span>")
		else
			to_chat(abductor_mind.current, "<span class='userdanger'>You have been brainwashed! You are no longer an abductor.</span>")
		SSticker.mode.update_abductor_icons_removed(abductor_mind)

/datum/game_mode/proc/update_abductor_icons_added(datum/mind/alien_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_ABDUCTOR]
	hud.join_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, ((alien_mind in abductors) ? "abductor" : "abductee"))

/datum/game_mode/proc/update_abductor_icons_removed(datum/mind/alien_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_ABDUCTOR]
	hud.leave_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, null)