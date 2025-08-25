// Force everyone to watch credits?
GLOBAL_VAR_INIT(credits_forced, FALSE)

/client/proc/toggle_credits()
	set category = "Server"
	set desc = "Просмотр титров по окончании раунда"
	set name = "Toggle Credits"

	if(!check_rights(R_ADMIN))
		return

	GLOB.credits_forced = !GLOB.credits_forced
	if(GLOB.credits_forced)
		to_chat(world, "<B>Все будут смотреть титры по окончании раунда.</B>")
		message_admins("[key_name_admin(usr)] устанавливает принудительные титры.", 1)
	else
		to_chat(world, "<B>Игроки будут смотреть титры в зависимости от своих настроек.</B>")
		message_admins("[key_name_admin(usr)] устанавливает титры по умолчанию.", 1)
	log_admin("[key_name(usr)] toggled credits.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Credits")
