GLOBAL_LIST_EMPTY(dynamic_forced_rulesets)

/datum/game_mode/dynamic
	name = "Dynamic"
	config_tag = "dynamic"
	/// Non-implied rulesets in play
	var/list/datum/ruleset/rulesets = list()
	/// Implied rulesets that are in play
	var/list/datum/ruleset/implied_rulesets = list()

	/// How much budget is left after roundstart antagonists roll
	var/antag_budget = 0

	/// Log for what happens in a dynamic round
	var/list/dynamic_log = list()

	/// Minimum amount of budget required to start considering latespawn antags. 0 disables latespawn antags.
	var/min_latespawn_budget = 0

/datum/game_mode/dynamic/announce()
	to_chat(world, "<b>The current game mode is - Dynamic</b>")
	var/list/possible_rulesets = list()
	for(var/datum/ruleset/ruleset as anything in subtypesof(/datum/ruleset))
		if(ruleset.ruleset_weight <= 0)
			continue
		possible_rulesets |= ruleset.name
		if(ruleset.implied_ruleset_type)
			possible_rulesets |= ruleset.implied_ruleset_type.name
	to_chat(world, "<b>Possible Rulesets:</b> [english_list(possible_rulesets)]")

/// Calculates the dynamic budget based on the number of players in the round
/datum/game_mode/dynamic/proc/calculate_budget(players)
	switch(players)
		if(0 to 4)
			// Flat budget of 7
			return 7
		if(5 to 20)
			// +0.5 budget each for players 5-20
			// Cumulative total at 20 players: 15
			return 7 + ceil(0.5 * (players - 4))
		if(21 to 30)
			// +1.5 budget each for players 21 to 30
			// Cumulative total at 30 players: 30
			return 15 + ceil(1.5 * (players - 20))
		else
			// +1 budget each for players 31+, so just player count.
			return players

/datum/game_mode/dynamic/proc/allocate_ruleset_budget()
	var/ruleset_budget = text2num(GLOB.dynamic_forced_rulesets["budget"] || pickweight(list("0" = 3, "1" = 8, "2" = 12, "3" = 3)))
	var/num_players = num_players()
	antag_budget = calculate_budget(num_players)
	log_dynamic("Allocated gamemode budget: [ruleset_budget]")
	SSblackbox.record_feedback("tally", "dynamic_budget", ruleset_budget, "ruleset")
	SSblackbox.record_feedback("tally", "dynamic_budget", antag_budget, "antag")
	SSblackbox.record_feedback("amount", "dynamic_num_players", num_players)
	var/list/possible_rulesets = list()
	for(var/datum/ruleset/ruleset as anything in subtypesof(/datum/ruleset))
		if(ruleset.ruleset_weight <= 0)
			continue
		if(GLOB.dynamic_forced_rulesets[ruleset] == DYNAMIC_RULESET_BANNED)
			continue
		var/datum/ruleset/new_ruleset = new ruleset()
		possible_rulesets[new_ruleset] = new_ruleset.ruleset_weight

	for(var/datum/ruleset/ruleset in possible_rulesets)
		SSblackbox.record_feedback("tally", "dynamic_possible_rulesets_by_weight", ruleset.ruleset_weight, "[ruleset.type]")
	log_dynamic("Available rulesets: [english_list(possible_rulesets)]")

	for(var/datum/ruleset/ruleset as anything in GLOB.dynamic_forced_rulesets)
		if(ruleset == "budget")
			continue
		if(GLOB.dynamic_forced_rulesets[ruleset] != DYNAMIC_RULESET_FORCED)
			continue
		if(!ispath(ruleset, /datum/ruleset))
			stack_trace("Non-ruleset in GLOB.dynamic_forced_rulesets: \"[ruleset]\" ([ruleset?.type])")
			continue
		log_dynamic("Forcing ruleset: [ruleset.name]")
		ruleset_budget -= pick_ruleset(new ruleset, ruleset_budget, force = TRUE)
		for(var/datum/ruleset/old_ruleset in possible_rulesets)
			if(old_ruleset.type == ruleset)
				possible_rulesets -= old_ruleset
				qdel(old_ruleset)

	while(ruleset_budget >= 0)
		var/datum/ruleset/ruleset = pickweight(possible_rulesets)
		if(!ruleset)
			log_dynamic("No more available rulesets")
			return
		ruleset_budget -= pick_ruleset(ruleset, ruleset_budget)
		possible_rulesets -= ruleset
	log_dynamic("No more ruleset budget")

