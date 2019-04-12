// This file handles all the discord webhook sending stuff
/proc/send2discord(var/target, var/msg, var/lesser_sanitize = FALSE)
	if(lesser_sanitize == 7355608) // Super random number because this could be bad if done accidentally
		msg = not_as_paranoid_sanitize(msg) // Keeps special characters needed for discord, such as <> and @
	else
		msg = paranoid_sanitize(msg) // Guts ANYTHING that isnt alphanumeric
	// Is the webhook set in config
	if(config.use_webhooks)
		switch(target)
			// Main
			if("main")
				if(config.main_webhook)
					ext_python("discord_webhook.py", "[config.main_webhook] [msg]")
				else
					message_admins("An attempt was made to send a message to the main discord webhook, but it has not been configured")
					log_world("fuck 1")
			// Admin
			if("admin")
				if(config.admin_webhook)
					ext_python("discord_webhook.py", "[config.admin_webhook] [msg]")
				else
					message_admins("An attempt was made to send a message to the main discord webhook, but it has not been configured")
					log_world("fuck 2")
            // None, so someone fucked up, most probably me
			else
				message_admins("An attempt was made to send a message a message to an undefined discord webhook. Please report this issue and or yell at affected")
				log_world("fuck 3")
	return
