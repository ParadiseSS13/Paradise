#define TOT_COST 5
#define VAMP_COST 10
#define CLING_COST 10


/datum/game_mode/trifecta
	name = "Trifecta"
	config_tag = "trifecta"
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Internal Affairs Agent", "Nanotrasen Career Trainer", "Nanotrasen Navy Officer", "Special Operations Officer", "Trans-Solar Federation General", "Nanotrasen Career Trainer", "Research Director", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Quartermaster")
	restricted_jobs = list("Cyborg")
	secondary_restricted_jobs = list("AI")
	required_players = 25
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	species_to_mindflayer = list("Machine")
	var/vampire_restricted_jobs = list("Chaplain")
	var/amount_vamp = 1
	var/amount_cling = 1
	var/amount_tot = 1
	/// How many points did we get at roundstart
	var/cost_at_roundstart

/datum/game_mode/trifecta/announce()
	to_chat(world, "<b>The current game mode is - Trifecta</b>")
	to_chat(world, "<b>Vampires, traitors, and changelings, oh my! Stay safe as these forces work to bring down the station.</b>")

/datum/game_mode/trifecta/pre_setup()
	calculate_quantities()
	cost_at_roundstart = num_players()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs
	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	if(!length(possible_vampires))
		return FALSE

	for(var/datum/mind/vampire as anything in shuffle(possible_vampires))
		if(length(pre_vampires) >= amount_vamp)
			break
		vampire.restricted_roles = restricted_jobs + secondary_restricted_jobs + vampire_restricted_jobs
		if(vampire.current.client.prefs.active_character.species in species_to_mindflayer)
			pre_mindflayers += vampire
			amount_vamp -= 1 //It's basically the same thing as incrementing pre_vampires
			vampire.special_role = SPECIAL_ROLE_MIND_FLAYER
			continue
		pre_vampires += vampire
		vampire.special_role = SPECIAL_ROLE_VAMPIRE

	//Vampires made, off to changelings
	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	if(!length(possible_changelings))
		return FALSE

	for(var/datum/mind/changeling as anything in shuffle(possible_changelings))
		if(length(pre_changelings) >= amount_cling)
			break
		if(changeling.special_role == SPECIAL_ROLE_VAMPIRE || changeling.special_role == SPECIAL_ROLE_MIND_FLAYER)
			continue
		changeling.restricted_roles = (restricted_jobs + secondary_restricted_jobs)
		if(changeling.current?.client?.prefs.active_character.species in species_to_mindflayer)
			pre_mindflayers += changeling
			amount_cling -= 1
			changeling.special_role = SPECIAL_ROLE_MIND_FLAYER
			continue
		pre_changelings += changeling
		changeling.special_role = SPECIAL_ROLE_CHANGELING

	//And now traitors
	var/list/datum/mind/possible_traitors = get_players_for_role(ROLE_TRAITOR)

	//stop setup if no possible traitors
	if(!length(possible_traitors))
		return FALSE

	for(var/datum/mind/traitor as anything in shuffle(possible_traitors))
		if(length(pre_traitors) >= amount_tot)
			break
		if(traitor.special_role == SPECIAL_ROLE_VAMPIRE || traitor.special_role == SPECIAL_ROLE_CHANGELING || traitor.special_role == SPECIAL_ROLE_MIND_FLAYER) // no traitor vampires or changelings
			continue
		pre_traitors += traitor
		traitor.special_role = SPECIAL_ROLE_TRAITOR
		traitor.restricted_roles = restricted_jobs

	return TRUE

/datum/game_mode/trifecta/proc/calculate_quantities()
	var/points = num_players()
	// So. to ensure that we had at least one vamp / changeling / traitor, I set the number of ammount to 1. I never subtracted points, leading to 25 players worth of antags added for free. Whoops.
	points -= TOT_COST + VAMP_COST + CLING_COST
	while(points > 0)
		if(points < TOT_COST)
			amount_tot++
			points = 0
			return

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
	for(var/datum/mind/vampire as anything in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire)

	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)

	var/random_time
	if(length(pre_traitors))
		random_time = rand(5 MINUTES, 15 MINUTES)
		addtimer(CALLBACK(src, PROC_REF(fill_antag_slots)), random_time)

	for(var/datum/mind/traitor in pre_traitors)
		var/datum/antagonist/traitor/traitor_datum = new(src)
		if(ishuman(traitor.current))
			traitor_datum.delayed_objectives = TRUE
			traitor_datum.addtimer(CALLBACK(traitor_datum, TYPE_PROC_REF(/datum/antagonist/traitor, reveal_delayed_objectives)), random_time, TIMER_DELETE_ME)

		traitor.add_antag_datum(traitor_datum)

	..()

/datum/game_mode/trifecta/traitors_to_add()
	. = 0
	for(var/datum/mind/traitor_mind as anything in traitors)
		if(!QDELETED(traitor_mind) && traitor_mind.current) // Explicitly no client check in case you happen to fall SSD when this gets ran
			continue
		.++
		traitors -= traitor_mind

	var/extra_points = num_players_started() - cost_at_roundstart
	if(extra_points - TOT_COST < 0)
		return 0 // Not enough new players to add extra tots

	while(extra_points)
		.++
		if(extra_points < TOT_COST) // The leftover change is enough for us to buy another traitor with, what a deal!
			return
		extra_points -= TOT_COST

#undef TOT_COST
#undef VAMP_COST
#undef CLING_COST
