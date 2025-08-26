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
	/// These roles can't be antagonists because mindshielding or are command staff (this can be disabled via config)
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
		"Trans-Solar Federation General",
		"Research Director",
		"Head of Personnel",
		"Chief Medical Officer",
		"Chief Engineer",
		"Quartermaster"
	)
	/// Applies the mind roll to assigned_role, preventing them from rolling a normal job. Good for wizards and nuclear operatives.
	var/assign_job_role = FALSE
	/// A blacklist of species names that cannot play this antagonist
	var/list/banned_species = list()
	/// If true, the species blacklist is now a species whitelist
	var/banned_species_only = FALSE

	/// Rulesets that cannot be rolled while this ruleset is active. Used to prevent traitors from rolling while theres cultists, etc.
	var/list/banned_mutual_rulesets = list(
		/datum/ruleset/traitor/autotraitor,
		/datum/ruleset/team/cult,
	)

	/* This stuff changes, all stuff above is static */
	/// How many antagonists to spawn
	var/antag_amount = 0
	/// All of the minds that we will make into our antagonist type
	var/list/datum/mind/pre_antags = list()
	/// If non-zero, how long from the start of the game should a latespawn for this role occur?
	var/latespawn_time

/datum/ruleset/Destroy(force, ...)
	stack_trace("[src] ([type]) was destroyed.")
	return ..()

/datum/ruleset/proc/ruleset_possible(ruleset_budget, rulesets, antag_budget)
	if(ruleset_budget < ruleset_cost)
		return RULESET_FAILURE_BUDGET
	if(antag_budget < antag_cost)
		return RULESET_FAILURE_ANTAG_BUDGET
	if(!length(SSticker.mode.get_players_for_role(antagonist_type::job_rank))) // this specifically needs to be job_rank not special_rank
		return RULESET_FAILURE_NO_PLAYERS
	if(length(banned_mutual_rulesets) && length(rulesets))
		for(var/datum/ruleset/ruleset in rulesets)
			if(ruleset.type in banned_mutual_rulesets)
				return RULESET_FAILURE_MUTUAL_RULESET

/datum/ruleset/proc/antagonist_possible(budget)
	return budget >= antag_cost

/datum/ruleset/proc/roundstart_pre_setup()
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
		if(!roundstart_can_apply(antag))
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

/datum/ruleset/proc/roundstart_can_apply(datum/mind/antag)
	var/client/antag_client = GLOB.directory[ckey(antag.key)]
	if(!antag_client)
		CRASH("Null client for key [antag.key] during dynamic antag assignment.")
	if(EXCLUSIVE_OR(antag_client.prefs.active_character.species in banned_species, banned_species_only))
		SEND_SIGNAL(src, COMSIG_RULESET_FAILED_SPECIES)
		return FALSE
	if(antag.special_role) // You can only have 1 antag roll at a time, sorry
		return FALSE
	return TRUE

/datum/ruleset/proc/roundstart_post_setup(datum/game_mode/dynamic)
	for(var/datum/mind/antag as anything in pre_antags)
		antag.add_antag_datum(antagonist_type)
		SSblackbox.record_feedback("nested tally", "dynamic_selections", 1, list("roundstart", "[antagonist_type]"))

/datum/ruleset/proc/refund(info)
	// not enough antagonists signed up!!! idk what to do. The only real solution is to procedurally allocate budget, which will result in 1000x more get_players_for_role() calls. Which is not cheap.
	// OR we cache get_players_for_role() and then just check if they have a special_role. May be unreliable.
	log_dynamic("[info] Refund unimplemented, wasting [antag_cost * antag_amount] budget.")
	// Currently unimplemented. Will be useful for a possible future PR where latejoin antagonists are factored in.
	return

/datum/ruleset/proc/get_latejoin_players()
	var/list/candidates = list()

	// Assemble a list of active players without jobbans.
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		// Has a mind
		if(!player.mind)
			continue
		// Connected and not AFK
		if(!player.client || (locate(player) in SSafk.afk_players))
			continue
		// Not antag-banned and not specific antag banned
		if(jobban_isbanned(player, ROLE_SYNDICATE) || jobban_isbanned(player, antagonist_type::job_rank))
			continue
		// Make sure they want to play antag, and that they're not already something (off station or antag)
		if(player.client.persistent.skip_antag || player.mind.offstation_role || player.mind.special_role)
			continue
		// Make sure they actually want to be this antagonist
		if(!(antagonist_type::job_rank in player.client.prefs.be_special))
			continue
		// Make sure their species CAN be this antagonist
		if(EXCLUSIVE_OR(player.dna.species.name in banned_species, banned_species_only))
			continue
		// Make sure they're not in a banned job
		if(player.mind.assigned_role in banned_jobs)
			continue

		candidates += player.mind

	return shuffle(candidates)

/datum/ruleset/proc/latespawn(datum/game_mode/dynamic/dynamic)
	// latespawning is only used by traitors at this point, so we're just going to be naive and allocate all budget when this proc is called.
	var/late_antag_amount = floor(dynamic.antag_budget / antag_cost)
	dynamic.antag_budget -= (late_antag_amount * antag_cost)

	var/list/datum/mind/possible_antags = get_latejoin_players()
	for(var/i in 1 to late_antag_amount)
		var/datum/mind/antag = pick_n_take(possible_antags)
		antag.add_antag_datum(antagonist_type)
		SSblackbox.record_feedback("nested tally", "dynamic_selections", 1, list("latespawn", "[antagonist_type]"))

	log_dynamic("Latespawned [late_antag_amount] [name]\s.")
	message_admins("Dynamic latespawned [late_antag_amount] [name]\s.")

