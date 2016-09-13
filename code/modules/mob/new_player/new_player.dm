//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/mob/new_player
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0
	universal_speak = 1

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

/mob/new_player/New()
	mob_list += src

/mob/new_player/verb/new_player_panel()
	set src = usr
	new_player_panel_proc()


/mob/new_player/proc/new_player_panel_proc()
	var/real_name = client.prefs.real_name
	var/output = "<center><p><a href='byond://?src=[UID()];show_preferences=1'>Setup Character</A><br /><i>[real_name]</i></p>"

	if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
		if(!ready)	output += "<p><a href='byond://?src=[UID()];ready=1'>Declare Ready</A></p>"
		else	output += "<p><b>You are ready</b> (<a href='byond://?src=[UID()];ready=2'>Cancel</A>)</p>"

	else
		output += "<p><a href='byond://?src=[UID()];manifest=1'>View the Crew Manifest</A></p>"
		output += "<p><a href='byond://?src=[UID()];late_join=1'>Join Game!</A></p>"

	output += "<p><a href='byond://?src=[UID()];observe=1'>Observe</A></p>"

	if(!IsGuestKey(src.key))
		establish_db_connection()

		if(dbcon.IsConnected())
			var/isadmin = 0
			if(src.client && src.client.holder)
				isadmin = 1
			var/DBQuery/query = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM [format_table_name("poll_vote")] WHERE ckey = \"[ckey]\") AND id NOT IN (SELECT pollid FROM [format_table_name("poll_textreply")] WHERE ckey = \"[ckey]\")")
			query.Execute()
			var/newpoll = 0
			while(query.NextRow())
				newpoll = 1
				break

			if(newpoll)
				output += "<p><b><a href='byond://?src=[UID()];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
			else
				output += "<p><a href='byond://?src=[UID()];showpoll=1'>Show Player Polls</A></p>"

	output += "</center>"

	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>New Player Options</div>", 220, 290)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(0)
	return

/mob/new_player/Stat()
	if((!ticker) || ticker.current_state == GAME_STATE_PREGAME)
		statpanel("Lobby") // First tab during pre-game.
	..()

	statpanel("Status")
	if(client.statpanel == "Status" && ticker)
		if(ticker.current_state != GAME_STATE_PREGAME)
			stat(null, "Station Time: [worldtime2text()]")
	statpanel("Lobby")
	if(client.statpanel=="Lobby" && ticker)
		if(ticker.hide_mode)
			stat("Game Mode:", "Secret")
		else
			if(ticker.hide_mode == 0)
				stat("Game Mode:", "[master_mode]") // Old setting for showing the game mode
			else
				stat("Game Mode: ", "Secret")

		if((ticker.current_state == GAME_STATE_PREGAME) && going)
			stat("Time To Start:", ticker.pregame_timeleft)
		if((ticker.current_state == GAME_STATE_PREGAME) && !going)
			stat("Time To Start:", "DELAYED")

		if(ticker.current_state == GAME_STATE_PREGAME)
			stat("Players:", "[totalPlayers]")
			if(check_rights(R_ADMIN, 0, src))
				stat("Players Ready:", "[totalPlayersReady]")
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in player_list)
				if(check_rights(R_ADMIN, 0, src))
					stat("[player.key]", (player.ready)?("(Playing)"):(null))
				totalPlayers++
				if(player.ready)
					totalPlayersReady++

