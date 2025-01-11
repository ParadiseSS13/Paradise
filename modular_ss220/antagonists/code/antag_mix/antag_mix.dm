/datum/game_mode/antag_mix
	name = "Antag Mix"
	config_tag = "antag_mix"
	/// Multiplier of antag credits. Credits will be used to choose antag scenarios
	var/budget_multiplier = 1
	/// Max fraction of antags relative to ready players. Value between 0 and 1
	var/max_antag_fraction = 1
	/// How much budget has left
	var/budget = 0
	/// Scenarious for choose
	var/list/datum/antag_scenario/list_scenarios = list()
	/// List of scenarios chosen on `pre_setup` stage, and which will be applied on `post_setup`
	var/list/datum/antag_scenario/executed_scenarios = list()


/datum/game_mode/antag_mix/New()
	. = ..()
	apply_configuration()
	list_scenarios = subtypesof(/datum/antag_scenario)


/datum/game_mode/antag_mix/pre_setup()
	var/list/datum/antag_scenario/possible_scenarios = list_scenarios

	var/list/mob/new_player/ready_players = get_ready_players()
	var/ready_players_amount = length(ready_players)
	log_antag_mix("Trying to start round with [ready_players_amount] ready players")
	log_antag_mix("Max antagonist fraction is '[max_antag_fraction]'")

	var/list/datum/antag_scenario/acceptable_scenarios = initialize_acceptable_scenarios(possible_scenarios, ready_players_amount)
	if(!length(acceptable_scenarios))
		log_antag_mix("Invalid game mode pre setup antag_mix - acceptable scenarios.")
		return FALSE

	budget = calculate_budget(ready_players_amount)
	log_antag_mix("Roundstart budget: [budget]")
	return pick_scenarios(draft_scenarios(acceptable_scenarios, ready_players), ready_players_amount)


/datum/game_mode/antag_mix/post_setup()
	for(var/datum/antag_scenario/scenario_to_execute as anything in executed_scenarios)
		scenario_to_execute.execute()

	return ..()


/datum/game_mode/antag_mix/proc/apply_configuration()
	budget_multiplier = GLOB.configuration.antag_mix_gamemode.budget_multiplier
	max_antag_fraction = GLOB.configuration.antag_mix_gamemode.max_antag_fraction


/**
 * Calculates amount of `credits` that will spent on antag scenarios, that are available.
*/
/datum/game_mode/antag_mix/proc/calculate_budget(ready_players_amount)
	return ready_players_amount * budget_multiplier


/**
 * Count players that are currently ingame and ready.
*/
/datum/game_mode/antag_mix/proc/get_ready_players()
	var/list/mob/new_player/ready_players = list()
	for(var/mob/new_player/player in GLOB.player_list)
		if(!player.client || !player.ready)
			continue

		ready_players.Add(player)

	return ready_players

/**
 * Creates actual scenario datums from `inited_scenario_paths`.
*/
/datum/game_mode/antag_mix/proc/initialize_acceptable_scenarios(list/datum/antag_scenario/scenarios_to_init, players_ready)
	var/list/datum/antag_scenario/acceptable_scenarios = list()
	for(var/datum/antag_scenario/scenario_path as anything in scenarios_to_init)
		if(!ispath(scenario_path))
			continue

		if(initial(scenario_path.abstract))
			continue

		var/datum/antag_scenario/possible_scenario = new scenario_path
		if(!possible_scenario.acceptable(players_ready))
			qdel(possible_scenario)
			continue

		acceptable_scenarios += possible_scenario

	return acceptable_scenarios