/datum/ruleset/proc/automatic_deduct(budget)
	. = antag_cost * antag_amount
	log_dynamic("Automatic deduction: +[antag_amount] [name]\s. Remaining budget: [budget - .].")

/datum/ruleset/proc/declare_completion()
	return

/datum/ruleset/traitor
	name = "Traitor"
	ruleset_weight = 11
	antag_cost = 7
	antag_weight = 2
	antagonist_type = /datum/antagonist/traitor

/datum/ruleset/traitor/roundstart_post_setup(datum/game_mode/dynamic)
	latespawn_time = rand(5 MINUTES, 15 MINUTES)
	for(var/datum/mind/antag as anything in pre_antags)
		var/datum/antagonist/traitor/traitor_datum = new antagonist_type()
		if(ishuman(antag.current))
			traitor_datum.delayed_objectives = TRUE
			traitor_datum.addtimer(CALLBACK(traitor_datum, TYPE_PROC_REF(/datum/antagonist/traitor, reveal_delayed_objectives)), latespawn_time, TIMER_DELETE_ME)
		antag.add_antag_datum(traitor_datum)
		SSblackbox.record_feedback("nested tally", "dynamic_selections", 1, list("roundstart", "[antagonist_type]"))

/datum/ruleset/traitor/autotraitor
	name = "Autotraitor"
	ruleset_weight = 2
	antag_cost = 10
	banned_mutual_rulesets = list(
		/datum/ruleset/traitor,
		/datum/ruleset/vampire,
		/datum/ruleset/changeling,
		/datum/ruleset/team/cult
	)

/datum/ruleset/traitor/autotraitor/roundstart_post_setup(datum/game_mode/dynamic)
	. = ..()
	latespawn_time = null
	addtimer(CALLBACK(src, PROC_REF(latespawn), dynamic), 5 MINUTES, TIMER_DELETE_ME|TIMER_LOOP)

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

/datum/ruleset/changeling/ruleset_possible(ruleset_budget, rulesets, antag_budget)
	// Theres already a ruleset, we're good to go
	if(length(rulesets))
		return ..()
	// We're the first ruleset, but we can afford another ruleset
	if(ruleset_budget > 1)
		return ..()
	return RULESET_FAILURE_CHANGELING_SECONDARY_RULESET

// This is the fucking worst, but its required to not change functionality with mindflayers. Cannot be rolled normally, this is applied by other methods.
/datum/ruleset/implied
	name = "BASE IMPLIED RULESET"
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
	log_dynamic("Rolled implied [name]: +1 [name], -1 [implier.name].")
	implier.antag_amount -= 1
	antag_amount += 1
	was_triggered = TRUE

/datum/ruleset/team
	name = "BASE TEAM RULESET"
	ruleset_weight = 0
	/// Whether there should only be one of this kind of team. This could be used for blood-brothers if false.
	var/unique_team = TRUE
	/// How many players on a team.
	var/team_size = 1
	/// Team datum to create.
	var/datum/team/team_type

/datum/ruleset/team/roundstart_post_setup(datum/game_mode/dynamic)
	if(unique_team)
		SSblackbox.record_feedback("nested tally", "dynamic_selections", 1, list("roundstart", "[team_type]"))
		new team_type(pre_antags)
		return
	stack_trace("Undefined behavior for dynamic non-unique teams!")

/datum/ruleset/team/automatic_deduct(budget)
	antag_amount = team_size
	. = antag_cost
	log_dynamic("Automatic deduction: +[antag_amount] [name]\s. Remaining budget: [budget - .].")

/datum/ruleset/team/antagonist_possible(budget)
	if(unique_team) // we're given our size at the start, no more please!
		return FALSE
	return ..()

/datum/ruleset/team/cult
	name = "Cultist"
	ruleset_weight = 3
	// antag_weight doesnt matter, since we've already allocated our budget for 4 cultists only
	antag_cost = 30
	antagonist_type = /datum/antagonist/cultist
	banned_mutual_rulesets = list(
		/datum/ruleset/traitor,
		/datum/ruleset/traitor/autotraitor,
		/datum/ruleset/vampire,
		/datum/ruleset/changeling
	)
	banned_jobs = list("Cyborg", "AI", "Chaplain", "Head of Personnel")

	team_size = 4
	team_type = /datum/team/cult

/datum/ruleset/team/cult/declare_completion()
	if(SSticker.mode.cult_team.cult_status == NARSIE_HAS_RISEN)
		SSticker.mode_result = "cult win - cult win"
		to_chat(world, "<span class='danger'><FONT size=3>The cult wins! It has succeeded in summoning [GET_CULT_DATA(entity_name, "their god")]!</FONT></span>")
	else if(SSticker.mode.cult_team.cult_status == NARSIE_HAS_FALLEN)
		SSticker.mode_result = "cult draw - narsie died, nobody wins"
		to_chat(world, "<span class='danger'><FONT size = 3>Nobody wins! [GET_CULT_DATA(entity_name, "the cult god")] was summoned, but banished!</FONT></span>")
	else
		SSticker.mode_result = "cult loss - staff stopped the cult"
		to_chat(world, "<span class='warning'><FONT size = 3>The staff managed to stop the cult!</FONT></span>")
