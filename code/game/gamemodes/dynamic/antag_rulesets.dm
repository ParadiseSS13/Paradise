/**
 * These are gamemode rulesets for the dynamic gamemode type. They determine what antagonists spawn during a round.
 */
/datum/ruleset
	/// What this ruleset is called
	var/name = "BASE RULESET"
	/// The cost to roll this ruleset
	var/ruleset_cost = 1
	/// The weight to roll this ruleset
	var/ruleset_weight = 1
	/// The cost to roll an antagonist of this ruleset
	var/antag_cost = 1
	/// The weight to roll an antagonist of this ruleset
	var/antag_weight = 1
	/// Antagonist datum to apply to users
	var/datum/antagonist/antagonist_type
	/// A ruleset to be added when this ruleset is selected by the gamemode
	var/datum/ruleset/implied/implied_ruleset_type

	/// These roles 100% cannot be this antagonist
	var/list/banned_jobs = list("Cyborg")
	/// These roles can't be antagonists because mindshielding (this can be disabled via config)
	var/list/protected_jobs = list(
		"Security Officer",
		"Warden",
		"Detective",
		"Head of Security",
		"Captain",
		"Blueshield",
		"Nanotrasen Representative",
		"Magistrate",
		"Internal Affairs Agent",
		"Nanotrasen Career Trainer",
		"Nanotrasen Navy Officer",
		"Special Operations Officer",
		"Trans-Solar Federation General"
	)
	/// Applies the mind roll to assigned_role, preventing them from rolling a normal job. Good for wizards and nuclear operatives.
	var/assign_job_role = FALSE
	/// A blacklist of species names that cannot play this antagonist
	var/list/banned_species = list()
	/// If true, the species blacklist is now a species whitelist
	var/banned_species_only = FALSE

	// var/list/banned_mutual_rulesets = list() // UNIMPLEMENTED: could be used to prevent nukies rolling while theres cultists, or wizards, etc

	/* This stuff changes, all stuff above is static */
	/// How many antagonists to spawn
	var/antag_amount = 0
	/// All of the minds that we will make into our antagonist type
	var/list/datum/mind/pre_antags = list()

/datum/ruleset/Destroy(force, ...)
	stack_trace("[src] ([type]) was destroyed.")
	return ..()

/datum/ruleset/proc/ruleset_possible(ruleset_budget, rulesets)
	if(ruleset_budget < ruleset_cost)
		return RULESET_FAILURE_BUDGET
	if(!length(SSticker.mode.get_players_for_role(antagonist_type::job_rank))) // this specifically needs to be job_rank not special_rank
		return RULESET_FAILURE_NO_PLAYERS

/datum/ruleset/proc/antagonist_possible(budget)
	return budget >= antag_cost

/datum/ruleset/proc/pre_setup()
	if(antag_amount == 0)
		return
	if(antag_amount < 0)
		stack_trace("/datum/ruleset/proc/pre_setup() for [type] somehow had a negative antagonist amount")
		return
	var/list/datum/mind/possible_antags = SSticker.mode.get_players_for_role(antagonist_type::job_rank) // this specifically needs to be job_rank not special_rank
	if(!length(possible_antags))
		refund("No possible players for [src] ruleset.") // we allocate antag budget before we allocate players, and previous rulesets can steal our players
		return antag_cost * antag_amount // shitty refund for now

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		banned_jobs += protected_jobs

	shuffle_inplace(possible_antags)
	for(var/datum/mind/antag as anything in possible_antags)
		if(antag_amount <= 0)
			break
		if(!can_apply(antag))
			continue
		pre_antags += antag
		if(assign_job_role)
			antag.assigned_role = antagonist_type::special_role
		antag.special_role = antagonist_type::special_role
		antag.restricted_roles = banned_jobs
		antag_amount -= 1

	if(antag_amount > 0)
		refund("Missing [antag_amount] antagonists for [src] ruleset.")
		return antag_cost * antag_amount // shitty refund for now

/datum/ruleset/proc/can_apply(datum/mind/antag)
	if(EXCLUSIVE_OR(antag.current.client.prefs.active_character.species in banned_species, banned_species_only))
		SEND_SIGNAL(src, COMSIG_RULESET_FAILED_SPECIES)
		return FALSE
	if(antag.special_role) // You can only have 1 antag roll at a time, sorry
		return FALSE
	return TRUE

