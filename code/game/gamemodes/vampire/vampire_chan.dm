/datum/game_mode/vampire/changeling
	name = "vampire_changeling"
	config_tag = "vampchan"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Chaplain", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Solar Federation General")
	protected_species = list("Machine")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 3
	secondary_enemies_scaling = 0.025
	vampire_penalty = 0.6 // Cut out 40% of the vampires since we'll replace some with changelings
	/// A list of all soon-to-be changelings
	var/list/datum/mind/pre_changelings = list()

/datum/game_mode/vampire/changeling/pre_setup()
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

	return ..()

/datum/game_mode/vampire/announce()
	to_chat(world, "<b>The current game mode is - Vampires+Changelings!</b>")
	to_chat(world, "<b>Some of your co-workers are vampires, and others might not even be your coworkers!</b>")

/datum/game_mode/vampire/changeling/post_setup()
	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	..()
