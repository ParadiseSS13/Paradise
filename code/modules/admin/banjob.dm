//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

var/jobban_runonce			// Updates legacy bans with new info
var/jobban_keylist[0]		// Linear list of jobban strings, kept around for the legacy system
var/jobban_assoclist[0] // Associative list, for efficiency

// Matches string-based jobbans into ckey, rank, and reason groups
var/regex/jobban_regex = regex("(\[\\S]+) - (\[^#]+\[^# ])(?: ## (.+))?")

/proc/jobban_assoc_insert(ckey, rank, reason)
	if(!ckey || !rank)
		return
	if(!jobban_assoclist[ckey])
		jobban_assoclist[ckey] = list()
	jobban_assoclist[ckey][rank] = reason || "Reason Unspecified"

/proc/jobban_fullban(mob/M, rank, reason)
	if(!M || !M.key)
		return
	jobban_keylist.Add(text("[M.ckey] - [rank] ## [reason]"))
	jobban_assoc_insert(M.ckey, rank, reason)
	if(config.ban_legacy_system)
		jobban_savebanfile()

/proc/jobban_client_fullban(ckey, rank)
	if(!ckey || !rank)
		return
	jobban_keylist.Add(text("[ckey] - [rank]"))
	jobban_assoc_insert(ckey, rank)
	if(config.ban_legacy_system)
		jobban_savebanfile()

//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(!M || !rank)
		return 0

	if(config.guest_jobban && guest_jobbans(rank))
		if(IsGuestKey(M.key))
			return "Guest Job-ban"

	if(jobban_assoclist[M.ckey])
		return jobban_assoclist[M.ckey][rank]
	else
		return 0

/*
DEBUG
/mob/verb/list_all_jobbans()
	set name = "list all jobbans"

	for(var/s in jobban_keylist)
		to_chat(world, s)

/mob/verb/reload_jobbans()
	set name = "reload jobbans"

	jobban_loadbanfile()
*/

/hook/startup/proc/loadJobBans()
	jobban_loadbanfile()
	return 1

/proc/jobban_loadbanfile()
	if(config.ban_legacy_system)
		var/savefile/S=new("data/job_full.ban")
		S["keys[0]"] >> jobban_keylist
		log_admin("Loading jobban_rank")
		S["runonce"] >> jobban_runonce

		if(!length(jobban_keylist))
			jobban_keylist=list()
			log_admin("jobban_keylist was empty")

		for(var/s in jobban_keylist)
			if(jobban_regex.Find(s))
				jobban_assoc_insert(jobban_regex.group[1], jobban_regex.group[2], jobban_regex.group[3])
			else
				log_runtime(EXCEPTION("Skipping malformed job ban: [s]"))
	else
		if(!establish_db_connection())
			log_to_dd("Database connection failed. Reverting to the legacy ban system.")
			diary << "Database connection failed. Reverting to the legacy ban system."
			config.ban_legacy_system = 1
			jobban_loadbanfile()
			return

		//Job permabans
		var/DBQuery/permabans = dbcon.NewQuery("SELECT ckey, job FROM [format_table_name("ban")] WHERE bantype = 'JOB_PERMABAN' AND isnull(unbanned)")
		permabans.Execute()
		// Job tempbans
		var/DBQuery/tempbans = dbcon.NewQuery("SELECT ckey, job FROM [format_table_name("ban")] WHERE bantype = 'JOB_TEMPBAN' AND isnull(unbanned) AND expiration_time > Now()")
		tempbans.Execute()

		while(TRUE)
			var/ckey
			var/job
			if(permabans.NextRow())
				ckey = permabans.item[1]
				job = permabans.item[2]
			else if(tempbans.NextRow())
				ckey = tempbans.item[1]
				job = tempbans.item[2]
			else
				break

			jobban_keylist.Add("[ckey] - [job]")
			jobban_assoc_insert(ckey, job)

/proc/jobban_savebanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] << jobban_keylist

/proc/jobban_unban(mob/M, rank)
	jobban_remove("[M.ckey] - [rank]")

/proc/jobban_unban_client(ckey, rank)
	jobban_remove("[ckey] - [rank]")

/proc/ban_unban_log_save(var/formatted_log)
	text2file(formatted_log,"data/ban_unban_log.txt")


/proc/jobban_remove(X)
	for(var/i = 1; i <= length(jobban_keylist); i++)
		if( findtext(jobban_keylist[i], "[X]") )
			// This need to be here, instead of jobban_unban, due to direct calls to jobban_remove
			if(jobban_regex.Find(X))
				var/ckey = jobban_regex.group[1]
				var/rank = jobban_regex.group[2]
				if(jobban_assoclist[ckey] && jobban_assoclist[ckey][rank])
					jobban_assoclist[ckey] -= rank
				else
					log_runtime(EXCEPTION("Attempted to remove non-existent job ban: [X]"))
			else
				log_runtime(EXCEPTION("Failed to remove malformed job ban from associative list: [X]"))
			jobban_keylist.Remove(jobban_keylist[i])
			if(config.ban_legacy_system)
				jobban_savebanfile()
			return 1
	return 0