/datum/game_mode/dynamic/proc/pick_ruleset(datum/ruleset/ruleset, ruleset_budget, force)
	if(!ruleset)
		return
	if(!force)
		var/failure_reason = ruleset.ruleset_possible(ruleset_budget, rulesets, antag_budget)
		if(failure_reason)
			log_dynamic("Failed [ruleset.name] ruleset: [failure_reason].")
			return
		log_dynamic("Rolled ruleset: [ruleset.name]")
	rulesets[ruleset] = ruleset.antag_weight
	. = ruleset.ruleset_cost // return the ruleset cost to be subtracted from the gamemode budget
	if(!ruleset.implied_ruleset_type)
		return

	var/datum/ruleset/implied/implied = locate(ruleset.implied_ruleset_type) in implied_rulesets
	if(!implied)
		log_dynamic("Adding implied ruleset: [ruleset.implied_ruleset_type.name]")
		implied = new ruleset.implied_ruleset_type
		implied_rulesets += implied
	implied.RegisterSignal(ruleset, implied.target_signal, TYPE_PROC_REF(/datum/ruleset/implied, on_implied))

/datum/game_mode/dynamic/proc/allocate_antagonist_budget()
	if(!length(rulesets))
		log_dynamic("No rulesets in play.")
		return
	log_dynamic("Allocated antagonist budget: [antag_budget].", TRUE)

	for(var/datum/ruleset/ruleset in rulesets)
		ruleset.antag_amount = 1
		antag_budget -= ruleset.automatic_deduct(antag_budget)

	log_dynamic("Rulesets in play: [english_list((rulesets + implied_rulesets))]", TRUE)

	apply_antag_budget()

/datum/game_mode/dynamic/proc/apply_antag_budget(consider_latespawns = FALSE)
	var/list/temp_rulesets = rulesets.Copy()
	var/antags_rolled = 0
	while(antag_budget >= 0)
		var/datum/ruleset/ruleset = pickweight(temp_rulesets)
		if(!ruleset)
			log_dynamic("No rulesets remaining. Remaining budget: [antag_budget]. Antagonists rolled: [antags_rolled]")
			return antags_rolled
		if((consider_latespawns && !ruleset.latespawns_enabled) || !ruleset.antagonist_possible(antag_budget))
			log_dynamic("Rolled [ruleset.name]: failed, removing [ruleset.name] ruleset.")
			temp_rulesets -= ruleset
			continue
		ruleset.antag_amount += 1
		antags_rolled += 1
		antag_budget -= ruleset.antag_cost
		log_dynamic("Rolled [ruleset.name]: success, +1 [ruleset.name]. Remaining budget: [antag_budget].")
	log_dynamic("No more antagonist budget remaining. Antagonists rolled: [antags_rolled]")
	return antags_rolled

/datum/game_mode/dynamic/proc/set_latespawn_budget()
	// Disable latespawns if there's no rulesets to roll from
	if(length(rulesets) <= 0)
		log_dynamic("Found zero rulesets. Disabling latespawns.", TRUE)
		return
	if(length(rulesets) == 1)
		var/datum/ruleset/ruleset = rulesets[1]
		if(!ruleset.latespawns_enabled)
			min_latespawn_budget = 0
			log_dynamic("The only ruleset, [ruleset.name], does not support latespawns. Disabling latespawns.", TRUE)
			return
		min_latespawn_budget = ruleset.antag_cost
	else
		var/max_cost = 0
		for(var/datum/ruleset/ruleset as anything in rulesets)
			if(!ruleset.latespawns_enabled)
				continue
			if(ruleset.antag_cost > max_cost)
				max_cost = ruleset.antag_cost
		min_latespawn_budget = max_cost
	log_dynamic("Latespawn budget threshold set to [min_latespawn_budget] from [length(rulesets)] ruleset(s).", TRUE)

