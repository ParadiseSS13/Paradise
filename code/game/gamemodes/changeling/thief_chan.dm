/datum/game_mode/thief/changeling
	name = "thief+changeling(less)"
	config_tag = "thiefchan"
	restricted_jobs = list("AI", "Cyborg")
	required_players = 15
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	var/protected_species_changeling = list("Machine")
	var/list/datum/mind/pre_changelings = list()

/datum/game_mode/thief/changeling/announce()
	to_chat(world, "<B>The current game mode is - Thief+Changeling!</B>")
	to_chat(world, "<B>На станции зафиксирована деятельность гильдии воров и генокрадов. Не дайте генокрадам достичь успеха и скрыться, и не допустите кражу дорогостоящего оборудования!</B>")


/datum/game_mode/thief/changeling/pre_setup()
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

/datum/game_mode/thief/changeling/post_setup()
	for(var/datum/mind/changeling in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	..()

