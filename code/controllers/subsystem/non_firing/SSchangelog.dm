/*
	Subsystem core for ParadiseSS13 changelogs
	Author: AffectedArc07

	Basically this SS extracts changelogs from the past 30 days from the database, and cleanly formats them into HTML that the players can see
	It only runs the extraction on initialize to ensure that the changelog doesnt change mid round, and to reduce the amount of DB calls that need to be done
	The changelog entries are generated from the PHP scripts in tools/githubChangelogProcessor.php

	This SS also handles the checking of player CL dates and informing them if it has changed

*/

SUBSYSTEM_DEF(changelog)
	name = "Changelog"
	flags = SS_NO_FIRE
	var/current_cl_timestamp = "0" // Timestamp is seconds since UNIX epoch (1st January 1970). ITs also a string because BYOND doesnt like big numbers.
	var/ss_ready = FALSE // Is the SS ready? We dont want to run procs if we have not generated yet
	var/list/client/startup_clients_open = list() // Clients who connected before initialization who need the CL opening
	var/list/changelog_data = list() // Parsed changelog data

/datum/controller/subsystem/changelog/Initialize()
	// This entire subsystem relies on SQL being here.
	if(!SSdbcore.IsConnected())
		return

	var/datum/db_query/latest_cl_date = SSdbcore.NewQuery("SELECT CAST(UNIX_TIMESTAMP(date_merged) AS CHAR) AS ut FROM changelog ORDER BY date_merged DESC LIMIT 1")
	if(!latest_cl_date.warn_execute())
		qdel(latest_cl_date)
		// Abort if we cant do this
		return

	while(latest_cl_date.NextRow())
		current_cl_timestamp = latest_cl_date.item[1]

	qdel(latest_cl_date)

	if(!GenerateChangelogData()) // if this failed to generate
		to_chat(world, "<span class='alert'>WARNING: Changelog failed to generate. Please inform a coder/server dev</span>")
		return ..()

	ss_ready = TRUE

	// Update buttons for those who logged in
	for(var/client/C as anything in GLOB.clients)
		UpdatePlayerChangelogButton(C)

	// Now we can alert anyone who wanted to check the changelog
	for(var/client/C as anything in startup_clients_open)
		OpenChangelog(C)


/datum/controller/subsystem/changelog/proc/UpdatePlayerChangelogDate(client/C)
	if(!ss_ready)
		return // Only return here, we dont have to worry about a queue list because this will be called from ShowChangelog()

	C.prefs.lastchangelog = current_cl_timestamp

	var/datum/db_query/updatePlayerCLTime = SSdbcore.NewQuery(
		"UPDATE player SET lastchangelog=:lastchangelog WHERE ckey=:ckey", list(
			"lastchangelog" = current_cl_timestamp,
			"ckey" = C.ckey
		)
	)

	// We dont do anything with this query so we dont care about errors too much
	updatePlayerCLTime.warn_execute()
	qdel(updatePlayerCLTime)


/datum/controller/subsystem/changelog/proc/UpdatePlayerChangelogButton(client/C)
	// If SQL aint even enabled, or we aint ready just set the button to default style
	if(!SSdbcore.IsConnected() || !ss_ready)
		return

	// If we are ready, process the button style
	if(C.prefs.lastchangelog != current_cl_timestamp)
		winset(C, "rpane.changelog", "border=line;background-color=#bb7700;text-color=#FFFFFF;font-style=bold")
		to_chat(C, "<span class='boldnotice'>Changelog has changed since your last visit.</span>")

/datum/controller/subsystem/changelog/proc/OpenChangelog(client/C)
	// If SQL isnt enabled, dont even queue them, just tell them it wont work
	if(!SSdbcore.IsConnected())
		to_chat(C, "<span class='notice'>This server is not running with an SQL backend. Changelog is unavailable.</span>")
		return

	// If SQL is enabled but we aint ready, queue them up
	if(!ss_ready)
		startup_clients_open |= C
		to_chat(C, "<span class='notice'>The changelog system is still initializing. The changelog will open for you once it has initialized.</span>")
		return

	UpdatePlayerChangelogDate(C)
	UpdatePlayerChangelogButton(C)

	ui_interact(C.mob)

/client/verb/changes()
	set name = "Changelog"
	set desc = "View the changelog."
	set category = null
	// Just invoke the actual CL thing
	SSchangelog.OpenChangelog(src)

