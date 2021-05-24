/// Config holder for stuff relating to the ingame vote system
/datum/configuration_section/vote_configuration
	/// Allow players to start restart votes?
	var/allow_restart_votes = FALSE
	/// Allow players to start gamemode votes?
	var/allow_mode_votes = FALSE
	/// Minimum delay between each vote (deciseconds)
	var/vote_delay = 18000 // 30 mins
	/// How long will a vote last for (deciseconds)
	var/vote_time = 600 // 60 seconds
	/// Time before the first shuttle vote (deciseconds)
	var/autotransfer_initial_time = 72000 // 2 hours
	/// Time between subsequent shuttle votes if the first one is not successful (deciseconds)
	var/autotransfer_interval_time = 18000 // 30 mins
	/// Prevent dead players from voting
	var/prevent_dead_voting = FALSE
	/// Default to players not voting
	var/disable_default_vote = TRUE
	/// Enable map voting?
	var/enable_map_voting = FALSE

/datum/configuration_section/vote_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(allow_restart_votes, data["allow_vote_restart"])
	CONFIG_LOAD_BOOL(allow_mode_votes, data["allow_vote_mode"])
	CONFIG_LOAD_BOOL(prevent_dead_voting, data["prevent_dead_voting"])
	CONFIG_LOAD_BOOL(disable_default_vote, data["disable_default_vote"])
	CONFIG_LOAD_BOOL(enable_map_voting, data["enable_map_voting"])

	CONFIG_LOAD_NUM(vote_delay, data["vote_delay"])
	CONFIG_LOAD_NUM(vote_time, data["vote_time"])
	CONFIG_LOAD_NUM(autotransfer_initial_time, data["autotransfer_initial_time"])
	CONFIG_LOAD_NUM(autotransfer_interval_time, data["autotransfer_interval_time"])
