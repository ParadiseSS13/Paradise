/// Config holder for stuff relating to server backend management and secrets
/datum/configuration_section/system_configuration
	// NO EDITS OR READS TO THIS WHAT SOEVER
	protection_state = PROTECTION_PRIVATE
	/// Password for authorising world/Topic requests
	var/topic_key = null
	/// Do we want the server to kill on reboot instead of keeping the same DD session
	var/shutdown_on_reboot = FALSE
	/// Is this server a production server (Has higher security and requires 2FA)
	var/is_production = FALSE
	/// If above is true, you can run a shell command
	var/shutdown_shell_command = null
	/// Internal API host
	var/api_host = null
	/// Internal API key
	var/api_key = null
	/// Github API token
	var/github_api_token = null
	/// List of IP addresses which bypass world topic rate limiting
	var/list/topic_ip_ratelimit_bypass = list()
	/// Server instance ID
	var/instance_id = "paradise_main"
	/// Do we want to enable instancing stuff at all?
	var/enable_multi_instance_support = FALSE
	/// Server internal IP
	var/internal_ip = "127.0.0.1"
	/// Are we using an external handler for TOS
	var/external_tos_handler = FALSE
	/// Map datum of the map to use, overriding the defaults, and `data/next_map.txt`
	var/override_map = null
	/// Assoc list of region names and their server IPs. Used for geo-routing.
	var/list/region_map = list()
	/// Send a system toast on init completion?
	var/toast_on_init_complete = FALSE
	/// The URL for a ss13-yt-wrap server (https://github.com/Absolucy/ss13-yt-wrap) to use.
	var/ytdlp_url = null

/datum/configuration_section/system_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(shutdown_on_reboot, data["shutdown_on_reboot"])
	CONFIG_LOAD_BOOL(is_production, data["is_production"])
	CONFIG_LOAD_BOOL(external_tos_handler, data["external_tos_handler"])
	CONFIG_LOAD_BOOL(enable_multi_instance_support, data["enable_multi_instance_support"])
	CONFIG_LOAD_BOOL(toast_on_init_complete, data["toast_on_init_complete"])

	CONFIG_LOAD_STR(topic_key, data["communications_password"])
	CONFIG_LOAD_STR(shutdown_shell_command, data["shutdown_shell_command"])
	CONFIG_LOAD_STR(api_host, data["api_host"])
	CONFIG_LOAD_STR(api_key, data["api_key"])
	CONFIG_LOAD_STR(github_api_token, data["github_api_token"])

	CONFIG_LOAD_LIST(topic_ip_ratelimit_bypass, data["topic_ip_ratelimit_bypass"])

	CONFIG_LOAD_STR(instance_id, data["instance_id"])
	CONFIG_LOAD_STR(internal_ip, data["internal_ip"])

	CONFIG_LOAD_STR(override_map, data["override_map"])
	CONFIG_LOAD_STR(ytdlp_url, data["ytdlp_url"])


	// Load region overrides
	if(islist(data["regional_servers"]))
		region_map.Cut()
		for(var/list/kvset in data["regional_servers"])
			region_map[kvset["name"]] = kvset["ip"]