/datum/game_mode/antag_mix/proc/pick_scenarios(list/datum/antag_scenario/drafted_scenarios, players_ready_amount, current_antag_fraction = 0)
	if(!length(drafted_scenarios))
		return FALSE

	var/budget_left = budget
	var/list/picked_scenarios = list()
	while(budget_left > 0)
		if(!length(drafted_scenarios) || (current_antag_fraction >= max_antag_fraction))
			break

		var/datum/antag_scenario/picked_scenario = length(drafted_scenarios) == 1 ? drafted_scenarios[1] : pickweight(drafted_scenarios)
		if(picked_scenario.cost > budget_left)
			drafted_scenarios.Remove(picked_scenario)
			continue

		var/added_antag_fraction = min(length(picked_scenario.candidates), picked_scenario.get_antag_cap(players_ready_amount)) / players_ready_amount
		if(!added_antag_fraction || (added_antag_fraction + current_antag_fraction > max_antag_fraction))
			drafted_scenarios.Remove(picked_scenario)
			continue

		budget_left -= picked_scenario.cost
		current_antag_fraction += added_antag_fraction

		picked_scenarios[picked_scenario] += 1
		log_antag_mix("Scenario '[picked_scenario.name]' with: cost '[picked_scenario.cost]', weight '[picked_scenario.weight]' was picked [picked_scenarios[picked_scenario]] times")
		log_antag_mix("Antagonist fraction is '[current_antag_fraction]'")

		if(picked_scenario.execution_once)
			drafted_scenarios.Remove(picked_scenario)

	if(!length(picked_scenarios))
		log_antag_mix("No antag scenarios were picked. Let another game mode roll.")
		return FALSE

	for(var/picked_scenario in picked_scenarios)
		log_debug("Antag mix picked scenario: [picked_scenario], spend budget [picked_scenarios[picked_scenario] - 1] times, left budget: [budget_left], players ready: [players_ready_amount]")
		//var/scaled_times_picked = length(picked_scenarios) > 1 ? picked_scenarios[picked_scenario] - 1 : 1
		//spend_budget(pre_execute_scenario(picked_scenario, scaled_times_picked, players_ready_amount))
		spend_budget(pre_execute_scenario(picked_scenario, picked_scenarios[picked_scenario] - 1, players_ready_amount))

	if(budget != budget_left && current_antag_fraction < max_antag_fraction && length(drafted_scenarios))
		log_antag_mix("Some of the picked scenarios failed pre execution, try to pick scenarios from leftovers")
		return pick_scenarios(drafted_scenarios, players_ready_amount, current_antag_fraction)

	return TRUE

/datum/game_mode/antag_mix/proc/spend_budget(budget_to_spend)
	budget = max(0, budget - budget_to_spend)
	log_antag_mix("Budget spent: [budget_to_spend], budget left: [budget]")


/datum/game_mode/antag_mix/proc/pre_execute_scenario(datum/antag_scenario/scenario_to_pre_execute, scaled_times, players_ready_amount)
	if(!scenario_to_pre_execute)
		log_antag_mix("Scenario '[scenario_to_pre_execute.name]' can't pre execute.")
		return 0

	log_antag_mix("Scenario '[scenario_to_pre_execute.name]' params: scaled_times [scaled_times]; players_ready_amount: [players_ready_amount]")
	scenario_to_pre_execute.trim_candidates()

	scenario_to_pre_execute.scaled_times = scaled_times
	if(!scenario_to_pre_execute.pre_execute(players_ready_amount))
		log_antag_mix("Scenario '[scenario_to_pre_execute.name]' failed to pre execute.")
		return 0

	executed_scenarios |= scenario_to_pre_execute
	return scenario_to_pre_execute.cost * (scenario_to_pre_execute.scaled_times + 1)


/datum/game_mode/antag_mix/proc/draft_scenarios(list/datum/antag_scenario/scenarios_to_pick_from, list/mob/new_player/ready_players)
	if(!length(scenarios_to_pick_from) || !length(ready_players))
		return

	var/drafted_scenarios = list()
	for(var/datum/antag_scenario/scenario as anything in scenarios_to_pick_from)
		if(!scenario.weight)
			continue

		scenario.candidates = ready_players.Copy()
		scenario.trim_candidates()
		if(!scenario.ready())
			continue

		drafted_scenarios[scenario] = scenario.weight
		log_antag_mix("Scenario: '[scenario.name]' with weight: '[scenario.weight]' was drafted")

	return drafted_scenarios

/datum/game_mode/antag_mix/proc/log_antag_mix(text)
	log_debug("\[ANTAG MIX\] [text]")
