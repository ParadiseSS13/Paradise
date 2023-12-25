#define TAB_SERVER 	0
#define TAB_JOB		1
#define TAB_ANTAGONIST 2
#define TAB_SILICON 3
#define TAB_GENERAL 4
#define TAB_EXPLOSIVE 5
#define TAB_ROUND 6

#define SERVER_MANAGER "server_manager"
#define EXPLOSIVE_MANAGER "explosive_manager"
#define ROUND_MANAGER "round_manager"
#define JOB_MANAGER "job_manager"
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
	/// For the round manager
	var/shuttle_recallable = TRUE
	var/shuttle_time_to_dock = 5 MINUTES

/datum/game_manager/proc/open_game_manager(mob/user)
	var/list/data = list()
	var/manager_uid = UID()
	data += "<center>"
	data += "<a href='?src=[manager_uid];manage_input=[ROUND_MANAGER]'>Round Manager</a>"
	data += "<a href='?src=[manager_uid];manage_input=[EXPLOSIVE_MANAGER]'>Explosive Manager</a>"
	data += "<a href='?src=[manager_uid];manage_input=[JOB_MANAGER]'>Job Manager</a>"
	data += "<a href='?src=[manager_uid];manage_input=antagonist_manager'>Antagonist Manager</a>"
	data += "<a href='?src=[manager_uid];manage_input=silicon_manager'>Silicon Manager</a>"
	data += "<a href='?src=[manager_uid];manage_input=[SERVER_MANAGER]'>Server Options</a>"
	data += "<a href='?src=[manager_uid];manage_input=general_options'>General Options</a>"
	data += "</center>"
	switch(current_tab)
		if(TAB_SERVER)
			data += open_server_mananger(user)
		if(TAB_JOB)
			data += open_job_manager(user)
		if(TAB_EXPLOSIVE)
			data += open_explosive_manager(user)
		if(TAB_ROUND)
			data += open_round_options(user)

	var/datum/browser/popup = new(user, "gamemanager", "<div align='center'>Game Manager</div>", 500, 550)
	popup.set_content(data.Join(""))
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=1;can_resize=1")
	popup.open(0)