/mob/new_player/Topic(href, href_list[])
	if(!client)	return 0

	if(href_list["show_preferences"])
		client.prefs.ShowChoices(src)
		return 1

	if(href_list["ready"])
		ready = !ready
		new_player_panel_proc()

	if(href_list["refresh"])
		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel_proc()

	if(href_list["observe"])

		if(alert(src,"Are you sure you wish to observe? You cannot normally join the round after doing this!","Player Setup","Yes","No") == "Yes")
			if(!client)	return 1
			var/mob/dead/observer/observer = new()
			src << browse(null, "window=playersetup")
			spawning = 1
			src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)// MAD JAMS cant last forever yo


			observer.started_as_observer = 1
			close_spawn_windows()
			var/obj/O = locate("landmark*Observer-Start")
			to_chat(src, "\blue Now teleporting.")
			observer.loc = O.loc
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
			respawnable_list += observer
			qdel(src)
			return 1

	if(href_list["late_join"])
		if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, "\red The round is either not ready, or has already finished...")
			return

		if(client.prefs.species in whitelisted_species)

			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
				return 0

		LateChoices()

	if(href_list["manifest"])
		ViewManifest()

	if(href_list["SelectedJob"])

		if(!enter_allowed)
			to_chat(usr, "\blue There is an administrative lock on entering the game!")
			return

		if(client.prefs.species in whitelisted_species)
			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
				return 0

		AttemptLateSpawn(href_list["SelectedJob"],client.prefs.spawnpoint)
		return

	if(!ready && href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)
	else if(!href_list["late_join"])
		new_player_panel()

	if(href_list["showpoll"])

		handle_player_polling()
		return

	if(href_list["pollid"])

		var/pollid = href_list["pollid"]
		if(istext(pollid))
			pollid = text2num(pollid)
		if(isnum(pollid))
			src.poll_player(pollid)
		return

	if(href_list["votepollid"] && href_list["votetype"])
		var/pollid = text2num(href_list["votepollid"])
		var/votetype = href_list["votetype"]
		switch(votetype)
			if("OPTION")
				var/optionid = text2num(href_list["voteoptionid"])
				vote_on_poll(pollid, optionid)
			if("TEXT")
				var/replytext = href_list["replytext"]
				log_text_poll_reply(pollid, replytext)
			if("NUMVAL")
				var/id_min = text2num(href_list["minid"])
				var/id_max = text2num(href_list["maxid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["o[optionid]"]))	//Test if this optionid was replied to
						var/rating
						if(href_list["o[optionid]"] == "abstain")
							rating = null
						else
							rating = text2num(href_list["o[optionid]"])
							if(!isnum(rating))
								return

						vote_on_numval_poll(pollid, optionid, rating)
			if("MULTICHOICE")
				var/id_min = text2num(href_list["minoptionid"])
				var/id_max = text2num(href_list["maxoptionid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
						vote_on_poll(pollid, optionid, 1)

/mob/new_player/proc/IsJobAvailable(rank)
	var/datum/job/job = job_master.GetJob(rank)
	if(!job)	return 0
	if(!job.is_position_available()) return 0
	if(jobban_isbanned(src,rank))	return 0
	if(!is_job_whitelisted(src, rank))	 return 0
	if(!job.player_old_enough(src.client))	return 0
	if(job.admin_only && !(check_rights(R_EVENT, 0))) return 0

	if(config.assistantlimit)
		if(job.title == "Civilian")
			var/count = 0
			var/datum/job/officer = job_master.GetJob("Security Officer")
			var/datum/job/warden = job_master.GetJob("Warden")
			var/datum/job/hos = job_master.GetJob("Head of Security")
			count += (officer.current_positions + warden.current_positions + hos.current_positions)
			if(job.current_positions > (config.assistantratio * count))
				if(count >= 5) // if theres more than 5 security on the station just let assistants join regardless, they should be able to handle the tide
					return 1
				return 0
	return 1

/mob/new_player/proc/IsAdminJob(rank)
	var/datum/job/job = job_master.GetJob(rank)
	if(job.admin_only)
		return 1
	else
		return 0

/mob/new_player/proc/IsERTSpawnJob(rank)
	var/datum/job/job = job_master.GetJob(rank)
	if(job.spawn_ert)
		return 1
	else
		return 0

/mob/new_player/proc/AttemptLateSpawn(rank,var/spawning_at)
	if(src != usr)
		return 0
	if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "\red The round is either not ready, or has already finished...")
		return 0
	if(!enter_allowed)
		to_chat(usr, "\blue There is an administrative lock on entering the game!")
		return 0
	if(!IsJobAvailable(rank))
		to_chat(src, alert("[rank] is not available. Please try another."))
		return 0

	job_master.AssignRole(src, rank, 1)

	var/mob/living/character = create_character()	//creates the human and transfers vars and mind
	character = job_master.EquipRank(character, rank, 1)					//equips the human
	EquipCustomItems(character)

	// AIs don't need a spawnpoint, they must spawn at an empty core
	if(character.mind.assigned_role == "AI")

		var/mob/living/silicon/ai/ai_character = character.AIize() // AIize the character, but don't move them yet

		// IsJobAvailable for AI checks that there is an empty core available in this list
		ai_character.moveToEmptyCore()
		AnnounceCyborg(ai_character, rank, "has been downloaded to the empty core in \the [get_area(ai_character)]")

		ticker.mode.latespawn(ai_character)
		qdel(src)
		return

	//Find our spawning point.
	var/join_message
	var/datum/spawnpoint/S

	if(IsAdminJob(rank))
		if(IsERTSpawnJob(rank))
			character.loc = pick(ertdirector)
		else
			character.loc = pick(aroomwarp)
		join_message = "has arrived"
	else
		if(spawning_at)
			S = spawntypes[spawning_at]
		if(S && istype(S))
			if(S.check_job_spawning(rank))
				character.loc = pick(S.turfs)
				join_message = S.msg
			else
				to_chat(character, "Your chosen spawnpoint ([S.display_name]) is unavailable for your chosen job. Spawning you at the Arrivals shuttle instead.")
				character.loc = pick(latejoin)
				join_message = "has arrived on the station"
		else
			character.loc = pick(latejoin)
			join_message = "has arrived on the station"

	character.lastarea = get_area(loc)
	// Moving wheelchair if they have one
	if(character.buckled && istype(character.buckled, /obj/structure/stool/bed/chair/wheelchair))
		character.buckled.loc = character.loc
		character.buckled.dir = character.dir

	ticker.mode.latespawn(character)

	if(character.mind.assigned_role == "Cyborg")
		AnnounceCyborg(character, rank, join_message)
		callHook("latespawn", list(character))
	else if(IsAdminJob(rank))
		callHook("latespawn", list(character))
	else
		data_core.manifest_inject(character)
		ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
		AnnounceArrival(character, rank, join_message)
		callHook("latespawn", list(character))


	qdel(src)


/mob/new_player/proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank, var/join_message)
	if(ticker.current_state == GAME_STATE_PLAYING)
		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in living_mob_list)
			ailist += A
		if(ailist.len)
			var/mob/living/silicon/ai/announcer = pick(ailist)
			if(character.mind)
				if((character.mind.assigned_role != "Cyborg") && (character.mind.special_role != "MODE"))
					if(character.mind.role_alt_title)
						rank = character.mind.role_alt_title
					var/arrivalmessage = announcer.arrivalmsg
					arrivalmessage = replacetext(arrivalmessage,"$name",character.real_name)
					arrivalmessage = replacetext(arrivalmessage,"$rank",rank ? "[rank]" : "visitor")
					arrivalmessage = replacetext(arrivalmessage,"$species",character.species.name)
					arrivalmessage = replacetext(arrivalmessage,"$age",num2text(character.age))
					arrivalmessage = replacetext(arrivalmessage,"$gender",character.gender == FEMALE ? "Female" : "Male")
					announcer.say(";[arrivalmessage]")
		else
			if(character.mind)
				if((character.mind.assigned_role != "Cyborg") && (character.mind.special_role != "MODE"))
					if(character.mind.role_alt_title)
						rank = character.mind.role_alt_title
					global_announcer.autosay("[character.real_name],[rank ? " [rank]," : " visitor," ] [join_message ? join_message : "has arrived on the station"].", "Arrivals Announcement Computer")

/mob/new_player/proc/AnnounceCyborg(var/mob/living/character, var/rank, var/join_message)
	if(ticker.current_state == GAME_STATE_PLAYING)
		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in living_mob_list)
			ailist += A
		if(ailist.len)
			var/mob/living/silicon/ai/announcer = pick(ailist)
			if(character.mind)
				if((character.mind.special_role != "MODE"))
					var/arrivalmessage = "A new[rank ? " [rank]" : " visitor" ] [join_message ? join_message : "has arrived on the station"]."
					announcer.say(";[arrivalmessage]")
		else
			if(character.mind)
				if((character.mind.special_role != "MODE"))
					// can't use their name here, since cyborg namepicking is done post-spawn, so we'll just say "A new Cyborg has arrived"/"A new Android has arrived"/etc.
					global_announcer.autosay("A new[rank ? " [rank]" : " visitor" ] [join_message ? join_message : "has arrived on the station"].", "Arrivals Announcement Computer")

