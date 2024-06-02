/// Config holder for stuff relating to the ingame vote system
/datum/configuration_section/vote_configuration
	/// How long will a vote last for in deciseconds
	var/vote_time = 60 SECONDS // 60 seconds
	/// Time before the first shuttle vote (deciseconds)
	var/autotransfer_initial_time = 2 HOURS // 2 hours
	/// Time between subsequent shuttle votes if the first one is not successful (deciseconds)
	var/autotransfer_interval_time = 30 MINUTES // 30 mins
	/// Prevent dead players from voting
	var/prevent_dead_voting = FALSE
	/// Default to players not voting
	var/disable_default_vote = TRUE
	/// Enable map voting?
	var/enable_map_voting = FALSE
	/// If TRUE, you will not be able to vote for the current map
	var/non_repeating_maps = TRUE
	/// Dictionary of day number (string) to vote string
	var/list/map_vote_day_types = list()

/datum/configuration_section/vote_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(prevent_dead_voting, data["prevent_dead_voting"])
	CONFIG_LOAD_BOOL(disable_default_vote, data["disable_default_vote"])
	CONFIG_LOAD_BOOL(enable_map_voting, data["enable_map_voting"])
	CONFIG_LOAD_BOOL(non_repeating_maps, data["non_repeating_maps"])

	CONFIG_LOAD_NUM(vote_time, data["vote_time"])
	CONFIG_LOAD_NUM(autotransfer_initial_time, data["autotransfer_initial_time"])
	CONFIG_LOAD_NUM(autotransfer_interval_time, data["autotransfer_interval_time"])

	// Load map vote data
	if(islist(data["map_vote_day_types"]))
		map_vote_day_types.Cut()
		for(var/list/kvset in data["map_vote_day_types"])
			map_vote_day_types["[kvset["day_number"]]"] = kvset["rotation_type"]

