/datum/admins/proc/open_game_manager(mob/user)
	var/list/data = list()
	var/manager_uid = UID()
	data += "<div align='center'><b>Game manager:&nbsp;</b>"
	data += "<p><a href='?src=[manager_uid];game_manager_open=explosive_manager'>Explosive Manager</a><br></p>"
	data += "<p><a href='?src=[manager_uid];game_manager_open=job_manager'>Job Manager</a><br></p>"
	data += "<p><a href='?src=[manager_uid];game_manager_open=antagonist_manager'>Antagonist Manager</a><br></p>"
	data += "<p><a href='?src=[manager_uid];game_manager_open=silicon_manager'>Silicon Manager</a><br></p>"
	data += "<p><a href='?src=[manager_uid];game_manager_open=server_options'>Server Options</a><br></p>"
	data += "<p><a href='?src=[manager_uid];game_manager_open=general_options'>General Options</a><br></p>"

	var/datum/browser/popup = new(user, "gamemanager", "<div align='center'>Game Manager:</div>", 500, 550)
	popup.set_content(data.Join("<br>"))
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=1;can_resize=1")
	popup.open(FALSE)

/datum/game_manager

/datum/game_manager/Topic(href, list/href_list)
	if(href_list["explosive_manager"])
		switch(href_list["explosive_manager"])
			if("make_fake_bomb")
				usr.client.check_bomb_impacts()
			if("make_bomb")
				usr.client.cmd_admin_explosion(get_turf(usr))
			if("make_emp")
				usr.client.cmd_admin_emp(get_turf(usr))
	if(href_list["server_manager"])
		switch(href_list["server_manager"])
			if("toggle_deadchat")
				toggledeadchat(usr)
			if("toggle_ooc")
				toggleooc(usr)
			if("toggle_looc")
				togglelooc(usr)
			if("toggle_msay")
				toggle_mentor_chat(usr)
			if("toggle_ooc_dead")
				toggleoocdead(usr)
			if("toggle_ooc_emojis")
				toggleemoji(usr)
			if("toggle_antaghud_restrictions")
				toggle_antagHUD_restrictions(usr)
			if("toggle_antaghud_usage")
				toggle_antagHUD_use(usr)
			if("toggle_href_logging")
				toggle_log_hrefs(usr)
			if("toggle_game_entering")
				toggleenter(usr)
			if("toggle_guest_entering")
				toggleguests(usr)
			if("toggle_ai_entering")
				toggleAI(usr)

/datum/game_manager/proc/manage_input(mob/user, list/href_list)
	switch(href_list["game_manager_open"])
		if("explosive_manager")
			open_explosive_manager(user)
		if("job_manager")
			open_job_manager(user)
		if("antagonist_manager")
			open_antagonist_manager(user)
		if("silicon_manager")
			open_silicon_manager(user)
		if("server_options")
			open_server_mananger(user)
		if("general_options")
			open_general_options(user)

/datum/game_manager/proc/open_explosive_manager(mob/user)
	var/manager_uid = UID()
	var/list/dat = list()
	dat += "<b>Explosive manager:</b><br>"
	dat += "<a href='?src=[manager_uid];explosive_manager=make_fake_bomb'>Show Explosive Impact</a><br>"
	dat += "<a href='?src=[manager_uid];explosive_manager=make_bomb'>Create Explosive</a><br>"
	dat += "<a href='?src=[manager_uid];explosive_manager=make_emp'>Create EMP blast</a><br>"
	var/datum/browser/popup = new(user, "explosive_manager", "<div align='center'>Explosive Manager</div>", 360, 80)
	popup.set_content(dat.Join(""))
	popup.open(FALSE)

/datum/game_manager/proc/open_job_manager(mob/user)

/datum/game_manager/proc/open_antagonist_manager(mob/user)

/datum/game_manager/proc/open_silicon_manager(mob/user)

/datum/game_manager/proc/open_server_mananger(mob/user)
	var/manager_uid = UID()
	var/list/dat = list()
	dat += "<b>Server Manager:</b><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_deadchat'>Toggle Deadchat</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_ooc'>Toggle OOC</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_looc'>Toggle LOOC</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_msay'>Toggle Msay</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_ooc_dead'>Toggle Dead OOC</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_ooc_emojis'>Toggle OOC Emojis</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_antaghud_restrictions'>Toggle Antaghud Restrictions</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_antaghud_usage'>Toggle Antaghud Usage</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_href_logging'>Toggle HREF logging</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_game_entering'>Toggle Game Entering</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_guest_entering'>Toggle Guest Entering</a><br>"
	dat += "<a href='?src=[manager_uid];server_manager=toggle_ai_entering'>Toggle AI Entering</a><br>"
	var/datum/browser/popup = new(user, "server_manager", "<div align='center'>Server Manager</div>", 450, 150)
	popup.set_content(dat.Join(""))
	popup.open(FALSE)

/datum/game_manager/proc/open_general_options(mob/user)
