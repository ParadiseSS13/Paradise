SUBSYSTEM_DEF(jobs)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS // 12
	wait = 5 MINUTES // Dont ever make this a super low value since EXP updates are calculated from this value
	runlevels = RUNLEVEL_GAME
	offline_implications = "Job playtime hours will no longer be logged. No immediate action is needed."
	cpu_display = SS_CPUDISPLAY_LOW

	//List of all jobs
	var/list/occupations = list()
	var/list/name_occupations = list()	//Dict of all jobs, keys are titles
	var/list/type_occupations = list()	//Dict of all jobs, keys are types
	var/list/prioritized_jobs = list() // List of jobs set to priority by HoP/Captain
	var/list/id_change_records = list() // List of all job transfer records
	var/probability_of_antag_role_restriction = 100 // Dict probability of a job rolling an antagonist role
	var/id_change_counter = 1

	///list of station departments and their associated roles and economy payments
	var/list/station_departments = list()
	/// Do we spawn everyone at shuttle due to late arivals?
	var/late_arrivals_spawning = FALSE
	/// Do we spawn people drunkenly due to the party last night?
	var/drunken_spawning = FALSE
	/// Job selector, used for roundstart and late join job assignment
	var/datum/job_selector/job_selector

/datum/controller/subsystem/jobs/Initialize()
	if(!length(occupations))
		SetupOccupations()
	for(var/department_type in subtypesof(/datum/station_department))
		station_departments += new department_type()
	LoadJobs(FALSE)

// Only fires every 5 minutes
/datum/controller/subsystem/jobs/fire()
	if(!SSdbcore.IsConnected() || !GLOB.configuration.jobs.enable_exp_tracking)
		return
	batch_update_player_exp(announce = FALSE) // Set this to true if you ever want to inform players about their EXP gains

/datum/controller/subsystem/jobs/proc/SetupOccupations(list/faction = list("Station"))
	occupations = list()
	var/list/all_jobs = subtypesof(/datum/job)
	if(!length(all_jobs))
		to_chat(world, "<span class='warning'>Error setting up jobs, no job datums found.</span>")
		return 0

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		occupations += job
		name_occupations[job.title] = job
		type_occupations[J] = job

	return 1

/datum/controller/subsystem/jobs/proc/GetJob(rank)
	if(!length(occupations))
		SetupOccupations()
	return name_occupations[rank]

/datum/controller/subsystem/jobs/proc/GetJobType(jobtype)
	if(!length(occupations))
		SetupOccupations()
	return type_occupations[jobtype]

/datum/controller/subsystem/jobs/proc/GetPlayerAltTitle(mob/new_player/player, rank)
	return player.client.prefs.active_character.GetPlayerAltTitle(GetJob(rank))

/datum/controller/subsystem/jobs/proc/FreeRole(rank, force = FALSE)	//making additional slot on the fly
	var/datum/job/job = GetJob(rank)
	if(!job)
		return FALSE
	if(job.job_banned_gamemode)
		if(!force)
			return FALSE
		job.job_banned_gamemode = FALSE // If admins want to force it, they can reopen banned job slots

	if(job.current_positions >= job.total_positions && job.total_positions != -1)
		job.total_positions++
		return TRUE
	return FALSE

