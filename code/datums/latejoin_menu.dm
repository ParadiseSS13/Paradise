GLOBAL_DATUM_INIT(latejoin_menu, /datum/latejoin_menu, new)

/datum/latejoin_menu

/datum/latejoin_menu/ui_state(mob/user)
	return GLOB.new_player_state

/datum/latejoin_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LateJoin", "Join Game")
		ui.open()

/datum/latejoin_menu/proc/round_duration()
	var/round_ticks = ROUND_TIME // 1/10 of a second, not real milliseconds but whatever
	return list(
		"hours" = round(round_ticks / 36000),
		"mins" = round((round_ticks % 36000) / 600),
	)

/datum/latejoin_menu/ui_data(mob/new_player/user)
	if(!istype(user))
		return

	var/list/data = list()

	data["round_duration"] = round_duration()
	data["security_level"] = list(
		"name" = SSsecurity_level.current_security_level.name,
		"color" = SSsecurity_level.current_security_level.color,
	)

	if(SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		data["shuttle_status"] = "The station has been evacuated."
	else if(SSshuttle.emergency.mode >= SHUTTLE_CALL)
		data["shuttle_status"] = "The station is currently undergoing evacuation procedures."

	if(length(SSjobs.prioritized_jobs))
		var/prioritized_jobs = ""
		var/amt = length(SSjobs.prioritized_jobs)
		var/amt_count
		for(var/datum/job/a in SSjobs.prioritized_jobs)
			amt_count++
			if(amt_count != amt)
				prioritized_jobs += " [a.title], "
			else
				prioritized_jobs += " [a.title]."

		data["prioritized_jobs"] = prioritized_jobs

	var/list/categorizedJobs = list(
		"Command" = list(jobs = list(), titles = GLOB.command_positions, color = "#071b30"),
		"Engineering" = list(jobs = list(), titles = GLOB.engineering_positions, color = "#2e2e00"),
		"Miscellaneous" = list(jobs = list(), titles = list(), color = "#2e2e2e"),
		"Service" = list(jobs = list(), titles = GLOB.service_positions, color = "#123107"),
		"Security" = list(jobs = list(), titles = GLOB.active_security_positions, color = "#310808"),
		"Synthetic" = list(jobs = list(), titles = GLOB.nonhuman_positions, color = "#3a001f"),
		"Medical" = list(jobs = list(), titles = GLOB.medical_positions, color = "#002a30"),
		"Science" = list(jobs = list(), titles = GLOB.science_positions, color = "#24003d"),
		"Supply" = list(jobs = list(), titles = GLOB.supply_positions, color = "#332006"),
	)
	for(var/datum/job/job in SSjobs.occupations)
		var/categorized = FALSE
		for(var/jobcat in categorizedJobs)
			var/list/jobs = categorizedJobs[jobcat]["jobs"]
			if(job.title in categorizedJobs[jobcat]["titles"])
				categorized = TRUE
				if(jobcat == "Command") // Put captain at top of command jobs
					if(job.title == "Captain")
						jobs.Insert(1, list(job.ui_data(user)))
					else
						jobs += list(job.ui_data(user))
				else // Put heads at top of non-command jobs
					if(job.title in GLOB.command_positions)
						jobs.Insert(1, list(job.ui_data(user)))
					else
						jobs += list(job.ui_data(user))

		if(!categorized)
			categorizedJobs["Miscellaneous"]["jobs"] += list(job.ui_data(user))

	data["job_columns"] = list()
	data["categorized_jobs"] = categorizedJobs

	return data

/datum/latejoin_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	var/mob/new_player/new_player = ui.user
	if(!istype(new_player))
		to_chat(ui.user, SPAN_NOTICE("You must not currently be playing to late-join."))
		return TRUE

	var/client/client = ui.user.client

	if(!GLOB.enter_allowed)
		to_chat(new_player, SPAN_NOTICE("There is an administrative lock on entering the game!"))
		return TRUE

	if(client.prefs.toggles2 & PREFTOGGLE_2_RANDOMSLOT)
		client.prefs.load_random_character_slot(client)

	if(!can_use_species(src, client.prefs.active_character.species))
		to_chat(src, alert("You are currently not whitelisted to play [client.prefs.active_character.species]."))
		return TRUE

	if(new_player.AttemptLateSpawn(params["job"]))
		ui_close(ui.user)

	return
