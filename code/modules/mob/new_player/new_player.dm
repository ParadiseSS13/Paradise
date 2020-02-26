/mob/new_player
	var/ready = 0
	var/spawning = 0	//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0
	universal_speak = 1

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

/mob/new_player/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE
	GLOB.mob_list += src
	return INITIALIZE_HINT_NORMAL

/mob/new_player/verb/new_player_panel()
	set src = usr

	if(client.tos_consent)
		new_player_panel_proc()
	else
		privacy_consent()


/mob/new_player/proc/privacy_consent()
	src << browse(null, "window=playersetup")
	var/output = GLOB.join_tos
	output += "<p><a href='byond://?src=[UID()];consent_signed=SIGNED'>I consent</A>"
	output += "<p><a href='byond://?src=[UID()];consent_rejected=NOTSIGNED'>I DO NOT consent</A>"
	src << browse(output,"window=privacy_consent;size=500x300")
	var/datum/browser/popup = new(src, "privacy_consent", "<div align='center'>Privacy Consent</div>", 500, 400)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(0)
	return


/mob/new_player/proc/new_player_panel_proc()
	var/real_name = client.prefs.real_name
	if(client.prefs.toggles2 & PREFTOGGLE_2_RANDOMSLOT)
		real_name = "Random Character Slot"
	var/output = "<center><p><a href='byond://?src=[UID()];show_preferences=1'>Setup Character</A><br /><i>[real_name]</i></p>"

	if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
		if(!ready)	output += "<p><a href='byond://?src=[UID()];ready=1'>Declare Ready</A></p>"
		else	output += "<p><b>You are ready</b> (<a href='byond://?src=[UID()];ready=2'>Cancel</A>)</p>"
	else
		output += "<p><a href='byond://?src=[UID()];manifest=1'>View the Crew Manifest</A></p>"
		output += "<p><a href='byond://?src=[UID()];late_join=1'>Join Game!</A></p>"

	var/list/antags = client.prefs.be_special
	if(antags && antags.len)
		if(!client.skip_antag) output += "<p><a href='byond://?src=[UID()];skip_antag=1'>Global Antag Candidacy</A>"
		else	output += "<p><a href='byond://?src=[UID()];skip_antag=2'>Global Antag Candidacy</A>"
		output += "<br /><small>You are <b>[client.skip_antag ? "ineligible" : "eligible"]</b> for all antag roles.</small></p>"

	if(!SSticker || SSticker.current_state == GAME_STATE_STARTUP)
		output += "<p>Observe (Please wait...)</p>"
	else
		output += "<p><a href='byond://?src=[UID()];observe=1'>Observe</A></p>"

	if(GLOB.join_tos)
		output += "<p><a href='byond://?src=[UID()];tos=1'>Terms of Service</A></p>"

	output += "</center>"

	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>New Player Options</div>", 240, 330)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(0)
	return

/mob/new_player/Stat()
	statpanel("Status")

	..()

	statpanel("Lobby")
	if(client.statpanel=="Lobby" && SSticker)
		if(SSticker.hide_mode)
			stat("Game Mode:", "Secret")
		else
			if(SSticker.hide_mode == 0)
				stat("Game Mode:", "[GLOB.master_mode]") // Old setting for showing the game mode
			else
				stat("Game Mode: ", "Secret")

		if((SSticker.current_state == GAME_STATE_PREGAME) && SSticker.ticker_going)
			stat("Time To Start:", round(SSticker.pregame_timeleft/10))
		if((SSticker.current_state == GAME_STATE_PREGAME) && !SSticker.ticker_going)
			stat("Time To Start:", "DELAYED")

		if(SSticker.current_state == GAME_STATE_PREGAME)
			stat("Players:", "[totalPlayers]")
			if(check_rights(R_ADMIN, 0, src))
				stat("Players Ready:", "[totalPlayersReady]")
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in GLOB.player_list)
				if(check_rights(R_ADMIN, 0, src))
					stat("[player.key]", (player.ready)?("(Playing)"):(null))
				totalPlayers++
				if(player.ready)
					totalPlayersReady++


