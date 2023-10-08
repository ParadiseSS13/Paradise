/// Config holder for everything regarding gamemodes
/datum/configuration_section/gamemode_configuration
	/// List of all gamemodes (value: config-tag)
	var/list/gamemodes = list()
	/// Assoc list of gamemode names (key: config-tag | value: mode name)
	var/list/gamemode_names = list()
	/// Assoc list of gamemode probabilities  (key: config-tag | value: probability)
	var/list/probabilities = list()
	/// List of all gamemodes that can be voted for, (value: config-tag)
	var/list/votable_modes = list()
	/// Should antags be restricted based on account age?
	var/antag_account_age_restriction = FALSE
	/// Scale amount of traitors with population
	var/traitor_scaling = TRUE
	/// Prevent mindshield roles getting antagonist status
	var/prevent_mindshield_antags = TRUE
	/// Rounds such as rev, wizard and malf end instantly when the antag has won. Enable the setting below to not do that.
	var/disable_certain_round_early_end = FALSE
	/// Amount of objectives traitors should get. Does not include escape or hijack.
	var/traitor_objectives_amount = 2
	/// Enable player limits on gamemodes? Disabling can be useful for testing
	var/enable_gamemode_player_limit = TRUE

// Dynamically setup a list of all gamemodes
/datum/configuration_section/gamemode_configuration/New()
	for(var/T in subtypesof(/datum/game_mode))
		var/datum/game_mode/M = T

		// Dont bother if theres no tag
		if(!initial(M.config_tag))
			continue
		// Ensure each mode is added only once
		if(initial(M.config_tag) in gamemodes)
			continue

		// Add it in
		gamemodes += initial(M.config_tag)
		gamemode_names[initial(M.config_tag)] = initial(M.name)
		probabilities[initial(M.config_tag)] = initial(M.probability)

		if(initial(M.votable))
			votable_modes += initial(M.config_tag)

	// Add secret to the votable pool
	votable_modes += "secret"

/datum/configuration_section/gamemode_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(antag_account_age_restriction, data["antag_account_age_restrictions"])
	CONFIG_LOAD_BOOL(traitor_scaling, data["traitor_scaling"])
	CONFIG_LOAD_BOOL(prevent_mindshield_antags, data["prevent_mindshield_antag"])
	CONFIG_LOAD_BOOL(disable_certain_round_early_end, data["disable_certain_round_early_end"])
	CONFIG_LOAD_BOOL(enable_gamemode_player_limit, data["enable_gamemode_player_limit"])

	CONFIG_LOAD_NUM(traitor_objectives_amount, data["traitor_objective_amount"])

	// Load gamemode probabilities
	if(islist(data["gamemode_probabilities"]))
		for(var/list/assocset in data["gamemode_probabilities"])
			// Make sure it exists
			if(assocset["gamemode"] in gamemodes)
				probabilities[assocset["gamemode"]] = assocset["probability"]
			else
				stack_trace("Gamemode [assocset["gamemode"]] has a probability in config, but does not exist!")

/datum/configuration_section/gamemode_configuration/proc/pick_mode(mode_name)
	for(var/T in subtypesof(/datum/game_mode))
		var/datum/game_mode/M = T
		// If the tag exists, and its the same as the mode
		if(initial(M.config_tag) && (initial(M.config_tag) == mode_name))
			return new T()

	// Default to extended if it didnt work
	stack_trace("Could not pick a gamemode. Defaulting to extended. (Attempted mode: [mode_name])")
	return new /datum/game_mode/extended()

/datum/configuration_section/gamemode_configuration/proc/get_runnable_modes()
	var/list/datum/game_mode/runnable_modes = new
	for(var/T in subtypesof(/datum/game_mode))
		var/datum/game_mode/M = new T()

		if(!(M.config_tag in gamemodes))
			qdel(M)
			continue

		if(probabilities[M.config_tag] <= 0)
			qdel(M)
			continue

		if(M.can_start())
			runnable_modes[M] = probabilities[M.config_tag]

	return runnable_modes
