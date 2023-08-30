/datum/preferences
	var/discord_id

/client/verb/link_discord_account()
	set name = "Привязка Discord"
	set category = "Special Verbs"
	set desc = "Привязать аккаунт Discord для удобного просмотра игровой статистики на нашем Discord-сервере."

	if(!GLOB.configuration.url.discord_url)
		return

	if(IsGuestKey(key))
		to_chat(usr, "Гостевой аккаунт не может быть связан.")
		return

	if(prefs?.discord_id)
		to_chat(usr, span_darkmblue("Аккаунт Discord уже привязан! Чтобы отвязать используйте команду [span_boldannounce("/отвязать")] в канале <b>#дом-бота</b> в Discord-сообществе!"))
		return

	var/token = md5("[world.time+rand(1000,1000000)]")
	if(SSdbcore.IsConnected())
		var/datum/db_query/query_update_token = SSdbcore.NewQuery("UPDATE discord_links SET one_time_token=:token WHERE ckey =:ckey", list("token" = token, "ckey" = ckey))
		if(!query_update_token.warn_execute())
			to_chat(usr, span_warning("Ошибка записи токена в БД! Обратитесь к администрации."))
			log_debug("link_discord_account: failed db update discord_id for ckey [ckey]")
			qdel(query_update_token)
			return
		qdel(query_update_token)
		to_chat(usr, span_darkmblue("Аккаунт Discord уже привязан! Чтобы отвязать используйте команду [span_boldannounce("/отвязать")] в канале <b>#дом-бота</b> в Discord-сообществе!"))
		prefs?.load_preferences(usr)

/mob/new_player/Topic(href, href_list)
	if(src != usr)
		return

	if(!client)
		return

	if(href_list["observe"] || href_list["ready"] || href_list["late_join"])
		if (GLOB.configuration.database.enabled && !client.prefs.discord_id)
			to_chat(usr, span_danger("Вам необходимо привязать дискорд-профиль к аккаунту!"))
			to_chat(usr, span_warning("Нажмите 'Привязка Discord' во вкладке 'Special Verbs' для получения инструкций."))
			return FALSE

	. = ..()

/datum/preferences/proc/get_discord_id()
	var/datum/db_query/discord_query = SSdbcore.NewQuery({"SELECT discord_id, valid FROM discord_links WHERE ckey=:ckey"}, list(
			"ckey" = parent.ckey
		))

	if(!discord_query.warn_execute())
		qdel(discord_query)
		return FALSE

	while(discord_query.NextRow())
		var/valid = discord_query.item[2]
		if(valid)
			discord_id = discord_query.item[1]
			break

	qdel(discord_query)
	return TRUE

/datum/preferences/load_preferences(datum/db_query/query)
	. = ..()
	if (!.)
		return

	return get_discord_id()