/mob/new_player/Topic(href, href_list[])
	if(!client)
		return FALSE

	if(href_list["consent_signed"])
		var/datum/db_query/query = SSdbcore.NewQuery("REPLACE INTO [format_table_name("privacy")] (ckey, datetime, consent) VALUES (:ckey, Now(), 1)", list(
			"ckey" = ckey
		))
		// If the query fails we dont want them permenantly stuck on being unable to accept TOS
		query.warn_execute()
		qdel(query)
		src << browse(null, "window=privacy_consent")
		client.tos_consent = TRUE
		// Now they have accepted TOS, we can log data
		client.chatOutput.sendClientData()
		new_player_panel_proc()
	if(href_list["consent_rejected"])
		client.tos_consent = FALSE
		to_chat(usr, "<span class='warning'>You must consent to the terms of service before you can join!</span>")
		var/datum/db_query/query = SSdbcore.NewQuery("REPLACE INTO [format_table_name("privacy")] (ckey, datetime, consent) VALUES (:ckey, Now(), 0)", list(
			"ckey" = ckey
		))
		// If the query fails we dont want them permenantly stuck on being unable to accept TOS
		query.warn_execute()
		qdel(query)

	if(href_list["show_preferences"])
		client.prefs.ShowChoices(src)
		return TRUE

	if(href_list["ready"])
		if(!client.tos_consent)
			to_chat(usr, "<span class='warning'>You must consent to the terms of service before you can join!</span>")
			return FALSE
		if(client.version_blocked)
			client.show_update_notice()
			return FALSE
		ready = !ready
		new_player_panel_proc()

	if(href_list["skip_antag"])
		client.skip_antag = !client.skip_antag
		new_player_panel_proc()

	if(href_list["refresh"])
		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel_proc()

	if(href_list["observe"])
		if(!client.tos_consent)
			to_chat(usr, "<span class='warning'>You must consent to the terms of service before you can join!</span>")
			return FALSE
		if(client.version_blocked)
			client.show_update_notice()
			return FALSE
		if(!SSticker || SSticker.current_state == GAME_STATE_STARTUP)
			to_chat(usr, "<span class='warning'>You must wait for the server to finish starting before you can join!</span>")
			return FALSE

		if(alert(src,"Are you sure you wish to observe?[(config.respawn_observer ? "" : " You cannot normally join the round after doing this!")]","Player Setup","Yes","No") == "Yes")
			if(!client)
				return 1
			var/mob/dead/observer/observer = new()
			src << browse(null, "window=playersetup")
			spawning = 1
			stop_sound_channel(CHANNEL_LOBBYMUSIC)


			observer.started_as_observer = 1
			close_spawn_windows()
			var/obj/O = locate("landmark*Observer-Start")
			to_chat(src, "<span class='notice'>Now teleporting.</span>")
			observer.forceMove(O.loc)
			observer.timeofdeath = world.time // Set the time of death so that the respawn timer works correctly.
			client.prefs.update_preview_icon(1)
			observer.icon = client.prefs.preview_icon
			observer.alpha = 127

			if(client.prefs.be_random_name)
				client.prefs.real_name = random_name(client.prefs.gender,client.prefs.species)
			observer.real_name = client.prefs.real_name
			observer.name = observer.real_name
			if(!client.holder && !config.antag_hud_allowed)           // For new ghosts we remove the verb from even showing up if it's not allowed.
				observer.verbs -= /mob/dead/observer/verb/toggle_antagHUD        // Poor guys, don't know what they are missing!
			observer.key = key
			QDEL_NULL(mind)
			if (config.respawn_observer) GLOB.respawnable_list += observer			// If enabled in config - observer cant respawn as Player
			qdel(src)
			return 1
	if(href_list["tos"])
		privacy_consent()
		return FALSE

	if(href_list["late_join"])
		if(!client.tos_consent)
			to_chat(usr, "<span class='warning'>You must consent to the terms of service before you can join!</span>")
			return FALSE
		if(client.version_blocked)
			client.show_update_notice()
			return FALSE
		if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
			return
		if(client.prefs.species in GLOB.whitelisted_species)

			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
				return FALSE

		LateChoices()

	if(href_list["manifest"])
		ViewManifest()

	if(href_list["SelectedJob"])

		if(!GLOB.enter_allowed)
			to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
			return

		if(client.prefs.toggles2 & PREFTOGGLE_2_RANDOMSLOT)
			client.prefs.load_random_character_slot(client)

		if(client.prefs.species in GLOB.whitelisted_species)
			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
				return FALSE

		AttemptLateSpawn(href_list["SelectedJob"],client.prefs.spawnpoint)
		return

	if(!ready && href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)
	else if(!href_list["late_join"])
		new_player_panel()

