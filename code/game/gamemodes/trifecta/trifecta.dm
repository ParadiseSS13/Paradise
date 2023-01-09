#define TOT_COST 5
#define VAMP_COST 10
#define CLING_COST 10


/datum/game_mode/trifecta
	name = "Trifecta"
	config_tag = "trifecta"
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Chaplain", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Solar Federation General")
	restricted_jobs = list("Cyborg")
	secondary_restricted_jobs = list("AI")
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	secondary_protected_species = list("Machine")
	var/list/datum/mind/pre_traitors = list()
	var/list/datum/mind/pre_changelings = list()
	var/list/datum/mind/pre_vampires = list()
	var/amount_vamp = 1
	var/amount_cling = 1
	var/amount_tot = 1

/datum/game_mode/trifecta/announce()
	to_chat(world, "<B>The current game mode is - Trifecta</B>")
	to_chat(world, "<B>Vampires, traitors, and changelings, oh my! Stay safe as these forces work to bring down the station.</B>")


/datum/game_mode/trifecta/pre_setup()
	calculate_quantities()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs
	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)
	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_vampires) && (player.client.prefs.active_character.species in secondary_protected_species))
			possible_vampires -= player.mind

	if(!length(possible_vampires))
		return FALSE

	if(possible_vampires.len > 0)
		for(var/I in possible_vampires)
			if(length(pre_vampires) >= amount_vamp)
				break
			var/datum/mind/vampire = pick_n_take(possible_vampires)
			pre_vampires += vampire
			vampire.special_role = SPECIAL_ROLE_VAMPIRE
			vampire.restricted_roles = (restricted_jobs + secondary_restricted_jobs)

	//Vampires made, off to changelings
	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)
	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_changelings) && (player.client.prefs.active_character.species in secondary_protected_species))
			possible_changelings -= player.mind

	if(!length(possible_changelings))
		return FALSE

	for(var/datum/mind/candidate in possible_changelings)
		if(candidate.special_role == SPECIAL_ROLE_VAMPIRE) // no vampire changelings security does not deserve that hell
			possible_changelings.Remove(candidate)

	for(var/I in possible_changelings)
		if(length(pre_changelings) >= amount_cling)
			break
		var/datum/mind/changeling = pick_n_take(possible_changelings)
		pre_changelings += changeling
		changeling.restricted_roles = (restricted_jobs + secondary_restricted_jobs)
		changeling.special_role = SPECIAL_ROLE_CHANGELING

	//And now traitors
	var/list/possible_traitors = get_players_for_role(ROLE_TRAITOR)

	for(var/datum/mind/candidate in possible_traitors)
		if(candidate.special_role == SPECIAL_ROLE_VAMPIRE || candidate.special_role == SPECIAL_ROLE_CHANGELING) // no traitor vampires or changelings
			possible_traitors.Remove(candidate)

	// stop setup if no possible traitors
	if(!length(possible_traitors))
		return FALSE

	for(var/i in 1 to amount_tot)
		if(!length(possible_traitors))
			break
		var/datum/mind/traitor = pick_n_take(possible_traitors)
		pre_traitors += traitor
		traitor.special_role = SPECIAL_ROLE_TRAITOR
		traitor.restricted_roles = restricted_jobs

	if(!length(pre_traitors))
		return FALSE
	return TRUE

/datum/game_mode/trifecta/proc/calculate_quantities()
	var/points = num_players()
	while(points > 0)
		if(points < TOT_COST)
			amount_tot++
			points = 0

		switch(rand(1, 4))
			if(1 to 2)
				amount_tot++
				points -= TOT_COST
			if(3)
				amount_vamp++
				points -= VAMP_COST
			if(4)
				amount_cling++
				points -= CLING_COST

/datum/game_mode/trifecta/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire)
	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	for(var/t in pre_traitors)
		var/datum/mind/traitor = t
		traitor.add_antag_datum(/datum/antagonist/traitor)
	..()


#undef TOT_COST
#undef VAMP_COST
#undef CLING_COST