/mob/new_player/proc/LateChoices()
	var/mills = ROUND_TIME // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = (mills % 36000) / 600
	var/hours = mills / 36000

	var/dat = "<html><body><center>"
	dat += "Round Duration: [round(hours)]h [round(mins)]m<br>"

	if(shuttle_master.emergency.mode >= SHUTTLE_ESCAPE)
		dat += "<font color='red'><b>The station has been evacuated.</b></font><br>"
	else if(shuttle_master.emergency.mode >= SHUTTLE_CALL)
		dat += "<font color='red'>The station is currently undergoing evacuation procedures.</font><br>"

	dat += "Choose from the following open positions:<br><br>"

	var/list/activePlayers = list()
	var/list/categorizedJobs = list(
		"Command" = list(jobs = list(), titles = command_positions, color = "#aac1ee"),
		"Engineering" = list(jobs = list(), titles = engineering_positions, color = "#ffd699"),
		"Security" = list(jobs = list(), titles = security_positions, color = "#ff9999"),
		"Miscellaneous" = list(jobs = list(), titles = list(), color = "#ffffff", colBreak = 1),
		"Synthetic" = list(jobs = list(), titles = nonhuman_positions, color = "#ccffcc"),
		"Support / Service" = list(jobs = list(), titles = service_positions, color = "#cccccc"),
		"Medical" = list(jobs = list(), titles = medical_positions, color = "#99ffe6", colBreak = 1),
		"Science" = list(jobs = list(), titles = science_positions, color = "#e6b3e6"),
		"Supply" = list(jobs = list(), titles = supply_positions, color = "#ead4ae"),
		)
	for(var/datum/job/job in job_master.occupations)
		if(job && IsJobAvailable(job.title))
			activePlayers[job] = 0
			var/categorized = 0
			// Only players with the job assigned and AFK for less than 10 minutes count as active
			for(var/mob/M in player_list) if(M.mind && M.client && M.mind.assigned_role == job.title && M.client.inactivity <= 10 MINUTES)
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
						if(job.title in command_positions)
							jobs.Insert(1, job)
						else
							jobs += job
			if(!categorized)
				categorizedJobs["Miscellaneous"]["jobs"] += job

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
			dat += "<a href='byond://?src=[UID()];SelectedJob=[job.title]'>[job.title] ([job.current_positions]) (Active: [activePlayers[job]])</a><br>"
		dat += "</fieldset><br>"

	dat += "</td></tr></table></center>"
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

	if(ticker.random_players || appearance_isbanned(new_character))
		client.prefs.random_character()
		client.prefs.real_name = random_name(client.prefs.gender)
	client.prefs.copy_to(new_character)

	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)// MAD JAMS cant last forever yo


	if(mind)
		mind.active = 0					//we wish to transfer the key manually
		if(mind.assigned_role == "Clown")				//give them a clownname if they are a clown
			new_character.real_name = pick(clown_names)	//I hate this being here of all places but unfortunately dna is based on real_name!
			new_character.rename_self("clown")
		else if(new_character.species == "Diona")
			new_character.real_name = pick(diona_names)	//I hate this being here of all places but unfortunately dna is based on real_name!
			new_character.rename_self("diona")
		mind.original = new_character
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active


	new_character.key = key		//Manually transfer the key to log them in

	return new_character