/mob/new_player/proc/IsJobAvailable(rank)
	var/datum/job/job = SSjobs.GetJob(rank)
	if(!job)	return 0
	if(!job.is_position_available()) return 0
	if(jobban_isbanned(src,rank))	return 0
	if(!is_job_whitelisted(src, rank))	 return 0
	if(!job.player_old_enough(client))	return 0
	if(job.admin_only && !(check_rights(R_EVENT, 0))) return 0
	if(job.available_in_playtime(client))
		return 0

	if(config.assistantlimit)
		if(job.title == "Civilian")
			var/count = 0
			var/datum/job/officer = SSjobs.GetJob("Security Officer")
			var/datum/job/warden = SSjobs.GetJob("Warden")
			var/datum/job/hos = SSjobs.GetJob("Head of Security")
			count += (officer.current_positions + warden.current_positions + hos.current_positions)
			if(job.current_positions > (config.assistantratio * count))
				if(count >= 5) // if theres more than 5 security on the station just let assistants join regardless, they should be able to handle the tide
					return 1
				return 0
	return 1

/mob/new_player/proc/IsAdminJob(rank)
	var/datum/job/job = SSjobs.GetJob(rank)
	if(job.admin_only)
		return 1
	else
		return 0

/mob/new_player/proc/IsERTSpawnJob(rank)
	var/datum/job/job = SSjobs.GetJob(rank)
	if(job.spawn_ert)
		return 1
	else
		return 0

/mob/new_player/proc/IsSyndicateCommand(rank)
	var/datum/job/job = SSjobs.GetJob(rank)
	if(job.syndicate_command)
		return 1
	else
		return 0

/mob/new_player/proc/AttemptLateSpawn(rank,var/spawning_at)
	if(src != usr)
		return 0
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
		return 0
	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
		return 0
	if(!IsJobAvailable(rank))
		to_chat(src, alert("[rank] is not available. Please try another."))
		return 0
	var/datum/job/thisjob = SSjobs.GetJob(rank)
	if(thisjob.barred_by_disability(client))
		to_chat(src, alert("[rank] is not available due to your character's disability. Please try another."))
		return 0

	SSjobs.AssignRole(src, rank, 1)

	var/mob/living/character = create_character()	//creates the human and transfers vars and mind
	character = SSjobs.AssignRank(character, rank, 1)					//equips the human

	// AIs don't need a spawnpoint, they must spawn at an empty core
	if(character.mind.assigned_role == "AI")
		var/mob/living/silicon/ai/ai_character = character.AIize() // AIize the character, but don't move them yet

		// IsJobAvailable for AI checks that there is an empty core available in this list
		ai_character.moveToEmptyCore()
		AnnounceCyborg(ai_character, rank, "has been downloaded to the empty core in \the [get_area(ai_character)]")

		SSticker.mode.latespawn(ai_character)
		qdel(src)
		return

	//Find our spawning point.
	var/join_message
	var/datum/spawnpoint/S

	if(IsAdminJob(rank))
		if(IsERTSpawnJob(rank))
			character.loc = pick(GLOB.ertdirector)
		else if(IsSyndicateCommand(rank))
			character.loc = pick(GLOB.syndicateofficer)
		else
			character.forceMove(pick(GLOB.aroomwarp))
		join_message = "has arrived"
	else
		if(spawning_at)
			S = GLOB.spawntypes[spawning_at]
		if(S && istype(S))
			if(S.check_job_spawning(rank))
				character.forceMove(pick(S.turfs))
				join_message = S.msg
			else
				to_chat(character, "Your chosen spawnpoint ([S.display_name]) is unavailable for your chosen job. Spawning you at the Arrivals shuttle instead.")
				character.forceMove(pick(GLOB.latejoin))
				join_message = "has arrived on the station"
		else
			character.forceMove(pick(GLOB.latejoin))
			join_message = "has arrived on the station"

	character.lastarea = get_area(loc)
	// Moving wheelchair if they have one
	if(character.buckled && istype(character.buckled, /obj/structure/chair/wheelchair))
		character.buckled.forceMove(character.loc)
		character.buckled.dir = character.dir

	character = SSjobs.EquipRank(character, rank, 1)					//equips the human
	EquipCustomItems(character)

	SSticker.mode.latespawn(character)

	if(character.mind.assigned_role == "Cyborg")
		AnnounceCyborg(character, rank, join_message)
	else
		SSticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
		if(!IsAdminJob(rank))
			GLOB.data_core.manifest_inject(character)
			AnnounceArrival(character, rank, join_message)
			AddEmploymentContract(character)

			if(GLOB.summon_guns_triggered)
				give_guns(character)
			if(GLOB.summon_magic_triggered)
				give_magic(character)

	if(!thisjob.is_position_available() && (thisjob in SSjobs.prioritized_jobs))
		SSjobs.prioritized_jobs -= thisjob
	qdel(src)


