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
			return 7 + 0.5 * (players - 4)
		if(21 to 30)
			// +1.5 budget each for players 21 to 30
			// Cumulative total at 30 players: 30
			return 15 + 1.5 * (players - 20)
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
	log_dynamic("Allocated antagonist budget: [antag_budget].")

	for(var/datum/ruleset/ruleset in rulesets)
		ruleset.antag_amount = 1
		antag_budget -= ruleset.automatic_deduct(antag_budget)

	log_dynamic("Rulesets in play: [english_list((rulesets + implied_rulesets))]")

	apply_antag_budget()

/datum/game_mode/dynamic/proc/apply_antag_budget() // todo, can be called later in the game to apply more budget. That also means there has to be shit done for latejoins.
	var/list/temp_rulesets = rulesets.Copy()
	while(antag_budget >= 0)
		var/datum/ruleset/ruleset = pickweight(temp_rulesets)
		if(!ruleset)
			log_dynamic("No rulesets remaining. Remaining budget: [antag_budget].")
			return
		if(!ruleset.antagonist_possible(antag_budget))
			log_dynamic("Rolled [ruleset.name]: failed, removing [ruleset.name] ruleset.")
			temp_rulesets -= ruleset
			continue
		ruleset.antag_amount++
		antag_budget -= ruleset.antag_cost
		log_dynamic("Rolled [ruleset.name]: success, +1 [ruleset.name]. Remaining budget: [antag_budget].")
	log_dynamic("No more antagonist budget remaining.")

/datum/game_mode/dynamic/pre_setup()
	var/watch = start_watch()
	log_dynamic("Starting dynamic setup.")
	allocate_ruleset_budget()
	log_dynamic("-=-=-=-=-=-=-=-=-=-=-=-=-")
	allocate_antagonist_budget()
	log_dynamic("=-=-=-=-=-=-=-=-=-=-=-=-=")

	for(var/datum/ruleset/ruleset in (rulesets + implied_rulesets)) // rulesets first, then implied rulesets
		log_dynamic("Applying [ruleset.antag_amount] [ruleset.name]\s.")
		antag_budget += ruleset.roundstart_pre_setup()

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
			addtimer(CALLBACK(ruleset, TYPE_PROC_REF(/datum/ruleset, latespawn), src), ruleset.latespawn_time)
			log_dynamic("[ruleset]s will latespawn at [ruleset.latespawn_time / 600].")
	..()

/datum/game_mode/dynamic/latespawn(mob)
	. = ..()
	antag_budget++

/datum/game_mode/dynamic/on_mob_cryo(mob/sleepy_mob, obj/machinery/cryopod/cryopod)
	var/turf/T = get_turf(cryopod)
	if(!T || is_admin_level(T.z))
		return
	antag_budget--
	if(!sleepy_mob.mind || !length(sleepy_mob.mind.antag_datums))
		return
	for(var/datum/antagonist/antag in sleepy_mob.mind.antag_datums)
		for(var/datum/ruleset/possible_ruleset as anything in subtypesof(/datum/ruleset))
			if(istype(antag, possible_ruleset.antagonist_type))
				antag_budget += possible_ruleset.antag_cost
				log_dynamic("[possible_ruleset] cryo. +[possible_ruleset.antag_cost] budget.")

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

/proc/log_dynamic(text)
	log_game("Dynamic: [text]")
	var/datum/game_mode/dynamic/dynamic = SSticker.mode
	if(!istype(dynamic))
		return
	dynamic.dynamic_log += text
