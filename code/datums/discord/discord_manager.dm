GLOBAL_DATUM_INIT(discord_manager, /datum/discord_manager, new())

/datum/discord_manager
	/// Last time the administrator ping was dropped. This ensures administrators cannot be mass pinged if a large chunk of ahelps go off at once (IE: tesloose)
	var/last_administration_ping = 0
	/// Last time the mentor ping was dropped. This ensures mentors cannot be mass pinged if a large chunk of mhelps go off at once.
	var/last_mentor_ping = 0

// This is designed for ease of simplicity for sending quick messages from parts of the code
/datum/discord_manager/proc/send2discord_simple(destination, content)
	if(!GLOB.configuration.discord.webhooks_enabled)
		return
	var/list/webhook_urls
	switch(destination)
		if(DISCORD_WEBHOOK_ADMIN)
			webhook_urls = GLOB.configuration.discord.admin_webhook_urls
		if(DISCORD_WEBHOOK_PRIMARY)
			webhook_urls = GLOB.configuration.discord.main_webhook_urls
		if(DISCORD_WEBHOOK_MENTOR)
			webhook_urls = GLOB.configuration.discord.mentor_webhook_urls

	var/datum/discord_webhook_payload/dwp = new()
	dwp.webhook_content = "**\[[GLOB.configuration.system.instance_id]]** [content]"
	for(var/url in webhook_urls)
		SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_POST, url, dwp.serialize2json(), list("content-type" = "application/json"))

// This one is designed to take in a [/datum/discord_webhook_payload] which was prepared beforehand
/datum/discord_manager/proc/send2discord_complex(destination, datum/discord_webhook_payload/dwp)
	if(!GLOB.configuration.discord.webhooks_enabled)
		return
	var/list/webhook_urls
	switch(destination)
		if(DISCORD_WEBHOOK_ADMIN)
			webhook_urls = GLOB.configuration.discord.admin_webhook_urls
		if(DISCORD_WEBHOOK_PRIMARY)
			webhook_urls = GLOB.configuration.discord.main_webhook_urls
		if(DISCORD_WEBHOOK_MENTOR)
			webhook_urls = GLOB.configuration.discord.mentor_webhook_urls
	for(var/url in webhook_urls)
		SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_POST, url, dwp.serialize2json(), list("content-type" = "application/json"))

// This one is for sending messages to the admin channel if no admins are active, complete with a ping to the game admins role
/datum/discord_manager/proc/send2discord_simple_noadmins(content, check_send_always = FALSE)
	if(!GLOB.configuration.discord.webhooks_enabled)
		return
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
		if(check_send_always && GLOB.configuration.discord.forward_all_ahelps)
			// If we are here, there are admins online. We want to forward everything, but obviously dont want to add a ping, so we do this
			add_ping = FALSE
		else
			// We have active admins, we dont care about the rest of this proc
			return

	var/message = "[content] [alerttext] [add_ping ? handle_administrator_ping() : ""]"

	var/datum/discord_webhook_payload/dwp = new()
	dwp.webhook_content = "**\[[GLOB.configuration.system.instance_id]]** [message]"
	for(var/url in GLOB.configuration.discord.admin_webhook_urls)
		SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_POST, url, dwp.serialize2json(), list("content-type" = "application/json"))

/datum/discord_manager/proc/send2discord_simple_mentor(content)
	var/alerttext
	var/list/mentorcounter = staff_countup(R_MENTOR)
	var/active_mentors = mentorcounter[1]
	var/inactive_mentors = mentorcounter[3]
	var/add_ping = FALSE

	if(active_mentors <= 0)
		add_ping = TRUE
		if(inactive_mentors)
			alerttext = "| **ALL MENTORS AFK**"
		else
			alerttext = "| **NO MENTORS ONLINE**"

	var/message = "[html_decode(strip_html_tags(content))] [alerttext][add_ping ? handle_mentor_ping() : ""]"

	var/datum/discord_webhook_payload/dwp = new()
	dwp.webhook_content = "**\[[GLOB.configuration.system.instance_id]]** [message]"
	for(var/url in GLOB.configuration.discord.mentor_webhook_urls)
		SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_POST, url, dwp.serialize2json(), list("content-type" = "application/json"))

// Helper to make administrator ping easier
/datum/discord_manager/proc/handle_administrator_ping()
	// Check if a role is even set
	if(GLOB.configuration.discord.admin_role_id)
		if(last_administration_ping > world.time)
			return "*(Role pinged recently)*"

		last_administration_ping = world.time + 60 SECONDS
		return "<@&[GLOB.configuration.discord.admin_role_id]>"

	return ""

/datum/discord_manager/proc/handle_mentor_ping()
	if(GLOB.configuration.discord.mentor_role_id)
		if(last_mentor_ping > world.time)
			return " *(Role pinged recently)*"

		last_mentor_ping = world.time + 60 SECONDS
		return " <@&[GLOB.configuration.discord.mentor_role_id]>"

	return ""
