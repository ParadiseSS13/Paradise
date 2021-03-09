/datum/game_mode/traitor/changeling
	name = "traitor+changeling"
	config_tag = "traitorchan"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg")
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	var/protected_species_changeling = list("Machine")

/datum/game_mode/traitor/changeling/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Changeling!</B>")
	to_chat(world, "<B>There is an alien creature on the station along with some syndicate operatives out for their own gain! Do not let the changeling and the traitors succeed!</B>")


/datum/game_mode/traitor/changeling/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_changelings) && (player.client.prefs.species in protected_species_changeling))
			possible_changelings -= player.mind

	if(possible_changelings.len > 0)
		var/datum/mind/changeling = pick(possible_changelings)
		changelings += changeling
		modePlayer += changelings
		changeling.restricted_roles = restricted_jobs
		changeling.special_role = SPECIAL_ROLE_CHANGELING
		return ..()
	else
		return 0

/datum/game_mode/traitor/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		changeling.special_role = SPECIAL_ROLE_CHANGELING
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)
		update_change_icons_added(changeling)
	..()
	return
