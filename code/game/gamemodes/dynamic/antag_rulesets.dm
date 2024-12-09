#define MINDSHIELDED_JOBS list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Trans-Solar Federation General")

/datum/ruleset
	var/name = "BASE RULESET"
	var/ruleset_cost = 1
	var/ruleset_weight = 1
	var/cost = 1
	var/weight = 1
	// var/list/banned_mutual_rulesets = list() // could be used to prevent nukies rolling while theres cultists, or wizards, etc
	var/datum/ruleset/implied/implied_ruleset

	var/datum/antagonist/antagonist
	var/mind_role

	// these roles 100% cannot be this antagonist
	var/list/banned_jobs = list("Cyborg")
	// These roles can't be antagonists because mindshielding (this can be disabled via config)
	var/list/protected_jobs = MINDSHIELDED_JOBS
	// Applies the mind roll to assigned_role, preventing them from rolling a normal job. Good for wizards and nuclear operatives.
	var/assign_job_role = FALSE

	var/list/banned_species = list()
	var/banned_species_only = FALSE

	/* This stuff changes, all stuff above is static */
	var/antag_amount = 0
	var/list/datum/mind/pre_antags = list()


/datum/ruleset/proc/ruleset_possible()
	return length(SSticker.mode.get_players_for_role(mind_role))

/datum/ruleset/proc/antagonist_possible(budget)
	return budget >= cost

/datum/ruleset/proc/pre_setup()
	var/list/datum/mind/possible_antags = SSticker.mode.get_players_for_role(mind_role)
	if(!length(possible_antags))
		refund("No possible players for [src] ruleset.") // we allocate antag budget before we allocate players, and previous rulesets can steal our players
		return cost*antag_amount // shitty refund for now

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		banned_jobs += protected_jobs

	for(var/datum/mind/antag as anything in shuffle(possible_antags))
		if(antag_amount <= 0)
			break
		if(!can_apply(antag))
			continue
		pre_antags += antag
		if(assign_job_role)
			antag.assigned_role = mind_role
		antag.special_role = mind_role
		antag.restricted_roles = banned_jobs
		antag_amount -= 1

	if(antag_amount > 0)
		refund("Missing [antag_amount] antagonists for [src] ruleset.")
		return cost*antag_amount // shitty refund for now

/datum/ruleset/proc/can_apply(datum/mind/antag)
	if(EXCLUSIVE_OR(antag.current.client.prefs.active_character.species in banned_species, banned_species_only))
		SEND_SIGNAL(src, COMSIG_RULESET_FAILED_SPECIES)
		return FALSE
	if(antag.special_role) // You can only have 1 antag roll at a time, sorry
		return FALSE
	return TRUE

/datum/ruleset/proc/post_setup()
	for(var/datum/mind/antag as anything in pre_antags)
		antag.add_antag_datum(antagonist)

/datum/ruleset/proc/refund(info)
	// not enough antagonists signed up!!! idk what to do. The only real solution is to procedurally allocate budget, which will result in 1000x more get_players_for_role() calls. Which is not cheap.
	// OR we cache get_players_for_role() and then just check if they have a special_role. May be unreliable.
	stack_trace("[info] Refunding [cost*antag_amount] budget.")
	stack_trace("REFUNDING NOT IMPLEMENTED!!")
	// ctodo real refunding?

/datum/ruleset/traitor
	name = "Traitor"
	ruleset_weight = 11
	cost = 5
	weight = 2
	antagonist = /datum/antagonist/traitor
	mind_role = SPECIAL_ROLE_TRAITOR

/datum/ruleset/traitor/post_setup()
	var/random_time = rand(5 MINUTES, 15 MINUTES)
	for(var/datum/mind/antag as anything in pre_antags)
		var/datum/antagonist/traitor/traitor_datum = new antagonist()
		if(ishuman(antag.current))
			traitor_datum.delayed_objectives = TRUE
			traitor_datum.addtimer(CALLBACK(traitor_datum, TYPE_PROC_REF(/datum/antagonist/traitor, reveal_delayed_objectives)), random_time, TIMER_DELETE_ME)
		antag.add_antag_datum(traitor_datum)

/datum/ruleset/vampire
	name = "Vampire"
	ruleset_weight = 12
	cost = 10
	antagonist = /datum/antagonist/vampire
	mind_role = ROLE_VAMPIRE

	banned_jobs = list("Cyborg", "AI", "Chaplain")
	banned_species = list("Machine")
	implied_ruleset = /datum/ruleset/implied/mindflayer

/datum/ruleset/changeling
	name = "Changeling"
	ruleset_weight = 9
	cost = 10
	antagonist = /datum/antagonist/changeling
	mind_role = ROLE_CHANGELING

	banned_jobs = list("Cyborg", "AI")
	banned_species = list("Machine")
	implied_ruleset = /datum/ruleset/implied/mindflayer

// This is the fucking worst, but its required to not change functionality with mindflayers
/datum/ruleset/implied
	// cannot be rolled normally, this is applied by other methods.
	ruleset_cost = 0
	ruleset_weight = 0
	cost = 0
	weight = 0
	// This signal is registered on whatever (multiple) rulesets implied us. This will call on_implied.
	var/target_signal

/datum/ruleset/implied/proc/on_implied(datum/antagonist/implier)
	return

/datum/ruleset/implied/mindflayer
	name = "Mindflayer"
	antagonist = /datum/antagonist/mindflayer
	mind_role = ROLE_MIND_FLAYER
	target_signal = COMSIG_RULESET_FAILED_SPECIES

	banned_jobs = list("Cyborg", "AI")
	banned_species = list("Machine")
	banned_species_only = TRUE

/datum/ruleset/implied/mindflayer/on_implied(datum/ruleset/implier)
	implier.antag_amount -= 1
	antag_amount += 1

// /datum/ruleset/team
// 	var/datum/team/team_type