/datum/game_mode/dynamic/pre_setup()
	var/watch = start_watch()
	log_dynamic("Starting dynamic setup.")
	allocate_ruleset_budget()
	set_latespawn_budget()
	log_dynamic("-=-=-=-=-=-=-=-=-=-=-=-=-")
	allocate_antagonist_budget()
	log_dynamic("=-=-=-=-=-=-=-=-=-=-=-=-=")

	for(var/datum/ruleset/ruleset in (rulesets + implied_rulesets)) // rulesets first, then implied rulesets
		log_dynamic("Applying [ruleset.antag_amount] [ruleset.name]\s.")
		antag_budget += ruleset.roundstart_pre_setup()
	if(antag_budget < 0)
		antag_budget = 0
	
	log_dynamic("Budget overflow: [antag_budget].")
	// for the future, maybe try readding antagonists with apply_antag_budget(antag_budget)
	log_dynamic("Finished dynamic setup in [stop_watch(watch)]s.")
	return TRUE

/datum/game_mode/dynamic/post_setup()
	for(var/datum/ruleset/ruleset in (rulesets + implied_rulesets))
		if(length(ruleset.pre_antags))
			log_dynamic("Making antag datums for [ruleset.name] ruleset.")
		ruleset.roundstart_post_setup(src)
		if(ruleset.latespawn_time)
			ruleset.latespawns_enabled = FALSE
			addtimer(CALLBACK(ruleset, TYPE_PROC_REF(/datum/ruleset, enable_latespawns)), ruleset.latespawn_time)
			log_dynamic("[ruleset]s will latespawn at [ruleset.latespawn_time / 600].", TRUE)
	..()

/datum/game_mode/dynamic/latespawn(mob)
	. = ..()
	if(min_latespawn_budget <= 0)
		return
	antag_budget += 1
	log_dynamic("Crew joined. New budget: [antag_budget] (latespawn in [min_latespawn_budget - antag_budget])", TRUE)
	if(antag_budget >= min_latespawn_budget)
		log_dynamic("Budget at latespawn threshold ([min_latespawn_budget]), buying antagonists.", TRUE)
		if(apply_antag_budget(TRUE))
			for(var/datum/ruleset/ruleset as anything in (rulesets + implied_rulesets))
				if(ruleset.antag_amount <= 0)
					continue
				ruleset.latespawn(src)

/datum/game_mode/dynamic/on_mob_cryo(mob/sleepy_mob, obj/machinery/cryopod/cryopod)
	if(min_latespawn_budget <= 0)
		return
	var/turf/T = get_turf(cryopod)
	if(!T || is_admin_level(T.z))
		return
	antag_budget -= 1
	if(!sleepy_mob.mind || !length(sleepy_mob.mind.antag_datums))
		log_dynamic("Crew cryo. New budget: [antag_budget]", TRUE)
		return
	for(var/datum/antagonist/antag in sleepy_mob.mind.antag_datums)
		for(var/datum/ruleset/possible_ruleset as anything in subtypesof(/datum/ruleset))
			if(istype(antag, possible_ruleset.antagonist_type))
				antag_budget += possible_ruleset.antag_cost + 1
				log_dynamic("[possible_ruleset] cryo, refunded [possible_ruleset.antag_cost] budget. New budget: [antag_budget]", TRUE)

/datum/game_mode/dynamic/get_webhook_name()
	var/list/implied_and_used = list()
	for(var/datum/ruleset/implied/implied as anything in implied_rulesets)
		if(implied.was_triggered)
			implied_and_used += implied
	return "[name] ([english_list(rulesets + implied_and_used, nothing_text = "Extended")])"

/datum/game_mode/dynamic/declare_completion()
	for(var/datum/ruleset/ruleset in rulesets)
		ruleset.declare_completion()
	. = ..()

