#define TAB_SERVER 	0
#define TAB_JOB		1
#define TAB_ANTAGONIST 2
#define TAB_SILICON 3
#define TAB_GENERAL 4
#define TAB_EXPLOSIVE 5

#define SERVER_MANAGER "server_manager"

/datum/game_manager
	var/current_tab = 0
	/// For the explosive manager
	var/explosive_devastation = 0
	var/explosive_heavy = 0
	var/explosive_light = 0
	var/explosive_flash = 0
	var/explosive_flame = 0
	var/emp_heavy = 0
	var/emp_light = 0

/datum/game_manager/proc/open_game_manager(mob/user)
	var/list/data = list()
	var/manager_uid = UID()
	data += "<center>"
	data += "<a href='?src=[manager_uid];manage_input=explosive_manager'>Explosive Manager</a>"
	data += "<a href='?src=[manager_uid];manage_input=job_manager'>Job Manager</a>"
	data += "<a href='?src=[manager_uid];manage_input=antagonist_manager'>Antagonist Manager</a>"
	data += "<a href='?src=[manager_uid];manage_input=silicon_manager'>Silicon Manager</a>"
	data += "<a href='?src=[manager_uid];manage_input=server_options'>Server Options</a>"
	data += "<a href='?src=[manager_uid];manage_input=general_options'>General Options</a>"
	data += "</center>"
	switch(current_tab)
		if(TAB_SERVER)
			data += open_server_mananger(user)
		if(TAB_JOB)
			data += open_job_manager(user)
		if(TAB_EXPLOSIVE)
			data += open_explosive_manager(user)

	var/datum/browser/popup = new(user, "gamemanager", "<div align='center'>Game Manager</div>", 500, 550)
	popup.set_content(data.Join(""))
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=1;can_resize=1")
	popup.open(0)

/datum/game_manager/Topic(href, list/href_list)
	if(href_list["manage_input"])
		manage_input(usr, href_list["manage_input"])
	else if(href_list["explosive_manager"])
		switch(href_list["explosive_manager"])
			if("make_fake_bomb")
				usr.client.check_bomb_impacts(explosive_devastation, explosive_heavy, explosive_light)
			if("explosive_devastation")
				explosive_devastation = input("Enter the new devastation target") as num|null
			if("explosive_heavy")
				explosive_heavy = input("Enter the new heavy target") as num|null
			if("explosive_light")
				explosive_light = input("Enter the new light target") as num|null
			if("explosive_flash")
				explosive_flash = input("Enter the new flash target") as num|null
			if("explosive_flame")
				explosive_flame = input("Enter the new flame target") as num|null
			if("emp_heavy")
				emp_heavy = input("Enter the new emp heavy target") as num|null
			if("emp_light")
				emp_light = input("Enter the new emp light target") as num|null
			if("detonate_emp")
				var/turf/our_turf = get_turf(usr)
				empulse(our_turf, emp_heavy, emp_light)
				log_admin("[key_name(usr)] created an EM pulse ([emp_heavy], [emp_light]) at ([our_turf.x],[our_turf.y],[our_turf.z])")
				message_admins("[key_name_admin(usr)] created an EM pulse ([emp_heavy], [emp_light]) at ([our_turf.x],[our_turf.y],[our_turf.z])")
			if("detonate_bomb")
				var/turf/our_turf = get_turf(usr)
				explosion(our_turf, explosive_devastation, explosive_heavy, explosive_light, explosive_flash,, FALSE, explosive_flame)
				log_admin("[key_name(usr)] created an explosion ([explosive_devastation],[explosive_heavy],[explosive_light],[explosive_flame]) at ([our_turf.x],[our_turf.y],[our_turf.z])")
				message_admins("[key_name_admin(usr)] created an explosion ([explosive_devastation],[explosive_heavy],[explosive_light],[explosive_flame]) at ([our_turf.x],[our_turf.y],[our_turf.z])")
	else if(href_list[SERVER_MANAGER])
		switch(href_list[SERVER_MANAGER])
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
			if("toggle_ert_sending")
				usr.client.toggle_ert_calling(usr)
	else if(href_list["library_manager"])
		usr.client.library_manager(usr)
	else if(href_list["job_manager"])
		switch(href_list["job_manager"])
			if("increase")
				var/datum/job/job = locateUID(href_list["jobtype"])
				job.total_positions++
			if("decrease")
				var/datum/job/job = locateUID(href_list["jobtype"])
				job.total_positions--
	open_game_manager(usr)

