/// Config holder for all things relating to discord webhooks
/datum/configuration_section/discord_configuration
	protection_state = PROTECTION_PRIVATE // No hook reading
	/// Are webhooks enabled at all
	var/webhooks_enabled = FALSE
	/// Do we want to forward all ahelps or just ones sent with no active admins
	var/forward_all_ahelps = TRUE
	/// Admin role to ping if no admins are online. Disables if empty string
	var/admin_role_id = ""
	/// Mentor role to ping if no mentors are online. Disables if empty string
	var/mentor_role_id = ""
	/// List of all URLs for the main webhooks
	var/list/main_webhook_urls = list()
	/// List of all URLs for the mentor webhooks
	var/list/mentor_webhook_urls = list()
	/// List of all URLs for the admin webhooks
	var/list/admin_webhook_urls = list()


/datum/configuration_section/discord_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(webhooks_enabled, data["enable_discord_webhooks"])
	CONFIG_LOAD_BOOL(forward_all_ahelps, data["forward_all_ahelps"])
	CONFIG_LOAD_STR(admin_role_id, data["admin_role_id"])
	CONFIG_LOAD_STR(mentor_role_id, data["mentor_role_id"])
	CONFIG_LOAD_LIST(main_webhook_urls, data["main_webhook_urls"])
	CONFIG_LOAD_LIST(mentor_webhook_urls, data["mentor_webhook_urls"])
	CONFIG_LOAD_LIST(admin_webhook_urls, data["admin_webhook_urls"])
