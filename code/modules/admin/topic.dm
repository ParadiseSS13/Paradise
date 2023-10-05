/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		message_admins("[key_name_admin(usr)] has attempted to override the admin panel!")
		return

	if(SSticker.mode && SSticker.mode.check_antagonists_topic(href, href_list))
		check_antagonists()
		return

	if(href_list["rejectadminhelp"])
		if(!check_rights(R_ADMIN|R_MOD))
			return
		var/client/C = locateUID(href_list["rejectadminhelp"])
		if(!isclient(C))
			return

		SEND_SOUND(C, sound('sound/effects/adminhelp.ogg'))

		to_chat(C, "<font color='red' size='4'><b>- AdminHelp Rejected! -</b></font>")
		to_chat(C, "<font color='red'><b>Your admin help was rejected.</b></font>")
		to_chat(C, "Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting. If you asked a question, please ensure it was clear what you were asking.")

		message_admins("[key_name_admin(usr)] rejected [key_name_admin(C.mob)]'s admin help")
		log_admin("[key_name(usr)] rejected [key_name(C.mob)]'s admin help")

	if(href_list["openticket"])
		var/ticketID = text2num(href_list["openticket"])
		if(!href_list["is_mhelp"])
			if(!check_rights(R_ADMIN))
				return
			SStickets.showDetailUI(usr, ticketID)
		else
			if(!check_rights(R_MENTOR|R_MOD|R_ADMIN))
				return
			SSmentor_tickets.showDetailUI(usr, ticketID)

	if(href_list["makeAntag"])
		switch(href_list["makeAntag"])
			if("1")
				log_admin("[key_name(usr)] has spawned a traitor.")
				if(!makeTraitors())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("2")
				log_admin("[key_name(usr)] has spawned a changeling.")
				if(!makeChangelings())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("3")
				log_admin("[key_name(usr)] has spawned revolutionaries.")
				if(!makeRevs())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("4")
				log_admin("[key_name(usr)] has spawned a cultists.")
				if(!makeCult())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("5")
				log_admin("[key_name(usr)] has spawned a wizard.")
				if(!makeWizard())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("6")
				log_admin("[key_name(usr)] has spawned vampires.")
				if(!makeVampires())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("7")
				log_admin("[key_name(usr)] has spawned an abductor team.")
				if(!makeAbductorTeam())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")

	else if(href_list["dbsearchckey"] || href_list["dbsearchadmin"] || href_list["dbsearchip"] || href_list["dbsearchcid"] || href_list["dbsearchbantype"])
		var/adminckey = href_list["dbsearchadmin"]
		var/playerckey = href_list["dbsearchckey"]
		var/playerip = href_list["dbsearchip"]
		var/playercid = href_list["dbsearchcid"]
		var/dbbantype = text2num(href_list["dbsearchbantype"])
		var/match = 0

		if("dbmatch" in href_list)
			match = 1

		DB_ban_panel(playerckey, adminckey, playerip, playercid, dbbantype, match)
		return

	else if(href_list["dbbanedit"])
		var/banedit = href_list["dbbanedit"]
		var/banid = text2num(href_list["dbbanid"])
		if(!banedit || !banid)
			return

		DB_ban_edit(banid, banedit)
		return

	else if(href_list["dbbanaddtype"])

		var/bantype = text2num(href_list["dbbanaddtype"])
		var/banckey = href_list["dbbanaddckey"]
		var/banip = href_list["dbbanaddip"]
		var/bancid = href_list["dbbanaddcid"]
		var/banduration = text2num(href_list["dbbaddduration"])
		var/banjob = href_list["dbbanaddjob"]
		var/banreason = href_list["dbbanreason"]

		var/job_ban = FALSE
		var/multi_job = FALSE
		var/list/jobs_to_ban = list()

		banckey = ckey(banckey)

		switch(bantype)
			if(BANTYPE_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey and reason)</span>")
					return
				banduration = null
				banjob = null
			if(BANTYPE_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey, reason and duration)</span>")
					return
				banjob = null
			if(BANTYPE_JOB_PERMA)
				if(!banckey || !banreason || !banjob)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey, reason and job)</span>")
					return
				banduration = null
				job_ban = TRUE
			if(BANTYPE_JOB_TEMP)
				if(!banckey || !banreason || !banjob || !banduration)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey, reason and job)</span>")
					return
				job_ban = TRUE
			if(BANTYPE_ADMIN_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey and reason)</span>")
					return
				banduration = null
				banjob = null
			if(BANTYPE_ADMIN_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "<span class='warning'>Not enough parameters (Requires ckey, reason and duration)</span>")
					return
				banjob = null

		var/mob/playermob

		if("autopopulate" in href_list)
			for(var/mob/M in GLOB.player_list)
				if(M.ckey == banckey)
					playermob = M
					break

		banreason = "(MANUAL BAN) "+banreason

		if(!playermob)
			if(banip)
				banreason = "[banreason] (CUSTOM IP)"
			if(bancid)
				banreason = "[banreason] (CUSTOM CID)"
		else
			message_admins("Ban process: A mob matching [playermob.ckey] was found at location [playermob.x], [playermob.y], [playermob.z]. Custom IP and computer id fields replaced with the IP and computer id from the located mob")

		if(job_ban)
			if(banjob in list("commanddept","securitydept","engineeringdept","medicaldept","sciencedept","supportdept","nonhumandept"))
				multi_job = TRUE
				switch(banjob)
					if("commanddept")
						for(var/jobPos in GLOB.command_positions)
							if(!jobPos)	continue
							var/datum/job/temp = SSjobs.GetJob(jobPos)
							if(!temp) continue
							jobs_to_ban += temp.title
					if("securitydept")
						for(var/jobPos in GLOB.security_positions)
							if(!jobPos)	continue
							var/datum/job/temp = SSjobs.GetJob(jobPos)
							if(!temp) continue
							jobs_to_ban += temp.title
					if("engineeringdept")
						for(var/jobPos in GLOB.engineering_positions)
							if(!jobPos)	continue
							var/datum/job/temp = SSjobs.GetJob(jobPos)
							if(!temp) continue
							jobs_to_ban += temp.title
					if("medicaldept")
						for(var/jobPos in GLOB.medical_positions)
							if(!jobPos)	continue
							var/datum/job/temp = SSjobs.GetJob(jobPos)
							if(!temp) continue
							jobs_to_ban += temp.title
					if("sciencedept")
						for(var/jobPos in GLOB.science_positions)
							if(!jobPos)	continue
							var/datum/job/temp = SSjobs.GetJob(jobPos)
							if(!temp) continue
							jobs_to_ban += temp.title
					if("supportdept")
						for(var/jobPos in GLOB.support_positions)
							if(!jobPos)	continue
							var/datum/job/temp = SSjobs.GetJob(jobPos)
							if(!temp) continue
							jobs_to_ban += temp.title
					if("nonhumandept")
						jobs_to_ban += "pAI"
						for(var/jobPos in GLOB.nonhuman_positions)
							if(!jobPos)	continue
							var/datum/job/temp = SSjobs.GetJob(jobPos)
							if(!temp) continue
							jobs_to_ban += temp.title

		// If the job ban is for multiple jobs in one group (IE: Command), iterate through jobs and ban each individually
		if(multi_job)
			//Create a list of unbanned jobs within joblist
			var/list/notbannedlist = list()
			var/list/banned_list = get_jobbans_for_offline_ckey(banckey) // They might be offline, you never know
			for(var/job in jobs_to_ban)
				if(!(job in banned_list))
					notbannedlist += job

			for(var/job in notbannedlist)
				DB_ban_record(bantype, playermob, banduration, banreason, job, null, banckey, banip, bancid)

		// Otherwise, do it normally
		else
			DB_ban_record(bantype, playermob, banduration, banreason, banjob, null, banckey, banip, bancid)


	else if(href_list["editrights"])
		if(!check_rights(R_PERMISSIONS))
			message_admins("[key_name_admin(usr)] attempted to edit the admin permissions without sufficient rights.")
			log_admin("[key_name(usr)] attempted to edit the admin permissions without sufficient rights.")
			return

		var/adm_ckey

		var/task = href_list["editrights"]
		if(task == "add")
			var/new_ckey = ckey(clean_input("New admin's ckey","Admin ckey", null))
			if(!new_ckey)	return
			if(new_ckey in GLOB.admin_datums)
				to_chat(usr, "<font color='red'>Error: Topic 'editrights': [new_ckey] is already an admin</font>")
				return
			adm_ckey = new_ckey
			task = "rank"
		else if(task != "show")
			adm_ckey = ckey(href_list["ckey"])
			if(!adm_ckey)
				to_chat(usr, "<font color='red'>Error: Topic 'editrights': No valid ckey</font>")
				return

		var/datum/admins/D = GLOB.admin_datums[adm_ckey]

		if(task == "remove")
			if(alert("Are you sure you want to remove [adm_ckey]?","Message","Yes","Cancel") == "Yes")
				if(!D)	return
				GLOB.admin_datums -= adm_ckey
				D.disassociate()

				updateranktodb(adm_ckey, "player")
				message_admins("[key_name_admin(usr)] removed [adm_ckey] from the admins list")
				log_admin("[key_name(usr)] removed [adm_ckey] from the admins list")
				log_admin_rank_modification(adm_ckey, "Removed")

		else if(task == "rank")
			var/new_rank
			if(GLOB.admin_ranks.len)
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in (GLOB.admin_ranks|"*New Rank*")
			else
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in list("Mentor", "Trial Admin", "Game Admin", "*New Rank*")

			var/rights = 0
			if(D)
				rights = D.rights
			switch(new_rank)
				if(null,"") return
				if("*New Rank*")
					new_rank = input("Please input a new rank", "New custom rank", null, null) as null|text
					if(!GLOB.configuration.admin.use_database_admins)
						new_rank = ckeyEx(new_rank)
					if(!new_rank)
						to_chat(usr, "<font color='red'>Error: Topic 'editrights': Invalid rank</font>")
						return
					if(!GLOB.configuration.admin.use_database_admins)
						if(GLOB.admin_ranks.len)
							if(new_rank in GLOB.admin_ranks)
								rights = GLOB.admin_ranks[new_rank]		//we typed a rank which already exists, use its rights
							else
								GLOB.admin_ranks[new_rank] = 0			//add the new rank to admin_ranks
				else
					if(!GLOB.configuration.admin.use_database_admins)
						new_rank = ckeyEx(new_rank)
						rights = GLOB.admin_ranks[new_rank]				//we input an existing rank, use its rights

			if(D)
				D.disassociate()								//remove adminverbs and unlink from client
				D.rank = new_rank								//update the rank
				D.rights = rights								//update the rights based on admin_ranks (default: 0)
			else
				D = new /datum/admins(new_rank, rights, adm_ckey)

			var/client/C = GLOB.directory[adm_ckey]						//find the client with the specified ckey (if they are logged in)
			D.associate(C)											//link up with the client and add verbs

			updateranktodb(adm_ckey, new_rank)
			message_admins("[key_name_admin(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin("[key_name(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin_rank_modification(adm_ckey, new_rank)

		else if(task == "permissions")
			if(!D)	return
			while(TRUE)
				var/list/permissionlist = list()
				for(var/i=1, i<=R_MAXPERMISSION, i<<=1)		//that <<= is shorthand for i = i << 1. Which is a left bitshift
					permissionlist[rights2text(i)] = i
				var/new_permission = input("Select a permission to turn on/off", adm_ckey + "'s Permissions", null, null) as null|anything in permissionlist
				if(!new_permission)
					return
				var/oldrights = D.rights
				var/toggleresult = "ON"
				D.rights ^= permissionlist[new_permission]
				if(oldrights > D.rights)
					toggleresult = "OFF"

				message_admins("[key_name_admin(usr)] toggled the [new_permission] permission of [adm_ckey] to [toggleresult]")
				log_admin("[key_name(usr)] toggled the [new_permission] permission of [adm_ckey] to [toggleresult]")
				log_admin_permission_modification(adm_ckey, permissionlist[new_permission])


		edit_admin_permissions()

	else if(href_list["call_shuttle"])
		if(!check_rights(R_ADMIN))	return


		switch(href_list["call_shuttle"])
			if("1")
				if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
					return
				SSshuttle.emergency.request()
				log_admin("[key_name(usr)] called the Emergency Shuttle")
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>")

			if("2")
				if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
					return
				switch(SSshuttle.emergency.mode)
					if(SHUTTLE_CALL)
						SSshuttle.emergency.cancel()
						log_admin("[key_name(usr)] sent the Emergency Shuttle back")
						message_admins("<span class='adminnotice'>[key_name_admin(usr)] sent the Emergency Shuttle back</span>")
					else
						SSshuttle.emergency.cancel()
						log_admin("[key_name(usr)] called the Emergency Shuttle")
						message_admins("<span class='adminnotice'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>")


		href_list["secrets"] = "check_antagonist"

	else if(href_list["edit_shuttle_time"])
		if(!check_rights(R_SERVER))	return

		var/timer = input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", SSshuttle.emergency.timeLeft() ) as num
		SSshuttle.emergency.setTimer(timer*10)
		log_admin("[key_name(usr)] edited the Emergency Shuttle's timeleft to [timer] seconds")
		GLOB.minor_announcement.Announce("The emergency shuttle will reach its destination in [round(SSshuttle.emergency.timeLeft(600))] minutes.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] edited the Emergency Shuttle's timeleft to [timer] seconds</span>")
		href_list["secrets"] = "check_antagonist"

	else if(href_list["delay_round_end"])
		if(!check_rights(R_SERVER))	return

		SSticker.delay_end = !SSticker.delay_end
		log_admin("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins("<span class='notice'>[key_name_admin(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].</span>", 1)
		if(SSticker.delay_end)
			SSticker.real_reboot_time = 0 // If they set this at round end, show the "Reboot was cancelled by an admin" message instantly
		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["simplemake"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locateUID(href_list["mob"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		var/delmob = 0
		switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
			if("Cancel")	return
			if("Yes")		delmob = 1

		switch(href_list["simplemake"])
			if("observer")			M.change_mob_type( /mob/dead/observer , null, null, delmob, 1 )
			if("drone")				M.change_mob_type( /mob/living/carbon/alien/humanoid/drone , null, null, delmob, 1 )
			if("hunter")			M.change_mob_type( /mob/living/carbon/alien/humanoid/hunter , null, null, delmob, 1 )
			if("queen")				M.change_mob_type( /mob/living/carbon/alien/humanoid/queen/large , null, null, delmob, 1 )
			if("sentinel")			M.change_mob_type( /mob/living/carbon/alien/humanoid/sentinel , null, null, delmob, 1 )
			if("larva")				M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob, 1 )
			if("human")
				var/posttransformoutfit = usr.client.robust_dress_shop()
				var/mob/living/carbon/human/newmob = M.change_mob_type(/mob/living/carbon/human, null, null, delmob, 1)
				if(posttransformoutfit && istype(newmob))
					newmob.equipOutfit(posttransformoutfit)
			if("slime")				M.change_mob_type( /mob/living/simple_animal/slime , null, null, delmob, 1 )
			if("monkey")			M.change_mob_type( /mob/living/carbon/human/monkey , null, null, delmob, 1 )
			if("robot")				M.change_mob_type( /mob/living/silicon/robot , null, null, delmob, 1 )
			if("cat")				M.change_mob_type( /mob/living/simple_animal/pet/cat , null, null, delmob, 1 )
			if("runtime")			M.change_mob_type( /mob/living/simple_animal/pet/cat/Runtime , null, null, delmob, 1 )
			if("corgi")				M.change_mob_type( /mob/living/simple_animal/pet/dog/corgi , null, null, delmob, 1 )
			if("crab")				M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob, 1 )
			if("coffee")			M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob, 1 )
			if("parrot")			M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob, 1 )
			if("polyparrot")		M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob, 1 )
			if("constructarmoured")	M.change_mob_type( /mob/living/simple_animal/hostile/construct/armoured , null, null, delmob, 1 )
			if("constructbuilder")	M.change_mob_type( /mob/living/simple_animal/hostile/construct/builder , null, null, delmob, 1 )
			if("constructwraith")	M.change_mob_type( /mob/living/simple_animal/hostile/construct/wraith , null, null, delmob, 1 )
			if("shade")				M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob, 1 )

		log_admin("[key_name(usr)] has used rudimentary transformation on [key_name(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]")
		message_admins("<span class='notice'>[key_name_admin(usr)] has used rudimentary transformation on [key_name_admin(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]</span>", 1)

	else if(href_list["jobban2"])
//		if(!check_rights(R_BAN))	return

		if(!SSdbcore.IsConnected())
			alert(usr, "Job bans require the datbase to be setup.", "Error", "Ok")
			return

		var/mob/M = locateUID(href_list["jobban2"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		if(!M.ckey)	//sanity
			to_chat(usr, "<span class='warning'>This mob has no ckey</span>")
			return
		if(!SSjobs)
			to_chat(usr, "<span class='warning'>SSjobs has not been setup!</span>")
			return

		var/dat = ""
		var/header = "<head><title>Job-Ban Panel: [M.name]</title></head>"
		var/body
		var/jobs = ""

		/***********************************WARNING!************************************
						The jobban stuff looks mangled and disgusting
								But it looks beautiful in-game
											-Nodrak
		************************************WARNING!***********************************/
		var/counter = 0
//Regular jobs
	//Command (Blue)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(GLOB.command_positions)]'><a href='?src=[UID()];jobban3=commanddept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Command Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.command_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 6) //So things dont get squiiiiished!
				jobs += "</tr><tr>"
				counter = 0
		jobs += "</tr></table>"

	//Security (Red)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffddf0'><th colspan='[length(GLOB.security_positions)]'><a href='?src=[UID()];jobban3=securitydept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Security Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.security_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Engineering (Yellow)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='fff5cc'><th colspan='[length(GLOB.engineering_positions)]'><a href='?src=[UID()];jobban3=engineeringdept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Engineering Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.engineering_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Medical (White)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeef0'><th colspan='[length(GLOB.medical_positions)]'><a href='?src=[UID()];jobban3=medicaldept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Medical Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.medical_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Science (Purple)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='e79fff'><th colspan='[length(GLOB.science_positions)]'><a href='?src=[UID()];jobban3=sciencedept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Science Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.science_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Support (Grey)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(GLOB.support_positions)]'><a href='?src=[UID()];jobban3=supportdept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Support Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.support_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Non-Human (Green)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccffcc'><th colspan='[length(GLOB.nonhuman_positions)+1]'><a href='?src=[UID()];jobban3=nonhumandept;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Non-human Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.nonhuman_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjobs.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[job.title];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		//Drone
		if(jobban_isbanned(M, "Drone"))
			jobs += "<td width='20%'><a href='?src=[UID()];jobban3=Drone;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>Drone</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=[UID()];jobban3=Drone;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Drone</a></td>"

		//pAI
		if(jobban_isbanned(M, "pAI"))
			jobs += "<td width='20%'><a href='?src=[UID()];jobban3=pAI;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>pAI</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=[UID()];jobban3=pAI;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>pAI</a></td>"

		jobs += "</tr></table>"

	//Antagonist (Orange)
		var/isbanned_dept = jobban_isbanned(M, "Syndicate")
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=[UID()];jobban3=Syndicate;jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>Antagonist Positions</a></th></tr><tr align='center'>"

		counter = 0
		for(var/role in GLOB.antag_roles)
			if(jobban_isbanned(M, role) || isbanned_dept)
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[role];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>[replacetext(role, " ", "&nbsp")]</font></a></td>"
			else
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[role];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(role, " ", "&nbsp")]</a></td>"
			counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

		//Other races  (BLUE, because I have no idea what other color to make this)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccccff'><th colspan='10'>Other</th></tr><tr align='center'>"

		counter = 0
		for(var/role in GLOB.other_roles)
			if(jobban_isbanned(M, role) || isbanned_dept)
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[role];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'><font color=red>[replacetext(role, " ", "&nbsp")]</font></a></td>"
			else
				jobs += "<td width='20%'><a href='?src=[UID()];jobban3=[role];jobban4=[M.UID()];dbbanaddckey=[M.ckey]'>[replacetext(role, " ", "&nbsp")]</a></td>"
			counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

		body = "<body>[jobs]</body>"
		dat = "<tt>[header][body]</tt>"
		usr << browse(dat, "window=jobban2;size=800x490")
		return

	//JOBBAN'S INNARDS
	else if(href_list["jobban3"])
		if(!check_rights(R_BAN))	return

		var/mob/M = locateUID(href_list["jobban4"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		if(M != usr)																//we can jobban ourselves
			if(M.client && M.client.holder && (M.client.holder.rights & R_BAN))		//they can ban too. So we can't ban them
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

		var/ban_ckey_param = href_list["dbbanaddckey"]

		if(!SSjobs)
			to_chat(usr, "<span class='warning'>SSjobs has not been setup!</span>")
			return

		//get jobs for department if specified, otherwise just returnt he one job in a list.
		var/list/joblist = list()
		switch(href_list["jobban3"])
			if("commanddept")
				for(var/jobPos in GLOB.command_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("securitydept")
				for(var/jobPos in GLOB.security_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in GLOB.engineering_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in GLOB.medical_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("sciencedept")
				for(var/jobPos in GLOB.science_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("supportdept")
				for(var/jobPos in GLOB.support_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("nonhumandept")
				joblist += "pAI"
				for(var/jobPos in GLOB.nonhuman_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			else
				joblist += href_list["jobban3"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_isbanned(M, job))
				notbannedlist += job

		//Banning comes first
		if(notbannedlist.len) //at least 1 unbanned job exists in joblist so we have stuff to ban.
			switch(alert("Temporary Ban of [M.ckey]?",,"Yes","No", "Cancel"))
				if("Yes")
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(!mins)
						return
					var/reason = input(usr,"Please state the reason","Reason","") as message|null
					if(!reason)
						return

					var/msg
					M = admin_ban_mobsearch(M, ban_ckey_param, usr)
					for(var/job in notbannedlist)
						log_admin("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes")
						DB_ban_record(BANTYPE_JOB_TEMP, M, mins, reason, job)
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					add_note(M.ckey, "Banned  from [msg] - [reason]", null, usr.ckey, 0)
					message_admins("<span class='notice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg] for [mins] minutes</span>", 1)

					// Reload their job ban holder (refresh this round)
					if(M.client)
						M.client.jbh.reload_jobbans(M.client)
						to_chat(M, "<span class='warning'><big><b>You have been jobbanned by [usr.client.ckey] from: [msg].</b></big></span>")
						to_chat(M, "<span class='danger'>The reason is: [reason]</span>")
						to_chat(M, "<span class='warning'>This jobban will be lifted in [mins] minutes.</span>")
					href_list["jobban2"] = 1 // lets it fall through and refresh
					return 1
				if("No")
					var/reason = input(usr,"Please state the reason","Reason","") as message|null
					if(reason)
						var/msg
						M = admin_ban_mobsearch(M, ban_ckey_param, usr)
						for(var/job in notbannedlist)
							log_admin("[key_name(usr)] perma-banned [key_name(M)] from [job]")
							DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job)
							if(!msg)
								msg = job
							else
								msg += ", [job]"
						add_note(M.ckey, "Banned  from [msg] - [reason]", null, usr.ckey, 0)
						message_admins("<span class='notice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg]</span>", 1)

						// Reload their job ban holder (refresh this round)
						if(M.client)
							M.client.jbh.reload_jobbans(M.client)
							to_chat(M, "<span class='warning'><big><b>You have been jobbanned by [usr.client.ckey] from: [msg].</b></big></span>")
							to_chat(M, "<span class='danger'>The reason is: [reason]</span>")
							to_chat(M, "<span class='warning'>Jobban can be lifted only upon request.</span>")
						href_list["jobban2"] = 1 // lets it fall through and refresh
						return 1
				if("Cancel")
					return

	else if(href_list["boot2"])
		var/mob/M = locateUID(href_list["boot2"])
		if(!ismob(M))
			return
		var/client/C = M.client
		if(C == null)
			to_chat(usr, "<span class='warning'>Mob has no client to kick.</span>")
			return
		if(alert("Kick [C.ckey]?",,"Yes","No") == "Yes")
			if(C && C.holder && (C.holder.rights & R_BAN))
				to_chat(usr, "<span class='warning'>[key_name_admin(C)] cannot be kicked from the server.</span>")
				return
			to_chat(C, "<span class='warning'>You have been kicked from the server</span>")
			log_admin("[key_name(usr)] booted [key_name(C)].")
			message_admins("<span class='notice'>[key_name_admin(usr)] booted [key_name_admin(C)].</span>", 1)
			//C = null
			qdel(C)

	else if(href_list["open_logging_view"])
		var/mob/M = locateUID(href_list["open_logging_view"])
		if(ismob(M))
			usr.client.open_logging_view(list(M), TRUE)

	//Player Notes
	else if(href_list["addnote"])
		var/target_ckey = href_list["addnote"]
		add_note(target_ckey)

	else if(href_list["addnoteempty"])
		add_note()

	else if(href_list["removenote"])
		var/note_id = href_list["removenote"]
		if(alert("Do you really want to delete this note?", "Note deletion confirmation", "Yes", "No") == "Yes")
			remove_note(note_id)

	else if(href_list["editnote"])
		var/note_id = href_list["editnote"]
		edit_note(note_id)

	else if(href_list["shownote"])
		var/target = href_list["shownote"]
		show_note(index = target)

	else if(href_list["nonalpha"])
		var/target = href_list["nonalpha"]
		target = text2num(target)
		show_note(index = target)

	else if(href_list["webtools"])
		var/target_ckey = href_list["webtools"]
		if(GLOB.configuration.url.forum_playerinfo_url)
			var/url_to_open = "[GLOB.configuration.url.forum_playerinfo_url][target_ckey]"
			if(alert("Open [url_to_open]",,"Yes","No")=="Yes")
				usr.client << link(url_to_open)

	else if(href_list["shownoteckey"])
		var/target_ckey = href_list["shownoteckey"]
		show_note(target_ckey)

	else if(href_list["notessearch"])
		var/target = href_list["notessearch"]
		show_note(index = target)

	else if(href_list["noteedits"])
		var/note_id = text2num(href_list["noteedits"])
		var/datum/db_query/query_noteedits = SSdbcore.NewQuery("SELECT edits FROM notes WHERE id=:note_id", list(
			"note_id" = note_id
		))
		if(!query_noteedits.warn_execute())
			qdel(query_noteedits)
			return
		if(query_noteedits.NextRow())
			var/edit_log = query_noteedits.item[1]
			usr << browse(edit_log,"window=noteedits")
		qdel(query_noteedits)

	else if(href_list["newban"])
		if(!check_rights(R_BAN))	return

		if(!SSdbcore.IsConnected())
			alert(usr, "Bans require the database to be connected.<br>If this is a local server, please ban from within Dream Daemon.", "Error", "Ok")
			return

		var/mob/M = locateUID(href_list["newban"])
		if(!ismob(M))
			return
		var/ban_ckey_param = href_list["dbbanaddckey"]

		switch(alert("Temporary Ban of [M.ckey] / [ban_ckey_param]?",,"Yes","No", "Cancel"))
			if("Yes")
				var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
				if(!mins)
					return
				if(mins >= 525600) mins = 525599
				var/reason = input(usr,"Please state the reason","Reason") as message|null
				if(!reason)
					return
				M = admin_ban_mobsearch(M, ban_ckey_param, usr)
				to_chat(M, "<span class='warning'><big><b>You have been banned by [usr.client.ckey].\nReason: [reason].</b></big></span>")
				to_chat(M, "<span class='warning'>This is a temporary ban, it will be removed in [mins] minutes.</span>")
				DB_ban_record(BANTYPE_TEMP, M, mins, reason)
				add_note(M.ckey, "Banned for [mins] minutes - [reason]", null, usr.ckey, FALSE)
				if(M.client)
					M.client.link_forum_account(TRUE)
				if(GLOB.configuration.url.banappeals_url)
					to_chat(M, "<span class='warning'>To try to resolve this matter head to [GLOB.configuration.url.banappeals_url]</span>")
				else
					to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
				log_admin("[key_name(usr)] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
				message_admins("<span class='notice'>[key_name_admin(usr)] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.</span>")

				qdel(M.client)
			if("No")
				var/reason = input(usr,"Please state the reason","Reason") as message|null
				if(!reason)
					return
				to_chat(M, "<span class='warning'><big><b>You have been banned by [usr.client.ckey].\nReason: [reason].</b></big></span>")
				to_chat(M, "<span class='warning'>This ban does not expire automatically and must be appealed.</span>")
				if(M.client)
					M.client.link_forum_account(TRUE)
				if(GLOB.configuration.url.banappeals_url)
					to_chat(M, "<span class='warning'>To try to resolve this matter head to [GLOB.configuration.url.banappeals_url]</span>")
				else
					to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
				log_admin("[key_name(usr)] has banned [M.ckey].\nReason: [reason]\nThis ban does not expire automatically and must be appealed.")
				message_admins("<span class='notice'>[key_name_admin(usr)] has banned [M.ckey].\nReason: [reason]\nThis ban does not expire automatically and must be appealed.</span>")
				DB_ban_record(BANTYPE_PERMA, M, -1, reason)
				add_note(M.ckey, "Permanently banned - [reason]", null, usr.ckey, FALSE)

				qdel(M.client)
			if("Cancel")
				return


	//Watchlist
	else if(href_list["watchadd"])
		var/target_ckey = href_list["watchadd"]
		usr.client.watchlist_add(target_ckey)

	else if(href_list["watchremove"])
		var/target_ckey = href_list["watchremove"]
		var/confirm = alert("Are you sure you want to remove [target_ckey] from the watchlist?", "Confirm Watchlist Removal", "Yes", "No")
		if(confirm == "Yes")
			usr.client.watchlist_remove(target_ckey)

	else if(href_list["watchedit"])
		var/target_ckey = href_list["watchedit"]
		usr.client.watchlist_edit(target_ckey)

	else if(href_list["watchaddbrowse"])
		usr.client.watchlist_add(null, 1)

	else if(href_list["watchremovebrowse"])
		var/target_ckey = href_list["watchremovebrowse"]
		usr.client.watchlist_remove(target_ckey, 1)

	else if(href_list["watcheditbrowse"])
		var/target_ckey = href_list["watcheditbrowse"]
		usr.client.watchlist_edit(target_ckey, 1)

	else if(href_list["watchsearch"])
		var/target_ckey = href_list["watchsearch"]
		usr.client.watchlist_show(target_ckey)

	else if(href_list["watchshow"])
		usr.client.watchlist_show()

	else if(href_list["watcheditlog"])
		var/target_ckey = href_list["watcheditlog"]
		var/datum/db_query/query_watchedits = SSdbcore.NewQuery("SELECT edits FROM watch WHERE ckey=:targetkey", list(
			"targetkey" = target_ckey
		))
		if(!query_watchedits.warn_execute())
			qdel(query_watchedits)
			return
		if(query_watchedits.NextRow())
			var/edit_log = query_watchedits.item[1]
			usr << browse(edit_log,"window=watchedits")
		qdel(query_watchedits)

	else if(href_list["mute"])
		if(!check_rights(R_ADMIN|R_MOD))
			return

		var/mob/M = locateUID(href_list["mute"])
		if(!ismob(M))	return
		if(!M.client)	return

		var/mute_type = href_list["mute_type"]
		if(istext(mute_type))	mute_type = text2num(mute_type)
		if(!isnum(mute_type))	return

		cmd_admin_mute(M, mute_type)

	else if(href_list["c_mode"])
		if(!check_rights(R_ADMIN))	return

		if(SSticker && SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		var/dat = {"<b>What mode do you wish to play?</b><hr>"}
		for(var/mode in GLOB.configuration.gamemode.gamemodes)
			dat += {"<A href='?src=[UID()];c_mode2=[mode]'>[GLOB.configuration.gamemode.gamemode_names[mode]]</A><br>"}
		dat += {"<A href='?src=[UID()];c_mode2=secret'>Secret</A><br>"}
		dat += {"<A href='?src=[UID()];c_mode2=random'>Random</A><br>"}
		dat += {"Now: [GLOB.master_mode]"}
		usr << browse(dat, "window=c_mode")

	else if(href_list["f_secret"])
		if(!check_rights(R_ADMIN))	return

		if(SSticker && SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(GLOB.master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		var/dat = {"<b>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</b><hr>"}
		for(var/mode in GLOB.configuration.gamemode.gamemodes)
			dat += {"<A href='?src=[UID()];f_secret2=[mode]'>[GLOB.configuration.gamemode.gamemode_names[mode]]</A><br>"}
		dat += {"<A href='?src=[UID()];f_secret2=secret'>Random (default)</A><br>"}
		dat += {"Now: [GLOB.secret_force_mode]"}
		usr << browse(dat, "window=f_secret")

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if(SSticker && SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		GLOB.master_mode = href_list["c_mode2"]
		log_admin("[key_name(usr)] set the mode as [GLOB.master_mode].")
		message_admins("<span class='notice'>[key_name_admin(usr)] set the mode as [GLOB.master_mode].</span>", 1)
		to_chat(world, "<span class='boldnotice'>The mode is now: [GLOB.master_mode]</span>")
		Game() // updates the main game menu
		world.save_mode(GLOB.master_mode)
		.(href, list("c_mode"=1))

	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if(SSticker && SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(GLOB.master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		GLOB.secret_force_mode = href_list["f_secret2"]
		log_admin("[key_name(usr)] set the forced secret mode as [GLOB.secret_force_mode].")
		message_admins("<span class='notice'>[key_name_admin(usr)] set the forced secret mode as [GLOB.secret_force_mode].</span>", 1)
		Game() // updates the main game menu
		.(href, list("f_secret"=1))

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["monkeyone"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return
		if(alert(usr, "Confirm make monkey?",, "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] attempting to monkeyize [key_name(H)]")
		message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)]</span>", 1)
		H.monkeyize()


	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["corgione"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return

		if(alert(usr, "Confirm make corgi?",, "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] attempting to corgize [key_name(H)]")
		message_admins("<span class='notice'>[key_name_admin(usr)] attempting to corgize [key_name_admin(H)]</span>", 1)
		H.corgize()

	else if(href_list["makePAI"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makePAI"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return
		if(alert(usr, "Confirm make pai?",, "Yes", "No") != "Yes")
			return

		var/painame = "Default"
		var/name = ""
		if(alert(usr, "Do you want to set their name or let them choose their own name?", "Name Choice", "Set Name", "Let them choose") == "Set Name")
			name = sanitize(copytext_char(input(usr, "Enter a name for the new pAI. Default name is [painame].", "pAI Name", painame),1,MAX_NAME_LEN))					// SS220 EDIT - ORIGINAL: copytext
		else
			name = sanitize(copytext_char(input(H, "An admin wants to make you into a pAI. Choose a name. Default is [painame].", "pAI Name", painame),1,MAX_NAME_LEN))	// SS220 EDIT - ORIGINAL: copytext

		if(!name)
			name = painame

		log_admin("[key_name(usr)] attempting to pAIze [key_name(H)]")
		message_admins("<span class='notice'>[key_name_admin(usr)] attempting to pAIze [key_name_admin(H)]</span>", 1)
		H.paize(name)

	else if(href_list["forcespeech"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		var/mob/M = locateUID(href_list["forcespeech"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)	return
		M.say(speech)
		speech = sanitize(speech) // Nah, we don't trust them
		log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
		message_admins("<span class='notice'>[key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]</span>")

	else if(href_list["sendtoprison"])
		if(!check_rights(R_ADMIN))	return

		if(alert(usr, "Send to admin prison for the round?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locateUID(href_list["sendtoprison"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		if(isAI(M))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>")
			return

		var/turf/prison_cell = pick(GLOB.prisonwarp)
		if(!prison_cell)	return

		var/obj/structure/closet/secure_closet/brig/locker = new /obj/structure/closet/secure_closet/brig(prison_cell)
		locker.opened = FALSE
		locker.locked = TRUE
		locker.update_icon()

		//strip their stuff and stick it in the crate
		for(var/obj/item/I in M)
			if(M.unEquip(I))
				I.loc = locker
				I.layer = initial(I.layer)
				I.plane = initial(I.plane)
				I.dropped(M)
		M.update_icons()

		//so they black out before warping
		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		if(!M)
			return

		M.loc = prison_cell
		if(ishuman(M))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), SLOT_HUD_JUMPSUIT)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), SLOT_HUD_SHOES)

		to_chat(M, "<span class='warning'>You have been sent to the prison station!</span>")
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("<span class='notice'>[key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.</span>", 1)

	else if(href_list["sendbacktolobby"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["sendbacktolobby"])

		if(!isobserver(M))
			to_chat(usr, "<span class='notice'>You can only send ghost players back to the Lobby.</span>")
			return

		if(!M.client)
			to_chat(usr, "<span class='warning'>[M] doesn't seem to have an active client.</span>")
			return

		if(alert(usr, "Send [key_name(M)] back to Lobby?", "Message", "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] has sent [key_name(M)] back to the Lobby.")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] back to the Lobby.")

		var/mob/new_player/NP = new()
		GLOB.non_respawnable_keys -= M.ckey
		NP.ckey = M.ckey
		qdel(M)

	else if(href_list["eraseflavortext"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["eraseflavortext"])

		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		if(!M.client)
			to_chat(usr, "<span class='warning'>[M] doesn't seem to have an active client.</span>")
			return

		if(M.flavor_text == "" && M.client.prefs.active_character.flavor_text == "")
			to_chat(usr, "<span class='warning'>[M] has no flavor text set.</span>")
			return

		if(alert(usr, "Erase [key_name(M)]'s flavor text?", "Message", "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] has erased [key_name(M)]'s flavor text.")
		message_admins("[key_name_admin(usr)] has erased [key_name_admin(M)]'s flavor text.")

		// Clears the mob's flavor text
		M.flavor_text = ""

		// Clear and save the DB character's flavor text
		M.client.prefs.active_character.flavor_text = ""
		M.client.prefs.active_character.save(M.client)

	else if(href_list["userandomname"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["userandomname"])

		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		if(!M.client)
			to_chat(usr, "<span class='warning'>[M] doesn't seem to have an active client.</span>")
			return

		if(alert(usr, "Force [key_name(M)] to use a random name?", "Message", "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] has forced [key_name(M)] to use a random name.")
		message_admins("[key_name_admin(usr)] has forced [key_name_admin(M)] to use a random name.")

		// Update the mob's name with a random one straight away
		var/random_name = random_name(M.client.prefs.active_character.gender, M.client.prefs.active_character.species)
		M.rename_character(M.real_name, random_name)

		// Save that random name for next rounds
		M.client.prefs.active_character.real_name = random_name
		M.client.prefs.active_character.save(M.client)

	else if(href_list["asays"])
		if(!check_rights(R_ADMIN))
			return

		usr.client.view_asays()

	else if(href_list["tdome1"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locateUID(href_list["tdome1"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		if(isAI(M))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>")
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.plane = initial(I.plane)
				I.dropped(M)

		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		M.loc = pick(GLOB.tdome1)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 1)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 1)", 1)

	else if(href_list["tdome2"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locateUID(href_list["tdome2"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		if(isAI(M))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>")
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.plane = initial(I.plane)
				I.dropped(M)

		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		M.loc = pick(GLOB.tdome2)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 2)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 2)", 1)

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locateUID(href_list["tdomeadmin"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		if(isAI(M))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>")
			return

		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		M.loc = pick(GLOB.tdomeadmin)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Admin.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Admin.)", 1)

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locateUID(href_list["tdomeobserve"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		if(isAI(M))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>")
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.plane = initial(I.plane)
				I.dropped(M)

		if(ishuman(M))
			var/mob/living/carbon/human/observer = M
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit(observer), SLOT_HUD_JUMPSUIT)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(observer), SLOT_HUD_SHOES)
		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		M.loc = pick(GLOB.tdomeobserve)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Observer.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Observer.)", 1)

	else if(href_list["contractor_stop"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		var/mob/M = locateUID(href_list["contractor_stop"])
		if(!istype(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob.</span>")
			return

		var/datum/syndicate_contract/contract = LAZYACCESS(GLOB.prisoner_belongings.prisoners, M)
		if(!contract)
			to_chat(usr, "<span class='warning'>[M] is currently not imprisoned by the Syndicate.</span>")
			return
		if(!contract.prisoner_timer_handle)
			to_chat(usr, "<span class='warning'>[M] is already NOT scheduled to return from the Syndicate Jail.</span>")
			return

		deltimer(contract.prisoner_timer_handle)
		contract.prisoner_timer_handle = null
		to_chat(usr, "Stopped automatic return of [M] from the Syndicate Jail.")
		message_admins("[key_name_admin(usr)] has stopped the automatic return of [key_name_admin(M)] from the Syndicate Jail")
		log_admin("[key_name(usr)] has stopped the automatic return of [key_name(M)] from the Syndicate Jail")

	else if(href_list["contractor_start"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		var/mob/M = locateUID(href_list["contractor_start"])
		if(!istype(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob.</span>")
			return

		var/datum/syndicate_contract/contract = LAZYACCESS(GLOB.prisoner_belongings.prisoners, M)
		if(!contract)
			to_chat(usr, "<span class='warning'>[M] is currently not imprisoned by the Syndicate.</span>")
			return
		if(contract.prisoner_timer_handle)
			to_chat(usr, "<span class='warning'>[M] is already scheduled to return from the Syndicate Jail.</span>")
			return

		var/time_seconds = input(usr, "Enter the jail time in seconds:", "Start Syndicate Jail Timer") as num|null
		time_seconds = text2num(time_seconds)
		if(time_seconds < 0)
			return

		contract.prisoner_timer_handle = addtimer(CALLBACK(contract, TYPE_PROC_REF(/datum/syndicate_contract, handle_target_return), M), time_seconds * 10, TIMER_STOPPABLE)
		to_chat(usr, "Started automatic return of [M] from the Syndicate Jail in [time_seconds] second\s.")
		message_admins("[key_name_admin(usr)] has started the automatic return of [key_name_admin(M)] from the Syndicate Jail in [time_seconds] second\s")
		log_admin("[key_name(usr)] has started the automatic return of [key_name(M)] from the Syndicate Jail in [time_seconds] second\s")

	else if(href_list["contractor_release"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		var/mob/M = locateUID(href_list["contractor_release"])
		if(!istype(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob.</span>")
			return

		var/datum/syndicate_contract/contract = LAZYACCESS(GLOB.prisoner_belongings.prisoners, M)
		if(!contract)
			to_chat(usr, "<span class='warning'>[M] is currently not imprisoned by the Syndicate.</span>")
			return

		deltimer(contract.prisoner_timer_handle)
		contract.handle_target_return(M)
		to_chat(usr, "Immediately returned [M] from the Syndicate Jail.")
		message_admins("[key_name_admin(usr)] has immediately returned [key_name_admin(M)] from the Syndicate Jail")
		log_admin("[key_name(usr)] has immediately returned [key_name(M)] from the Syndicate Jail")


	else if(href_list["aroomwarp"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locateUID(href_list["aroomwarp"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		if(isAI(M))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/living/silicon/ai</span>")
			return

		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)
		M.loc = pick(GLOB.aroomwarp)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the <b>Admin Room!</b>.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the Admin Room")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the Admin Room", 1)


	else if(href_list["revive"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/living/L = locateUID(href_list["revive"])
		if(!istype(L))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living</span>")
			return

		L.revive()
		message_admins("<span class='warning'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)]!</span>", 1)
		log_admin("[key_name(usr)] healed / revived [key_name(L)]")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return

		if(alert(usr, "Confirm make ai?",, "Yes", "No") != "Yes")
			return

		message_admins("<span class='warning'>Admin [key_name_admin(usr)] AIized [key_name_admin(H)]!</span>", 1)
		log_admin("[key_name(usr)] AIized [key_name(H)]")
		var/mob/living/silicon/ai/ai_character = H.AIize()
		ai_character.moveToAILandmark()

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return
		if(alert(usr, "Confirm make alien?",, "Yes", "No") != "Yes")
			return

		usr.client.cmd_admin_alienize(H)

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return
		if(alert(usr, "Confirm make slime?",, "Yes", "No") != "Yes")
			return

		usr.client.cmd_admin_slimeize(H)

	else if(href_list["makesuper"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makesuper"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return

		if(alert(usr, "Confirm make superhero?",, "Yes", "No") != "Yes")
			return

		usr.client.cmd_admin_super(H)

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return
		if(alert(usr, "Confirm make robot?",, "Yes", "No") != "Yes")
			return

		usr.client.cmd_admin_robotize(H)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locateUID(href_list["makeanimal"])
		if(isnewplayer(M))
			to_chat(usr, "<span class='warning'>This cannot be used on instances of type /mob/new_player</span>")
			return
		if(alert(usr, "Confirm make animal?",, "Yes", "No") != "Yes")
			return

		usr.client.cmd_admin_animalize(M)

	else if(href_list["incarn_ghost"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/dead/observer/G = locateUID(href_list["incarn_ghost"])
		if(!istype(G))
			to_chat(usr, "<span class='warning'>This will only work on /mob/dead/observer</span>")
			return

		var/posttransformoutfit = usr.client.robust_dress_shop()

		if(!posttransformoutfit)
			return

		var/mob/living/carbon/human/H = G.incarnate_ghost()

		if(posttransformoutfit && istype(H))
			H.equipOutfit(posttransformoutfit)

		log_admin("[key_name(G)] was incarnated by [key_name(owner)]")
		message_admins("[key_name_admin(G)] was incarnated by [key_name_admin(owner)]")

	else if(href_list["togmutate"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["togmutate"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return
		var/block=text2num(href_list["block"])
		//testing("togmutate([href_list["block"]] -> [block])")
		usr.client.cmd_admin_toggle_block(H,block)
		show_player_panel(H)
		//H.regenerate_icons()

	else if(href_list["adminplayeropts"])
		var/mob/M = locateUID(href_list["adminplayeropts"])

		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		show_player_panel(M)

	else if(href_list["adminplayerobservefollow"])
		var/client/C = usr.client
		if(!isobserver(usr))
			if(!check_rights(R_ADMIN|R_MOD)) // Need to be mod or admin to aghost
				return
			C.admin_ghost()
		var/mob/M = locateUID(href_list["adminplayerobservefollow"])

		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		var/mob/dead/observer/A = C.mob
		sleep(2)
		A.ManualFollow(M)

	else if(href_list["check_antagonist"])
		check_antagonists()

	else if(href_list["check_teams"])
		if(!check_rights(R_ADMIN))
			return
		check_teams()

	else if(href_list["team_command"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/team/team
		if(href_list["team_command"] == "new_custom_team") // this needs to be handled before all the other stuff, as the team doesn't exist yet
			message_admins("[key_name_admin(usr)] created a new custom team.")
			log_admin("[key_name(usr)] created a new custom team.")
			team = new()
			team.admin_rename_team(usr)
			check_teams()
			return

		var/datum/mind/member
		if(href_list["team"])
			team = locateUID(href_list["team"])
			if(QDELETED(team))
				to_chat(usr, "<span class='warning'>This team doesn't exist anymore!</span>")
				return
		if(href_list["member"])
			member = locateUID(href_list["member"])
			if(QDELETED(member))
				to_chat(usr, "<span class='warning'>This team member doesn't exist anymore!</span>")
				return
		switch(href_list["team_command"])
			if("communicate")
				team.admin_communicate(usr)
			if("delete_team")
				message_admins("[key_name_admin(usr)] has deleted the '[team.name]' team.")
				log_admin("[key_name_admin(usr)] has deleted the '[team.name]' team.")
				qdel(team)
			if("rename_team")
				team.admin_rename_team(usr)
			if("admin_add_member")
				team.admin_add_member(usr)
			if("remove_member")
				team.admin_remove_member(usr, member)
			if("view_member")
				show_player_panel(member.current)
			if("add_objective")
				team.admin_add_objective(usr)
			if("announce_objectives")
				team.admin_announce_objectives(usr)
			if("remove_objective")
				var/datum/objective/O = locateUID(href_list["objective"])
				if(O)
					team.admin_remove_objective(usr, O)
		check_teams()

	else if(href_list["take_question"])
		var/index = text2num(href_list["take_question"])

		if(href_list["is_mhelp"])
			SSmentor_tickets.takeTicket(index)
		else //Ahelp
			SStickets.takeTicket(index)

	else if(href_list["resolve"])
		var/index = text2num(href_list["resolve"])
		if(href_list["is_mhelp"])
			SSmentor_tickets.resolveTicket(index)
		else //Ahelp
			SStickets.resolveTicket(index)

	else if(href_list["autorespond"])
		if(href_list["is_mhelp"])
			to_chat(usr, "<span class='warning'>Auto responses are not available for mentor helps.</span>")
			return
		var/index = text2num(href_list["autorespond"])
		if(!check_rights(R_ADMIN|R_MOD))
			return
		SStickets.autoRespond(index)

	if(href_list["convert_ticket"])
		var/indexNum = text2num(href_list["convert_ticket"])
		if(href_list["is_mhelp"])
			SSmentor_tickets.convert_to_other_ticket(indexNum)
		else
			SStickets.convert_to_other_ticket(indexNum)

	else if(href_list["cult_mindspeak"])
		var/input = stripped_input(usr, "Communicate to all the cultists with the voice of [SSticker.cultdat.entity_name]", "Voice of [SSticker.cultdat.entity_name]")
		if(!input)
			return

		for(var/datum/mind/H in SSticker.mode.cult)
			if(H.current)
				to_chat(H.current, "<span class='cult'>[SSticker.cultdat.entity_name] murmurs,</span> <span class='cultlarge'>\"[input]\"</span>")

		for(var/mob/dead/observer/O in GLOB.player_list)
			to_chat(O, "<span class='cult'>[SSticker.cultdat.entity_name] murmurs,</span> <span class='cultlarge'>\"[input]\"</span>")

		message_admins("Admin [key_name_admin(usr)] has talked with the Voice of [SSticker.cultdat.entity_name].")
		log_admin("[key_name(usr)] Voice of [SSticker.cultdat.entity_name]: [input]")

	else if(href_list["cult_adjustsacnumber"])
		var/amount = input("Adjust the amount of sacrifices required before summoning Nar'Sie", "Sacrifice Adjustment", 2) as null | num
		if(amount > 0)
			var/datum/game_mode/gamemode = SSticker.mode
			var/old = gamemode.cult_objs.sacrifices_required
			gamemode.cult_objs.sacrifices_required = amount
			message_admins("Admin [key_name_admin(usr)] has modified the amount of cult sacrifices required before summoning from [old] to [amount]")
			log_admin("Admin [key_name_admin(usr)] has modified the amount of cult sacrifices required before summoning from [old] to [amount]")

	else if(href_list["cult_newtarget"])
		if(alert(usr, "Reroll the cult's sacrifice target?", "Cult Debug", "Yes", "No") != "Yes")
			return

		var/datum/game_mode/gamemode = SSticker.mode
		if(!gamemode.cult_objs.find_new_sacrifice_target())
			gamemode.cult_objs.ready_to_summon()

		message_admins("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")
		log_admin("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")

	else if(href_list["cult_newsummonlocations"])
		if(alert(usr, "Reroll the cult's summoning locations?", "Cult Debug", "Yes", "No") != "Yes")
			return

		var/datum/game_mode/gamemode = SSticker.mode
		gamemode.cult_objs.obj_summon.find_summon_locations(TRUE)
		if(gamemode.cult_objs.cult_status == NARSIE_NEEDS_SUMMONING) //Only update cultists if they are already have the summon goal since they arent aware of summon spots till then
			for(var/datum/mind/cult_mind in gamemode.cult)
				if(cult_mind && cult_mind.current)
					to_chat(cult_mind.current, "<span class='cult'>The veil has shifted! Our summoning will need to take place elsewhere.</span>")
					to_chat(cult_mind.current, "<span class='cult'>Current goal : [gamemode.cult_objs.obj_summon.explanation_text]</span>")

		message_admins("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")
		log_admin("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")

	else if(href_list["cult_unlocknarsie"])
		if(alert(usr, "Unlock the ability to summon Nar'Sie?", "Cult Debug", "Yes", "No") != "Yes")
			return

		var/datum/game_mode/gamemode = SSticker.mode
		gamemode.cult_objs.ready_to_summon()
		message_admins("Admin [key_name_admin(usr)] has unlocked the Cult's ability to summon Nar'Sie.")
		log_admin("Admin [key_name_admin(usr)] has unlocked the Cult's ability to summon Nar'Sie.")

	else if(href_list["adminplayerobservecoodjump"])
		var/client/C = usr.client
		if(!isobserver(usr))
			if(!check_rights(R_ADMIN)) // Need to be admin to aghost
				return
			C.admin_ghost()

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["adminchecklaws"])
		output_ai_laws()

	else if(href_list["adminmoreinfo"])
		var/mob/M = locateUID(href_list["adminmoreinfo"])

		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		admin_mob_info(M)

	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/living/carbon/human/H = locateUID(href_list["adminspawncookie"])
		if(!ishuman(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return

		H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), SLOT_HUD_LEFT_HAND )
		if(!(istype(H.l_hand,/obj/item/reagent_containers/food/snacks/cookie)))
			H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), SLOT_HUD_RIGHT_HAND )
			if(!(istype(H.r_hand,/obj/item/reagent_containers/food/snacks/cookie)))
				log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				message_admins("[key_name_admin(H)] has [H.p_their()] hands full, so [H.p_they()] did not receive [H.p_their()] cookie, spawned by [key_name_admin(src.owner)].")
				return
			else
				H.update_inv_r_hand()//To ensure the icon appears in the HUD
		else
			H.update_inv_l_hand()
		log_admin("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
		message_admins("[key_name_admin(H)] got [H.p_their()] cookie, spawned by [key_name_admin(src.owner)]")
		SSblackbox.record_feedback("amount", "admin_cookies_spawned", 1)
		to_chat(H, "<span class='notice'>Your prayers have been answered!! You received the <b>best cookie</b>!</span>")

	else if(href_list["BlueSpaceArtillery"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/living/M = locateUID(href_list["BlueSpaceArtillery"])
		if(!isliving(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living</span>")
			return

		if(alert(owner, "Are you sure you wish to hit [key_name(M)] with Bluespace Artillery?",  "Confirm Firing?" , "Yes" , "No") != "Yes")
			return

		if(GLOB.BSACooldown)
			to_chat(owner, "Standby. Reload cycle in progress. Gunnery crews ready in five seconds!")
			return

		GLOB.BSACooldown = 1
		spawn(50)
			GLOB.BSACooldown = 0

		to_chat(M, "You've been hit by bluespace artillery!")
		log_admin("[key_name(M)] has been hit by Bluespace Artillery fired by [key_name(owner)]")
		message_admins("[key_name_admin(M)] has been hit by Bluespace Artillery fired by [key_name_admin(owner)]")

		var/turf/simulated/floor/T = get_turf(M)
		if(istype(T))
			if(prob(80))
				T.break_tile_to_plating()
			else
				T.break_tile()

		if(M.health <= 1)
			M.gib()
		else
			M.adjustBruteLoss(min(99,(M.health - 1)))
			M.Weaken(40 SECONDS)
			M.Stuttering(40 SECONDS)

	else if(href_list["CentcommReply"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["CentcommReply"])

		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		usr.client.admin_headset_message(M, "Centcomm")

	else if(href_list["SyndicateReply"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["SyndicateReply"])

		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		usr.client.admin_headset_message(M, "Syndicate")

	else if(href_list["HeadsetMessage"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["HeadsetMessage"])

		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return

		usr.client.admin_headset_message(M)

	else if(href_list["EvilFax"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/living/carbon/human/H = locateUID(href_list["EvilFax"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return
		var/etypes = list("Borgification", "Corgification", "Death By Fire", "Total Brain Death", "Honk Tumor", "Cluwne", "Demote", "Demote with Bot", "Revoke Fax Access", "Angry Fax Machine")
		var/eviltype = input(src.owner, "Which type of evil fax do you wish to send [H]?","Its good to be baaaad...", "") as null|anything in etypes
		if(!(eviltype in etypes))
			return
		var/customname = clean_input("Pick a title for the evil fax.", "Fax Title", , owner)
		if(!customname)
			customname = "paper"
		var/obj/item/paper/evilfax/P = new /obj/item/paper/evilfax(null)
		var/obj/machinery/photocopier/faxmachine/fax = locate(href_list["originfax"])

		P.name = "Central Command - [customname]"
		P.info = "<b>You <i>really</i> should've known better.</b>"
		P.myeffect = eviltype
		P.mytarget = H
		if(alert("Do you want the Evil Fax to activate automatically if [H] tries to ignore it?",,"Yes", "No") == "Yes")
			P.activate_on_timeout = TRUE
		P.x = rand(-2, 0)
		P.y = rand(-1, 2)
		P.offset_x += P.x
		P.offset_y += P.y
		P.update_icon()
		var/stampvalue = "cent"
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.icon_state = "paper_stamp-[stampvalue]"
		stampoverlay.pixel_x = P.x
		stampoverlay.pixel_y = P.y
		P.stamped = list()
		P.stamped += /obj/item/stamp/centcom
		if(!P.ico)
			P.ico = new
		P.ico += "paper_stamp-[stampvalue]"
		P.stamp_overlays += stampoverlay
		P.stamps += "<hr><img src='large_stamp-[stampvalue].png'>"
		P.update_icon()
		P.faxmachineid = fax.UID()
		P.loc = fax.loc // Do not use fax.receivefax(P) here, as it won't preserve the type. Physically teleporting the fax paper is required.
		if(istype(H) && H.stat == CONSCIOUS && (istype(H.l_ear, /obj/item/radio/headset) || istype(H.r_ear, /obj/item/radio/headset)))
			to_chat(H, "<span class='specialnoticebold'>Your headset pings, notifying you that a reply to your fax has arrived.</span>")
		to_chat(src.owner, "You sent a [eviltype] fax to [H]")
		log_admin("[key_name(src.owner)] sent [key_name(H)] a [eviltype] fax")
		message_admins("[key_name_admin(src.owner)] replied to [key_name_admin(H)] with a [eviltype] fax")
	else if(href_list["Bless"])
		if(!check_rights(R_EVENT))
			return
		var/mob/living/M = locateUID(href_list["Bless"])
		if(!istype(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living</span>")
			return
		var/btypes = list("To Arrivals", "Moderate Heal")
		var/mob/living/carbon/human/H
		if(ishuman(M))
			H = M
			btypes += "Heal Over Time"
			btypes += "Permanent Regeneration"
			btypes += "Super Powers"
			btypes += "Scarab Guardian"
			btypes += "Human Protector"
			btypes += "Sentient Pet"
			btypes += "All Access"
		var/blessing = input(owner, "How would you like to bless [M]?", "Its good to be good...", "") as null|anything in btypes
		if(!(blessing in btypes))
			return
		var/logmsg = null
		switch(blessing)
			if("To Arrivals")
				M.forceMove(pick(GLOB.latejoin))
				to_chat(M, "<span class='userdanger'>You are abruptly pulled through space!</span>")
				logmsg = "a teleport to arrivals."
			if("Moderate Heal")
				M.adjustBruteLoss(-25)
				M.adjustFireLoss(-25)
				M.adjustToxLoss(-25)
				M.adjustOxyLoss(-25)
				to_chat(M,"<span class='userdanger'>You feel invigorated!</span>")
				logmsg = "a moderate heal."
			if("Heal Over Time")
				H.reagents.add_reagent("salglu_solution", 30)
				H.reagents.add_reagent("salbutamol", 20)
				H.reagents.add_reagent("spaceacillin", 20)
				logmsg = "a heal over time."
			if("Permanent Regeneration")
				H.dna.SetSEState(GLOB.regenerateblock, 1)
				singlemutcheck(H, GLOB.regenerateblock, MUTCHK_FORCED)
				H.update_mutations()
				H.gene_stability = 100
				logmsg = "permanent regeneration."
			if("Super Powers")
				var/list/default_mutations = list(GLOB.regenerateblock, GLOB.breathlessblock, GLOB.coldblock)
				for(var/mutation in default_mutations)
					H.dna.SetSEState(mutation, 1)
					singlemutcheck(H, mutation, MUTCHK_FORCED)
					H.update_mutations()
				H.gene_stability = 100
				logmsg = "superpowers."
			if("Scarab Guardian")
				var/obj/item/guardiancreator/biological/scarab = new /obj/item/guardiancreator/biological(H)
				var/list/possible_guardians = list("Chaos", "Standard", "Ranged", "Support", "Explosive", "Random")
				var/typechoice = input("Select Guardian Type", "Type") as null|anything in possible_guardians
				if(isnull(typechoice))
					return
				if(typechoice != "Random")
					possible_guardians -= "Random"
					scarab.possible_guardians = list()
					scarab.possible_guardians += typechoice
				scarab.attack_self(H)
				spawn(700)
					qdel(scarab)
				logmsg = "scarab guardian."
			if("Sentient Pet")
				var/pets = subtypesof(/mob/living/simple_animal)
				var/petchoice = input("Select pet type", "Pets") as null|anything in pets
				if(isnull(petchoice))
					return
				var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Play as the special event pet [H]?", poll_time = 20 SECONDS, min_hours = 10, source = petchoice)
				var/mob/dead/observer/theghost = null
				if(candidates.len)
					var/mob/living/simple_animal/pet/P = new petchoice(H.loc)
					theghost = pick(candidates)
					P.key = theghost.key
					dust_if_respawnable(theghost)
					P.master_commander = H
					P.universal_speak = TRUE
					P.universal_understand = TRUE
					P.can_collar = TRUE
					P.faction = list("neutral")
					var/obj/item/petcollar/C = new
					P.add_collar(C)
					var/obj/item/card/id/I = H.wear_id
					if(I)
						var/obj/item/card/id/D = new /obj/item/card/id(C)
						D.access = I.access
						D.registered_name = P.name
						D.assignment = "Pet"
						C.access_id = D
					spawn(30)
						var/newname = sanitize(copytext_char(input(P, "You are [P], special event pet of [H]. Change your name to something else?", "Name change", P.name) as null|text,1,MAX_NAME_LEN))	// SS220 EDIT - ORIGINAL: copytext
						if(newname && newname != P.name)
							P.name = newname
							if(P.mind)
								P.mind.name = newname
					logmsg = "pet ([P])."
				else
					to_chat(usr, "<span class='warning'>WARNING: Nobody volunteered to play the special event pet.</span>")
					logmsg = "pet (no volunteers)."
			if("Human Protector")
				usr.client.create_eventmob_for(H, 0)
				logmsg = "syndie protector."
			if("All Access")
				var/obj/item/card/id/I = H.wear_id
				if(I)
					var/list/access_to_give = get_all_accesses()
					for(var/this_access in access_to_give)
						if(!(this_access in I.access))
							// don't have it - add it
							I.access |= this_access
				else
					to_chat(usr, "<span class='warning'>ERROR: [H] is not wearing an ID card.</span>")
				logmsg = "all access."
		if(logmsg)
			log_admin("[key_name(owner)] answered [key_name(M)]'s prayer with a blessing: [logmsg]")
			message_admins("[key_name_admin(owner)] answered [key_name_admin(M)]'s prayer with a blessing: [logmsg]")
	else if(href_list["Smite"])
		if(!check_rights(R_EVENT))
			return
		var/mob/living/M = locateUID(href_list["Smite"])
		var/mob/living/carbon/human/H
		if(!istype(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living</span>")
			return
		var/ptypes = list("Lightning bolt", "Fire Death", "Gib", "Dust")
		if(ishuman(M))
			H = M
			ptypes += "Brain Damage"
			ptypes += "Honk Tumor"
			ptypes += "Hallucinate"
			ptypes += "Cold"
			ptypes += "Hunger"
			ptypes += "Cluwne"
			ptypes += "Mutagen Cookie"
			ptypes += "Hellwater Cookie"
			ptypes += "Hunter"
			ptypes += "Crew Traitor"
			ptypes += "Floor Cluwne"
			ptypes += "Shamebrero"
			ptypes += "Nugget"
			ptypes += "Bread"
		var/punishment = input(owner, "How would you like to smite [M]?", "Its good to be baaaad...", "") as null|anything in ptypes
		if(!(punishment in ptypes))
			return
		var/logmsg = null
		switch(punishment)
			// These smiting types are valid for all living mobs
			if("Lightning bolt")
				M.electrocute_act(5, "Lightning Bolt", flags = SHOCK_NOGLOVES)
				playsound(get_turf(M), 'sound/magic/lightningshock.ogg', 50, 1, -1)
				M.adjustFireLoss(75)
				M.Weaken(10 SECONDS)
				to_chat(M, "<span class='userdanger'>The gods have punished you for your sins!</span>")
				logmsg = "a lightning bolt."
			if("Fire Death")
				to_chat(M,"<span class='userdanger'>You feel hotter than usual. Maybe you should lowe-wait, is that your hand melting?</span>")
				var/turf/simulated/T = get_turf(M)
				new /obj/effect/hotspot(T)
				M.adjustFireLoss(150)
				logmsg = "a firey death."
			if("Gib")
				M.gib(FALSE)
				logmsg = "gibbed."
			if("Dust")
				M.dust()
				logmsg = "dust"

			// These smiting types are only valid for ishuman() mobs
			if("Brain Damage")
				H.adjustBrainLoss(75)
				logmsg = "75 brain damage."
			if("Honk Tumor")
				if(!H.get_int_organ(/obj/item/organ/internal/honktumor))
					var/obj/item/organ/internal/organ = new /obj/item/organ/internal/honktumor
					to_chat(H, "<span class='userdanger'>Life seems funnier, somehow.</span>")
					organ.insert(H)
				logmsg = "a honk tumor."
			if("Hallucinate")
				H.Hallucinate(1000 SECONDS)
				logmsg = "hallucinations."
			if("Cold")
				H.reagents.add_reagent("frostoil", 40)
				H.reagents.add_reagent("ice", 40)
				logmsg = "cold."
			if("Hunger")
				H.set_nutrition(NUTRITION_LEVEL_CURSED)
				logmsg = "starvation."
			if("Cluwne")
				H.makeCluwne()
				ADD_TRAIT(H, TRAIT_BADDNA, "smiting")
				logmsg = "cluwned."
			if("Mutagen Cookie")
				var/obj/item/reagent_containers/food/snacks/cookie/evilcookie = new /obj/item/reagent_containers/food/snacks/cookie
				evilcookie.reagents.add_reagent("mutagen", 10)
				evilcookie.desc = "It has a faint green glow."
				evilcookie.bitesize = 100
				evilcookie.flags = NODROP | DROPDEL
				H.drop_l_hand()
				H.equip_to_slot_or_del(evilcookie, SLOT_HUD_LEFT_HAND)
				logmsg = "a mutagen cookie."
			if("Hellwater Cookie")
				var/obj/item/reagent_containers/food/snacks/cookie/evilcookie = new /obj/item/reagent_containers/food/snacks/cookie
				evilcookie.reagents.add_reagent("hell_water", 25)
				evilcookie.desc = "Sulphur-flavored."
				evilcookie.bitesize = 100
				evilcookie.flags = NODROP | DROPDEL
				H.drop_l_hand()
				H.equip_to_slot_or_del(evilcookie, SLOT_HUD_LEFT_HAND)
				logmsg = "a hellwater cookie."
			if("Hunter")
				ADD_TRAIT(H, TRAIT_BADDNA, "smiting")
				usr.client.create_eventmob_for(H, 1)
				logmsg = "hunter."
			if("Crew Traitor")
				if(!H.mind)
					to_chat(usr, "<span class='warning'>ERROR: This mob ([H]) has no mind!</span>")
					return
				var/list/possible_traitors = list()
				for(var/mob/living/player in GLOB.alive_mob_list)
					if(player.client && player.mind && player.stat != DEAD && player != H)
						if(ishuman(player) && !player.mind.special_role)
							if(player.client && (ROLE_TRAITOR in player.client.prefs.be_special) && !jobban_isbanned(player, ROLE_TRAITOR) && !jobban_isbanned(player, "Syndicate"))
								possible_traitors += player.mind
				for(var/datum/mind/player in possible_traitors)
					if(player.current)
						if(ismindshielded(player.current))
							possible_traitors -= player
				if(possible_traitors.len)
					var/datum/mind/newtraitormind = pick(possible_traitors)

					var/datum/objective/assassinate/kill_objective = new()
					kill_objective.target = H.mind
					kill_objective.explanation_text = "Assassinate [H.mind.name], the [H.mind.assigned_role]"
					newtraitormind.add_mind_objective(kill_objective)

					var/datum/antagonist/traitor/T = new()
					T.give_objectives = FALSE
					to_chat(newtraitormind.current, "<span class='danger'>ATTENTION:</span> It is time to pay your debt to the Syndicate...")
					to_chat(newtraitormind.current, "<b>Goal: <span class='danger'>KILL [H.real_name]</span>, currently in [get_area(H.loc)]</b>")
					newtraitormind.add_antag_datum(T)
				else
					to_chat(usr, "<span class='warning'>ERROR: Unable to find any valid candidate to send after [H].</span>")
					return
				logmsg = "crew traitor."
			if("Floor Cluwne")
				var/turf/T = get_turf(M)
				var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(T)
				FC.smiting = TRUE
				FC.Acquire_Victim(M)
				logmsg = "floor cluwne"
			if("Shamebrero")
				if(H.head)
					H.unEquip(H.head, TRUE)
				var/obj/item/clothing/head/sombrero/shamebrero/S = new(H.loc)
				H.equip_to_slot_or_del(S, SLOT_HUD_HEAD)
				logmsg = "shamebrero"
			if("Nugget")
				H.Weaken(12 SECONDS, TRUE)
				H.AdjustJitter(40 SECONDS)
				to_chat(H, "<span class='danger'>You feel as if your limbs are being ripped from your body!</span>")
				addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, make_nugget)), 6 SECONDS)
				logmsg = "nugget"

			if("Bread")
				var/mob/living/simple_animal/shade/sword/bread/breadshade = new(H.loc)
				var/bready = pick(/obj/item/reagent_containers/food/snacks/customizable/cook/bread, /obj/item/reagent_containers/food/snacks/sliceable/meatbread, /obj/item/reagent_containers/food/snacks/sliceable/xenomeatbread, /obj/item/reagent_containers/food/snacks/sliceable/spidermeatbread, /obj/item/reagent_containers/food/snacks/sliceable/bananabread, /obj/item/reagent_containers/food/snacks/sliceable/tofubread, /obj/item/reagent_containers/food/snacks/sliceable/bread, /obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread, /obj/item/reagent_containers/food/snacks/sliceable/banarnarbread, /obj/item/reagent_containers/food/snacks/flatbread, /obj/item/reagent_containers/food/snacks/baguette)
				var/obj/item/bread = new bready(get_turf(H))
				breadshade.forceMove(bread)
				breadshade.key = H.key
				breadshade.RegisterSignal(bread, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/mob/living/simple_animal/shade/sword/bread, handle_bread_deletion))
				qdel(H)
				logmsg = "baked"
				to_chat(breadshade, "<span class='warning'>Get bready for combat, you've been baked into a piece of bread! Before you break down and rye thinking that your life is over, people are after you waiting for a snack! If you'd rather not be toast, lunge away from any hungry crew else you bite the crust. At the yeast you may survive a little longer...</span>")
		if(logmsg)
			log_admin("[key_name(owner)] smited [key_name(M)] with: [logmsg]")
			message_admins("[key_name_admin(owner)] smited [key_name_admin(M)] with: [logmsg]")
	else if(href_list["cryossd"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/living/M = locateUID(href_list["cryossd"])
		var/human = ishuman(M)
		if(!human && !issilicon(M))
			to_chat(usr, "<span class='warning'>This can only be used on humans and silicons.</span>")
			return
		if(!href_list["cryoafk"] && !isLivingSSD(M))
			to_chat(usr, "<span class='warning'>This can only be used on living, SSD players.</span>")
			return
		if(isAI(M))
			var/mob/living/silicon/ai/A = M
			A.cryo_AI()
		if(istype(M.loc, /obj/machinery/cryopod))
			var/obj/machinery/cryopod/P = M.loc
			P.despawn_occupant()
			if(human)
				var/mob/living/carbon/human/H = M
				log_admin("[key_name(usr)] despawned [H.job] [H] in cryo.")
				message_admins("[key_name_admin(usr)] despawned [H.job] [H] in cryo.")
			else //robot
				log_admin("[key_name(usr)] despawned [M] in cryo.")
				message_admins("[key_name_admin(usr)] despawned [M] in cryo.")
		else
			var/area/mob_area = get_area(M)
			var/should_despawn = FALSE
			if(mob_area.fast_despawn)
				if(alert(owner, "[M] is an area where players being AFK cryo'd should be despawned immediately. \
						Do you wish to immediately de-spawn them, or just continue moving them to the cryopod?", "Cryo or De-Spawn", "De-Spawn", "Move to Cryopod") == "De-Spawn")
					should_despawn = TRUE
			if(!cryo_ssd(M))
				return

			if(human)
				var/mob/living/carbon/human/H = M
				var/msg = "[key_name(usr)] [should_despawn ? "despawned" : "sent"] [H.job] [H] [should_despawn ? "in" : "to"] cryo."
				log_admin(msg)
				message_admins(msg)
			else
				var/msg = "[key_name(usr)] [should_despawn ? "despawned" : "sent"] [M] [should_despawn ? "in" : "to"] cryo."
				log_admin(msg)
				message_admins(msg)

			if(should_despawn)
				var/obj/machinery/cryopod/P = M.loc // They've already been placed in the cryopod because of `cryo_ssd(M)` above.
				P.despawn_occupant()
				return

			if(href_list["cryoafk"]) // Warn them if they are send to storage and are AFK
				to_chat(M, "<span class='danger'>The admins have moved you to cryo storage for being AFK. Please eject yourself (right click, eject) out of the cryostorage if you want to avoid being despawned.</span>")
				SEND_SOUND(M, sound('sound/effects/adminhelp.ogg'))
				if(M.client)
					window_flash(M.client)

	else if(href_list["FaxReplyTemplate"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/living/carbon/human/H = locateUID(href_list["FaxReplyTemplate"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return
		var/obj/item/paper/P = new /obj/item/paper(null)
		var/obj/machinery/photocopier/faxmachine/fax = locate(href_list["originfax"])
		P.name = "Central Command - paper"
		var/stypes = list("Handle it yourselves!","Illegible fax","Fax not signed","Not Right Now","You are wasting our time", "Keep up the good work", "ERT Instructions")
		var/stype = input(src.owner, "Which type of standard reply do you wish to send to [H]?","Choose your paperwork", "") as null|anything in stypes
		var/tmsg = "<font face='Verdana' color='black'><center><img src = 'ntlogo.png'><br><br><br><font size='4'><b>[SSmapping.map_datum.fluff_name]</b></font><br><br><br><font size='4'>NAS Trurl Communications Department Report</font></center><br><br>"
		if(stype == "Handle it yourselves!")
			tmsg += "Greetings, esteemed crewmember. Your fax has been <b><i>DECLINED</i></b> automatically by NAS Trurl Fax Registration.<br><br>Please proceed in accordance with Standard Operating Procedure and/or Space Law. You are fully trained to handle this situation without Central Command intervention.<br><br><i><small>This is an automatic message.</small>"
		else if(stype == "Illegible fax")
			tmsg += "Greetings, esteemed crewmember. Your fax has been <b><i>DECLINED</i></b> automatically by NAS Trurl Fax Registration.<br><br>Your fax's grammar, syntax and/or typography are of a sub-par level and do not allow us to understand the contents of the message.<br><br>Please consult your nearest dictionary and/or thesaurus and try again.<br><br><i><small>This is an automatic message.</small>"
		else if(stype == "Fax not signed")
			tmsg += "Greetings, esteemed crewmember. Your fax has been <b><i>DECLINED</i></b> automatically by NAS Trurl Fax Registration.<br><br>Your fax has not been correctly signed and, as such, we cannot verify your identity.<br><br>Please sign your faxes before sending them so that we may verify your identity.<br><br><i><small>This is an automatic message.</small>"
		else if(stype == "Not Right Now")
			tmsg += "Greetings, esteemed crewmember. Your fax has been <b><i>DECLINED</i></b> automatically by NAS Trurl Fax Registration.<br><br>Due to pressing concerns of a matter above your current paygrade, we are unable to provide assistance in whatever matter your fax referenced.<br><br>This can be either due to a power outage, bureaucratic audit, pest infestation, Ascendance Event, corgi outbreak, or any other situation that would affect the proper functioning of the NAS Trurl.<br><br>Please try again later.<br><br><i><small>This is an automatic message.</small>"
		else if(stype == "You are wasting our time")
			tmsg += "Greetings, esteemed crewmember. Your fax has been <b><i>DECLINED</i></b> automatically by NAS Trurl Fax Registration.<br><br>In the interest of preventing further mismanagement of company resources, please avoid wasting our time with such petty drivel.<br><br>Do kindly remember that we expect our workforce to maintain at least a semi-decent level of professionalism. Do not test our patience.<br><br><i><small>This is an automatic message.</i></small>"
		else if(stype == "Keep up the good work")
			tmsg += "Greetings, esteemed crewmember. Your fax has been received successfully by NAS Trurl Fax Registration.<br><br>We at the NAS Trurl appreciate the good work that you have done here, and sincerely recommend that you continue such a display of dedication to the company.<br><br><i><small>This is absolutely not an automated message.</i></small>"
		else if(stype == "ERT Instructions")
			tmsg += "Greetings, esteemed crewmember. Your fax has been <b><i>DECLINED</i></b> automatically by NAS Trurl Fax Registration.<br><br>Please utilize the Card Swipers if you wish to call for an ERT.<br><br><i><small>This is an automated message.</i></small>"
		else
			return
		tmsg += "</font>"
		P.info = tmsg
		P.x = rand(-2, 0)
		P.y = rand(-1, 2)
		P.offset_x += P.x
		P.offset_y += P.y
		P.update_icon()
		var/stampvalue = "cent"
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.icon_state = "paper_stamp-[stampvalue]"
		stampoverlay.pixel_x = P.x
		stampoverlay.pixel_y = P.y
		P.stamped = list()
		P.stamped += /obj/item/stamp/centcom
		if(!P.ico)
			P.ico = new
		P.ico += "paper_stamp-[stampvalue]"
		P.stamp_overlays += stampoverlay
		P.stamps += "<hr><img src='large_stamp-[stampvalue].png'>"
		P.update_icon()
		fax.receivefax(P)
		if(istype(H) && H.stat == CONSCIOUS && (istype(H.l_ear, /obj/item/radio/headset) || istype(H.r_ear, /obj/item/radio/headset)))
			to_chat(H, "<span class='specialnoticebold'>Your headset pings, notifying you that a reply to your fax has arrived.</span>")
		to_chat(src.owner, "You sent a standard '[stype]' fax to [H]")
		log_admin("[key_name(src.owner)] sent [key_name(H)] a standard '[stype]' fax")
		message_admins("[key_name_admin(src.owner)] replied to [key_name_admin(H)] with a standard '[stype]' fax")

	else if(href_list["HONKReply"])
		var/mob/living/carbon/human/H = locateUID(href_list["HONKReply"])
		if(!istype(H))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
			return
		if(!istype(H.l_ear, /obj/item/radio/headset) && !istype(H.r_ear, /obj/item/radio/headset))
			to_chat(usr, "<span class='warning'>The person you are trying to contact is not wearing a headset</span>")
			return

		var/input = input(src.owner, "Please enter a message to reply to [key_name(H)] via [H.p_their()] headset.","Outgoing message from HONKplanet", "")
		if(!input)	return

		to_chat(src.owner, "You sent [input] to [H] via a secure channel.")
		log_admin("[src.owner] replied to [key_name(H)]'s HONKplanet message with the message [input].")
		to_chat(H, "You hear something crackle in your headset for a moment before a voice speaks.  \"Please stand by for a message from your HONKbrothers.  Message as follows, HONK. [input].  Message ends, HONK.\"")

	else if(href_list["ErtReply"])
		if(!check_rights(R_ADMIN))
			return

		if(alert(owner, "Accept or Deny ERT request?", "CentComm Response", "Accept", "Deny") == "Deny")
			var/mob/living/carbon/human/H = locateUID(href_list["ErtReply"])
			if(!istype(H))
				to_chat(owner, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
				return

			var/reason = input(owner, "Please enter a reason for denying [key_name(H)]'s ERT request.", "Outgoing message from CentComm") as null|message
			if(!reason)
				return
			var/announce_to_crew = alert(owner, "Announce ERT request denial to crew or only to the sender [key_name(H)]?", "Send reason to who", "Crew", "Sender") == "Crew"
			GLOB.ert_request_answered = TRUE
			log_admin("[owner] denied [key_name(H)]'s ERT request with the message [reason]. Announced to [announce_to_crew ? "the entire crew." : "only the sender"].")

			if(announce_to_crew)
				GLOB.major_announcement.Announce("[station_name()], we are unfortunately unable to send you an Emergency Response Team at this time. Your ERT request has been denied for the following reasons:\n[reason]", "ERT Unavailable")
				return

			if(H.stat != CONSCIOUS)
				to_chat(owner, "<span class='warning'>The person you are trying to contact is not conscious. ERT denied but no message has been sent.</span>")
				return
			if(!istype(H.l_ear, /obj/item/radio/headset) && !istype(H.r_ear, /obj/item/radio/headset))
				to_chat(owner, "<span class='warning'>The person you are trying to contact is not wearing a headset. ERT denied but no message has been sent.</span>")
				return
			to_chat(owner, "<span class='notice'>You sent [reason] to [H] via a secure channel.</span>")
			to_chat(H, "<span class='specialnoticebold'>Incoming priority transmission from Central Command. Message as follows,</span><span class='specialnotice'> Your ERT request has been denied for the following reasons: [reason].</span>")
		else
			owner.response_team()


	else if(href_list["AdminFaxView"])
		if(!check_rights(R_ADMIN))
			return

		var/obj/item/fax = locate(href_list["AdminFaxView"])
		if(istype(fax, /obj/item/paper))
			var/obj/item/paper/P = fax
			P.show_content(usr,1)
		else if(istype(fax, /obj/item/photo))
			var/obj/item/photo/H = fax
			H.show(usr)
		else if(istype(fax, /obj/item/paper_bundle))
			//having multiple people turning pages on a paper_bundle can cause issues
			//open a browse window listing the contents instead
			var/data = ""
			var/obj/item/paper_bundle/B = fax

			for(var/page = 1, page <= B.amount + 1, page++)
				var/obj/pageobj = B.contents[page]
				data += "<A href='?src=[UID()];AdminFaxViewPage=[page];paper_bundle=\ref[B]'>Page [page] - [pageobj.name]</A><BR>"

			usr << browse(data, "window=PaperBundle[B.UID()]")
		else
			to_chat(usr, "<span class='warning'>The faxed item is not viewable. This is probably a bug, and should be reported on the tracker: [fax.type]</span>")

	else if(href_list["AdminFaxViewPage"])
		if(!check_rights(R_ADMIN))
			return

		var/page = text2num(href_list["AdminFaxViewPage"])
		var/obj/item/paper_bundle/bundle = locate(href_list["paper_bundle"])

		if(!bundle) return

		if(istype(bundle.contents[page], /obj/item/paper))
			var/obj/item/paper/P = bundle.contents[page]
			P.show_content(usr, 1)
		else if(istype(bundle.contents[page], /obj/item/photo))
			var/obj/item/photo/H = bundle.contents[page]
			H.show(usr)
		return

	else if(href_list["AdminFaxCreate"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/sender = locate(href_list["AdminFaxCreate"])
		var/obj/machinery/photocopier/faxmachine/fax = locate(href_list["originfax"])
		var/faxtype = href_list["faxtype"]
		var/reply_to = locate(href_list["replyto"])
		var/destination
		var/notify
		var/obj/item/paper/P

		if(sender)
			message_admins("[key_name_admin(owner)] has started replying to a fax message from [key_name_admin(sender)]")

		var/use_letterheard = alert("Use letterhead? If so, do not add your own header or a footer. Type and format only your actual message.",,"Nanotrasen","Syndicate", "No")
		switch(use_letterheard)
			if("Nanotrasen")
				P = new /obj/item/paper/central_command(null)
			if("Syndicate")
				P = new /obj/item/paper/syndicate(null)
			if("No")
				P = new /obj/item/paper(null)
		if(!fax)
			var/list/departmentoptions = GLOB.alldepartments + GLOB.hidden_departments + "All Departments"
			destination = input(usr, "To which department?", "Choose a department", "") as null|anything in departmentoptions
			if(!destination)
				qdel(P)
				return

			for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
				if(destination != "All Departments" && F.department == destination)
					fax = F


		var/input = input(src.owner, "Please enter a message to send a fax via secure connection. Use <br> for line breaks. Both pencode and HTML work.", "Outgoing message from Centcomm", "") as message|null
		if(!input)
			qdel(P)
			return
		input = admin_pencode_to_html(html_encode(input)) // Encode everything from pencode to html

		var/customname = clean_input("Pick a title for the fax.", "Fax Title", , owner)
		if(!customname)
			customname = "paper"

		var/stampname
		var/stamptype
		var/stampvalue
		var/sendername
		switch(faxtype)
			if("Central Command")
				stamptype = "icon"
				stampvalue = "cent"
				sendername = "NAS Trurl"
			if("Syndicate")
				stamptype = "icon"
				stampvalue = "syndicate"
				sendername = "UNKNOWN"
			if("Administrator")
				stamptype = input(src.owner, "Pick a stamp type.", "Stamp Type") as null|anything in list("icon","text","none")
				if(stamptype == "icon")
					stampname = input(src.owner, "Pick a stamp icon.", "Stamp Icon") as null|anything in list("centcom","syndicate","granted","denied","clown")
					switch(stampname)
						if("centcom")
							stampvalue = "cent"
						if("syndicate")
							stampvalue = "syndicate"
						if("granted")
							stampvalue = "ok"
						if("denied")
							stampvalue = "deny"
						if("clown")
							stampvalue = "clown"
				else if(stamptype == "text")
					stampvalue = clean_input("What should the stamp say?", "Stamp Text", , owner)
				else if(stamptype == "none")
					stamptype = ""
				else
					qdel(P)
					return

				sendername = clean_input("What organization does the fax come from? This determines the prefix of the paper (i.e. Central Command- Title). This is optional.", "Organization", , owner)

		if(sender)
			notify = alert(src.owner, "Would you like to inform the original sender that a fax has arrived?","Notify Sender","Yes","No")

		// Create the reply message
		if(sendername)
			P.name = "[sendername]- [customname]"
		else
			P.name = "[customname]"
		P.info = input
		P.update_icon()
		P.x = rand(-2, 0)
		P.y = rand(-1, 2)
		P.offset_x += P.x
		P.offset_y += P.y
		if(stamptype)
			var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
			stampoverlay.pixel_x = P.x
			stampoverlay.pixel_y = P.y

			if(!P.ico)
				P.ico = new
			P.ico += "paper_stamp-[stampvalue]"
			stampoverlay.icon_state = "paper_stamp-[stampvalue]"

			if(stamptype == "icon")
				if(!P.stamped)
					P.stamped = new
				P.stamped += /obj/item/stamp/centcom
				P.stamp_overlays += stampoverlay
				P.stamps += "<hr><img src='large_stamp-[stampvalue].png'>"

			else if(stamptype == "text")
				if(!P.stamped)
					P.stamped = new
				P.stamped += /obj/item/stamp
				P.stamp_overlays += stampoverlay
				P.stamps += "<hr><i>[stampvalue]</i>"

		if(destination != "All Departments")
			if(!fax.receivefax(P))
				to_chat(src.owner, "<span class='warning'>Message transmission failed.</span>")
				return
		else
			for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
				if(is_station_level(F.z))
					spawn(0)
						if(!F.receivefax(P))
							to_chat(src.owner, "<span class='warning'>Message transmission to [F.department] failed.</span>")

		var/datum/fax/admin/A = new /datum/fax/admin()
		A.name = P.name
		A.from_department = faxtype
		if(destination != "All Departments")
			A.to_department = fax.department
		else
			A.to_department = "All Departments"
		A.origin = "Administrator"
		A.message = P
		A.reply_to = reply_to
		A.sent_by = usr
		A.sent_at = world.time

		to_chat(src.owner, "<span class='notice'>Message transmitted successfully.</span>")
		if(notify == "Yes")
			var/mob/living/carbon/human/H = sender
			if(istype(H) && H.stat == CONSCIOUS && (istype(H.l_ear, /obj/item/radio/headset) || istype(H.r_ear, /obj/item/radio/headset)))
				to_chat(sender, "<span class='specialnoticebold'>Your headset pings, notifying you that a reply to your fax has arrived.</span>")
		if(sender)
			log_admin("[key_name(src.owner)] replied to a fax message from [key_name(sender)]: [input]")
			message_admins("[key_name_admin(src.owner)] replied to a fax message from [key_name_admin(sender)] (<a href='?_src_=holder;AdminFaxView=\ref[P]'>VIEW</a>).", 1)
		else
			log_admin("[key_name(src.owner)] sent a fax message to [destination]: [input]")
			message_admins("[key_name_admin(src.owner)] sent a fax message to [destination] (<a href='?_src_=holder;AdminFaxView=\ref[P]'>VIEW</a>).", 1)
		return

	else if(href_list["refreshfaxpanel"])
		if(!check_rights(R_ADMIN))
			return

		fax_panel(usr)

	else if(href_list["getplaytimewindow"])
		if(!check_rights(R_ADMIN | R_MOD | R_MENTOR))
			return
		var/mob/M = locateUID(href_list["getplaytimewindow"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		cmd_mentor_show_exp_panel(M.client)

	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locateUID(href_list["jumpto"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		usr.client.jumptomob(M)

	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")	return
		var/mob/M = locateUID(href_list["getmob"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		usr.client.Getmob(M)

	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locateUID(href_list["sendmob"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		usr.client.sendmob(M)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locateUID(href_list["narrateto"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		usr.client.cmd_admin_direct_narrate(M)

	else if(href_list["subtlemessage"])
		if(!check_rights(R_EVENT))
			return

		var/mob/M = locateUID(href_list["subtlemessage"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		usr.client.cmd_admin_subtle_message(M)

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN|R_MOD))	return

		if(!SSticker || !SSticker.mode)
			alert("The game hasn't started yet!")
			return

		var/mob/M = locateUID(href_list["traitor"])
		if(!ismob(M))
			to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		show_traitor_panel(M)

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))	return
		return create_object(usr)

	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))	return
		return quick_create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))	return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))	return
		return create_mob(usr)

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))	return

		var/atom/loc = usr.loc

		var/dirty_paths
		if(istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if(istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				continue
			paths += path

		if(!paths)
			alert("The path list you sent is empty")
			return
		if(length(paths) > 5)
			alert("Select fewer object types, (max 5)")
			return

		var/list/offset = splittext(href_list["offset"],",")
		var/number = dd_range(1, 100, text2num(href_list["object_count"]))
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/tmp_dir = href_list["object_dir"]
		var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
		if(!obj_dir || !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = 2
		var/obj_name = sanitize(href_list["object_name"])


		var/atom/target //Where the object will be spawned
		var/where = href_list["object_where"]
		if(!( where in list("onfloor","inhand","inmarked") ))
			where = "onfloor"


		switch(where)
			if("inhand")
				if(!iscarbon(usr) && !isrobot(usr))
					to_chat(usr, "<span class='warning'>Can only spawn in hand when you're a carbon mob or cyborg.</span>")
					where = "onfloor"
				target = usr

			if("onfloor")
				switch(href_list["offset_type"])
					if("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if("inmarked")
				if(!marked_datum)
					to_chat(usr, "<span class='warning'>You don't have any object marked. Abandoning spawn.</span>")
					return
				else if(!istype(marked_datum,/atom))
					to_chat(usr, "<span class='warning'>The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.</span>")
					return
				else
					target = marked_datum

		if(target)
			for(var/path in paths)
				for(var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N && obj_name)
							N.name = obj_name
					else
						var/atom/O = new path(target)
						if(O)
							O.admin_spawned = TRUE
							O.dir = obj_dir
							if(obj_name)
								O.name = obj_name
								if(ismob(O))
									var/mob/M = O
									M.real_name = obj_name
							if(where == "inhand" && isliving(usr) && isitem(O))
								var/mob/living/L = usr
								var/obj/item/I = O
								L.put_in_hands(I)
								if(isrobot(L))
									var/mob/living/silicon/robot/R = L
									if(R.module)
										R.module.modules += I
										I.loc = R.module
										R.module.rebuild_modules()
										R.activate_module(I)
										R.module.fix_modules()

		if(number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created a [english_list(paths)]")
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)]")
					break
		return

	else if(href_list["kick_all_from_lobby"])
		if(!check_rights(R_ADMIN))
			return
		if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
			var/afkonly = text2num(href_list["afkonly"])
			if(alert("Are you sure you want to kick all [afkonly ? "AFK" : ""] clients from the lobby?","Confirmation","Yes","Cancel") != "Yes")
				return
			var/list/listkicked = kick_clients_in_lobby("<span class='danger'>You were kicked from the lobby by an Administrator.</span>", afkonly)

			var/strkicked = ""
			for(var/name in listkicked)
				strkicked += "[name], "
			message_admins("[key_name_admin(usr)] has kicked [afkonly ? "all AFK" : "all"] clients from the lobby. [length(listkicked)] clients kicked: [strkicked ? strkicked : "--"]")
			log_admin("[key_name(usr)] has kicked [afkonly ? "all AFK" : "all"] clients from the lobby. [length(listkicked)] clients kicked: [strkicked ? strkicked : "--"]")
		else
			to_chat(usr, "<span class='warning'>You may only use this when the game is running.</span>")

	else if(href_list["memoeditlist"])
		if(!check_rights(R_SERVER)) return
		var/sql_key = href_list["memoeditlist"]
		var/datum/db_query/query_memoedits = SSdbcore.NewQuery("SELECT edits FROM memo WHERE (ckey=:sql_key)", list(
			"sql_key" = sql_key
		))
		if(!query_memoedits.warn_execute())
			qdel(query_memoedits)
			return
		if(query_memoedits.NextRow())
			var/edit_log = query_memoedits.item[1]
			usr << browse(edit_log,"window=memoeditlist")
		qdel(query_memoedits)

	else if(href_list["secretsfun"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		var/ok = 0
		switch(href_list["secretsfun"])
			if("sec_clothes")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Remove 'internal' clothing")
				for(var/obj/item/clothing/under/O in world)
					qdel(O)
				ok = 1
			if("sec_all_clothes")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Remove ALL clothing")
				for(var/obj/item/clothing/O in world)
					qdel(O)
				ok = 1
			if("sec_classic1")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Remove firesuits, grilles, and pods")
				for(var/obj/item/clothing/suit/fire/O in world)
					qdel(O)
				for(var/obj/structure/grille/O in world)
					qdel(O)
			if("monkey")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Monkeyize All Humans")
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					spawn(0)
						H.monkeyize()
				ok = 1
			if("corgi")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Corgize All Humans")
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					spawn(0)
						H.corgize()
				ok = 1
			if("deathsquad")
				if(usr.client.send_deathsquad())
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Team - Deathsquad")
			if("striketeam_syndicate")
				if(usr.client.syndicate_strike_team())
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Team - Syndie Strike Team")
			if("infiltrators_syndicate")
				if(usr.client.syndicate_infiltration_team())
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Team - Syndicate Infiltration Team")
			if("gimmickteam")
				if(usr.client.gimmick_team())
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Team - Gimmick Team")
			if("tripleAI")
				usr.client.triple_ai()
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Triple AI")
			if("gravity")
				if(!(SSticker && SSticker.mode))
					to_chat(usr, "<span class='warning'>Please wait until the game starts! Not sure how it will work otherwise.</span>")
					return
				GLOB.gravity_is_on = !GLOB.gravity_is_on
				for(var/area/A in world)
					A.gravitychange(GLOB.gravity_is_on,A)
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Gravity")
				if(GLOB.gravity_is_on)
					log_admin("[key_name(usr)] toggled gravity on.", 1)
					message_admins("<span class='notice'>[key_name_admin(usr)] toggled gravity on.</span>", 1)
					GLOB.minor_announcement.Announce("Gravity generators are again functioning within normal parameters. Sorry for any inconvenience.")
				else
					log_admin("[key_name(usr)] toggled gravity off.", 1)
					message_admins("<span class='notice'>[key_name_admin(usr)] toggled gravity off.</span>", 1)
					GLOB.minor_announcement.Announce("Feedback surge detected in mass-distributions systems. Artificial gravity has been disabled whilst the system reinitializes. Further failures may result in a gravitational collapse and formation of blackholes. Have a nice day.")

			if("power")
				switch(alert("What Would You Like to Do?", "Make All Areas Powered", "Power all APCs", "Repair all APCs", "Repair and Power APCs")) //Alert notification in this code for standarization purposes
					if("Power all APCs")
						power_restore(TRUE, 0)
						SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Power all APCs")
						log_and_message_admins("<span class='notice'>[key_name_admin(usr)] powered all APCs</span>", 1)
					if("Repair all APCs")
						power_restore(TRUE, 1)
						SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Repair all APCs")
						log_and_message_admins("<span class='notice'>[key_name_admin(usr)] repaired all APCs</span>", 1)
					if("Repair and Power APCs")
						power_restore(TRUE, 2)
						SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Repair and Power all APCs")
						log_and_message_admins("<span class='notice'>[key_name_admin(usr)] repaired and powered all APCs</span>", 1)
			if("unpower")
				if(alert("What Would You Like to Do?", "Make All Areas Unpowered", "Depower all APCs", "Short out APCs") == "Depower all APCs")
					depower_apcs()
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Depower all APCs")
					log_and_message_admins("<span class='notice'>[key_name_admin(usr)] made all areas unpowered</span>", 1)
				else
					power_failure()
					SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Short out APCs")
					log_and_message_admins("<span class='notice'>[key_name_admin(usr)] has shorted APCs</span>", 1)
			if("quickpower")
				power_restore_quick()
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Power All SMESs")
				log_and_message_admins("<span class='notice'>[key_name(usr)] made all SMESs powered</span>", 1)
			if("prisonwarp")
				if(!SSticker)
					alert("The game hasn't started yet!", null, null, null, null, null)
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Prison Warp")
				message_admins("<span class='notice'>[key_name_admin(usr)] teleported all players to the prison station.</span>", 1)
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					var/turf/loc = find_loc(H)
					var/security = 0
					if(!is_station_level(loc.z) || GLOB.prisonwarped.Find(H))

//don't warp them if they aren't ready or are already there
						continue
					H.Paralyse(10 SECONDS)
					if(H.wear_id)
						var/obj/item/card/id/id = H.get_idcard()
						for(var/A in id.access)
							if(A == ACCESS_SECURITY)
								security++
					if(!security)
						//strip their stuff before they teleport into a cell :downs:
						for(var/obj/item/W in H)
							H.unEquip(W)
							if(H.client)
								H.client.screen -= W
							if(W)
								W.loc = H.loc
								W.dropped(H)
								W.layer = initial(W.layer)
								W.plane = initial(W.plane)
						//teleport person to cell
						H.loc = pick(GLOB.prisonwarp)
						H.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(H), SLOT_HUD_JUMPSUIT)
						H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), SLOT_HUD_SHOES)
					else
						//teleport security person
						H.loc = pick(GLOB.prisonsecuritywarp)
					GLOB.prisonwarped += H
			if("traitor_all")
				if(!SSticker)
					alert("The game hasn't started yet!")
					return
				var/objective = sanitize(copytext_char(input("Enter an objective"),1,MAX_MESSAGE_LEN))	// SS220 EDIT - ORIGINAL: copytext
				if(!objective)
					return
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Traitor All ([objective])")

				for(var/mob/living/carbon/human/H in GLOB.player_list)
					if(H.stat == DEAD || !H.client || !H.mind)
						continue
					if(is_special_character(H))
						continue
					if(jobban_isbanned(H, ROLE_TRAITOR) || jobban_isbanned(H, ROLE_SYNDICATE))
						continue
					H.mind.add_antag_datum(/datum/antagonist/traitor)

				for(var/mob/living/silicon/A in GLOB.player_list)
					A.mind.add_antag_datum(/datum/antagonist/traitor)

				message_admins("<span class='notice'>[key_name_admin(usr)] used everyone is a traitor secret. Objective is [objective]</span>", 1)
				log_admin("[key_name(usr)] used everyone is a traitor secret. Objective is [objective]")

			if("togglebombcap")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Bomb Cap")

				var/newBombCap = input(usr,"What would you like the new bomb cap to be. (entered as the light damage range (the 3rd number in common (1,2,3) notation)) Must be between 4 and 128)", "New Bomb Cap", GLOB.configuration.general.bomb_cap) as num|null
				if(newBombCap < 4)
					return
				if(newBombCap > 128)
					newBombCap = 128

				GLOB.configuration.general.bomb_cap = newBombCap

				message_admins("<span class='boldannounce'>[key_name_admin(usr)] changed the bomb cap to [GLOB.configuration.general.bomb_cap / 4], [GLOB.configuration.general.bomb_cap / 2], [GLOB.configuration.general.bomb_cap]</span>")
				log_admin("[key_name(usr)] changed the bomb cap to [GLOB.configuration.general.bomb_cap / 4], [GLOB.configuration.general.bomb_cap / 2], [GLOB.configuration.general.bomb_cap]")

			if("flicklights")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Flicker Lights")
				while(!usr.stat)
					//knock yourself out to stop the ghosts
					for(var/mob/M in GLOB.player_list)
						if(M.stat != 2 && prob(25))
							var/area/AffectedArea = get_area(M)
							if(AffectedArea.name != "Space" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
								AffectedArea.powernet.set_power_channel(PW_CHANNEL_LIGHTING, FALSE)
								spawn(rand(55, 185))
									AffectedArea.powernet.set_power_channel(PW_CHANNEL_LIGHTING, TRUE)
								var/Message = rand(1,4)
								switch(Message)
									if(1)
										M.show_message(text("<span class='notice'>You shudder as if cold...</span>"), 1)
									if(2)
										M.show_message(text("<span class='notice'>You feel something gliding across your back...</span>"), 1)
									if(3)
										M.show_message(text("<span class='notice'>Your eyes twitch, you feel like something you can't see is here...</span>"), 1)
									if(4)
										M.show_message(text("<span class='notice'>You notice something moving out of the corner of your eye, but nothing is there...</span>"), 1)
								for(var/obj/W in orange(5,M))
									if(prob(25) && !W.anchored)
										step_rand(W)
					sleep(rand(100,1000))
				for(var/mob/M in GLOB.player_list)
					if(M.stat != 2)
						M.show_message(text("<span class='notice'>The chilling wind suddenly stops...</span>"), 1)
			if("lightout")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Lights Out")
				message_admins("[key_name_admin(usr)] has broke a lot of lights", 1)
				var/datum/event/electrical_storm/E = new /datum/event/electrical_storm
				E.lightsoutAmount = 2
			if("blackout")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Black Out")
				message_admins("[key_name_admin(usr)] broke all lights", 1)
				for(var/obj/machinery/light/L in GLOB.machines)
					L.break_light_tube()
			if("whiteout")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Fix All Lights")
				message_admins("[key_name_admin(usr)] fixed all lights", 1)
				for(var/obj/machinery/light/L in GLOB.machines)
					L.fix()
					L.switchcount = 0
			if("floorlava")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1,  "Lava Floor")
				var/sure = alert(usr, "Are you sure you want to do this?", "Confirmation", "Yes", "No")
				if(sure == "No")
					return
				SSweather.run_weather(/datum/weather/floor_is_lava)
				message_admins("[key_name_admin(usr)] made the floor lava")
			if("fakelava")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1,  "Lava Floor Fake")
				var/sure = alert(usr, "Are you sure you want to do this?", "Confirmation", "Yes", "No")
				if(sure == "No")
					return
				SSweather.run_weather(/datum/weather/floor_is_lava/fake)
				message_admins("[key_name_admin(usr)] made aesthetic lava on the floor")
			if("weatherashstorm")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1,  "Weather Ash Storm")
				var/sure = alert(usr, "Are you sure you want to do this?", "Confirmation", "Yes", "No")
				if(sure == "No")
					return
				SSweather.run_weather(/datum/weather/ash_storm)
				message_admins("[key_name_admin(usr)] spawned an ash storm on the mining level")
			if("stupify")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Mass Braindamage")
				for(var/mob/living/carbon/human/H in GLOB.player_list)
					to_chat(H, "<span class='danger'>You suddenly feel stupid.</span>")
					H.setBrainLoss(60)
				message_admins("[key_name_admin(usr)] made everybody stupid")
			if("fakeguns")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Fake Guns")
				for(var/obj/item/W in world)
					if(isclothing(W) || istype(W, /obj/item/card/id) || istype(W, /obj/item/disk) || istype(W, /obj/item/tank))
						continue
					W.icon = 'icons/obj/guns/projectile.dmi'
					W.icon_state = "revolver"
					W.item_state = "gun"
				message_admins("[key_name_admin(usr)] made every item look like a gun")
			if("schoolgirl") // nyaa~ How much are you paying attention in reviews?
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Chinese Cartoons")
				for(var/obj/item/clothing/under/W in world)
					W.icon_state = "schoolgirl"
					W.item_state = "w_suit"
					W.item_color = "schoolgirl"
				message_admins("[key_name_admin(usr)] activated Japanese Animes mode")
				SEND_SOUND(world, sound('sound/AI/animes.ogg'))
			if("eagles")//SCRAW
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Egalitarian Station")
				for(var/obj/machinery/door/airlock/W in GLOB.airlocks)
					if(is_station_level(W.z) && !istype(get_area(W), /area/station/command/bridge) && !istype(get_area(W), /area/station/public) && !istype(get_area(W), /area/station/security/prison))
						W.req_access = list()
				message_admins("[key_name_admin(usr)] activated Egalitarian Station mode")
				GLOB.minor_announcement.Announce("Centcomm airlock control override activated. Please take this time to get acquainted with your coworkers.", new_sound = 'sound/AI/commandreport.ogg')
			if("onlyone")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Only One")
				usr.client.only_one()
//				message_admins("[key_name_admin(usr)] has triggered HIGHLANDER")
			if("onlyme")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Only Me")
				usr.client.only_me()
			if("onlyoneteam")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Only One Team")
				usr.client.only_one_team()
//				message_admins("[key_name_admin(usr)] has triggered ")
			if("rolldice")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Roll The Dice")
				usr.client.roll_dices()
			if("guns")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Summon Guns")
				var/survivor_probability = 0
				switch(alert("Do you want this to create survivors antagonists?", , "No Antags", "Some Antags", "All Antags!"))
					if("Some Antags")
						survivor_probability = 25
					if("All Antags!")
						survivor_probability = 100

				rightandwrong(SUMMON_GUNS, usr, survivor_probability)
			if("magic")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Summon Magic")
				var/survivor_probability = 0
				switch(alert("Do you want this to create survivors antagonists?", , "No Antags", "Some Antags", "All Antags!"))
					if("Some Antags")
						survivor_probability = 25
					if("All Antags!")
						survivor_probability = 100

				rightandwrong(SUMMON_MAGIC, usr, survivor_probability)
			if("tdomereset")
				var/delete_mobs = alert("Clear all mobs?","Confirm","Yes","No","Cancel")
				if(delete_mobs == "Cancel")
					return

				var/area/thunderdome = locate(/area/tdome/arena)
				if(delete_mobs == "Yes")
					for(var/mob/living/mob in thunderdome)
						qdel(mob) //Clear mobs
				for(var/obj/obj in thunderdome)
					if(!istype(obj,/obj/machinery/camera))
						qdel(obj) //Clear objects

				var/area/template = locate(/area/tdome/arena_source)
				template.copy_contents_to(thunderdome)

				log_admin("[key_name(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs].", 1)
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs].</span>")

			if("tdomestart")
				var/confirmation = alert("Start a Thunderdome match?","Confirm","Yes","No")
				if(confirmation == "No")
					return
				makeThunderdomeTeams()
			if("securitylevel")
				var/level_number = text2num(href_list["number"])
				SSsecurity_level.set_level(level_number)
				message_admins("<span class='notice'>[key_name_admin(usr)] change security level to [SSsecurity_level.number_level_to_text(level_number)].</span>")
			if("moveminingshuttle")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Mining Shuttle")
				if(!SSshuttle.toggleShuttle("mining","mining_home","mining_away"))
					message_admins("[key_name_admin(usr)] moved mining shuttle")
					log_admin("[key_name(usr)] moved the mining shuttle")

			if("movelaborshuttle")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Labor Shuttle")
				if(!SSshuttle.toggleShuttle("laborcamp","laborcamp_home","laborcamp_away"))
					message_admins("[key_name_admin(usr)] moved labor shuttle")
					log_admin("[key_name(usr)] moved the labor shuttle")

			if("moveferry")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send CentComm Ferry")
				if(!SSshuttle.toggleShuttle("ferry","ferry_home","ferry_away"))
					message_admins("[key_name_admin(usr)] moved the centcom ferry")
					log_admin("[key_name(usr)] moved the centcom ferry")

			if("gammashuttle")
				SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Send Gamma Armory")
				message_admins("[key_name_admin(usr)] moved the gamma armory")
				log_admin("[key_name(usr)] moved the gamma armory")
				move_gamma_ship()

		if(usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsfun"]]")
			if(ok)
				to_chat(world, text("<b>A secret has been activated by []!</b>", usr.key))

	else if(href_list["secretsadmin"])
		if(!check_rights(R_ADMIN))	return

		var/ok = 0
		switch(href_list["secretsadmin"])
			if("list_signalers")
				var/dat = "<b>Showing last [length(GLOB.lastsignalers)] signalers.</b><hr>"
				for(var/sig in GLOB.lastsignalers)
					dat += "[sig]<BR>"
				usr << browse(dat, "window=lastsignalers;size=800x500")
			if("list_lawchanges")
				var/dat = "<b>Showing last [length(GLOB.lawchanges)] law changes.</b><hr>"
				for(var/sig in GLOB.lawchanges)
					dat += "[sig]<BR>"
				usr << browse(dat, "window=lawchanges;size=800x500")
			if("list_job_debug")
				var/dat = "<b>Job Debug info.</b><hr>"
				if(SSjobs)
					for(var/line in SSjobs.job_debug)
						dat += "[line]<BR>"
					dat+= "*******<BR><BR>"
					for(var/datum/job/job in SSjobs.occupations)
						if(!job)	continue
						dat += "job: [job.title], current_positions: [job.current_positions], total_positions: [job.total_positions] <BR>"
					usr << browse(dat, "window=jobdebug;size=600x500")
			if("showailaws")
				output_ai_laws()
			if("showgm")
				if(!SSticker)
					alert("The game hasn't started yet!")
				else if(SSticker.mode)
					alert("The game mode is [SSticker.mode.name]")
				else alert("For some reason there's a ticker, but not a game mode")
			if("manifest")
				var/dat = "<b>Showing Crew Manifest.</b><hr>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					if(H.ckey)
						dat += text("<tr><td>[]</td><td>[]</td></tr>", H.name, H.get_assignment())
				dat += "</table>"
				usr << browse(dat, "window=manifest;size=440x410")
			if("check_antagonist")
				check_antagonists()
			if("view_codewords")
				to_chat(usr, "<b>Code Phrases:</b> <span class='codephrases'>[GLOB.syndicate_code_phrase]</span>")
				to_chat(usr, "<b>Code Responses:</b> <span class='coderesponses'>[GLOB.syndicate_code_response]</span>")
			if("DNA")
				var/dat = "<b>Showing DNA from blood.</b><hr>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					if(H.dna && H.ckey)
						dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.dna.blood_type]</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=DNA;size=440x410")
			if("fingerprints")
				var/dat = "<b>Showing Fingerprints.</b><hr>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
				for(var/thing in GLOB.human_list)
					var/mob/living/carbon/human/H = thing
					if(H.ckey)
						if(H.dna && H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
						else if(H.dna && !H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>H.dna.uni_identity = null</td></tr>"
						else if(!H.dna)
							dat += "<tr><td>[H]</td><td>H.dna = null</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=fingerprints;size=440x410")
			if("night_shift_set")
				var/val = alert(usr, "What do you want to set night shift to? This will override the automatic system until set to automatic again.", "Night Shift", "On", "Off", "Automatic")
				switch(val)
					if("Automatic")
						if(GLOB.configuration.general.enable_night_shifts)
							SSnightshift.can_fire = TRUE
							SSnightshift.fire()
						else
							SSnightshift.update_nightshift(FALSE, TRUE)
						to_chat(usr, "<span class='notice'>Night shift set to automatic.</span>")
					if("On")
						SSnightshift.can_fire = FALSE
						SSnightshift.update_nightshift(TRUE, FALSE)
						to_chat(usr, "<span class='notice'>Night shift forced on.</span>")
					if("Off")
						SSnightshift.can_fire = FALSE
						SSnightshift.update_nightshift(FALSE, FALSE)
						to_chat(usr, "<span class='notice'>Night shift forced off.</span>")
		if(usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsadmin"]]")
			if(ok)
				to_chat(world, text("<b>A secret has been activated by []!</b>", usr.key))

	else if(href_list["secretscoder"])
		if(!check_rights(R_DEBUG))	return

		switch(href_list["secretscoder"])
			if("spawn_objects")
				var/dat = "<b>Admin Log<hr></b>"
				for(var/l in GLOB.admin_log)
					dat += "<li>[l]</li>"
				if(!GLOB.admin_log.len)
					dat += "No-one has done anything this round!"
				usr << browse(dat, "window=admin_log")
			if("maint_ACCESS_BRIG")
				for(var/obj/machinery/door/airlock/maintenance/M in GLOB.airlocks)
					if(ACCESS_MAINT_TUNNELS in M.req_access)
						M.req_access = list(ACCESS_BRIG)
				message_admins("[key_name_admin(usr)] made all maint doors brig access-only.")
			if("maint_access_engiebrig")
				for(var/obj/machinery/door/airlock/maintenance/M in GLOB.airlocks)
					if(ACCESS_MAINT_TUNNELS in M.req_access)
						M.req_access = list()
						M.req_one_access = list(ACCESS_BRIG,ACCESS_ENGINE)
				message_admins("[key_name_admin(usr)] made all maint doors engineering and brig access-only.")
			if("infinite_sec")
				var/datum/job/J = SSjobs.GetJob("Security Officer")
				if(!J) return
				J.total_positions = -1
				J.spawn_positions = -1
				message_admins("[key_name_admin(usr)] has removed the cap on security officers.")

	if(href_list["secretsmenu"])
		switch(href_list["secretsmenu"])
			if("tab")
				current_tab = text2num(href_list["tab"])
				Secrets(usr)
				return 1

	else if(href_list["viewruntime"])
		var/datum/ErrorViewer/error_viewer = locateUID(href_list["viewruntime"])
		if(!istype(error_viewer))
			to_chat(usr, "<span class='warning'>That runtime viewer no longer exists.</span>")
			return
		if(href_list["viewruntime_backto"])
			error_viewer.showTo(usr, locateUID(href_list["viewruntime_backto"]), href_list["viewruntime_linear"])
		else
			error_viewer.showTo(usr, null, href_list["viewruntime_linear"])

	else if(href_list["add_station_goal"])
		if(!check_rights(R_EVENT))
			return
		var/list/type_choices = typesof(/datum/station_goal)
		var/picked = input("Choose goal type") in type_choices|null
		if(!picked)
			return
		var/datum/station_goal/G = new picked()
		if(picked == /datum/station_goal)
			var/newname = clean_input("Enter goal name:")
			if(!newname)
				return
			G.name = newname
			var/description = input("Enter NAS Trurl message contents:") as message|null
			if(!description)
				return
			G.report_message = description
		message_admins("[key_name_admin(usr)] created \"[G.name]\" station goal.")
		SSticker.mode.station_goals += G
		modify_goals()

	else if(href_list["showdetails"])
		if(!check_rights(R_ADMIN))
			return
		var/text = html_decode(href_list["showdetails"])
		usr << browse("<html><meta charset='utf-8'><HEAD><TITLE>Details</TITLE></HEAD><BODY><TT>[replacetext(text, "\n", "<BR>")]</TT></BODY></HTML>",
			"window=show_details;size=500x200")

	else if(href_list["create_outfit_finalize"])
		if(!check_rights(R_EVENT))
			return
		create_outfit_finalize(usr,href_list)
	else if(href_list["load_outfit"])
		if(!check_rights(R_EVENT))
			return
		load_outfit(usr)
	else if(href_list["create_outfit_menu"])
		if(!check_rights(R_EVENT))
			return
		create_outfit(usr)
	else if(href_list["delete_outfit"])
		if(!check_rights(R_EVENT))
			return
		var/datum/outfit/O = locate(href_list["chosen_outfit"]) in GLOB.custom_outfits
		delete_outfit(usr,O)
	else if(href_list["save_outfit"])
		if(!check_rights(R_EVENT))
			return
		var/datum/outfit/O = locate(href_list["chosen_outfit"]) in GLOB.custom_outfits
		save_outfit(usr,O)
	else if(href_list["open_ccbdb"])
		if(!check_rights(R_ADMIN))
			return
		create_ccbdb_lookup(href_list["open_ccbdb"])
	else if(href_list["slowquery"])
		if(!check_rights(R_ADMIN))
			return
		message_admins("[key_name_admin(usr)] started responding to a query hang report") // So multiple admins dont try file the same report
		var/answer = href_list["slowquery"]
		if(answer == "yes")
			log_sql("[usr.key] | Reported a server hang")
			if(alert(usr, "Had you just pressed any admin buttons which could lag the server?", "Query server hang report", "Yes", "No") == "Yes")
				var/response = input(usr,"What were you just doing?","Query server hang report") as null|text
				if(response)
					log_sql("[usr.key] | [response]")
		else if(answer == "no")
			log_sql("[usr.key] | Reported no server hang. Please investigate")
	else if(href_list["suppresscidwarning"])
		if(!check_rights(R_ADMIN))
			return
		add_note(href_list["suppresscidwarning"], CIDWARNING_SUPPRESSED_NOTETEXT, show_after = FALSE)

	else if(href_list["who_advanced"])
		usr.client.who_advanced()

	else if(href_list["adminalert"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/about_to_be_banned = locateUID(href_list["adminalert"])
		usr.client.cmd_admin_alert_message(about_to_be_banned)

	else if(href_list["spawnjsondatum"])
		// Get the name and JSON to spawn
		var/datum/db_query/dbq = SSdbcore.NewQuery("SELECT slotname, slotjson FROM json_datum_saves WHERE ckey=:ckey AND id=:id", list(
			"ckey" = usr.ckey,
			"id" = href_list["spawnjsondatum"]
		))
		if(!dbq.warn_execute())
			qdel(dbq)
			return

		var/slot_name = null
		var/slot_json = null

		// Read it
		while(dbq.NextRow())
			slot_name = dbq.item[1]
			slot_json = dbq.item[2]

		qdel(dbq)

		// Double check
		var/spawn_choice = alert(usr, "Are you sure you wish to spawn '[slot_name]' at your current location?", "Warning", "Yes", "No")
		if(spawn_choice != "Yes")
			return

		// Log this for gods sake
		message_admins("[key_name_admin(usr)] spawned an atom from a JSON DB save.")
		log_admin("[key_name(usr)] spawned an atom from a JSON DB save, JSON Text: [slot_json]")
		json_to_object(slot_json, get_turf(usr))

	else if(href_list["deletejsondatum"])
		// Get the name
		var/datum/db_query/dbq = SSdbcore.NewQuery("SELECT slotname FROM json_datum_saves WHERE ckey=:ckey AND id=:id", list(
			"ckey" = usr.ckey,
			"id" = href_list["deletejsondatum"]
		))
		if(!dbq.warn_execute())
			qdel(dbq)
			return

		var/slot_name = null

		// Read it
		while(dbq.NextRow())
			slot_name = dbq.item[1]

		qdel(dbq)

		// Double check
		var/delete_choice = alert(usr, "Are you sure you wish to delete '[slot_name]'? This cannot be undone!", "Warning", "Yes", "No")
		if(delete_choice != "Yes")
			return

		var/datum/db_query/dbq2 = SSdbcore.NewQuery("DELETE FROM json_datum_saves WHERE ckey=:ckey AND id=:id", list(
			"ckey" = usr.ckey,
			"id" = href_list["deletejsondatum"]
		))

		if(!dbq2.warn_execute())
			qdel(dbq2)
			return

		qdel(dbq2)
		owner.json_spawn_menu() // Refresh their menu
		to_chat(usr, "Slot <code>[slot_name]</code> deleted.")


/client/proc/create_eventmob_for(mob/living/carbon/human/H, killthem = 0)
	if(!check_rights(R_EVENT))
		return
	var/admin_outfits = subtypesof(/datum/outfit/admin)
	var/hunter_outfits = list()
	for(var/type in admin_outfits)
		var/datum/outfit/admin/O = type
		hunter_outfits[initial(O.name)] = type
	var/dresscode = input("Select type", "Contracted Agents") as null|anything in hunter_outfits
	if(isnull(dresscode))
		return
	var/datum/outfit/O = hunter_outfits[dresscode]
	message_admins("[key_name_admin(mob)] is sending a ([dresscode]) to [killthem ? "assassinate" : "protect"] [key_name_admin(H)]...")
	var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_traitor")
	var/list/candidates = SSghost_spawns.poll_candidates("Play as a [killthem ? "murderous" : "protective"] [dresscode]?", ROLE_TRAITOR, TRUE, source = source, role_cleanname = "[killthem ? "murderous" : "protective"] [dresscode]")
	if(!candidates.len)
		to_chat(usr, "<span class='warning'>ERROR: Could not create eventmob. No valid candidates.</span>")
		return
	var/mob/C = pick(candidates)
	var/key_of_hunter = C.key
	if(!key_of_hunter)
		to_chat(usr, "<span class='warning'>ERROR: Could not create eventmob. Could not pick key.</span>")
		return
	var/datum/mind/hunter_mind = new /datum/mind(key_of_hunter)
	hunter_mind.active = TRUE
	var/mob/living/carbon/human/hunter_mob = new /mob/living/carbon/human(pick(GLOB.latejoin))
	hunter_mind.transfer_to(hunter_mob)
	dust_if_respawnable(C)
	hunter_mob.equipOutfit(O, FALSE)
	var/obj/item/pinpointer/advpinpointer/N = new /obj/item/pinpointer/advpinpointer(hunter_mob)
	hunter_mob.equip_to_slot_or_del(N, SLOT_HUD_IN_BACKPACK)
	N.mode = 3 //MODE_ADV, not defined here
	N.setting = 2 //SETTING_OBJECT, not defined here
	N.target = H
	N.point_at(N.target)
	N.modelocked = TRUE
	if(!locate(/obj/item/implant/dust, hunter_mob))
		var/obj/item/implant/dust/D = new /obj/item/implant/dust(hunter_mob)
		D.implant(hunter_mob)
	if(killthem)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.target = H.mind
		kill_objective.explanation_text = "Kill [H.real_name], the [H.mind.assigned_role]."
		hunter_mind.add_mind_objective(kill_objective)
	else
		var/datum/objective/protect/protect_objective = new
		protect_objective.target = H.mind
		protect_objective.explanation_text = "Protect [H.real_name], the [H.mind.assigned_role]."
		hunter_mind.add_mind_objective(protect_objective)
	SSticker.mode.traitors |= hunter_mob.mind
	to_chat(hunter_mob, "<span class='danger'>ATTENTION:</span> You are now on a mission!")
	to_chat(hunter_mob, "<b>Goal: <span class='danger'>[killthem ? "MURDER" : "PROTECT"] [H.real_name]</span>, currently in [get_area(H.loc)].</b>");
	if(killthem)
		to_chat(hunter_mob, "<b>If you kill [H.p_them()], [H.p_they()] cannot be revived.</b>");
	hunter_mob.mind.special_role = SPECIAL_ROLE_TRAITOR
	var/datum/atom_hud/antag/tatorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	tatorhud.join_hud(hunter_mob)
	set_antag_hud(hunter_mob, "hudsyndicate")

/proc/admin_jump_link(atom/target)
	if(!target) return
	// The way admin jump links handle their src is weirdly inconsistent...

	. = ADMIN_FLW(target,"FLW")
	if(isAI(target)) // AI core/eye follow links
		var/mob/living/silicon/ai/A = target
		if(A.client && A.eyeobj) // No point following clientless AI eyes
			. += "|[ADMIN_FLW(A.eyeobj,"EYE")]"
	else if(isobserver(target))
		var/mob/dead/observer/O = target
		if(O.mind && O.mind.current)
			. += "|[ADMIN_FLW(O.mind.current,"BDY")]"