/datum/ruleset/proc/post_setup(datum/game_mode/dynamic)
	for(var/datum/mind/antag as anything in pre_antags)
		antag.add_antag_datum(antagonist_type)

/datum/ruleset/proc/refund(info)
	// not enough antagonists signed up!!! idk what to do. The only real solution is to procedurally allocate budget, which will result in 1000x more get_players_for_role() calls. Which is not cheap.
	// OR we cache get_players_for_role() and then just check if they have a special_role. May be unreliable.
	// log_dynamic("[info] Refunding [antag_cost * antag_amount] budget.")
	// Currently unimplemented. Will be useful for a possible future PR where latejoin antagonists are factored in.
	return

/datum/ruleset/traitor
	name = "Traitor"
	ruleset_weight = 11
	antag_cost = 5
	antag_weight = 2
	antagonist_type = /datum/antagonist/traitor

/datum/ruleset/traitor/post_setup(datum/game_mode/dynamic)
	var/random_time = rand(5 MINUTES, 15 MINUTES)
	for(var/datum/mind/antag as anything in pre_antags)
		var/datum/antagonist/traitor/traitor_datum = new antagonist_type()
		if(ishuman(antag.current))
			traitor_datum.delayed_objectives = TRUE
			traitor_datum.addtimer(CALLBACK(traitor_datum, TYPE_PROC_REF(/datum/antagonist/traitor, reveal_delayed_objectives)), random_time, TIMER_DELETE_ME)
		antag.add_antag_datum(traitor_datum)
	addtimer(CALLBACK(dynamic, TYPE_PROC_REF(/datum/game_mode, fill_antag_slots)), random_time)

/datum/ruleset/vampire
	name = "Vampire"
	ruleset_weight = 12
	antag_cost = 10
	antagonist_type = /datum/antagonist/vampire

	banned_jobs = list("Cyborg", "AI", "Chaplain")
	banned_species = list("Machine")
	implied_ruleset_type = /datum/ruleset/implied/mindflayer

/datum/ruleset/changeling
	name = "Changeling"
	ruleset_weight = 9
	antag_cost = 10
	antagonist_type = /datum/antagonist/changeling

	banned_jobs = list("Cyborg", "AI")
	banned_species = list("Machine")
	implied_ruleset_type = /datum/ruleset/implied/mindflayer

/datum/ruleset/changeling/ruleset_possible(ruleset_budget, rulesets)
	// Theres already a ruleset, we're good to go
	if(length(rulesets))
		return ..()
	// We're the first ruleset, but we can afford another ruleset
	if((ruleset_budget >= /datum/ruleset/traitor::ruleset_cost) || (ruleset_budget >= /datum/ruleset/vampire::ruleset_cost))
		return ..()
	return RULESET_FAILURE_CHANGELING_SECONDARY_RULESET

// This is the fucking worst, but its required to not change functionality with mindflayers. Cannot be rolled normally, this is applied by other methods.
/datum/ruleset/implied
	// These 3 variables should never change
	ruleset_cost = 0
	ruleset_weight = 0
	antag_weight = 0
	// antag_cost is allowed to be edited to help with refunding antagonists
	antag_cost = 0
	/// This signal is registered on whatever (multiple) rulesets implied us. This will call on_implied.
	var/target_signal
	/// Set this to true if this implied ruleset was activated
	var/was_triggered = FALSE

/datum/ruleset/implied/proc/on_implied(datum/antagonist/implier)
	stack_trace("[type]/on_implied() not implemented!")

/datum/ruleset/implied/mindflayer
	name = "Mindflayer"
	antagonist_type = /datum/antagonist/mindflayer
	antag_cost = 10
	target_signal = COMSIG_RULESET_FAILED_SPECIES

	banned_jobs = list("Cyborg", "AI")
	banned_species = list("Machine")
	banned_species_only = TRUE

/datum/ruleset/implied/mindflayer/on_implied(datum/ruleset/implier)
	// log_dynamic("Rolled implied [name]: +1 [name], -1 [implier.name].")
	implier.antag_amount -= 1
	antag_amount += 1
	was_triggered = TRUE
