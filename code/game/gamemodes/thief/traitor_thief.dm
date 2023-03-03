/datum/game_mode/traitor/thief
	name = "traitor+thief"
	config_tag = "traitorthief"
	traitors_possible = 2 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg")
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3

/datum/game_mode/traitor/thief/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Thief!</B>")
	to_chat(world, "<B>На станции зафиксирована деятельность гильдии воров и агентов Синдиката. Не дайте агентам Синдиката достичь успеха и не допустите кражу дорогостоящего оборудования!</B>")


/datum/game_mode/traitor/thief/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_thieves = get_players_for_role(ROLE_THIEF)

	if(possible_thieves.len > 0)
		var/datum/mind/thief = pick(possible_thieves)
		thieves += thief
		modePlayer += thieves
		thief.restricted_roles = restricted_jobs
		thief.special_role = SPECIAL_ROLE_THIEF
		return ..()
	else
		return 0

/datum/game_mode/traitor/thief/post_setup()
	for(var/datum/mind/thief in thieves)
		thief.make_Thief()
	..()
	return
