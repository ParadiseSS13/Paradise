/atom/proc/investigate_log(message, subject)
	if(!message || !subject)
		return
	var/F = wrap_file("[GLOB.log_directory]/[subject].html")
	var/turf/T = get_turf(src)
	WRITE_FILE(F, "[time_stamp()] [src.UID()] ([T.x],[T.y],[T.z]) || [src] [message]<br>")

//ADMINVERBS
/client/proc/investigate_show()
	set name = "Investigate"
	set category = "Admin"
	if(!check_rights(R_ADMIN))
		return

	var/list/investigates = list(
		INVESTIGATE_ACCESSCHANGES,
		INVESTIGATE_ATMOS,
		INVESTIGATE_BOMB,
		INVESTIGATE_BOTANY,
		INVESTIGATE_CARGO,
		INVESTIGATE_CRAFTING,
		INVESTIGATE_ENGINE,
		INVESTIGATE_EXPERIMENTOR,
		INVESTIGATE_GRAVITY,
		INVESTIGATE_HALLUCINATIONS,
		INVESTIGATE_TELEPORTATION,
		INVESTIGATE_RECORDS,
		INVESTIGATE_RESEARCH,
		INVESTIGATE_SYNDIE_CARGO,
		INVESTIGATE_WIRES,
	)

	var/list/logs_present = list("notes", "watchlist", "hrefs")
	var/list/logs_missing = list("---")

	for(var/subject in investigates)
		var/temp_file = file("[GLOB.log_directory]/[subject].html")
		if(fexists(temp_file))
			logs_present += subject
		else
			logs_missing += "[subject] (empty)"

	var/list/combined = sortList(logs_present) + sortList(logs_missing)

	var/selected = input("Investigate what?", "Investigate") as null|anything in combined

	if(!(selected in combined) || selected == "---")
		return

	selected = replacetext(selected, " (empty)", "")

	switch(selected)
		if("notes")
			show_note()

		if("watchlist")
			watchlist_show()

		if("hrefs")				//persistant logs and stuff
			if(config && config.log_hrefs)
				if(GLOB.world_href_log)
					src << browse(wrap_file(GLOB.world_href_log), "window=investigate[selected];size=800x300")
				else
					to_chat(src, "<font color='red'>Error: admin_investigate: No href logfile found.</font>")
					return
			else
				to_chat(src, "<font color='red'>Error: admin_investigate: Href Logging is not on.</font>")
				return

		else //general one-round-only stuff
			var/F = file("[GLOB.log_directory]/[selected].html")
			if(!fexists(F))
				to_chat(src, "<class span='danger'>No [selected] logfile was found.</span>")
				return
			F = {"<meta charset="UTF-8">"} + wrap_file2text(F)
			src << browse(F,"window=investigate[selected];size=800x300")
