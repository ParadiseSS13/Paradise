#define EXTRABROTHERSCHANCE 10

/datum/game_mode
	var/list/datum/mind/brothers = list() //all participating brothers are stored here
	var/list/datum/team/brother_team/brother_teams = list() //all particapting brother teams are stored here

/datum/game_mode/traitor/bros
	name = "traitor+brothers"
	config_tag = "traitorbro"
	restricted_jobs = list("cyborg", "AI") //we don't want AIs as blood brothers. so no malf AIs on this game mode.

	var/list/datum/team/brother_team/pre_brother_teams = list()
	var/const/team_amount = 2 //hard limit on brother teams if scaling is turned off
	var/const/min_team_size = 2 //absolutle minimum team size

/datum/game_mode/traitor/bros/announce()
	to_chat(world, "<B>There are Syndicate agents and Blood Brothers on the station!</B>\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='danger'>Blood Brothers</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors or brothers succeed!")

/datum/game_mode/traitor/bros/pre_setup() //pre game mode set up
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_brothers = get_players_for_role(ROLE_BROTHER) 

	var/num_teams = team_amount //how many brother teams do we want
	var/bsc = config.brothers_scaling //what scaling is used.
	if(bsc)
		num_teams = max(1, round(num_players() / bsc)) //if scaling generate additional teams.

	for(var/j = 1 to num_teams) //Count the teams as we generate them.
		if(possible_brothers.len < min_team_size) //if the number of avaliable brothers are less then the minimum size stop.
			break 
		var/datum/team/brother_team/team = new
		var/team_size = prob(EXTRABROTHERSCHANCE) ? min(3, possible_brothers.len) : 2 //sometimes we want larger teams, sometimes we want normal sized teams.
		for(var/k = 1 to team_size) //Now we generate the teams
			var/datum/mind/bro = pick(possible_brothers)
			possible_brothers -= bro
			team.add_member(bro)
			bro.special_role = "brother"
			bro.restricted_roles = restricted_jobs
			log_game("[key_name(bro)] has been selected as a Brother")
		pre_brother_teams += team
	. = ..()
	if(.)	//To ensure the game mode is going ahead
		for(var/teams in pre_brother_teams)
			for(var/datum/mind/antag in teams)
				pre_traitors += antag //we add possible brothers to the pre antag list
	return

/datum/game_mode/traitor/bros/post_setup()
	for(var/datum/team/brother_team/team in pre_brother_teams) //generating meeting area and objectives.
		team.pick_meeting_area()
		team.forge_brother_objectives()
		for(var/datum/mind/M in team.members) //finally assigning the brothers and teams together while also denying normal status to them.
			M.add_antag_datum(/datum/antagonist/brother, team)
			pre_traitors -= M 
		team.update_name()
	brother_teams += pre_brother_teams
	return ..()

/datum/game_mode/proc/auto_declare_completion_bros()
	if(brother_teams.len)
		var/text
		for(var/datum/team/brother_team/team in brother_teams)
			var/win = TRUE
			var/objective_count = 1
			text += "<br><span class='header'>The blood brothers of [team.name] were:</span>"
			for(var/datum/mind/brother in team.members)
				text += " [brother.name]"
			for(var/datum/objective/objective in team.objectives)
				if(objective.check_completion())
					text += "<br><b>Objective #[objective_count]</b>: [objective.explanation_text] <span class='greentext'>Success!</span>"
					SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><b>Objective #[objective_count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
					SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[objective.type]", "FAIL"))
					win = FALSE
				objective_count++
			if(win)
				text += "<br><span class='greentext'>The blood brothers were successful!</span>"
				SSblackbox.record_feedback("tally", "traitor_success", 1, "SUCCESS")
			else
				text += "<br><span class='redtext'>The blood brothers have failed!</span>"
				SSblackbox.record_feedback("tally", "traitor_success", 1, "FAIL")
	
		to_chat(world, text)
	return 1
