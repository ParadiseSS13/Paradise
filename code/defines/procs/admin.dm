proc/log_and_message_admins(var/message as text)
	log_admin("[usr]([usr.ckey]) " + message)
	message_admins("[usr]([usr.ckey]) " + message)

proc/admin_log_and_message_admins(var/message as text)
	log_admin("[key_name(usr)] " + message)
	message_admins("[key_name_admin(usr)] " + message, 1)