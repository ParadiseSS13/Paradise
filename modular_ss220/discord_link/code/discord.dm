/mob/new_player/Topic(href, href_list)
	if(src != usr)
		return

	if(!client)
		return

	if(href_list["observe"] || href_list["ready"] || href_list["late_join"])
		if(GLOB.configuration.central.api_url && GLOB.configuration.central.force_discord_verification)
			if(!SScentral.is_player_discord_linked(client))
				to_chat(usr, chat_box_red(span_danger("Вам необходимо привязать дискорд-профиль к аккаунту!<br>") + span_warning("<br>Перейдите во вкладку '<b>Special Verbs</b>', она справа сверху, и нажмите '<b>Привязка Discord</b>' для получения инструкций.<br>") + span_notice("Если вы уверены, что ваш аккаунт уже привязан, подождите синхронизации и попробуйте снова.")))
				return FALSE

	. = ..()