/mob/new_player/proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank, var/join_message)
	if(SSticker.current_state == GAME_STATE_PLAYING)
		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in GLOB.alive_mob_list)
			if(A.announce_arrivals)
				ailist += A
		if(ailist.len)
			var/mob/living/silicon/ai/announcer = pick(ailist)
			if(character.mind)
				if((character.mind.assigned_role != "Cyborg") && (character.mind.assigned_role != character.mind.special_role))
					if(character.mind.role_alt_title)
						rank = character.mind.role_alt_title
					var/arrivalmessage = announcer.arrivalmsg
					arrivalmessage = replacetext(arrivalmessage,"$name",character.real_name)
					arrivalmessage = replacetext(arrivalmessage,"$rank",rank ? "[rank]" : "visitor")
					arrivalmessage = replacetext(arrivalmessage,"$species",character.dna.species.name)
					arrivalmessage = replacetext(arrivalmessage,"$age",num2text(character.age))
					arrivalmessage = replacetext(arrivalmessage,"$gender",character.gender == FEMALE ? "Female" : "Male")
					announcer.say(";[arrivalmessage]")
		else
			if(character.mind)
				if((character.mind.assigned_role != "Cyborg") && (character.mind.assigned_role != character.mind.special_role))
					if(character.mind.role_alt_title)
						rank = character.mind.role_alt_title
					GLOB.global_announcer.autosay("[character.real_name],[rank ? " [rank]," : " visitor," ] [join_message ? join_message : "has arrived on the station"].", "Arrivals Announcement Computer")

/mob/new_player/proc/AddEmploymentContract(mob/living/carbon/human/employee)
	spawn(30)
		for(var/C in GLOB.employmentCabinets)
			var/obj/structure/filingcabinet/employment/employmentCabinet = C
			if(employmentCabinet.populated)
				employmentCabinet.addFile(employee)

/mob/new_player/proc/AnnounceCyborg(var/mob/living/character, var/rank, var/join_message)
	if(SSticker.current_state == GAME_STATE_PLAYING)
		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in GLOB.alive_mob_list)
			ailist += A
		if(ailist.len)
			var/mob/living/silicon/ai/announcer = pick(ailist)
			if(character.mind)
				if(character.mind.assigned_role != character.mind.special_role)
					var/arrivalmessage = "A new[rank ? " [rank]" : " visitor" ] [join_message ? join_message : "has arrived on the station"]."
					announcer.say(";[arrivalmessage]")
		else
			if(character.mind)
				if(character.mind.assigned_role != character.mind.special_role)
					// can't use their name here, since cyborg namepicking is done post-spawn, so we'll just say "A new Cyborg has arrived"/"A new Android has arrived"/etc.
					GLOB.global_announcer.autosay("A new[rank ? " [rank]" : " visitor" ] [join_message ? join_message : "has arrived on the station"].", "Arrivals Announcement Computer")

