SUBSYSTEM_DEF(discord)
	name = "Discord"
	flags = SS_NO_FIRE
	/// Is the SS enabled
	var/enabled = FALSE
	/// Last time the administrator ping was dropped. This ensures administrators cannot be mass pinged if a large chunk of ahelps go off at once (IE: tesloose)
	var/last_administration_ping = 0

/datum/controller/subsystem/discord/Initialize(start_timeofday)
	if(config.discord_webhooks_enabled)
		enabled = TRUE
	return ..()

// This is designed for ease of simplicity for sending quick messages from parts of the code
/datum/controller/subsystem/discord/proc/send2discord_simple(destination, content)
	if(!enabled)
		return
	var/list/webhook_urls
	switch(destination)
		if(DISCORD_WEBHOOK_ADMIN)
			webhook_urls = config.discord_admin_webhook_urls
		if(DISCORD_WEBHOOK_PRIMARY)
			webhook_urls = config.discord_main_webhook_urls
		if(DISCORD_WEBHOOK_MENTOR)
			webhook_urls = config.discord_mentor_webhook_urls

	var/datum/discord_webhook_payload/dwp = new()
	dwp.webhook_content = content
	for(var/url in webhook_urls)
		SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, url, dwp.serialize2json(), list("content-type" = "application/json"))

// This one is designed to take in a [/datum/discord_webhook_payload] which was prepared beforehand
/datum/controller/subsystem/discord/proc/send2discord_complex(destination, datum/discord_webhook_payload/dwp)
	if(!enabled)
		return
	var/list/webhook_urls
	switch(destination)
		if(DISCORD_WEBHOOK_ADMIN)
			webhook_urls = config.discord_admin_webhook_urls
		if(DISCORD_WEBHOOK_PRIMARY)
			webhook_urls = config.discord_main_webhook_urls
	for(var/url in webhook_urls)
		SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, url, dwp.serialize2json(), list("content-type" = "application/json"))

// This one is for sending messages to the admin channel if no admins are active, complete with a ping to the game admins role
/datum/controller/subsystem/discord/proc/send2discord_simple_noadmins(content, check_send_always = FALSE)
	// Setup some stuff
	var/alerttext
	var/list/admincounter = staff_countup(R_BAN)
	var/active_admins = admincounter[1]
	var/inactive_admins = admincounter[3]
	var/add_ping = TRUE

	if(active_admins <= 0)
		if(inactive_admins > 0)
			alerttext = " | **ALL ADMINS AFK**"
		else
			alerttext = " | **NO ADMINS ONLINE**"
	else
		if(check_send_always && config.discord_forward_all_ahelps)
			// If we are here, there are admins online. We want to forward everything, but obviously dont want to add a ping, so we do this
			add_ping = FALSE
		else
			// We have active admins, we dont care about the rest of this proc
			return

	var/message = "[content] [alerttext] [add_ping ? handle_administrator_ping() : ""]"

	var/datum/discord_webhook_payload/dwp = new()
	dwp.webhook_content = message
	for(var/url in config.discord_admin_webhook_urls)
		SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, url, dwp.serialize2json(), list("content-type" = "application/json"))

// Helper to make administrator ping easier
/datum/controller/subsystem/discord/proc/handle_administrator_ping()
	// Check if a role is even set
	if(config.discord_admin_role_id)
		if(last_administration_ping > world.time)
			return "*(Role pinged recently)*"

		last_administration_ping = world.time + 60 SECONDS
		return "<@&[config.discord_admin_role_id]>"

	return ""