/datum/controller/subsystem/jobs/proc/ResetOccupations()
	for(var/mob/new_player/player in GLOB.player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.special_role = null
	occupations.Cut()
	SetupOccupations()
	return

/datum/controller/subsystem/jobs/proc/AssignRank(mob/living/carbon/human/H, rank, joined_late = FALSE)
	if(!H)
		return null
	var/datum/job/job = GetJob(rank)

	H.job = rank

	var/alt_title = null

	if(H.mind)
		H.mind.assigned_role = rank
		alt_title = H.mind.role_alt_title

		CreateMoneyAccount(H, rank, job)

	var/list/L = list()
	L.Add("<b>Your role on the station is: [alt_title ? alt_title : rank].")
	L.Add("You answer directly to [job.supervisors]. Special circumstances may change this.")
	L.Add("For more information on how the station works, see [wiki_link("Standard_Operating_Procedure", "Standard Operating Procedure (SOP)")].")
	if(job.job_department_flags & DEP_FLAG_SERVICE)
		L.Add("As a member of Service, make sure to read up on your [wiki_link("Standard_Operating_Procedure_(Service)", "Department SOP")].")
	if(job.job_department_flags & DEP_FLAG_SUPPLY)
		L.Add("As a member of Supply, make sure to read up on your [wiki_link("Standard_Operating_Procedure_(Supply)", "Department SOP")].")
	if(job.job_department_flags == DEP_FLAG_COMMAND) // Check if theyre only command, like captain/hop/bs/ntrep, to not spam their chatbox
		L.Add("As an important member of Command, read up on your [wiki_link("Standard_Operating_Procedure_(Command)", "Department SOP")].")
	if(job.job_department_flags & DEP_FLAG_LEGAL)
		L.Add("Your job requires complete knowledge of [wiki_link("Space Law", "Space Law")] and [wiki_link("Legal_Standard_Operating_Procedure", "Legal Standard Operating Procedure")].")
	if(job.job_department_flags & DEP_FLAG_ENGINEERING)
		L.Add("As a member of Engineering, make sure to read up on your [wiki_link("Standard_Operating_Procedure_(Engineering)", "Department SOP")].")
	if(job.job_department_flags & DEP_FLAG_MEDICAL)
		L.Add("As a member of Medbay, make sure to read up on your [wiki_link("Standard_Operating_Procedure_(Medical)", "Department SOP")].")
	if(job.job_department_flags & DEP_FLAG_SCIENCE)
		L.Add("As a member of Science, make sure to read up on your [wiki_link("Standard_Operating_Procedure_(Science)", "Department SOP")].")
	if(job.job_department_flags & DEP_FLAG_SECURITY)
		L.Add("As a member of Security, you are to know [wiki_link("Space Law", "Space Law")] and [wiki_link("Legal_Standard_Operating_Procedure", "Legal Standard Operating Procedure")], as well as your [wiki_link("Standard_Operating_Procedure_(Security)", "Department SOP")].")
	if(job.req_admin_notify)
		L.Add("You are playing a job that is important for the game progression. If you have to disconnect, please go to cryo and inform command. If you are unable to do so, please notify the admins via adminhelp.")
	L.Add("<br>If you need help, check the [wiki_link("Main_Page", "wiki")] or use Mentorhelp(F1)!</b>")
	if(job.important_information)
		L.Add("</b><span class='userdanger' style='width: 80%'>[job.important_information]</span>")

	to_chat(H, chat_box_green(L.Join("<br>")))

	// If the job has objectives, announce those too
	if(length(H.mind.job_objectives))
		var/list/objectives_message = list()
		var/counter = 1
		for(var/datum/job_objective/objective as anything in H.mind.job_objectives)
			objectives_message.Add("<b>Objective #[counter]: [objective.objective_name]</b>")
			objectives_message.Add("[objective.description]<br>")
			counter++
		to_chat(H, chat_box_notice(objectives_message.Join("<br>")))

	return H

/datum/controller/subsystem/jobs/proc/EquipRank(mob/living/carbon/human/H, rank, joined_late = 0) // Equip and put them in an area
	if(!H)
		return null

	var/datum/job/job = GetJob(rank)

	H.job = rank

	if(!joined_late && !late_arrivals_spawning)
		var/turf/T = null
		var/obj/S = null
		var/list/landmarks = GLOB.landmarks_list
		if(drunken_spawning)
			landmarks = shuffle(landmarks) //Shuffle it so it's random

		for(var/obj/effect/landmark/start/sloc in landmarks)
			if(sloc.name != rank && !drunken_spawning)
				continue
			if(locate(/mob/living) in sloc.loc)
				continue
			if(drunken_spawning && sloc.name == "AI")
				continue
			S = sloc
			break
		if(!S)
			S = locate("start*[rank]") // use old stype
		if(!S) // still no spawn, fall back to the arrivals shuttle
			for(var/turf/TS in get_area_turfs(/area/shuttle/arrival))
				if(!TS.density)
					var/clear = 1
					for(var/obj/O in TS)
						if(O.density)
							clear = 0
							break
					if(clear)
						T = TS
						continue

		if(isturf(S))
			T = S
		else if(istype(S, /obj/effect/landmark/start) && isturf(S.loc))
			T = S.loc

		if(T)
			H.forceMove(T)
			// Moving wheelchair if they have one
			if(H.buckled && istype(H.buckled, /obj/structure/chair/wheelchair))
				H.buckled.forceMove(H.loc)
				H.buckled.dir = H.dir

	if(job)
		var/new_mob = job.equip(H)
		if(ismob(new_mob))
			H = new_mob

	if(job && H)
		job.after_spawn(H)

		//Gives glasses to the vision impaired
		if(HAS_TRAIT(H, TRAIT_NEARSIGHT))
			var/equipped = H.equip_to_slot_or_del(new /obj/item/clothing/glasses/regular(H), ITEM_SLOT_EYES)
			if(equipped != 1)
				var/obj/item/clothing/glasses/G = H.glasses
				if(istype(G) && !G.prescription)
					G.upgrade_prescription()
					H.update_nearsighted_effects()

	if(joined_late || job.admin_only)
		H.create_log(MISC_LOG, "Spawned as \an [H.dna?.species ? H.dna.species : "Undefined species"] named [H]. [joined_late ? "Joined during the round" : "Roundstart joined"] as job: [rank].", force_no_usr_check=TRUE)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/controller/subsystem/jobs, show_location_blurb), H.client, H.mind), 1 SECONDS) //Moment for minds to boot up / people to load in
		return H
	if(late_arrivals_spawning)
		H.forceMove(pick(GLOB.latejoin))
	if(drunken_spawning)
		var/obj/item/organ/internal/liver/L
		var/liver_multiplier = 1
		L = H.get_int_organ(/obj/item/organ/internal/liver)
		if(L)
			liver_multiplier = L.alcohol_intensity
		if(isslimeperson(H) || isrobot(H))
			liver_multiplier = 5
		H.Sleeping(5 SECONDS)
		H.Drunk((2 / liver_multiplier) MINUTES)
	H.create_log(MISC_LOG, "Spawned as \an [H.dna?.species ? H.dna.species : "Undefined species"] named [H]. Roundstart joined as job: [rank].", force_no_usr_check=TRUE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/controller/subsystem/jobs, show_location_blurb), H.client, H.mind), 1 SECONDS) //Moment for minds to boot up / people to load in
	return H

