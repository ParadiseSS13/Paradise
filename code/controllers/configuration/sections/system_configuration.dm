/// Config holder for stuff relating to server backend management and secrets
/datum/configuration_section/system_configuration
	// NO EDITS OR READS TO THIS WHAT SOEVER
	protection_state = PROTECTION_PRIVATE
	/// Password for authorising world/Topic requests
	var/topic_key = null
	/// Medal hub address for lavaland stats
	var/medal_hub_address = null
	/// Medal hub password for lavaland stats
	var/medal_hub_password = null
	/// Do we want the server to kill on reboot instead of keeping the same DD session
	var/shutdown_on_reboot = FALSE
	/// If above is true, you can run a shell command
	var/shutdown_shell_command = null
	/// 2FA backend server host
	var/_2fa_auth_host = null
	/// List of IP addresses which bypass world topic rate limiting
	var/list/topic_ip_ratelimit_bypass = list()

/datum/configuration_section/system_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(shutdown_on_reboot, data["shutdown_on_reboot"])

	CONFIG_LOAD_STR(topic_key, data["communications_password"])
	CONFIG_LOAD_STR(medal_hub_address, data["medal_hub_address"])
	CONFIG_LOAD_STR(medal_hub_password, data["medal_hub_password"])
	CONFIG_LOAD_STR(shutdown_shell_command, data["shutdown_shell_command"])
	CONFIG_LOAD_STR(_2fa_auth_host, data["_2fa_auth_host"])

	CONFIG_LOAD_LIST(topic_ip_ratelimit_bypass, data["topic_ip_ratelimit_bypass"])
