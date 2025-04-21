/datum/preferences
	var/discord_id

/datum/configuration_section/ss220_misc_configuration
	/// Force discord verification
	var/force_discord_verification = FALSE

/datum/configuration_section/ss220_misc_configuration/load_data(list/data)
	. = ..()
	CONFIG_LOAD_BOOL(force_discord_verification, data["force_discord_verification"])

/client/verb/link_discord_account()
	set name = "Привязка Discord"
	set category = "Special Verbs"
	set desc = "Привязать аккаунт Discord для удобного просмотра игровой статистики на нашем Discord-сервере."

	if(!GLOB.configuration.url.discord_url)
		return

	if(IsGuestKey(key))
		to_chat(usr, "Гостевой аккаунт не может быть связан.")
		return

	if(prefs.get_discord_id() && prefs.discord_id)
		to_chat(usr, span_darkmblue("Аккаунт Discord уже привязан!"))
		return

	if(!SSdbcore.IsConnected())
		return

	var/token = "WyccStation_" + md5("[world.time+rand(1000,1000000)]")
	var/datum/db_query/query_replace_token = SSdbcore.NewQuery("REPLACE INTO discord_links (ckey, timestamp, one_time_token) VALUES (:ckey, NOW(), :token)", list(
		"token" = token,
		"ckey" = ckey
		))

	if(!query_replace_token.warn_execute())
		to_chat(usr, span_warning("Ошибка записи токена в БД! Обратитесь к администрации."))
		log_debug("link_discord_account: failed db update discord_id for ckey [ckey]")
		qdel(query_replace_token)
		return

	qdel(query_replace_token)
	to_chat(usr, chat_box_notice(span_darkmblue("Для завершения, вставьте это: <br>") + span_good("<b>/привязать token:[token]</b>") + span_darkmblue("<br>В канал <b><a href='https://discord.com/channels/1097181193939730453/1162068725168623696'>#paradise-бот</a></b> в Discord-сообществе!<br>") + span_notice("<br>Чтобы канал открылся, вам необходимо перейти в <a href='https://discord.com/channels/1097181193939730453/1178197552013770752/1178209983452692590'>#выбор-роли</a> и получить роль '<b>Space Station 13 Paradise</b>'.")))

/mob/new_player/Topic(href, href_list)
	if(src != usr)
		return

	if(!client)
		return

	if(href_list["observe"] || href_list["ready"] || href_list["late_join"])
		if(GLOB.configuration.database.enabled && GLOB.configuration.ss220_misc.force_discord_verification)
			if(!client.prefs.discord_id || !(client.prefs.get_discord_id() && client.prefs.discord_id))
				to_chat(usr, chat_box_red(span_danger("Вам необходимо привязать дискорд-профиль к аккаунту!<br>") + span_warning("<br>Перейдите во вкладку '<b>Special Verbs</b>', она справа сверху, и нажмите '<b>Привязка Discord</b>' для получения инструкций.")))
				return FALSE

	. = ..()

/datum/preferences/proc/get_discord_id()
	. = TRUE
	if(discord_id)
		return

	var/datum/db_query/discord_query = SSdbcore.NewQuery("SELECT discord_id, valid FROM discord_links WHERE ckey=:ckey", list(
			"ckey" = parent.ckey
		))

	if(!discord_query.warn_execute())
		qdel(discord_query)
		return FALSE

	while(discord_query.NextRow())
		var/valid = discord_query.item[2]
		if(valid)
			discord_id = discord_query.item[1]

	qdel(discord_query)

/datum/preferences/load_preferences(datum/db_query/query)
	. = ..()
	if(!.)
		return

	return get_discord_id()