/datum/controller/subsystem/jobs/proc/LoadJobs(highpop = FALSE) //ran during round setup, reads info from jobs list
	if(!GLOB.configuration.jobs.enable_job_amount_overrides)
		return FALSE

	var/list/joblist = list()

	if(highpop)
		joblist = GLOB.configuration.jobs.highpop_job_map.Copy()
	else
		joblist = GLOB.configuration.jobs.lowpop_job_map.Copy()

	for(var/job in joblist)
		// Key: name | Value: Amount
		var/datum/job/J = GetJob(job)
		if(!J)
			stack_trace("`[job]` not found while setting max slots. Check for misspellings or alternate titles")
			continue
		J.total_positions = text2num(joblist[job])
		J.spawn_positions = text2num(joblist[job])

		if(job == "AI" || job == "Cyborg") //I dont like this here but it will do for now
			J.total_positions = 0

	return TRUE

//fuck
/datum/controller/subsystem/jobs/proc/CreateMoneyAccount(mob/living/H, rank, datum/job/job)
	if(job && !job.has_bank_account)
		return
	var/starting_balance = job?.department_account_access ? COMMAND_MEMBER_STARTING_BALANCE : CREW_MEMBER_STARTING_BALANCE
	var/datum/money_account/account = GLOB.station_money_database.create_account(H.real_name, starting_balance, ACCOUNT_SECURITY_ID, "NAS Trurl Accounting", TRUE)

	for(var/datum/job_objective/objective as anything in H.mind.job_objectives)
		objective.owner_account = account

	H.mind.store_memory("<b>Your account number is:</b> #[account.account_number]<br><b>Your account pin is:</b> [account.account_pin]")
	H.mind.set_initial_account(account)

	to_chat(H, "<span class='boldnotice'>As an employee of Nanotrasen you will receive a paycheck of $[account.payday_amount] credits every 30 minutes</span>")
	to_chat(H, "<span class='boldnotice'>Your account number is: [account.account_number], your account pin is: [account.account_pin]</span>")

	if(!job) //if their job datum is null (looking at you ERTs...), we don't need to do anything past this point
		return

	//add them to their department datum, (this relates a lot to money account I promise)
	var/list/users_departments = get_departments_from_job(job.title)
	for(var/datum/station_department/department as anything in users_departments)
		var/datum/department_member/member = new
		member.name = H.real_name
		member.role = job.title
		member.set_member_account(account) //we need to set this through a proc so we can register signals
		member.can_approve_crates = job?.department_account_access
		department.members += member

	// If they're head, give them the account info for their department
	if(!job.department_account_access)
		return

	announce_department_accounts(users_departments, H, job)

