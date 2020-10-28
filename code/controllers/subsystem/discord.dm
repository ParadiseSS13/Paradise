SUBSYSTEM_DEF(discord)
	name = "Discord"
	flags = SS_NO_FIRE
	/// Is the SS enabled
	var/enabled = FALSE

/datum/controller/subsystem/discord/Initialize(start_timeofday)
	if(config.discord_webhooks_enabled)
		enabled = TRUE
	return ..()

// This is designed for ease of simplicity for sending quick messages from parts of the code
/datum/controller/subsystem/discord/proc/send2discord_simple(destination, content)
	if(!enabled)
		return
	var/webhook_url
	switch(destination)
		if(DISCORD_WEBHOOK_ADMIN)
			webhook_url = config.discord_admin_webhook_url
		if(DISCORD_WEBHOOK_PRIMARY)
			webhook_url = config.discord_main_webhook_url

	var/datum/discord_webhook_payload/dwp = new()
	dwp.webhook_content = content
	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, webhook_url, dwp.serialize2json(), list("content-type" = "application/json"))

// This one is designed to take in a [/datum/discord_webhook_payload] which was prepared beforehand
/datum/controller/subsystem/discord/proc/send2discord_complex(destination, datum/discord_webhook_payload/dwp)
	if(!enabled)
		return
	var/webhook_url
	switch(destination)
		if(DISCORD_WEBHOOK_ADMIN)
			webhook_url = config.discord_admin_webhook_url
		if(DISCORD_WEBHOOK_PRIMARY)
			webhook_url = config.discord_main_webhook_url
	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, webhook_url, dwp.serialize2json(), list("content-type" = "application/json"))

// This one is for sending messages to the admin channel if no admins are active, complete with a ping to the game admins role
/datum/controller/subsystem/discord/proc/send2discord_simple_noadmins(content)
	// Setup some stuff
	var/alerttext
	var/list/admincounter = staff_countup(R_BAN)
	var/active_admins = admincounter[1]
	var/inactive_admins = admincounter[3]
	var/total_admins = active_admins + inactive_admins

	if(active_admins <= 0)
		if(inactive_admins > 0)
			alerttext = "All admins AFK ([inactive_admins]/[total_admins])!"
		else
			alerttext = "No admins online!"
	else
		// We have active admins, we dont care about the rest of this proc
		return

	var/message = "[content] | [alerttext] <@&[config.discord_admin_role_id]>"

	var/datum/discord_webhook_payload/dwp = new()
	dwp.webhook_content = message

	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, config.discord_admin_webhook_url, dwp.serialize2json(), list("content-type" = "application/json"))