/mob/new_player/proc/LateChoices()
	var/mills = ROUND_TIME // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = (mills % 36000) / 600
	var/hours = mills / 36000

	var/dat = "<html><body><center>"
	dat += "Round Duration: [round(hours)]h [round(mins)]m<br>"

	if(SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		dat += "<font color='red'><b>The station has been evacuated.</b></font><br>"
	else if(SSshuttle.emergency.mode >= SHUTTLE_CALL)
		dat += "<font color='red'>The station is currently undergoing evacuation procedures.</font><br>"

	if(length(SSjobs.prioritized_jobs))
		dat += "<font color='lime'>The station has flagged these jobs as high priority: "
		var/amt = length(SSjobs.prioritized_jobs)
		var/amt_count
		for(var/datum/job/a in SSjobs.prioritized_jobs)
			amt_count++
			if(amt_count != amt)
				dat += " [a.title], "
			else
				dat += " [a.title]. </font><br>"


	var/num_jobs_available = 0
	var/list/activePlayers = list()
	var/list/categorizedJobs = list(
		"Command" = list(jobs = list(), titles = GLOB.command_positions, color = "#aac1ee"),
		"Engineering" = list(jobs = list(), titles = GLOB.engineering_positions, color = "#ffd699"),
		"Security" = list(jobs = list(), titles = GLOB.security_positions, color = "#ff9999"),
		"Miscellaneous" = list(jobs = list(), titles = list(), color = "#ffffff", colBreak = 1),
		"Synthetic" = list(jobs = list(), titles = GLOB.nonhuman_positions, color = "#ccffcc"),
		"Support / Service" = list(jobs = list(), titles = GLOB.service_positions, color = "#cccccc"),
		"Medical" = list(jobs = list(), titles = GLOB.medical_positions, color = "#99ffe6", colBreak = 1),
		"Science" = list(jobs = list(), titles = GLOB.science_positions, color = "#e6b3e6"),
		"Supply" = list(jobs = list(), titles = GLOB.supply_positions, color = "#ead4ae"),
		)
	for(var/datum/job/job in SSjobs.occupations)
		if(job && IsJobAvailable(job.title) && !job.barred_by_disability(client))
			num_jobs_available++
			activePlayers[job] = 0
			var/categorized = 0
			// Only players with the job assigned and AFK for less than 10 minutes count as active
			for(var/mob/M in GLOB.player_list) if(M.mind && M.client && M.mind.assigned_role == job.title && M.client.inactivity <= 10 MINUTES)
				activePlayers[job]++
			for(var/jobcat in categorizedJobs)
				var/list/jobs = categorizedJobs[jobcat]["jobs"]
				if(job.title in categorizedJobs[jobcat]["titles"])
					categorized = 1
					if(jobcat == "Command") // Put captain at top of command jobs
						if(job.title == "Captain")
							jobs.Insert(1, job)
						else
							jobs += job
					else // Put heads at top of non-command jobs
						if(job.title in GLOB.command_positions)
							jobs.Insert(1, job)
						else
							jobs += job
			if(!categorized)
				categorizedJobs["Miscellaneous"]["jobs"] += job

	if(num_jobs_available)
		dat += "Choose from the following open positions:<br><br>"
		dat += "<table><tr><td valign='top'>"
		for(var/jobcat in categorizedJobs)
			if(categorizedJobs[jobcat]["colBreak"])
				dat += "</td><td valign='top'>"
			if(length(categorizedJobs[jobcat]["jobs"]) < 1)
				continue
			var/color = categorizedJobs[jobcat]["color"]
			dat += "<fieldset style='border: 2px solid [color]; display: inline'>"
			dat += "<legend align='center' style='color: [color]'>[jobcat]</legend>"
			for(var/datum/job/job in categorizedJobs[jobcat]["jobs"])
				if(job in SSjobs.prioritized_jobs)
					dat += "<a href='byond://?src=[UID()];SelectedJob=[job.title]'><font color='lime'><B>[job.title] ([job.current_positions]) (Active: [activePlayers[job]])</B></font></a><br>"
				else
					dat += "<a href='byond://?src=[UID()];SelectedJob=[job.title]'>[job.title] ([job.current_positions]) (Active: [activePlayers[job]])</a><br>"
			dat += "</fieldset><br>"

		dat += "</td></tr></table></center>"
	else
		dat += "<br><br><center>Unfortunately, there are no job slots free currently.<BR>Wait a few minutes, then try again.<BR>Or, try observing the round.</center>"
	// Removing the old window method but leaving it here for reference
//		src << browse(dat, "window=latechoices;size=300x640;can_close=1")
	// Added the new browser window method
	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 900, 600)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.add_script("delay_interactivity", 'html/browser/delay_interactivity.js')
	popup.set_content(dat)
	popup.open(0) // 0 is passed to open so that it doesn't use the onclose() proc