// This is to check that the player only has preferences set that they're supposed to
/mob/new_player/proc/check_prefs_are_sane()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]
	if(!(chosen_species && (is_species_whitelisted(chosen_species) || has_admin_rights())))
		// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
		log_runtime(EXCEPTION("[src] had species [client.prefs.species], though they weren't supposed to. Setting to Human."), src)
		client.prefs.species = "Human"

	var/datum/language/chosen_language
	if(client.prefs.language)
		chosen_language = all_languages[client.prefs.language]
	if((chosen_language == null && client.prefs.language != "None") || (chosen_language && chosen_language.flags & RESTRICTED))
		log_runtime(EXCEPTION("[src] had language [client.prefs.language], though they weren't supposed to. Setting to None."), src)
		client.prefs.language = "None"

/mob/new_player/proc/ViewManifest()
	var/dat = "<html><body>"
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest(OOC = 1)

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
	return is_alien_whitelisted(src, S.name) || !config.usealienwhitelist || !(S.flags & IS_WHITELISTED)

/mob/new_player/get_species()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]

	if(!chosen_species)
		return "Human"

	if(is_species_whitelisted(chosen_species) || has_admin_rights())
		return chosen_species.name

	return "Human"

/mob/new_player/get_gender()
	if(!client || !client.prefs) ..()
	return client.prefs.gender

/mob/new_player/is_ready()
	return ready && ..()
