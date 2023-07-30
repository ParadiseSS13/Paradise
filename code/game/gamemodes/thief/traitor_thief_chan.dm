/datum/game_mode/traitor/thief/changeling
	name = "traitor+thief+changeling"
	config_tag = "traitorthiefchan"
	traitors_possible = 2 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg")
	required_players = 25
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	var/protected_species_changeling = list("Machine")
	var/list/datum/mind/pre_changelings = list()

/datum/game_mode/traitor/thief/changeling/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Thief+Changeling!</B>")
	to_chat(world, "<B>На станции зафиксирована деятельность гильдии воров, генокрадов и агентов Синдиката. Не дайте агентам Синдиката и Генокрадам достичь успеха и скрыться, и не допустите кражу дорогостоящего оборудования!</B>")


/datum/game_mode/traitor/thief/changeling/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_changelings) && (player.client.prefs.species in protected_species_changeling))
			possible_changelings -= player.mind

	if(length(possible_changelings))
		var/datum/mind/changeling = pick(possible_changelings)
		pre_changelings += changeling
		changeling.restricted_roles = restricted_jobs
		changeling.special_role = SPECIAL_ROLE_CHANGELING
		return ..()
	else
		return FALSE

/datum/game_mode/traitor/thief/changeling/post_setup()
	for(var/datum/mind/changeling in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	..()