/datum/controller/subsystem/jobs/proc/announce_department_accounts(users_departments, mob/living/H, datum/job/job)
	var/remembered_info = ""
	for(var/datum/station_department/department as anything in users_departments)
		if(job.title != department.head_of_staff)
			continue
		var/datum/money_account/department_account = department.department_account
		if(!department_account)
			return

		remembered_info += "As a head of staff you have access to your department's money account through your PDA's NanoBank or a station ATM<br>"
		remembered_info += "<b>The [department.department_name] department's account number is:</b> #[department_account.account_number]<br>"
		remembered_info += "<b>The [department.department_name] department's account pin is:</b> [department_account.account_pin]<br>"
		remembered_info += "<b>Your department's account funds are:</b> $[department_account.credit_balance]<br>"

		H.mind.store_memory(remembered_info)
		to_chat(H, "<span class='boldnotice'>Your department will receive a $[department_account.payday_amount] credit stipend every 30 minutes</span>")
		to_chat(H, "<span class='boldnotice'>The [department.department_name] department's account number is: #[department_account.account_number], Your department's account pin is: [department_account.account_pin]</span>")

/// Returns a list of jobs keyed by name to UI color for the job transfer selection.
/datum/controller/subsystem/jobs/proc/format_jobs_for_id_computer(obj/item/card/id/tgtcard)
	var/list/jobs_to_formats = list()
	if(tgtcard)
		var/mob/M = tgtcard.getPlayer()
		for(var/datum/job/job in occupations)
			if(tgtcard.rank && tgtcard.rank == job.title)
				jobs_to_formats[job.title] = "green" // the job they already have is pre-selected
			else if(tgtcard.assignment == "Demoted" || tgtcard.assignment == "Terminated")
				jobs_to_formats[job.title] = "grey"
			else if(!job.transfer_allowed)
				jobs_to_formats[job.title] = "grey" // jobs which shouldnt be transferred into for whatever reason, likely due to high hour requirements
			else if((job.title in GLOB.command_positions) && istype(M) && M.client && job.get_exp_restrictions(M.client))
				jobs_to_formats[job.title] = "grey" // command jobs which are playtime-locked and not unlocked for this player are discouraged
			else if(job.total_positions && !job.current_positions && job.title != "Assistant")
				jobs_to_formats[job.title] = "teal" // jobs with nobody doing them at all are encouraged
			else if(job.total_positions >= 0 && job.current_positions >= job.total_positions)
				jobs_to_formats[job.title] = "grey" // jobs that are full (no free positions) are discouraged
		if(tgtcard.assignment == "Demoted" || tgtcard.assignment == "Terminated")
			jobs_to_formats["Custom"] = "grey"
	return jobs_to_formats

