/mob/new_player/Login()
	. = ..()
	SStitle.show_title_screen_to(client)

/mob/new_player/new_player_panel_proc()
	return

/mob/new_player/Topic(href, href_list)
	. = ..()
	var/mob/new_player/user = usr
	var/client/client = user.client

	if(href_list["ready"])
		client << output(ready, "title_browser:ready")

	else if(href_list["skip_antag"])
		client << output(client.skip_antag, "title_browser:skip_antag")

	else if(href_list["char_preferences"])
		client.prefs.current_tab = TAB_CHAR
		client.prefs.ShowChoices(user)

	else if(href_list["game_preferences"])
		client.prefs.current_tab = TAB_GAME
		client.prefs.ShowChoices(user)

	else if(href_list["change_picture"])
		client.admin_change_title_screen()

	else if(href_list["leave_notice"])
		client.change_title_screen_notice()

	else if(href_list["swap_server"])
		client.swap_server()

	else if(href_list["wiki"])
		if(tgui_alert(usr, "Хотите открыть нашу вики?", "Вики", list("Да", "Нет")) != "Да")
			return
		client << link("https://wiki.ss220.club")

	else if(href_list["discord"])
		if(tgui_alert(usr, "Хотите перейти в наш дискорд сервер?", "Дискорд", list("Да", "Нет")) != "Да")
			return
		client << link("https://discord.gg/ss220")

	else if(href_list["changelog"])
		SSchangelog.OpenChangelog(client)

	else if(href_list["focus"])
		winset(client, "paramapwindow.map", "focus=true")
		return

/client/verb/swap_server()
	set category = "OOC"
	set name = "Swap Server"
	var/list/servers =  GLOB.configuration.ss220_misc.cross_server_list
	if(length(servers) == 0)
		return

	var/server_name
	var/server_ip
	if(length(servers) > 1)
		server_name = tgui_input_list(src, "Пожалуйста, выберите сервер куда собираетесь отправиться...", "Смена сервера!", servers)
		if(!server_name)
			return
		server_ip = servers[server_name]

	else
		server_name = servers[1]
		server_ip = servers[server_name]

	var/confirm = tgui_alert(usr, "Вы уверены что хотите перейти на [server_name] ([server_ip])?", "Смена сервера!", list("Поехали", "Побуду тут..."))
	if(confirm != "Поехали")
		return

	to_chat_immediate(usr, "Удачной охоты, сталкер.")
	src << link(server_ip)

/datum/preferences/process_link(mob/user, list/href_list)
	. = ..()
	var/task = href_list["task"]
	var/preference = href_list["preference"]

	if(preference == "changeslot" || (preference == "name" && task == "random") || task == "input")
		user.client << output(active_character.real_name, "title_browser:update_current_character")
		return TRUE
