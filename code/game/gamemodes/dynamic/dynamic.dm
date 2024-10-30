/datum/game_mode/dynamic
	name = "Dynamic"
	config_tag = "dynamic"
	secondary_restricted_jobs = list("AI")
	required_players = 25
	var/list/datum/antagonist_ruleset/rulesets = list()
	var/list/datum/antagonist_ruleset/implied_rulesets = list()

/datum/game_mode/dynamic/announce()
	to_chat(world, "<b>The current game mode is - Dynamic</b>")
	to_chat(world, "<b>There could be anything lurking in the shadows.</b>")

/datum/game_mode/dynamic/proc/allocate_gamemode_budget()
	var/gamemode_budget = text2num(pickweight(list("0" = 3, "1" = 8, "2" = 9, "3" = 3))) // more likely to be 1 or 2, than 3 or 0.
	if(gamemode_budget <= 0)
		return
	var/list/possible_rulesets = list()
	for(var/ruleset in subtypesof(/datum/antagonist_ruleset))
		if(ruleset.ruleset_weight <= 0)
			continue
		var/datum/antagonist_ruleset/new_ruleset = new ruleset()
		possible_rulesets[new_ruleset] = new_ruleset.ruleset_weight

	while(gamemode_budget >= 0)
		var/datum/antagonist_ruleset/ruleset in pickweight(possible_rulesets)
		if(!ruleset)
			return
		if(!ruleset.ruleset_possible(gamemode_budget))
			possible_rulesets -= ruleset
			continue

		rulesets[ruleset] = ruleset.weight
		gamemode_budget -= ruleset.ruleset_cost
		if(!ruleset.implied_ruleset)
			continue

		var/datum/antagonist_ruleset/implied = locate(ruleset.implied_ruleset) in implied_rulesets
		if(!implied)
			implied = new ruleset.implied_ruleset
			implied_rulesets += implied
		implied.RegisterSignal(ruleset, implied.target_signal, PROC_REF(on_implied))

/datum/game_mode/dynamic/proc/allocate_antagonist_budget()
	if(!length(rulesets))
		return
	var/budget = num_players()
	for(var/datum/antagonist_ruleset/ruleset in rulesets)
		ruleset.antag_amount = 1
		budget -= ruleset.cost

	apply_antag_budget(budget)

/datum/game_mode/dynamic/proc/apply_antag_budget(budget) // ctodo, can be called later in the game to apply more budget. That also means there has to be shit done for latejoins.
	var/list/temp_rulesets = rulesets.Copy()
	while(budget >= 0)
		var/datum/antagonist_ruleset/ruleset in pickweight(temp_rulesets)
		if(!ruleset)
			return
		if(!ruleset.antagonist_possible(budget))
			temp_rulesets -= ruleset
			continue
		ruleset.antag_amount++
		budget -= ruleset.cost

/datum/game_mode/dynamic/pre_setup()
	allocate_gamemode_budget()
	allocate_antagonist_budget()
	var/budget_overflow = 0
	for(var/datum/antagonist_ruleset/ruleset in (rulesets + implied_rulesets)) // rulesets first, then implied rulesets
		budget_overflow += ruleset.pre_setup()

	apply_antag_budget(budget_overflow) // CTODO CURRENTLY, THIS INCREASES THE BUDGET AND DOES NOTHING!!!
	return TRUE

/datum/game_mode/dynamic/post_setup()
	for(var/datum/antagonist_ruleset/ruleset in (rulesets + implied_rulesets))
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
