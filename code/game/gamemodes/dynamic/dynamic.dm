GLOBAL_LIST_EMPTY(dynamic_forced_rulesets)

/datum/game_mode/dynamic
	name = "Dynamic"
	config_tag = "dynamic"
	secondary_restricted_jobs = list("AI")
	required_players = 10
	var/list/forced_rulesets = list()
	var/list/datum/ruleset/rulesets = list()
	var/list/datum/ruleset/implied_rulesets = list()

/datum/game_mode/dynamic/announce()
	to_chat(world, "<b>The current game mode is - Dynamic</b>")
	var/list/possible_rulesets = list()
	for(var/datum/ruleset/ruleset as anything in subtypesof(/datum/ruleset))
		if(ruleset.ruleset_weight <= 0)
			continue
		possible_rulesets |= ruleset
		if(ruleset.implied_ruleset)
			possible_rulesets += ruleset.implied_ruleset
	to_chat(world, "<b>Possible Rulesets:</b> [english_list(possible_rulesets)]")

/datum/game_mode/dynamic/proc/allocate_ruleset_budget()
	var/ruleset_budget = text2num(pickweight(list("0" = 3, "1" = 5, "2" = 12, "3" = 3))) // more likely to or 2
	if(ruleset_budget <= 0)
		return
	var/list/possible_rulesets = list()
	for(var/datum/ruleset/ruleset as anything in subtypesof(/datum/ruleset))
		if(ruleset.ruleset_weight <= 0)
			continue
		var/datum/ruleset/new_ruleset = new ruleset()
		possible_rulesets[new_ruleset] = new_ruleset.ruleset_weight

	for(var/datum/ruleset/ruleset as anything in GLOB.dynamic_forced_rulesets)
		if(!ispath(ruleset, /datum/ruleset))
			stack_trace("Non-ruleset in GLOB.dynamic_forced_rulesets: \"[ruleset]\" ([ruleset?.type])")
			continue
		ruleset_budget -= pick_ruleset(new ruleset, ruleset_budget, ignore_budget = TRUE)

	while(ruleset_budget >= 0)
		var/datum/ruleset/ruleset = pickweight(possible_rulesets)
		if(!ruleset)
			return
		ruleset_budget -= pick_ruleset(ruleset, ruleset_budget)
		possible_rulesets -= ruleset

/datum/game_mode/dynamic/proc/pick_ruleset(datum/ruleset/ruleset, ruleset_budget, ignore_budget)
	if(!ruleset)
		return
	if(!ruleset.ruleset_possible())
		return
	if(!ignore_budget && (ruleset_budget < ruleset.ruleset_cost))
		return

	rulesets[ruleset] = ruleset.weight
	. = ruleset.ruleset_cost // return the ruleset cost to be subtracted from the gamemode budget
	if(!ruleset.implied_ruleset)
		return

	var/datum/ruleset/implied/implied = locate(ruleset.implied_ruleset) in implied_rulesets
	if(!implied)
		implied = new ruleset.implied_ruleset
		implied_rulesets += implied
	implied.RegisterSignal(ruleset, implied.target_signal, TYPE_PROC_REF(/datum/ruleset/implied, on_implied))
	return

/datum/game_mode/dynamic/proc/allocate_antagonist_budget()
	if(!length(rulesets))
		return
	var/budget = num_players()
	for(var/datum/ruleset/ruleset in rulesets)
		ruleset.antag_amount = 1
		budget -= ruleset.cost

	apply_antag_budget(budget)

/datum/game_mode/dynamic/proc/apply_antag_budget(budget) // ctodo, can be called later in the game to apply more budget. That also means there has to be shit done for latejoins.
	var/list/temp_rulesets = rulesets.Copy()
	while(budget >= 0)
		var/datum/ruleset/ruleset = pickweight(temp_rulesets)
		if(!ruleset)
			return
		if(!ruleset.antagonist_possible(budget))
			temp_rulesets -= ruleset
			continue
		ruleset.antag_amount++
		budget -= ruleset.cost

/datum/game_mode/dynamic/pre_setup()
	allocate_ruleset_budget()
	allocate_antagonist_budget()
	var/budget_overflow = 0
	for(var/datum/ruleset/ruleset in (rulesets + implied_rulesets)) // rulesets first, then implied rulesets
		budget_overflow += ruleset.pre_setup()

	apply_antag_budget(budget_overflow) // CTODO CURRENTLY, THIS INCREASES THE BUDGET AND DOES NOTHING!!!
	return TRUE

/datum/game_mode/dynamic/post_setup()
	for(var/datum/ruleset/ruleset in (rulesets + implied_rulesets))
		ruleset.post_setup()
	..()

// /datum/game_mode/dynamic/traitors_to_add()
// 	. = 0
// 	for(var/datum/mind/traitor_mind as anything in traitors)
// 		if(!QDELETED(traitor_mind) && traitor_mind.current) // Explicitly no client check in case you happen to fall SSD when this gets ran
// 			continue
// 		.++
// 		traitors -= traitor_mind

// 	var/extra_points = num_players_started() - cost_at_roundstart
// 	if(extra_points - TOT_COST < 0)
// 		return 0 // Not enough new players to add extra tots

// 	while(extra_points)
// 		.++
// 		if(extra_points < TOT_COST) // The leftover change is enough for us to buy another traitor with, what a deal!
// 			return
// 		extra_points -= TOT_COST
