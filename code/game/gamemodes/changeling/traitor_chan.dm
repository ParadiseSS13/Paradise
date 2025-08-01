/datum/game_mode/traitor/changeling
	name = "traitor_changeling"
	config_tag = "traitorchan"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("Cyborg")
	secondary_restricted_jobs = list("AI") // Allows AI to roll traitor, but not changeling
	required_players = 10
	recommended_enemies = 3
	secondary_enemies_scaling = 0.025
	species_to_mindflayer = list("Machine")

/datum/game_mode/traitor/changeling/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Changeling!</B>")
	to_chat(world, "<B>There is an alien creature on the station along with some syndicate operatives out for their own gain! Do not let the changeling and the traitors succeed!</B>")


/datum/game_mode/traitor/changeling/pre_setup()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)
	secondary_enemies = CEILING((secondary_enemies_scaling * num_players()), 1)

	if(!length(possible_changelings))
		return ..()

	for(var/I in possible_changelings)
		if((length(pre_changelings) + length(pre_mindflayers)) >= secondary_enemies)
			break
		var/datum/mind/changeling = pick_n_take(possible_changelings)
		changeling.restricted_roles = (restricted_jobs + secondary_restricted_jobs)
		if(changeling.current?.client?.prefs.active_character.species in species_to_mindflayer)
			pre_mindflayers += changeling
			changeling.special_role = SPECIAL_ROLE_MIND_FLAYER
			continue
		pre_changelings += changeling
		changeling.special_role = SPECIAL_ROLE_CHANGELING

	return ..()

/datum/game_mode/traitor/changeling/post_setup()
	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	..()