// This proc is the star of the show
/datum/controller/subsystem/changelog/proc/GenerateChangelogData()
	// This value will be returned if the proc crashes
	. = FALSE

	var/list/prs_to_process = list()

	// Grab all from last 30 days
	var/datum/db_query/pr_list_query = SSdbcore.NewQuery("SELECT DISTINCT pr_number FROM changelog WHERE date_merged BETWEEN NOW() - INTERVAL 30 DAY AND NOW() ORDER BY date_merged DESC")
	if(!pr_list_query.warn_execute())
		qdel(pr_list_query)
		return FALSE

	while(pr_list_query.NextRow())
		prs_to_process += text2num(pr_list_query.item[1])

	qdel(pr_list_query)

	// We put all these queries into a list so we can batch-execute them to avoid excess delays
	// We index these based on PR numbers. MAKE SURE YOU USE STRING INDICIES IN THIS IF YOU EVER TWEAK IT -aa
	var/list/datum/db_query/meta_queries = list()
	var/list/datum/db_query/entry_queries = list()

	// Create some queries for each PR
	for(var/pr_number in prs_to_process)
		var/datum/db_query/pr_meta = SSdbcore.NewQuery(
			"SELECT author, DATE_FORMAT(date_merged, '%Y-%m-%d at %T') AS date, CAST(UNIX_TIMESTAMP(date_merged) AS CHAR) AS ts FROM changelog WHERE pr_number = :prnum LIMIT 1",
			list("prnum" = pr_number)
		)

		// MAKE SURE YOU CAST TO STRINGS HERE!
		meta_queries["[pr_number]"] = pr_meta

		var/datum/db_query/pr_cl_entries = SSdbcore.NewQuery(
			"SELECT cl_type, cl_entry FROM changelog WHERE pr_number = :prnum",
			list("prnum" = pr_number)
		)

		// And here
		entry_queries["[pr_number]"] = pr_cl_entries

	ASSERT(length(meta_queries) == length(entry_queries)) // If these dont add up, something went very wrong

	// Explanation for parameters:
	// TRUE: We want warnings if these fail
	// FALSE: Do NOT qdel() queries here, otherwise they wont be read. At all.
	// TRUE: This is an assoc list, so it needs to prepare for that
	SSdbcore.MassExecute(meta_queries, TRUE, FALSE, TRUE)
	SSdbcore.MassExecute(entry_queries, TRUE, FALSE, TRUE)

	for(var/pr_number in prs_to_process)
		var/list/this_pr = list()

		this_pr["num"] = pr_number
		// Assemble metadata
		while(meta_queries["[pr_number]"].NextRow())
			this_pr["author"] = meta_queries["[pr_number]"].item[1]
			this_pr["merge_date"] = meta_queries["[pr_number]"].item[2]
			this_pr["merge_ts"] = meta_queries["[pr_number]"].item[3]

		var/list/cl_entries = list()

		while(entry_queries["[pr_number]"].NextRow())
			var/list/this_entry = list()
			this_entry["etype"] = entry_queries["[pr_number]"].item[1]
			this_entry["etext"] = entry_queries["[pr_number]"].item[2]
			cl_entries += list(this_entry) // Double list required or it merges them

		this_pr["entries"] = cl_entries

		changelog_data += list(this_pr)


	// Cleanup queries
	QDEL_LIST_ASSOC_VAL(meta_queries)
	QDEL_LIST_ASSOC_VAL(entry_queries)

	// Make sure we return TRUE so we know it worked
	return TRUE

/datum/controller/subsystem/changelog/ui_static_data(mob/user)
	var/list/data = list()
	data["cl_data"] = changelog_data
	data["last_cl"] = user.client.prefs.lastchangelog_2

	return data

/datum/controller/subsystem/changelog/ui_state(mob/user)
	return GLOB.always_state

/datum/controller/subsystem/changelog/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChangelogView", name)
		ui.set_autoupdate(FALSE)
		ui.open()


// Topic handler so that PRs and forums and stuff open in another window
/datum/controller/subsystem/changelog/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		// Takes a PR number as argument
		if("open_pr")
			var/pr_num = params["pr_number"]
			if(GLOB.configuration.url.github_url)
				if(tgui_alert(usr, "This will open PR #[pr_num] in your browser. Are you sure?", "Open PR", list("Yes", "No")) != "Yes")
					return

				// If the github URL in the config has a trailing slash, it doesnt matter here, thankfully github accepts having a double slash: https://github.com/org/repo//pull/1
				var/url = "[GLOB.configuration.url.github_url]/pull/[pr_num]"
				usr << link(url)
				return TRUE

			to_chat(usr, "<span class='danger'>The GitHub URL is not set in the server configuration. PRs cannot be opened from changelog view. Please inform the server host.</span>")

