/datum/game_mode
	var/list/datum/mind/brothers = list()
	var/list/datum/team/brother_team/brother_teams = list()

/datum/game_mode/traitor/bros
	name = "traitor+brothers"
	config_tag = "traitorbro"
	restricted_jobs = list("cyborg","AI")

	var/list/datum/team/brother_team/pre_brother_teams = list()
	var/const/team_amount = 2 //hard limit on brother teams if scaling is turned off
	var/const/min_team_size = 2

/datum/game_mode/traitor/bros/announce()
	to_chat(world, "<B>There are Syndicate agents and Blood Brothers on the station!</B>\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='danger'>Blood Brothers</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors or brothers succeed!")

/datum/game_mode/traitor/bros/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_brothers = get_players_for_role(ROLE_BROTHER)

	var/num_teams = team_amount
	var/bsc = config.brothers_scaling
	if(bsc)
		num_teams = max(1, round(num_players() / bsc))

	for(var/j = 1 to num_teams)
		if(possible_brothers.len < min_team_size)
			break
		var/datum/team/brother_team/team = new
		var/team_size = prob(10) ? min(3, possible_brothers.len) : 2
		for(var/k = 1 to team_size)
			var/datum/mind/bro = pick(possible_brothers)
			possible_brothers -= bro
			// make it possible to not be traitor too
			team.add_member(bro)
			bro.special_role = "brother"
			bro.restricted_roles = restricted_jobs
			log_game("[key_name(bro)] has been selected as a Brother")
		pre_brother_teams += team
	. = ..()
	if(.)	//To ensure the game mode is going ahead
		for(var/teams in pre_brother_teams)
			for(var/antag in teams)
				pre_traitors += antag
	return

/datum/game_mode/traitor/bros/post_setup()
	for(var/datum/team/brother_team/team in pre_brother_teams)
		team.pick_meeting_area()
		team.forge_brother_objectives()
		for(var/datum/mind/M in team.members)
			M.add_antag_datum(/datum/antagonist/brother, team)
			pre_traitors -= M
		team.update_name()
	brother_teams += pre_brother_teams
	return ..()
