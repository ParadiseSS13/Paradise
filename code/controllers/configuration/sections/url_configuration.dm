/// Config holder for all the server URLs
/datum/configuration_section/url_configuration
	// Dont tweak these. You can read them though.
	protection_state = PROTECTION_READONLY
	/// List of URLs for the server RSC data
	var/list/rsc_urls = list()
	/// Server URL for auto-reconnecting people at end round
	var/server_url
	/// URL for the server ban appeals forum
	var/banappeals_url
	/// URL for the server wiki
	var/wiki_url
	/// URL for the server forums
	var/forum_url
	/// URL for the server rules
	var/rules_url
	/// URL for the server github repository
	var/github_url
	/// URL for the server exploit report locaion
	var/exploit_url
	/// URL for server donations
	var/donations_url
	/// URL for a direct discord invite
	var/discord_url
	/// URL for a discord invite going via the forums
	var/discord_forum_url
	/// URL for linking ingame accounts and forum accounts. Token is appended to end
	var/forum_link_url
	/// URL for pulling player info on webtools
	var/forum_playerinfo_url
	/// URL for the CentCom Ban DB API
	var/centcom_ban_db_url
	/// URL for the stats page
	var/round_stats_url

/datum/configuration_section/url_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_LIST(rsc_urls, data["rsc_urls"])

	CONFIG_LOAD_STR(server_url, data["reboot_url"])
	CONFIG_LOAD_STR(banappeals_url, data["ban_appeals_url"])
	CONFIG_LOAD_STR(wiki_url, data["wiki_url"])
	CONFIG_LOAD_STR(forum_url, data["forum_url"])
	CONFIG_LOAD_STR(rules_url, data["rules_url"])
	CONFIG_LOAD_STR(github_url, data["github_url"])
	CONFIG_LOAD_STR(exploit_url, data["exploit_url"])
	CONFIG_LOAD_STR(donations_url, data["donations_url"])
	CONFIG_LOAD_STR(discord_url, data["discord_url"])
	CONFIG_LOAD_STR(discord_forum_url, data["discord_forum_url"])
	CONFIG_LOAD_STR(forum_link_url, data["forum_link_url"])
	CONFIG_LOAD_STR(forum_playerinfo_url, data["forum_playerinfo_url"])
	CONFIG_LOAD_STR(centcom_ban_db_url, data["centcomm_ban_db_url"])
	CONFIG_LOAD_STR(round_stats_url, data["round_stats_url"])
