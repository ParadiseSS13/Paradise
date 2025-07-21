/// This proc allows download of past server logs saved within the data/logs/ folder.
/client/proc/getserverlogs()
	set name = "Get Server Logs"
	set desc = "View/retrieve logfiles."
	set category = "Admin"

	if(!check_rights(R_ADMIN|R_VIEWLOGS))
		return

	access_file_by_browsing_path(usr, "data/logs/")

/// This proc allows download of past server logs saved within the data/logs/ folder by specifying a specific round ID.
/client/proc/get_server_logs_by_round_id()
	set name = "Get Round Logs"
	set desc = "View/retrieve logfiles for a given round."
	set category = "Admin"

	if(!check_rights(R_ADMIN|R_VIEWLOGS))
		return

	var/round_id = input(usr, "Enter a round ID.", "Enter Round ID", "[GLOB.round_id]") as null|text
	if(isnull(round_id))
		return

	var/round_path = "[GLOB.log_directory]/"
	if(round_id != "[GLOB.round_id]")
		var/datum/db_query/query = SSdbcore.NewQuery(
			"SELECT UNIX_TIMESTAMP(initialize_datetime) AS dt FROM round WHERE id = :id",
			list(id = round_id)
		)
		if(!query.warn_execute())
			qdel(query)
			to_chat(usr, "Could not check database for round [round_id].")
			return

		if(!query.NextRow())
			qdel(query)
			to_chat(usr, "Could not find round [round_id] in database.")
			return

		// convert unix timestamp in seconds to byond timestamp in deciseconds
		var/round_datetime = (query.item[1] - BYOND_EPOCH_UNIX) * 10
		round_path = "data/logs/[time2text(round_datetime, "YYYY/MM-Month/DD-Day", 0)]/round-[round_id]/"
		qdel(query)

	if(!fexists(round_path))
		log_debug("Logs for round `[round_id]` not found in path `[round_path]`.")
	access_file_by_browsing_path(usr, round_path)

/proc/access_file_by_browsing_path(mob/user, path)
	if(!user.client)
		return

	var/filename = user.client.browse_files(path)
	if(!filename)
		return

	if(user.client.file_spam_check())
		return

	message_admins("[key_name_admin(user)] accessed file: [filename]")
	switch(alert("View (in game), Open (in your system's text editor), or Download?", filename, "View", "Open", "Download"))
		if("View")
			user << browse("<pre style='word-wrap: break-word;'>[html_encode(wrap_file2text(wrap_file(filename)))]</pre>", list2params(list("window" = "viewfile.[filename]")))
		if("Open")
			user << run(wrap_file(filename))
		if("Download")
			user << ftp(wrap_file(filename))
		else
			return
	to_chat(user, "Attempting to send [filename], this may take a fair few minutes if the file is very large.")
