/datum/game_mode/abduction
	name = "abduction"
	config_tag = "abduction"
	recommended_enemies = 2
	required_players = 15
	abductor_teams = 1
	single_antag_positions = list()
	var/max_teams = 4
	var/finished = FALSE

/datum/game_mode/abduction/announce()
	to_chat(world, "<B>The current game mode is - Abduction!</B>")
	to_chat(world, "There are alien <b>abductors</b> sent to [world.name] to perform nefarious experiments!")
	to_chat(world, "<b>Abductors</b> - kidnap the crew and replace their organs with experimental ones.")
	to_chat(world, "<b>Crew</b> - don't get abducted and stop the abductors.")

/datum/game_mode/abduction/pre_setup()
	var/possible_abductors = get_players_for_role(ROLE_ABDUCTOR)
	if(!length(possible_abductors))
		return FALSE

	abductor_teams = clamp(min(round(num_players() / 15), round(length(possible_abductors) / 2)), 1, max_teams)

	for(var/i in 1 to abductor_teams)
		var/datum/mind/mind_1 = pick_n_take(possible_abductors)
		var/datum/mind/mind_2 = pick_n_take(possible_abductors)
		if(!mind_1 || !mind_2)
			break
		new /datum/team/abductor(list(mind_1, mind_2))

		// Add a special role so they dont pick up any other antagonist stuff
		mind_1.assigned_role = SPECIAL_ROLE_ABDUCTOR_AGENT
		mind_1.special_role = SPECIAL_ROLE_ABDUCTOR_AGENT
		mind_1.offstation_role = TRUE

		mind_2.assigned_role = SPECIAL_ROLE_ABDUCTOR_SCIENTIST
		mind_2.special_role = SPECIAL_ROLE_ABDUCTOR_SCIENTIST
		mind_2.offstation_role = TRUE
	..()
	return TRUE

/datum/game_mode/abduction/post_setup()
	for(var/datum/team/abductor/team in actual_abductor_teams)
		team.create_agent()
		team.create_scientist()
	return ..()

/datum/game_mode/abduction/proc/get_team_console(team_number)
	for(var/obj/machinery/abductor/console/C in SSmachines.get_by_type(/obj/machinery/abductor/console))
		if(C.team == team_number)
			return C

/datum/game_mode/abduction/check_finished()
	if(!finished)
		for(var/datum/team/abductor/team in actual_abductor_teams)
			var/obj/machinery/abductor/console/con = get_team_console(team.team_number)
			if(con.experiment.points >= team.experiment_objective.target_amount)
				SSshuttle.emergency.request(null, 0.5, reason = "Large amount of abnormal thought patterns detected. All crew are recalled for mandatory evaluation and reconditioning.")
				SSshuttle.emergency.canRecall = FALSE
				finished = TRUE
				return ..()
	return ..()

/datum/game_mode/abduction/declare_completion()
	for(var/datum/team/abductor/team in actual_abductor_teams)
		var/obj/machinery/abductor/console/console = get_team_console(team.team_number)
		if(console.experiment.points >= team.experiment_objective.target_amount)
			to_chat(world, "<span class='greenannounce'>[team.name] team fulfilled its mission!</span>")
		else
			to_chat(world, "<span class='boldannounceic'>[team.name] team failed its mission.</span>")
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_abduction()
	var/list/text = list()
	if(length(abductors))
		text += "<br><span class='big'><b>The abductors were:</b></span><br>"
		for(var/datum/mind/abductor_mind in abductors)
			text += printplayer(abductor_mind)
			text += "<br>"
			text += printobjectives(abductor_mind)
			text += "<br>"
		if(length(abductees))
			text += "<br><span class='big'><b>The abductees were:</b></span><br>"
			for(var/datum/mind/abductee_mind in abductees)
				text += printplayer(abductee_mind)
				text += "<br>"
				text += printobjectives(abductee_mind)
				text += "<br>"
		return text.Join("")

//Landmarks
// TODO: Split into seperate landmarks for prettier ships
/obj/effect/landmark/abductor
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "Abductor"
	var/team = 1

/obj/effect/landmark/abductor/agent
/obj/effect/landmark/abductor/scientist


// OBJECTIVES
//No check completion, it defaults to being completed unless an admin sets it to failed.
/datum/objective/stay_hidden
	explanation_text = "Limit contact with your targets outside of conducting your experiments and abduction."
	completed = TRUE
	needs_target = FALSE

/datum/objective/experiment
	explanation_text = "Experiment on some humans."
	target_amount = 6
	needs_target = FALSE
	/// Which abductor team number does this belong to.
	var/abductor_team_number

/datum/objective/experiment/New()
	..()
	explanation_text = "Experiment on [target_amount] humans."

/datum/objective/experiment/check_completion()
	var/ab_team = abductor_team_number
	var/list/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!M.current || !ishuman(M.current) || !isabductor(M.current))
			return FALSE
		var/mob/living/carbon/human/H = M.current
		var/datum/species/abductor/S = H.dna.species
		ab_team = S.team
	for(var/obj/machinery/abductor/experiment/E in SSmachines.get_by_type(/obj/machinery/abductor/experiment))
		if(E.team == ab_team)
			if(E.points >= target_amount)
				return TRUE
			else
				return FALSE
	return FALSE
