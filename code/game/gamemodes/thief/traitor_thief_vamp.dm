/datum/game_mode/traitor/thief/vampire
	name = "traitor+thief+vampire"
	config_tag = "traitorthiefvamp"
	traitors_possible = 2 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg")
	required_players = 25
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	var/protected_species_vampire = list("Machine")
	var/list/datum/mind/pre_vampires = list()

/datum/game_mode/traitor/thief/vampire/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Thief+Vampire!</B>")
	to_chat(world, "<B>На станции зафиксирована деятельность гильдии воров, вампиров и агентов Синдиката. Не дайте агентам Синдиката и Вампирам достичь успеха и не допустите кражу дорогостоящего оборудования!</B>")


/datum/game_mode/traitor/thief/vampire/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_vampires) && (player.client.prefs.species in protected_species_vampire))
			possible_vampires -= player.mind

	if(length(possible_vampires))
		var/datum/mind/vampire = pick(possible_vampires)
		pre_vampires += vampire
		vampire.restricted_roles = restricted_jobs
		vampire.special_role = SPECIAL_ROLE_VAMPIRE
		..()
		return TRUE
	else
		return FALSE

/datum/game_mode/traitor/thief/vampire/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire)
	..()