/datum/game_manager/proc/manage_input(mob/user, our_input)
	switch(our_input)
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
	dat += "<a href='?src=[manager_uid];explosive_manager=detonate_bomb'>Create Explosive</a><br>"
	dat += "<a href='?src=[manager_uid];explosive_manager=make_fake_bomb'>Show Explosive Impact</a><br>"
	dat += "<b>Devastation Level:</b> <a href='?src=[manager_uid];explosive_manager=explosive_devastation'>[explosive_devastation]</a><br>"
	dat += "<b>Heavy Level:</b> <a href='?src=[manager_uid];explosive_manager=explosive_heavy'>[explosive_heavy]</a><br>"
	dat += "<b>Light Level:</b> <a href='?src=[manager_uid];explosive_manager=explosive_light'>[explosive_light]</a><br>"
	dat += "<b>Flash Level:</b> <a href='?src=[manager_uid];explosive_manager=explosive_flash'>[explosive_flash]</a><br>"
	dat += "<b>Flame Level:</b> <a href='?src=[manager_uid];explosive_manager=explosive_flame'>[explosive_flame]</a><br>"
	dat += "<a href='?src=[manager_uid];explosive_manager=detonate_emp'>Create EMP blast</a><br>"
	dat += "<b>EMP Heavy Level:</b> <a href='?src=[manager_uid];explosive_manager=emp_heavy'>[emp_heavy]</a><br>"
	dat += "<b>EMP Light Level:</b> <a href='?src=[manager_uid];explosive_manager=emp_light'>[emp_light]</a><br>"
	current_tab = TAB_EXPLOSIVE
	return dat

/datum/game_manager/proc/open_job_manager(mob/user)
	if(!SSjobs)
		to_chat(user, "<span class='warning'>Jobs aren't set up yet! Wait for the subsystem to start.</span>")
		return
	var/manager_uid = UID()
	var/list/dat = list()
	dat += "<table align='center' width='100%'>"
	dat += "Job Name: Filled job slot / Total job slots <b>(Free job slots)</b>"
	for(var/datum/job/job in SSjobs.occupations)
		dat += "<tr>"
		dat += "<td style='width: 45%'>[job.title]:</td>"

		dat += "<td style='width: 20%'>[job.current_positions] / \
			[job.total_positions <= -1 ? "<b>UNLIMITED</b>" : job.total_positions] \
			<b>([job.total_positions <= -1 ? "UNLIMITED" : job.total_positions - job.current_positions])</b></td>"
		dat += "<td style='width: 10%'><a href='?src=[manager_uid];job_manager=increase;jobtype=[job.UID()];'><span class='good'>+</span></a></td>"
		dat += "<td style='width: 10%'><a href='?src=[manager_uid];job_manager=decrease;jobtype=[job.UID()];'><span class='bad'>-</span></a></td></tr>"
	dat += "</table>"
	current_tab = TAB_JOB
	return dat

/datum/game_manager/proc/open_antagonist_manager(mob/user)

/datum/game_manager/proc/open_silicon_manager(mob/user)

/datum/game_manager/proc/open_server_mananger(mob/user)
	var/manager_uid = UID()
	var/list/dat = list()
	dat += "<center>"
	dat += "<b>Server Manager:</b><br>"
	dat += "Mutes:<br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_deadchat'>Toggle Deadchat</a><br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_ooc'>Toggle OOC</a><br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_looc'>Toggle LOOC</a><br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_msay'>Toggle Msay</a><br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_ooc_dead'>Toggle Dead OOC</a><br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_ooc_emojis'>Toggle OOC Emojis</a><br>"
	dat += "Antagonist HUD:<br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_antaghud_restrictions'>Toggle Antaghud Restrictions</a><br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_antaghud_usage'>Toggle Antaghud Usage</a><br>"
	dat += "Misc:<br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_href_logging'>Toggle HREF logging</a><br>"
	dat += "Game Joining:<br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_game_entering'>Toggle Game Entering</a><br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_guest_entering'>Toggle Guest Entering</a><br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_ai_entering'>Toggle AI Entering</a><br>"
	dat += "<a href='?src=[manager_uid];[SERVER_MANAGER]=toggle_ert_sending'>Toggle ERT Availability</a><br>"
	dat += "</center>"
	current_tab = TAB_SERVER
	return dat

/datum/game_manager/proc/open_general_options(mob/user)
