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
	var/list/startup_clients_button = list() // Clients who connected before initialization who need their button color updating
	var/list/startup_clients_open = list() // Clients who connected before initialization who need the CL opening
	var/changelogHTML = "" // HTML that the changelog will use to display

/datum/controller/subsystem/changelog/Initialize()
	// This entire subsystem relies on SQL being here.
	if(!SSdbcore.IsConnected())
		return ..()

	var/datum/db_query/latest_cl_date = SSdbcore.NewQuery("SELECT CAST(UNIX_TIMESTAMP(date_merged) AS CHAR) AS ut FROM [format_table_name("changelog")] ORDER BY date_merged DESC LIMIT 1")
	if(!latest_cl_date.warn_execute())
		qdel(latest_cl_date)
		// Abort if we cant do this
		return ..()

	while(latest_cl_date.NextRow())
		current_cl_timestamp = latest_cl_date.item[1]
	qdel(latest_cl_date)

	if(!GenerateChangelogHTML()) // if this failed to generate
		to_chat(world, "<span class='alert'>WARNING: Changelog failed to generate. Please inform a coder/server dev</span>")
		return ..()

	ss_ready = TRUE
	// Now we can alert anyone who wanted to check the changelog
	for(var/x in startup_clients_button)
		var/client/C = x
		UpdatePlayerChangelogButton(C)

	// Now we can alert anyone who wanted to check the changelog
	for(var/client/C in startup_clients_open)
		OpenChangelog(C)

	return ..()


/datum/controller/subsystem/changelog/proc/UpdatePlayerChangelogDate(client/C)
	if(!ss_ready)
		return // Only return here, we dont have to worry about a queue list because this will be called from ShowChangelog()
	// Technically this is only for the date but we can also do the UI button at the same time
	var/datum/preferences/P = GLOB.preferences_datums[C.ckey]
	if(P.toggles & PREFTOGGLE_UI_DARKMODE)
		winset(C, "rpane.changelog", "background-color=#40628a;font-color=#ffffff;font-style=none")
	else
		winset(C, "rpane.changelog", "background-color=none;font-style=none")
	C.prefs.lastchangelog = current_cl_timestamp

	var/datum/db_query/updatePlayerCLTime = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET lastchangelog=:lastchangelog WHERE ckey=:ckey",
		list(
			"lastchangelog" = current_cl_timestamp,
			"ckey" = C.ckey
		)
	)
	// We dont do anything with this query so we dont care about errors too much
	updatePlayerCLTime.warn_execute()
	qdel(updatePlayerCLTime)


/datum/controller/subsystem/changelog/proc/UpdatePlayerChangelogButton(client/C)
	// If SQL aint even enabled, just set the button to default style
	if(!SSdbcore.IsConnected())
		if(C.prefs.toggles & PREFTOGGLE_UI_DARKMODE)
			winset(C, "rpane.changelog", "background-color=#40628a;text-color=#FFFFFF")
		else
			winset(C, "rpane.changelog", "background-color=none;text-color=#000000")
		return

	// If SQL is enabled but we aint ready, queue them up, and use the default style
	if(!ss_ready)
		startup_clients_button |= C
		if(C.prefs.toggles & PREFTOGGLE_UI_DARKMODE)
			winset(C, "rpane.changelog", "background-color=#40628a;text-color=#FFFFFF")
		else
			winset(C, "rpane.changelog", "background-color=none;text-color=#000000")
		return

	// Sanity check to ensure clients still exist (If a client DCs mid startup this would runtime)
	if(C && C.prefs)
		// If we are ready, process the button style
		if(C.prefs.lastchangelog != current_cl_timestamp)
			winset(C, "rpane.changelog", "background-color=#bb7700;text-color=#FFFFFF;font-style=bold")
			to_chat(C, "<span class='info'>Changelog has changed since your last visit.</span>")
		else
			if(C.prefs.toggles & PREFTOGGLE_UI_DARKMODE)
				winset(C, "rpane.changelog", "background-color=#40628a;text-color=#FFFFFF")
			else
				winset(C, "rpane.changelog", "background-color=none;text-color=#000000")


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

	var/datum/browser/cl_popup = new(C.mob, "changelog", "Changelog", 700, 800)
	cl_popup.set_content(changelogHTML)
	cl_popup.open()

/client/verb/changes()
	set name = "Changelog"
	set desc = "View the changelog."
	set category = "OOC"
	// Just invoke the actual CL thing
	SSchangelog.OpenChangelog(src)