/mob/new_player/proc/create_character()
	spawning = 1
	close_spawn_windows()

	check_prefs_are_sane()
	var/mob/living/carbon/human/new_character = new(loc)
	new_character.lastarea = get_area(loc)

	if(SSticker.random_players || appearance_isbanned(new_character))
		client.prefs.random_character()
		client.prefs.real_name = random_name(client.prefs.gender)
	client.prefs.copy_to(new_character)

	stop_sound_channel(CHANNEL_LOBBYMUSIC)


	if(mind)
		mind.active = 0					//we wish to transfer the key manually
		if(mind.assigned_role == "Clown")				//give them a clownname if they are a clown
			new_character.real_name = pick(GLOB.clown_names)	//I hate this being here of all places but unfortunately dna is based on real_name!
			new_character.rename_self("clown")
		else if(mind.assigned_role == "Mime")
			new_character.real_name = pick(GLOB.mime_names)
			new_character.rename_self("mime")
		mind.original = new_character
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active


	new_character.key = key		//Manually transfer the key to log them in

	return new_character

// This is to check that the player only has preferences set that they're supposed to
/mob/new_player/proc/check_prefs_are_sane()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = GLOB.all_species[client.prefs.species]
	if(!(chosen_species && (is_species_whitelisted(chosen_species) || has_admin_rights())))
		// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
		log_runtime(EXCEPTION("[src] had species [client.prefs.species], though they weren't supposed to. Setting to Human."), src)
		client.prefs.species = "Human"

	var/datum/language/chosen_language
	if(client.prefs.language)
		chosen_language = GLOB.all_languages[client.prefs.language]
	if((chosen_language == null && client.prefs.language != "None") || (chosen_language && chosen_language.flags & RESTRICTED))
		log_runtime(EXCEPTION("[src] had language [client.prefs.language], though they weren't supposed to. Setting to None."), src)
		client.prefs.language = "None"

/mob/new_player/proc/ViewManifest()
	var/dat = "<html><body>"
	dat += "<h4>Crew Manifest</h4>"
	dat += GLOB.data_core.get_manifest(OOC = 1)

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

/mob/new_player/Move()
	return 0


/mob/new_player/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window
	src << browse(null, "window=preferences") //closes job selection
	src << browse(null, "window=mob_occupation")
	src << browse(null, "window=latechoices") //closes late job selection


/mob/new_player/proc/has_admin_rights()
	return check_rights(R_ADMIN, 0, src)

/mob/new_player/proc/is_species_whitelisted(datum/species/S)
	if(!S) return 1
	return is_alien_whitelisted(src, S.name) || !config.usealienwhitelist || !(IS_WHITELISTED in S.species_traits)

/mob/new_player/get_gender()
	if(!client || !client.prefs) ..()
	return client.prefs.gender

/mob/new_player/is_ready()
	return ready && ..()

// No hearing announcements
/mob/new_player/can_hear()
	return 0
