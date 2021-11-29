GLOBAL_VAR(jobban_runonce)			// Updates legacy bans with new info
GLOBAL_LIST_INIT(jobban_keylist, new())		// Linear list of jobban strings, kept around for the legacy system
GLOBAL_LIST_INIT(jobban_assoclist, new())  // Associative list, for efficiency

// Matches string-based jobbans into ckey, rank, and reason groups
GLOBAL_DATUM_INIT(jobban_regex, /regex, regex("(\[\\S]+) - (\[^#]+\[^# ])(?: ## (.+))?"))

/proc/jobban_assoc_insert(ckey, rank, reason)
	if(!ckey || !rank)
		return
	if(!GLOB.jobban_assoclist[ckey])
		GLOB.jobban_assoclist[ckey] = list()
	GLOB.jobban_assoclist[ckey][rank] = reason || "Reason Unspecified"

/proc/jobban_fullban(mob/M, rank, reason)
	if(!M || !M.key)
		return
	GLOB.jobban_keylist.Add(text("[M.ckey] - [rank] ## [reason]"))
	jobban_assoc_insert(M.ckey, rank, reason)

/proc/jobban_client_fullban(ckey, rank)
	if(!ckey || !rank)
		return
	GLOB.jobban_keylist.Add(text("[ckey] - [rank]"))
	jobban_assoc_insert(ckey, rank)

//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(!M || !rank)
		return 0

	if(GLOB.configuration.jobs.guest_job_ban && check_job_karma(rank))
		if(IsGuestKey(M.key))
			return "Guest Job-ban"

	if(GLOB.jobban_assoclist[M.ckey])
		return GLOB.jobban_assoclist[M.ckey][rank]
	else
		return 0

/proc/jobban_isbanned_ckey(ckey, rank)
	if(!ckey || !rank)
		return null

	if(GLOB.configuration.jobs.guest_job_ban && check_job_karma(rank))
		if(IsGuestKey(ckey))
			return "Guest Job-ban"

	if(GLOB.jobban_assoclist[ckey])
		return GLOB.jobban_assoclist[ckey][rank]

	return null

/proc/jobban_loadbans()
	if(!SSdbcore.IsConnected())
		log_world("Database connection failed. Job bans not loaded.")
		return

	//Job permabans
	var/datum/db_query/permabans = SSdbcore.NewQuery("SELECT ckey, job FROM ban WHERE bantype = 'JOB_PERMABAN' AND isnull(unbanned)")

	if(!permabans.warn_execute(async=FALSE))
		qdel(permabans)
		return FALSE

	while(permabans.NextRow())
		var/ckey = permabans.item[1]
		var/job = permabans.item[2]
		GLOB.jobban_keylist.Add("[ckey] - [job]")
		jobban_assoc_insert(ckey, job)

	qdel(permabans)

	// Job tempbans
	var/datum/db_query/tempbans = SSdbcore.NewQuery("SELECT ckey, job FROM ban WHERE bantype = 'JOB_TEMPBAN' AND isnull(unbanned) AND expiration_time > Now()")

	if(!tempbans.warn_execute(async=FALSE))
		qdel(tempbans)
		return FALSE

	while(tempbans.NextRow())
		var/ckey = tempbans.item[1]
		var/job = tempbans.item[2]
		GLOB.jobban_keylist.Add("[ckey] - [job]")
		jobban_assoc_insert(ckey, job)

	qdel(tempbans)

/proc/jobban_savebanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] << GLOB.jobban_keylist

/proc/jobban_unban(mob/M, rank)
	jobban_remove("[M.ckey] - [rank]")

/proc/jobban_unban_client(ckey, rank)
	jobban_remove("[ckey] - [rank]")

/proc/jobban_remove(X)
	for(var/i = 1; i <= length(GLOB.jobban_keylist); i++)
		if( findtext(GLOB.jobban_keylist[i], "[X]") )
			// This need to be here, instead of jobban_unban, due to direct calls to jobban_remove
			if(GLOB.jobban_regex.Find(X))
				var/ckey = GLOB.jobban_regex.group[1]
				var/rank = GLOB.jobban_regex.group[2]
				if(GLOB.jobban_assoclist[ckey] && GLOB.jobban_assoclist[ckey][rank])
					GLOB.jobban_assoclist[ckey] -= rank
				else
					log_runtime(EXCEPTION("Attempted to remove non-existent job ban: [X]"))
			else
				log_runtime(EXCEPTION("Failed to remove malformed job ban from associative list: [X]"))
			GLOB.jobban_keylist.Remove(GLOB.jobban_keylist[i])
			return 1
	return 0

/mob/verb/displayjobbans()
	set category = "OOC"
	set name = "Display Current Jobbans"
	set desc = "Displays all of your current jobbans."

	if(!client || !ckey)
		return

	var/is_actually_banned = FALSE
	var/datum/db_query/select_query = SSdbcore.NewQuery({"
		SELECT bantime, bantype, reason, job, duration, expiration_time, a_ckey FROM ban
		WHERE ckey LIKE :ckey AND ((bantype like 'JOB_TEMPBAN' AND expiration_time > Now()) OR (bantype like 'JOB_PERMABAN')) AND isnull(unbanned)
		ORDER BY bantime DESC LIMIT 100"},
		list("ckey" = ckey)
	)

	if(!select_query.warn_execute())
		qdel(select_query)
		return FALSE

	while(select_query.NextRow())

		var/bantime = select_query.item[1]
		var/bantype  = select_query.item[2]
		var/reason = select_query.item[3]
		var/job = select_query.item[4]
		var/duration = select_query.item[5]
		var/expiration = select_query.item[6]
		var/ackey = select_query.item[7]

		if(bantype == "JOB_PERMABAN")
			to_chat(src, "<span class='warning'>[bantype]: [job] - REASON: [reason], by [ackey]; [bantime]</span>")
		else if(bantype == "JOB_TEMPBAN")
			to_chat(src, "<span class='warning'>[bantype]: [job] - REASON: [reason], by [ackey]; [bantime]; [duration]; expires [expiration]</span>")

		is_actually_banned = TRUE

	qdel(select_query)

	if(is_actually_banned)
		if(GLOB.configuration.url.banappeals_url)
			to_chat(src, "<span class='warning'>You can appeal the bans at: [GLOB.configuration.url.banappeals_url]</span>")
	else
		to_chat(src, "<span class='warning'>You have no active jobbans!</span>")