/datum/game_manager/Topic(href, list/href_list)
	if(!check_rights(R_ADMIN, user = usr))
		return
	if(href_list["manage_input"])
		manage_input(usr, href_list["manage_input"])
	else if(href_list[EXPLOSIVE_MANAGER])
		switch(href_list[EXPLOSIVE_MANAGER])
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
	else if(href_list[JOB_MANAGER])
		switch(href_list[JOB_MANAGER])
			if("increase")
				var/datum/job/job = locateUID(href_list["jobtype"])
				job.total_positions++
			if("decrease")
				var/datum/job/job = locateUID(href_list["jobtype"])
				job.total_positions--
	else if(href_list[ROUND_MANAGER])
		switch(href_list[ROUND_MANAGER])
			if("change_gamemode")
				var/list/gamemodes = list()
				for(var/mode in GLOB.configuration.gamemode.gamemodes)
					gamemodes += GLOB.configuration.gamemode.gamemode_names[mode]
				gamemodes += "secret"
				gamemodes += "random"
				var/mode_choice = input("Which gamemode would you like to set?") as anything in gamemodes
				GLOB.master_mode = mode_choice
				log_admin("[key_name(usr)] set the mode as [GLOB.master_mode].")
				message_admins("<span class='notice'>[key_name_admin(usr)] set the mode as [GLOB.master_mode].</span>", 1)
				var/do_we_want_to_alert_everyone = alert("Do you want to notify everyone of this change to the gamemode?",, "Yes", "No")
				if(do_we_want_to_alert_everyone == "Yes")
					to_chat(world, "<span class='boldnotice'>The mode is now: [GLOB.master_mode]</span>")
			if("call_shuttle")
				if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
					return
				SSshuttle.emergency.canRecall = shuttle_recallable

				if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
					SSshuttle.emergency.request(coefficient = 0.5, redAlert = TRUE)
				else
					SSshuttle.emergency.request()

				log_admin("[key_name(usr)] admin-called the emergency shuttle.")
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-called the emergency shuttle.</span>")
			if("cancel_shuttle")
				if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
					return

				SSshuttle.emergency.canRecall = TRUE
				SSshuttle.emergency.cancel()

				log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-recalled the emergency shuttle.</span>")
			if("cancel_all_shuttles")
				if(!SSticker)
					to_chat(usr, "<span class='warning'>The Ticker hasn't been set up yet, wait a bit!</span>")
					return

				if("admin" in SSshuttle.hostile_environments)
					SSshuttle.hostile_environments -= "admin"
					log_and_message_admins("has cleared all hostile environments, allowing the shuttle to be called.")
					return

				SSshuttle.registerHostileEnvironment("admin")

				log_and_message_admins("has denied the shuttle to be called.")
			if("shuttle_recall_toggle")
				shuttle_recallable = !shuttle_recallable
			if("start_round")
				if(GLOB.configuration.general.start_now_confirmation)
					if(alert(usr, "This is a live server. Are you sure you want to start now?", "Start game", "Yes", "No") != "Yes")
						return

				if(SSticker.current_state == GAME_STATE_PREGAME || SSticker.current_state == GAME_STATE_STARTUP)
					SSticker.force_start = TRUE
					log_admin("[usr.key] has started the game.")
					var/msg = ""
					if(SSticker.current_state == GAME_STATE_STARTUP)
						msg = " (The server is still setting up, but the round will be started as soon as possible.)"
					message_admins("<span class='darkmblue'>[usr.key] has started the game.[msg]</span>")
			if("delay_round")
				if(!SSticker || SSticker.current_state != GAME_STATE_PREGAME)
					SSticker.delay_end = !SSticker.delay_end
					log_admin("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
					message_admins("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].", 1)
					if(SSticker.delay_end)
						SSticker.real_reboot_time = 0
				else if(SSticker.ticker_going)
					SSticker.ticker_going = FALSE
					SSticker.delay_end = TRUE
					to_chat(world, "<b>The game start has been delayed.</b>")
					log_admin("[key_name(usr)] delayed the game.")
				else
					SSticker.ticker_going = TRUE
					to_chat(world, "<b>The game will start soon.</b>")
					log_admin("[key_name(usr)] removed the delay.")
			if("end_round")
				var/input = sanitize(copytext(input(usr, "What text should players see announcing the round end? Input nothing to cancel.", "Specify Announcement Text", "Shift Has Ended!"), 1, MAX_MESSAGE_LEN))

				if(!input)
					return
				if(SSticker.force_ending)
					return
				message_admins("[key_name_admin(usr)] has admin ended the round with message: '[input]'")
				log_admin("[key_name(usr)] has admin ended the round with message: '[input]'")
				SSticker.force_ending = TRUE
				to_chat(world, "<span class='warning'><big><b>[input]</b></big></span>")
				SSblackbox.record_feedback("tally", "admin_verb", 1, "End Round") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
				SSticker.mode_result = "admin ended"
			if("restart_server")
				var/is_live_server = TRUE
				if(usr.client.is_connecting_from_localhost())
					is_live_server = FALSE

				var/list/options = list("Regular Restart", "Hard Restart")
				if(world.TgsAvailable()) // TGS lets you kill the process entirely
					options += "Terminate Process (Kill and restart DD)"

				var/result = input(usr, "Select reboot method", "World Reboot", options[1]) as null|anything in options

				if(is_live_server)
					if(alert(usr, "WARNING: THIS IS A LIVE SERVER, NOT A LOCAL TEST SERVER. DO YOU STILL WANT TO RESTART","This server is live","Restart","Cancel") != "Restart")
						return FALSE

				if(!result)
					return
				var/init_by = "Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]."
				switch(result)
					if("Regular Restart")
						var/delay = input("What delay should the restart have (in seconds)?", "Restart Delay", 5) as num|null
						if(!delay)
							return FALSE
						// These are pasted each time so that they dont false send if reboot is cancelled
						message_admins("[key_name_admin(usr)] has initiated a server restart of type [result]")
						log_admin("[key_name(usr)] has initiated a server restart of type [result]")
						SSticker.delay_end = FALSE // We arent delayed anymore
						SSticker.reboot_helper(init_by, "admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]", delay * 10)

					if("Hard Restart")
						message_admins("[key_name_admin(usr)] has initiated a server restart of type [result]")
						log_admin("[key_name(usr)] has initiated a server restart of type [result]")
						world.Reboot(fast_track = TRUE)

					if("Terminate Process (Kill and restart DD)")
						message_admins("[key_name_admin(usr)] has initiated a server restart of type [result]")
						log_admin("[key_name(usr)] has initiated a server restart of type [result]")
						world.TgsEndProcess() // Just nuke the entire process if we are royally fucked
	open_game_manager(usr)

/datum/game_manager/proc/manage_input(mob/user, our_input)
	switch(our_input)
		if(EXPLOSIVE_MANAGER)
			open_explosive_manager(user)
		if(JOB_MANAGER)
			open_job_manager(user)
		if("antagonist_manager")
			open_antagonist_manager(user)
		if("silicon_manager")
			open_silicon_manager(user)
		if(SERVER_MANAGER)
			open_server_mananger(user)
		if("general_options")
			open_general_options(user)
		if(ROUND_MANAGER)
			open_round_options(user)

/datum/game_manager/proc/open_explosive_manager(mob/user)
	var/manager_uid = UID()
	var/list/dat = list()
	dat += "<b>Explosive manager:</b><br>"
	dat += "<a href='?src=[manager_uid];[EXPLOSIVE_MANAGER]=detonate_bomb'>Create Explosive</a><br>"
	dat += "<a href='?src=[manager_uid];[EXPLOSIVE_MANAGER]=make_fake_bomb'>Show Explosive Impact</a><br>"
	dat += "<b>Devastation Level:</b> <a href='?src=[manager_uid];[EXPLOSIVE_MANAGER]=explosive_devastation'>[explosive_devastation]</a><br>"
	dat += "<b>Heavy Level:</b> <a href='?src=[manager_uid];[EXPLOSIVE_MANAGER]=explosive_heavy'>[explosive_heavy]</a><br>"
	dat += "<b>Light Level:</b> <a href='?src=[manager_uid];[EXPLOSIVE_MANAGER]=explosive_light'>[explosive_light]</a><br>"
	dat += "<b>Flash Level:</b> <a href='?src=[manager_uid];[EXPLOSIVE_MANAGER]=explosive_flash'>[explosive_flash]</a><br>"
	dat += "<b>Flame Level:</b> <a href='?src=[manager_uid];[EXPLOSIVE_MANAGER]=explosive_flame'>[explosive_flame]</a><br>"
	dat += "<a href='?src=[manager_uid];[EXPLOSIVE_MANAGER]=detonate_emp'>Create EMP blast</a><br>"
	dat += "<b>EMP Heavy Level:</b> <a href='?src=[manager_uid];[EXPLOSIVE_MANAGER]=emp_heavy'>[emp_heavy]</a><br>"
	dat += "<b>EMP Light Level:</b> <a href='?src=[manager_uid];[EXPLOSIVE_MANAGER]=emp_light'>[emp_light]</a><br>"
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
		dat += "<td style='width: 10%'><a href='?src=[manager_uid];[JOB_MANAGER]=increase;jobtype=[job.UID()];'><span class='good'>+</span></a></td>"
		dat += "<td style='width: 10%'><a href='?src=[manager_uid];[JOB_MANAGER]=decrease;jobtype=[job.UID()];'><span class='bad'>-</span></a></td></tr>"
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

/datum/game_manager/proc/open_round_options(mob/user)
	var/manager_uid = UID()
	var/list/dat = list()
	dat += "<center>"
	if(SSticker && !SSticker.mode)
		dat += "<a href='?src=[manager_uid];[ROUND_MANAGER]=change_gamemode'><span class='good'>Change Gamemode</span></a><br>"
		dat += "<a href='?src=[manager_uid];[ROUND_MANAGER]=start_round'>Start Round</a>"
		dat += "<a href='?src=[manager_uid];[ROUND_MANAGER]=delay_round'>Delay Round start</a><br>"
	else
		dat += "<a href='?src=[manager_uid];[ROUND_MANAGER]=end_round'>End Round</a><br>"
	dat += "<a href='?src=[manager_uid];[ROUND_MANAGER]=restart_server'>Restart Server</a><br>"
	dat += "Shuttles:<br>"
	dat += "<a href='?src=[manager_uid];[ROUND_MANAGER]=call_shuttle'><span class='good'>Call Shuttle</span></a>"
	dat += "<a href='?src=[manager_uid];[ROUND_MANAGER]=cancel_shuttle'><span class='bad'>Cancel Shuttle</span></a>"
	dat += "<a href='?src=[manager_uid];[ROUND_MANAGER]=cancel_all_shuttles'>Toggle ALL shuttle calls</a>"
	dat += "Shuttle recallable:<a href='?src=[manager_uid];[ROUND_MANAGER]=shuttle_recall_toggle'><span class='good'>[shuttle_recallable ? "<span class='bad'>No</span>" : "<span class='good'>Yes</span>"]</span></a>"
	dat += "</center>"
	current_tab = TAB_ROUND
	return dat
