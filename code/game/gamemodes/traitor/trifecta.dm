/datum/game_mode/traitor/trifecta
	name = "Trifecta"
	config_tag = "trifecta"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Chaplain", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Solar Federation General")
	restricted_jobs = list("Cyborg")
	secondary_restricted_jobs = list("AI")
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	secondary_enemies_scaling = 0.025
	secondary_protected_species = list("Machine")
	traitor_scaling_coeff_adjustment = 2 // Half as many traitors, but a vamp and cling per 40 players As such, 4 traitors for each vamp / cling. 6 antags at 40 pop (compared to 8 on traitor), and 12 at 80 (compared to 16 on traitor)
	var/list/datum/mind/pre_changelings = list()
	var/list/datum/mind/pre_vampires = list()

/datum/game_mode/traitor/trifecta/announce()
	to_chat(world, "<B>The current game mode is - Trifecta</B>")
	to_chat(world, "<B>Vampires, traitors, and changelings, oh my! Stay safe as these forces work to bring down the station</B>")


/datum/game_mode/traitor/trifecta/pre_setup()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)
	secondary_enemies = CEILING((secondary_enemies_scaling * num_players()), 1)

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_vampires) && (player.client.prefs.active_character.species in secondary_protected_species))
			possible_vampires -= player.mind

	if(possible_vampires.len > 0)
		for(var/I in possible_vampires)
			if(length(pre_vampires) >= secondary_enemies)
				break
			var/datum/mind/vampire = pick_n_take(possible_vampires)
			pre_vampires += vampire
			vampire.special_role = SPECIAL_ROLE_VAMPIRE
			vampire.restricted_roles = (restricted_jobs + secondary_restricted_jobs)

	//Vampires made, off to changelings
	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)
	secondary_enemies = CEILING((secondary_enemies_scaling * num_players()), 1) //Reset secondary to zero, so we don't get zero changelings.

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_changelings) && (player.client.prefs.active_character.species in secondary_protected_species))
			possible_changelings -= player.mind

	if(!length(possible_changelings))
		return ..()

	for(var/datum/mind/candidate in possible_changelings)
		if(candidate.special_role == SPECIAL_ROLE_VAMPIRE) // no vampire changelings security does not deserve that hell
			possible_changelings.Remove(candidate)

	for(var/I in possible_changelings)
		if(length(pre_changelings) >= secondary_enemies)
			break
		var/datum/mind/changeling = pick_n_take(possible_changelings)
		pre_changelings += changeling
		changeling.restricted_roles = (restricted_jobs + secondary_restricted_jobs)
		changeling.special_role = SPECIAL_ROLE_CHANGELING

	return ..()

/datum/game_mode/traitor/trifecta/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire)
	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	..()
