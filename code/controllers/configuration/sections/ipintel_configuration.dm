/// Config holder for all things relating to IPIntel
/datum/configuration_section/ipintel_configuration
	/// Is IPIntel enabled
	var/enabled = FALSE
	/// Are we in whitelist mode (Auto-kick people who are on proxies/VPNs)
	var/whitelist_mode = TRUE
	/// 0-1 float for percentage threshold to kick people out
	var/bad_rating = 0.9
	/// IPIntel contact email. Required.
	var/contact_email = null
	/// How many hours to save good matches for. Cached due to rate limits
	var/hours_save_good = 72
	/// How many hours to save bad matches for. Cached due to rate limits
	var/hours_save_bad = 24
	/// IPIntel Domain. Do not prefix with a protocol
	var/ipintel_domain = "check.getipintel.net"
	/// Do not proxy-check players with more hours than the below threshold
	var/playtime_ignore_threshold = 10
	/// Details URL for more info on an IP, including ASN. IP is tacked straight on the end.
	var/details_url = "https://iphub.info/?ip="

/datum/configuration_section/ipintel_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(enabled, data["ipintel_enabled"])
	CONFIG_LOAD_BOOL(whitelist_mode, data["whitelist_mode"])

	CONFIG_LOAD_NUM(bad_rating, data["bad_rating"])
	CONFIG_LOAD_NUM(hours_save_good, data["hours_save_good"])
	CONFIG_LOAD_NUM(hours_save_bad, data["hours_save_bad"])
	CONFIG_LOAD_NUM(playtime_ignore_threshold, data["playtime_ignore_threshold"])

	CONFIG_LOAD_STR(contact_email, data["contact_email"])
	CONFIG_LOAD_STR(ipintel_domain, data["ipintel_domain"])
	CONFIG_LOAD_STR(details_url, data["details_url"])
