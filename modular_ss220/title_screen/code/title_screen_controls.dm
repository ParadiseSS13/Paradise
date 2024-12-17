/**
 * Enables an admin to upload a new titlescreen image.
 */
/client/proc/admin_change_title_screen()
	set category = "Event"
	set name = "Title Screen: Change"

	if(!check_rights(R_EVENT))
		return

	log_admin("[key_name(usr)] is changing the title screen.")
	message_admins("[key_name_admin(usr)] is changing the title screen.")

	switch(tgui_alert(usr, "Что делаем с изображением в лобби?", "Лобби", list("Меняем", "Сбрасываем", "Ничего")))
		if("Меняем")
			var/file = input(usr) as icon|null
			if(!file)
				return

			SStitle.set_title_image(file)
		if("Сбрасываем")
			SStitle.set_title_image()
		if("Ничего")
			return

/**
 * Sets a titlescreen notice, a big red text on the main screen.
 */
/client/proc/change_title_screen_notice()
	set category = "Event"
	set name = "Title Screen: Set Notice"

	if(!check_rights(R_EVENT))
		return

	log_admin("[key_name(usr)] is setting the title screen notice.")
	message_admins("[key_name_admin(usr)] is setting the title screen notice.")

	var/new_notice = tgui_input_text(usr, "Введи то что должно отображаться в лобби:", "Уведомление в лобби")
	if(isnull(new_notice))
		return

	SStitle.set_notice(new_notice)
	for(var/mob/new_player/new_player in GLOB.player_list)
		to_chat(new_player, span_boldannounce("УВЕДОМЛЕНИЕ В ЛОББИ ОБНОВЛЕНО: [new_notice]"))
		SEND_SOUND(new_player,  sound('sound/items/bikehorn.ogg'))

/**
 * Reloads the titlescreen if it is bugged for someone.
 */
/client/verb/fix_title_screen()
	set name = "Fix Lobby Screen"
	set desc = "Lobbyscreen broke? Press this."
	set category = "Special Verbs"

	if(istype(mob, /mob/new_player))
		SStitle.show_title_screen_to(src)
	else
		SStitle.hide_title_screen_from(src)

/**
 * An admin debug command that enables you to change the HTML on the go.
 */
/client/proc/change_title_screen_html()
	set category = "Event"
	set name = "Title Screen: Set HTML"

	if(!check_rights(R_DEBUG))
		return

	log_admin("[key_name(usr)] is setting the title screen HTML.")
	message_admins("[key_name_admin(usr)] is setting the title screen HTML.")

	var/new_html = tgui_input_text(usr, "Введи нужный HTML (ВНИМАНИЕ: ТЫ СКОРЕЕ ВСЕГО ЧТО-ТО СЛОМАЕШЬ!!!)", "РИСКОВАННО: ИЗМЕНЕНИЕ HTML ЛОББИ", max_length = 99999, multiline = TRUE, encode = FALSE)
	if(isnull(new_html))
		return

	if(tgui_alert(usr, "Всё ли верно? Нигде не ошибся? Возврата нет!", "Ты подумай...", list("Рискнём", "Пожалуй нет...")) != "Рискнём")
		return

	SStitle.set_title_html(new_html)
	message_admins("[key_name_admin(usr)] has changed the title screen HTML.")