// Helper to turn CL types into a fontawesome icon instead of an image
// The colors are #28a745 for green, #fd7e14 for orange, and #dc3545 for red.
// These colours are from bootstrap and look good with black and white
/datum/controller/subsystem/changelog/proc/Text2Icon(text)
	switch(text)
		if("FIX")
			return "<i title='Fix' class='fas fa-tools'></i></span>" // Fixes are white because while they are good, they have no negative coutnerpart
		if("WIP")
			return "<span style='color: #fd7e14;'><i title='Work In Progress' class='fas fa-hard-hat'></i></span>" // WIP stuff is orange because new code is good but its not done yet
		if("TWEAK")
			return "<i title='Tweak' class='fas fa-sliders-h'></i>" // Tweaks are white because they could be good or bad, and theres no specific add or remove
		if("SOUNDADD")
			return "<span style='color: #28a745;'><i title='Sound Added' class='fas fa-volume-up'></i></span>" // Sound additions are green because its something new
		if("SOUNDDEL")
			return "<span style='color: #dc3545;'><i title='Sound Removed' class='fas fa-volume-mute'></i></span>" // Sound removals are red because something has been removed
		if("CODEADD")
			return "<span style='color: #28a745;'><i title='Code Addition' class='fas fa-plus'></i></span>" // Code additions are green because its something new
		if("CODEDEL")
			return "<span style='color: #dc3545;'><i title='Code Removal' class='fas fa-minus'></i></span>" // Code removals are red becuase someting has been removed
		if("IMAGEADD")
			return "<span style='color: #28a745;'><i title='Image/Sprite Addition' class='fas fa-folder-plus'></i></span>" // Image additions are green because something has been added
		if("IMAGEDEL")
			return "<span style='color: #dc3545;'><i title='Image/Sprite Removal' class='fas fa-folder-minus'></i></span>" // Image removals are red because something has been removed
		if("SPELLCHECK")
			return "<i title='Spelling/Grammar Fix' class='fas fa-font'></i>" // Spellcheck is white because theres no dedicated negative to it, so theres no red for it to collate with
		if("EXPERIMENT")
			return "<span style='color: #fd7e14;'><i title='Experimental' class='fas fa-exclamation-triangle'></i></span>" // Experimental stuff is orange because while its a new feature, its unstable
		else // Just incase the DB somehow breaks
			return "<span style='color: #28a745;'><i title='Code Addition' class='fas fa-plus'></i></span>" // Same here

// This proc is the star of the show
/datum/controller/subsystem/changelog/proc/GenerateChangelogHTML()
	. = FALSE
	// Modify the code below to modify the header of the changelog
	var/changelog_header = {"
		<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css" rel="stylesheet">
		<title>ParadiseSS13 Changelog</title>
		<link rel='styelsheet' href='fontawesome.min.css'>
		<center>
			<p style='font-size: 20px'><b>Paradise Station Changelog</b></p>
			<p><a href='?src=[UID()];openPage=forum'>Forum</a> - <a href='?src=[UID()];openPage=wiki'>Wiki</a> - <a href='?src=[UID()];openPage=github'>GitHub</a></p>
		</center>
	"}

	var/list/prs_to_process = list()
	// Grab all from last 30 days
	var/datum/db_query/pr_list_query = SSdbcore.NewQuery("SELECT DISTINCT pr_number FROM changelog WHERE date_merged BETWEEN NOW() - INTERVAL 30 DAY AND NOW() ORDER BY date_merged DESC")
	if(!pr_list_query.warn_execute())
		qdel(pr_list_query)
		return FALSE

	while(pr_list_query.NextRow())
		prs_to_process += text2num(pr_list_query.item[1])
	qdel(pr_list_query)

	// Load in the header
	changelogHTML += changelog_header

	// We put all these queries into a list so we can batch-execute them to avoid excess delays
	// We index these based on PR numbers. MAKE SURE YOU USE STRING INDICIES IN THIS IF YOU EVER TWEAK IT -aa
	var/list/datum/db_query/meta_queries = list()
	var/list/datum/db_query/entry_queries = list()

	// Create some queries for each PR
	for(var/pr_number in prs_to_process)
		var/datum/db_query/pr_meta = SSdbcore.NewQuery(
			"SELECT author, DATE_FORMAT(date_merged, '%Y-%m-%d at %T') AS date FROM changelog WHERE pr_number = :prnum LIMIT 1",
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
		// Initial declarations
		var/pr_block = "" // HTML for the changelog section
		var/author = "" // Author of the PR
		var/merge_date = "" // Timestamp of when the PR was merged

		// Assemble metadata
		while(meta_queries["[pr_number]"].NextRow())
			author = meta_queries["[pr_number]"].item[1]
			merge_date = meta_queries["[pr_number]"].item[2]

		// Now for each actual entry
		pr_block += "<div class='statusDisplay'>"
		pr_block += "<p class='white'><a href='?src=[UID()];openPR=[pr_number]'>#[pr_number]</a> by <b>[author]</b> (Merged on [merge_date])</span>"

		while(entry_queries["[pr_number]"].NextRow())
			pr_block += "<p>[Text2Icon(entry_queries["[pr_number]"].item[1])] [entry_queries["[pr_number]"].item[2]]</p>"

		pr_block += "</div><br>"

		changelogHTML += pr_block

	// Cleanup queries
	QDEL_LIST_ASSOC_VAL(meta_queries)
	QDEL_LIST_ASSOC_VAL(entry_queries)

	// Make sure we return TRUE so we know it worked
	return TRUE


// Topic handler so that PRs and forums and stuff open in another window
/datum/controller/subsystem/changelog/Topic(href, href_list)
	// Handler to open pages in your browser instead of inside the CL window
	// Yes usr.client is gross here but src is the subsystem
	// Takes the page to open as an argument
	if(href_list["openPage"])
		switch(href_list["openPage"])
			if("forum")
				usr.client.forum()
			if("wiki")
				usr.client.wiki()
			if("github")
				usr.client.github()
	// Takes a PR number as argument
	if(href_list["openPR"])
		if(config.githuburl)
			if(alert("This will open PR #[href_list["openPR"]] in your browser. Are you sure?",,"Yes","No")=="No")
				return
			// If the github URL in the config has a trailing slash, it doesnt matter here, thankfully github accepts having a double slash: https://github.com/org/repo//pull/1
			var/url = "[config.githuburl]/pull/[href_list["openPR"]]"
			usr << link(url)
		else
			to_chat(usr, "<span class='danger'>The GitHub URL is not set in the server configuration. PRs cannot be opened from changelog view. Please inform the server host.</span>")

