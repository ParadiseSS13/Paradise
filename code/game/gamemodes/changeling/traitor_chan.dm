/datum/game_mode/traitor/changeling
	name = "traitor_changeling"
	config_tag = "traitorchan"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("Cyborg")
	secondary_restricted_jobs = list("AI") // Allows AI to roll traitor, but not changeling
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	secondary_enemies_scaling = 0.025
	secondary_protected_species = list("Machine")
	/// A list containing references to the minds of soon-to-be changelings. This is seperate to avoid duplicate entries in the `changelings` list.
	var/list/datum/mind/pre_changelings = list()

/datum/game_mode/traitor/changeling/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Changeling!</B>")
	to_chat(world, "<B>There is an alien creature on the station along with some syndicate operatives out for their own gain! Do not let the changeling and the traitors succeed!</B>")


/datum/game_mode/traitor/changeling/pre_setup()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)
	secondary_enemies = CEILING((secondary_enemies_scaling * num_players()), 1)

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_changelings) && (player.client.prefs.active_character.species in secondary_protected_species))
			possible_changelings -= player.mind

	if(!length(possible_changelings))
		return ..()

	for(var/I in possible_changelings)
		if(length(pre_changelings) >= secondary_enemies)
			break
		var/datum/mind/changeling = pick_n_take(possible_changelings)
		pre_changelings += changeling
		changeling.restricted_roles = (restricted_jobs + secondary_restricted_jobs)
		changeling.special_role = SPECIAL_ROLE_CHANGELING
		changeling.will_roll_antag = TRUE

	return ..()

/datum/game_mode/traitor/changeling/post_setup()
	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	..()
