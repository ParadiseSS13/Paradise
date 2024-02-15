/datum/antag_scenario
	/// Name of the scenario. Will be used in round end statistics
	var/name = "Generic Scenario"
	/// Configuration tag of scenario, which will be used on scenario configuration loading
	var/config_tag = null
	/// Whether scenario shouldn't be used in `Antag Mix` and which purpose is to be literally abstract.
	/// Scenario will crash in `/datum/antag_scenario/New()` if tried to instantiate
	var/abstract = TRUE
	/// Role used to check if the player is banned from it. Example: `ROLE_TRAITOR`, `ROLE_CHANGELING`, etc.
	var/antag_role = null
	/// Special role, that will be assigned to chosen players. Example: `SPECIAL_ROLE_TRAITOR`, `SPECIAL_ROLE_CHANGELIN`, etc.
	var/antag_special_role = null
	/// Antag datum, that will be granted to chosen players on `execute` which will be called on post setup
	var/datum/antagonist/antag_datum = null
	/// Amount of times, this scenario has been picked again
	var/scaled_times = 0
	/// Amount of players required to start this scenario
	var/required_players = 1
	/// Cost of the antag scenario. Antag_mix antag generation is based on this value.
	/// Scenarios with `0` cost considered free and only limited by `max_antag_fraction` of `/datum/game_mode/antag_mix`
	var/cost = 1
	/// Weight of the scenario. Will be taken into consideration by 'antag_mix' gamemode.
	/// Higher values make scenario more frequent, lower - less. Defaults to '1'
	var/weight = 1
	/// Number of player population, based on which the new scenario antag will be scaled.
	/// Can be specified using just number, which will be treated as hard cap, or in linear equation form:
	/// list("denominator" = 10, "offset" = 1), where 'denominator' is divider for current players population,
	/// and 'offset' is guaranteed amount of antag of scenario's type
	var/antag_cap = 1
	/// How many possible candidates are required for this scenario to be executed
	var/candidates_required = 1
	/// Jobs that can't be chosen for the scenario
	var/list/restricted_roles = list()
	/// Jobs that can't be chosen for the scenario if 'GLOB.configuration.gamemode.prevent_mindshield_antags' is TRUE
	var/list/protected_roles = list()
	/// Species that can't be chosen for the scenario
	var/list/restricted_species = list()
	/// List of available candidates for this scenario
	var/list/mob/new_player/candidates = list()
	/// List of players that were drafted to be antagonists of this scenario
	var/list/datum/mind/assigned = list()

/datum/antag_scenario/New()
	if(abstract)
		stack_trace("Instantiation of abstract antag scenarios is prohibited.")
		qdel(src)

	apply_configuration()


/**
 * Gets configuration params from [GLOB.configuration.antag_mix_gamemode.params_by_scenario],
 * which are grouped by `config_tag` property of `/datum/antag_scenario`.
 * If `config_tag` field is `null` - default scenario
 * and write them into
*/
/datum/antag_scenario/proc/apply_configuration()
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!config_tag)
		return

	var/params = GLOB.configuration.antag_mix_gamemode.params_by_scenario[config_tag]
	if(!islist(params))
		return

	for(var/param in params)
		if(!(param in vars))
			error("Invalid antag scenario configuration param '[param]' in [type]")
			continue

		vars[param] = params[param]

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_roles |= protected_roles + GLOB.restricted_jobs_ss220


/**
 * Performs sanity check for this scenario to be run.
 *
 * Returns: 'TRUE' if scenario is matching current situation (game has enough players, enough antags can be spawned).
 * 'FALSE' returned otherwise.
*/
/datum/antag_scenario/proc/acceptable(population)
	return (population >= required_players) && (get_antag_cap(population) > 0)


/**
 * Checks whether this scenario is ready to be applied.
 *
 * Returns: 'TRUE' if all requirements are met for this scenario to be executed, 'FALSE' otherwise
*/
/datum/antag_scenario/proc/ready()
	return length(candidates) >= candidates_required


/**
 * Called in `pre_setup` of [/datum/game_mode/antag_mix] gamemode. Here antags should be chosen.
 *
 * Returns: 'TRUE' if successfully executed, for example antags successfully chosen, 'FALSE' otherwise.
*/
/datum/antag_scenario/proc/pre_execute(population)
	var/assigned_before = length(assigned)
	var/calculated_antag_cap = get_total_antag_cap(population)
	for(var/i in 1 to calculated_antag_cap)
		if(!length(candidates))
			break

		var/mob/new_player/chosen = pick_n_take(candidates)

		// We will check if something bad happened with candidates here.
		if(!chosen || !chosen.mind)
			error("Antag scenario 'candidates' were containing 'null' or mindless mob. This should not happen.")
			calculated_antag_cap++
			continue

		var/datum/mind/chosen_mind = chosen.mind
		assigned |= chosen_mind
		chosen_mind.special_role = antag_special_role
		chosen_mind.restricted_roles |= restricted_roles

	return length(assigned) - assigned_before > 0

/**
 * Called in `post_setup`, which means that all players already have jobs. Here antags should receive everything they need.
 * Can fail here, but there is nothing we can do on this stage - all players already have their jobs.
*/
/datum/antag_scenario/proc/execute()
	for(var/datum/mind/assignee as anything in assigned)
		assignee.add_antag_datum(antag_datum)

	return TRUE

/**
 * Gets antag cap per one scenario.
*/
/datum/antag_scenario/proc/get_antag_cap(population)
	if(isnum(antag_cap))
		return antag_cap

	return FLOOR(population / (antag_cap["denominator"] || 1), 1) + (antag_cap["offset"] || 0)

/**
 * Gets antag cap per this scenario, but taking `scaled_times` into calculation.
*/
/datum/antag_scenario/proc/get_total_antag_cap(population)
	return get_antag_cap(population) * (scaled_times + 1)

/**
 * Filter candidates scenario specific requirement vise.
*/
/datum/antag_scenario/proc/trim_candidates()
	for(var/mob/new_player/candidate as anything in candidates)
		var/client/candidate_client = candidate.client
		var/datum/mind/candidate_mind = candidate.mind
		if(!candidate_client || !candidate_mind || !candidate.ready)
			candidates.Remove(candidate)
			continue

		if(candidate_client.skip_antag)
			candidates.Remove(candidate)
			continue

		if(candidate_mind.special_role)
			candidates.Remove(candidate)
			continue

		if(!player_old_enough_antag(candidate_client, antag_role))
			candidates.Remove(candidate)
			continue

		if(jobban_isbanned(candidate, ROLE_SYNDICATE) || jobban_isbanned(candidate, antag_role))
			candidates.Remove(candidate)
			continue

		if(!(antag_role in candidate.client.prefs.be_special) || (candidate.client.prefs.active_character.species in restricted_species))
			candidates.Remove(candidate)
			continue

		if(candidate_mind.assigned_role in restricted_roles)
			candidates.Remove(candidate)