/datum/controller/subsystem/jobs/proc/get_job_titles_for_id_computer()
	. = list()
	.["top"] = list("Captain", "Custom")
	.["assistant"] = GLOB.assistant_positions
	.["medical"] = GLOB.medical_positions
	.["engineering"] = GLOB.engineering_positions
	.["science"] = GLOB.science_positions
	.["security"] = GLOB.active_security_positions
	.["service"] = GLOB.service_positions
	.["supply"] = GLOB.supply_positions
	.["centcom"] = get_all_centcom_jobs() + get_all_ERT_jobs()

/datum/controller/subsystem/jobs/proc/log_job_transfer(transferee, oldvalue, newvalue, whodidit, reason)
	id_change_records["[id_change_counter]"] = list(
		"transferee" = transferee,
		"oldvalue" = oldvalue,
		"newvalue" = newvalue,
		"whodidit" = whodidit,
		"timestamp" = station_time_timestamp(),
		"reason" = reason
	)
	id_change_counter++

/datum/controller/subsystem/jobs/proc/slot_job_transfer(oldtitle, newtitle)
	var/datum/job/oldjobdatum = SSjobs.GetJob(oldtitle)
	var/datum/job/newjobdatum = SSjobs.GetJob(newtitle)
	if(istype(oldjobdatum) && oldjobdatum.current_positions > 0 && istype(newjobdatum))
		if(!(oldjobdatum.title in GLOB.command_positions) && !(newjobdatum.title in GLOB.command_positions))
			oldjobdatum.current_positions--
			newjobdatum.current_positions++

/datum/controller/subsystem/jobs/proc/notify_dept_head(jobtitle, antext)
	// Used to notify the department head of jobtitle X that their employee was brigged, demoted or terminated
	if(!jobtitle || !antext)
		return
	var/datum/job/tgt_job = GetJob(jobtitle)
	if(!tgt_job)
		return
	if(!length(tgt_job.department_head))
		return
	var/boss_title = tgt_job.department_head[1]
	var/obj/item/pda/target_pda
	for(var/obj/item/pda/check_pda in GLOB.PDAs)
		if(check_pda.ownrank == boss_title)
			target_pda = check_pda
			break
	if(!target_pda)
		return
	var/datum/data/pda/app/messenger/PM = target_pda.find_program(/datum/data/pda/app/messenger)
	if(PM && PM.can_receive())
		PM.notify("<b>Automated Notification: </b>\"[antext]\" (Unable to Reply)", 0) // the 0 means don't make the PDA flash

/datum/controller/subsystem/jobs/proc/notify_by_name(target_name, antext)
	// Used to notify a specific crew member based on their real_name
	if(!target_name || !antext)
		return
	var/obj/item/pda/target_pda
	for(var/obj/item/pda/check_pda in GLOB.PDAs)
		if(check_pda.owner == target_name)
			target_pda = check_pda
			break
	if(!target_pda)
		return
	var/datum/data/pda/app/messenger/PM = target_pda.find_program(/datum/data/pda/app/messenger)
	if(PM && PM.can_receive())
		PM.notify("<b>Automated Notification: </b>\"[antext]\" (Unable to Reply)", 0) // the 0 means don't make the PDA flash

/datum/controller/subsystem/jobs/proc/format_job_change_records(centcom)
	var/list/formatted = list()
	for(var/thisid in id_change_records)
		var/thisrecord = id_change_records[thisid]
		if(thisrecord["deletedby"] && !centcom)
			continue
		var/list/newlist = list()
		for(var/lkey in thisrecord)
			newlist[lkey] = thisrecord[lkey]
		formatted.Add(list(newlist))
	return formatted


/datum/controller/subsystem/jobs/proc/delete_log_records(sourceuser, delete_all)
	. = 0
	if(!sourceuser)
		return
	var/list/new_id_change_records = list()
	for(var/thisid in id_change_records)
		var/thisrecord = id_change_records[thisid]
		if(!thisrecord["deletedby"])
			if(delete_all || thisrecord["whodidit"] == sourceuser)
				thisrecord["deletedby"] = sourceuser
				.++
		new_id_change_records["[id_change_counter]"] = thisrecord
		id_change_counter++
	id_change_records = new_id_change_records

