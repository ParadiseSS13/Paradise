#define MINDSHIELDED_JOBS list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Trans-Solar Federation General")

/datum/antagonist_ruleset
	var/ruleset_cost = 1
	var/ruleset_weight = 1
	var/cost = 1
	var/weight = 1
	var/list/banned_mutual_rulesets = list() // could be used to prevent nukies rolling while theres cultists, or wizards, etc

	var/datum/antagonist/antagonist
	var/mind_role
	// these roles 100% cannot be this antagonist
	var/list/banned_jobs = list("Cyborg")
	// These roles can't be antagonists because mindshielding (this can be disabled via config)
	var/list/protected_jobs = MINDSHIELDED_JOBS
	var/list/banned_species = list()
	/* This stuff changes, all stuff above is static */
	var/antag_amount = 0
	var/list/datum/mind/pre_antags = list()


/datum/antagonist_ruleset/proc/ruleset_possible(gamerule_budget)
	if(gamerule_budget < ruleset_cost)
		return FALSE
	if(!length(Ssticker.mode.get_players_for_role(mind_role)))
		return FALSE
	return TRUE

/datum/antagonist_ruleset/proc/antagonist_possible(budget)
	return budget >= cost

/datum/antagonist_ruleset/proc/apply_ruleset()
	var/list/datum/mind/possible_antags = get_players_for_role(mind_role)
	if(!length(possible_antags))
		stack_trace("FUUUUUUUUUUUUUUUUUUUUUUUCK") // we allocate antag budget before we allocate players, and previous rulesets can steal our players
		return FALSE // oh shit this ruleset failed!!! not good

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		banned_jobs += protected_jobs
	for(var/datum/mind/antag as anything in shuffle(possible_antags))
		if(antag_amount <= 0)
			break
		if(antag.current.client.prefs.active_character.species in banned_species)
			continue
		pre_antags += antag
		antag.special_role = mind_role
		antag.restricted_roles = banned_jobs
		antag_amount -= 1

	if(antag_amount > 0)
		// not enough antagonists signed up!!! idk what to do. The only real solution is to procedurally allocate budget, which will result in 1000x more get_players_for_role() calls. Which is not cheap.
		// OR we cache get_players_for_role() and then just check if they have a special_role. May be unreliable.
		stack_trace("antag_amount: [antag_amount]. FUUUUUCK.")

/datum/antagonist_ruleset/proc/post_setup()
	for(var/datum/mind/antag as anything in pre_antags)
		antag.add_antag_datum(antagonist)

/datum/antagonist_ruleset/traitor
	ruleset_weight = 13
	cost = 5
	weight = 2
	antagonist = /datum/antagonist/traitor
	mind_role = SPECIAL_ROLE_TRAITOR

/datum/antagonist_ruleset/traitor/post_setup()
	var/random_time = rand(5 MINUTES, 15 MINUTES)
	for(var/datum/mind/antag as anything in pre_antags)
		var/datum/antagonist/traitor/traitor_datum = new antagonist()
		if(ishuman(antag.current))
			traitor_datum.delayed_objectives = TRUE
			traitor_datum.addtimer(CALLBACK(traitor_datum, TYPE_PROC_REF(/datum/antagonist/traitor, reveal_delayed_objectives)), random_time, TIMER_DELETE_ME)
		antag.add_antag_datum(traitor_datum)

/datum/antagonist_ruleset/vampire
	ruleset_weight = 9
	cost = 10
	antagonist = /datum/antagonist/vampire
	mind_role = ROLE_VAMPIRE

	banned_jobs = list("Cyborg", "AI", "Chaplain")
	banned_species = list("Machine")

/datum/antagonist_ruleset/changeling
	ruleset_weight = 9
	cost = 10
	antagonist = /datum/antagonist/changeling
	mind_role = ROLE_CHANGELING

	banned_jobs = list("Cyborg", "AI")
	banned_species = list("Machine")
