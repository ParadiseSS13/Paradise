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
	/// Will the scenario be selected repeatedly or only once?
	var/execution_once = FALSE
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

	/// Is the antagonist chosen from the station's crew?
	var/is_crew_antag = TRUE
	/// Spawn antagonist at landmark name
	var/obj/effect/landmark/spawner/landmark_type = /obj/effect/landmark/spawner/xeno
	/// What species can be used for the antagonist
	var/list/possible_species = list("Human")
	/// Recommended species at prefs to increase the chance of getting a role for RP-experienced players
	var/list/recommended_species_active_pref
	/// Multiplication modifier that increases the chance of landing by N times
	var/recommended_species_mod = 0

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
	modif_chance_recommended_species()

	for(var/i in 1 to calculated_antag_cap)
		if(!length(candidates))
			log_debug("Antag scenario 'candidates' null length")
			break

		var/mob/new_player/chosen = pickweight(candidates)
		candidates.Remove(chosen)

		// We will check if something bad happened with candidates here.
		if(!chosen || !chosen.mind)
			error("Antag scenario 'candidates' were containing 'null' or mindless mob. This should not happen.")
			calculated_antag_cap++
			continue

		var/datum/mind/chosen_mind = chosen.mind
		assigned |= chosen_mind
		chosen_mind.special_role = antag_special_role
		if(!is_crew_antag)
			chosen_mind.assigned_role = antag_special_role
		chosen_mind.restricted_roles |= restricted_roles

	var/string_names = ""
	for(var/mob/new_player/i in assigned)
		string_names += "[i.name](ckey:[i.ckey]), "
	log_debug("pre_execute: calculated_antag_cap = [calculated_antag_cap]; assigned_before = [assigned_before]; length(candidates): [length(candidates)]; assigned: [string_names];")

	return length(assigned) - assigned_before > 0

/**
 * Called in `post_setup`, which means that all players already have jobs. Here antags should receive everything they need.
 * Can fail here, but there is nothing we can do on this stage - all players already have their jobs.
*/
/datum/antag_scenario/proc/execute()
	for(var/datum/mind/assignee as anything in assigned)
		assignee.add_antag_datum(antag_datum)
	if(!is_crew_antag && !try_make_characters(assigned))
		return FALSE
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


/**
 * Create a character if the antagonist should not have a body initially.
*/
/datum/antag_scenario/proc/try_make_characters(list/datum/mind/assigned)
	if(!length(assigned))
		error("Invalid antag scenario - try make characters: Not enough assigned candidates.")
		return FALSE

	var/list/landmarks = GLOB.raider_spawn.Copy()

	if(!length(landmarks))
		landmarks = list()
		for(var/landmark in GLOB.latejoin)
			landmarks.Add(landmark)

	if(!length(landmarks))
		error("Invalid antag scenario - try make characters: Not enough landmarks.")
		return FALSE

	var/list/temp_landmarks = list()
	for(var/datum/mind/mind in assigned)
		if(!length(temp_landmarks))
			temp_landmarks = landmarks.Copy()
		var/picked_landmark = pick(temp_landmarks)
		temp_landmarks.Remove(picked_landmark)
		var/turf/loc_spawn = get_turf(picked_landmark)

		make_character(mind, loc_spawn)
		equip_character(mind)
		mind.current.dna.species.after_equip_job(null, mind.current)

	return TRUE

/**
 * Сreate characters if the antagonist is not from the crew.
*/
/datum/antag_scenario/proc/make_character(datum/mind/mind, turf/loc_spawn)
	var/picked_species = pick(possible_species)
	var/datum/antagonist/temp_antag_datum = locate(antag_datum) in mind.antag_datums
	temp_antag_datum.make_body(loc_spawn, mind, TRUE, picked_species, possible_species)

/datum/antag_scenario/proc/equip_character(datum/mind/mind)
	return TRUE
/**
 * Recommended species increase the chance of getting a role for RP-experienced players
*/
/datum/antag_scenario/proc/modif_chance_recommended_species()
	if(!length(candidates))
		return

	if(!recommended_species_mod)
		return

	if(!length(recommended_species_active_pref))
		return

	for(var/mob/new_player/candidate in candidates)
		var/list/datum/character_save/characters = candidate.client.prefs.character_saves
		for(var/datum/character_save/character in characters)
			if(character.species in recommended_species_active_pref)
				candidates[candidate] = recommended_species_mod
			else
				candidates[candidate] = 1