// This proc will update all players EXP at once. It will calculate amount of time to add dynamically based on the SS fire time.
/datum/controller/subsystem/jobs/proc/batch_update_player_exp(announce = FALSE)
	// Right off the bat
	var/start_time = start_watch()
	// First calculate minutes
	var/divider = 10 // By default, 10 deciseconds in 1 second
	if(flags & SS_TICKER)
		divider = 20 // If this SS ever gets made into a ticker SS, account for that

	var/minutes = (wait / divider) / 60 // Calculate minutes based on the SS wait time (How often this proc fires)

	// Step 1: Get us a list of clients to process
	var/list/client/clients_to_process = GLOB.clients.Copy() // This is copied so that clients joining in the middle of this dont break things
	log_debug("Starting EXP update for [length(clients_to_process)] clients. (Adding [minutes] minutes)")

	var/list/datum/db_query/select_queries = list() // List of SELECT queries to mass grab EXP.

	for(var/i in clients_to_process)
		var/client/C = i
		if(!C)
			continue // If a client logs out in the middle of this

		var/datum/db_query/exp_read = SSdbcore.NewQuery(
			"SELECT exp FROM player WHERE ckey=:ckey",
			list("ckey" = C.ckey)
		)

		select_queries[C.ckey] = exp_read

	var/list/read_records = list()
	// Explanation for parameters:
	// TRUE: We want warnings if these fail
	// FALSE: Do NOT qdel() queries here, otherwise they wont be read. At all.
	// TRUE: This is an assoc list, so it needs to prepare for that
	// FALSE: We dont want to logspam
	SSdbcore.MassExecute(select_queries, TRUE, FALSE, TRUE, FALSE) // Batch execute so we can take advantage of async magic

	for(var/i in clients_to_process)
		var/client/C = i
		if(!C)
			continue // If a client logs out in the middle of this

		if(select_queries[C.ckey]) // This check should not be necessary, but I am paranoid
			while(select_queries[C.ckey].NextRow())
				read_records[C.ckey] = params2list(select_queries[C.ckey].item[1])

	QDEL_LIST_ASSOC_VAL(select_queries) // Clean stuff up

	var/list/play_records = list()

	var/list/datum/db_query/player_update_queries = list() // List of queries to update player EXP
	var/list/datum/db_query/playtime_history_update_queries = list() // List of queries to update the playtime history table

	for(var/i in clients_to_process)
		var/client/C = i
		if(!C)
			continue // If a client logs out in the middle of this
		// Get us a container
		play_records[C.ckey] = list()
		for(var/rtype in GLOB.exp_jobsmap)
			if(text2num(read_records[C.ckey][rtype]))
				play_records[C.ckey][rtype] = text2num(read_records[C.ckey][rtype])
			else
				play_records[C.ckey][rtype] = 0


		var/myrole
		if(C.mob.mind)
			if(C.mob.mind.playtime_role)
				myrole = C.mob.mind.playtime_role
			else if(C.mob.mind.assigned_role)
				myrole = C.mob.mind.assigned_role

		// Track all the added ammounts for a mega update query
		var/list/added_differential = list(
			EXP_TYPE_LIVING = 0,
			EXP_TYPE_CREW = 0,
			EXP_TYPE_SPECIAL = 0,
			EXP_TYPE_GHOST = 0,
			EXP_TYPE_COMMAND = 0,
			EXP_TYPE_ENGINEERING = 0,
			EXP_TYPE_MEDICAL = 0,
			EXP_TYPE_SCIENCE = 0,
			EXP_TYPE_SUPPLY = 0,
			EXP_TYPE_SECURITY = 0,
			EXP_TYPE_SILICON = 0,
			EXP_TYPE_SERVICE = 0
		)
		if(C.mob.stat == CONSCIOUS && myrole)
			play_records[C.ckey][EXP_TYPE_LIVING] += minutes
			added_differential[EXP_TYPE_LIVING] += minutes

			if(announce)
				to_chat(C.mob, "<span class='notice'>You got: [minutes] Living EXP!</span>")

			for(var/category in GLOB.exp_jobsmap)
				if(GLOB.exp_jobsmap[category]["titles"])
					if(myrole in GLOB.exp_jobsmap[category]["titles"])
						play_records[C.ckey][category] += minutes
						added_differential[category] += minutes
						if(announce)
							to_chat(C.mob, "<span class='notice'>You got: [minutes] [category] EXP!</span>")

			if(C.mob.mind.special_role)
				play_records[C.ckey][EXP_TYPE_SPECIAL] += minutes
				if(announce)
					to_chat(C.mob, "<span class='notice'>You got: [minutes] Special EXP!</span>")

		else if(isobserver(C.mob))
			play_records[C.ckey][EXP_TYPE_GHOST] += minutes
			added_differential[EXP_TYPE_GHOST] += minutes
			if(announce)
				to_chat(C.mob, "<span class='notice'>You got: [minutes] Ghost EXP!</span>")
		else
			continue

		var/new_exp = list2params(play_records[C.ckey])

		C.prefs.exp = new_exp

		var/datum/db_query/update_query = SSdbcore.NewQuery(
			"UPDATE player SET exp =:newexp, lastseen=NOW() WHERE ckey=:ckey",
			list(
				"newexp" = new_exp,
				"ckey" = C.ckey
			)
		)

		player_update_queries += update_query

		// This gets hellish
		var/datum/db_query/update_query_history = SSdbcore.NewQuery({"
			INSERT INTO playtime_history (ckey, date, time_living, time_crew, time_special, time_ghost, time_command, time_engineering, time_medical, time_science, time_supply, time_security, time_silicon, time_service)
			VALUES (:ckey, CURDATE(), :addedliving, :addedcrew, :addedspecial, :addedghost, :addedcommand, :addedengineering, :addedmedical, :addedscience, :addedsupply, :addedsecurity, :addedsilicon, :addedservice)
			ON DUPLICATE KEY UPDATE time_living=time_living + VALUES(time_living), time_crew=time_crew + VALUES(time_crew), time_crew=time_special + VALUES(time_special), time_ghost=time_ghost + VALUES(time_ghost), time_command=time_command + VALUES(time_command), time_engineering=time_engineering + VALUES(time_engineering), time_medical=time_medical + VALUES(time_medical), time_science=time_science + VALUES(time_science), time_supply=time_supply + VALUES(time_supply), time_security=time_security + VALUES(time_security), time_silicon=time_silicon + VALUES(time_silicon), time_service=time_service + VALUES(time_service)"},
			list(
				"ckey" = C.ckey,
				"addedliving" = added_differential[EXP_TYPE_LIVING],
				"addedcrew" = added_differential[EXP_TYPE_CREW],
				"addedspecial" = added_differential[EXP_TYPE_SPECIAL],
				"addedghost" = added_differential[EXP_TYPE_GHOST],
				"addedcommand" = added_differential[EXP_TYPE_COMMAND],
				"addedengineering" = added_differential[EXP_TYPE_ENGINEERING],
				"addedmedical" = added_differential[EXP_TYPE_MEDICAL],
				"addedscience" = added_differential[EXP_TYPE_SCIENCE],
				"addedsupply" = added_differential[EXP_TYPE_SUPPLY],
				"addedsecurity" = added_differential[EXP_TYPE_SECURITY],
				"addedsilicon" = added_differential[EXP_TYPE_SILICON],
				"addedservice" = added_differential[EXP_TYPE_SERVICE]
			)
		)

		playtime_history_update_queries += update_query_history


	// warn=TRUE, qdel=TRUE, assoc=FALSE, log=FALSE
	SSdbcore.MassExecute(player_update_queries, TRUE, TRUE, FALSE, FALSE) // Batch execute so we can take advantage of async magic
	SSdbcore.MassExecute(playtime_history_update_queries, TRUE, TRUE, FALSE, FALSE)

	log_debug("Successfully updated all EXP data in [stop_watch(start_time)]s")
