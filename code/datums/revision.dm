GLOBAL_DATUM_INIT(revision_info, /datum/code_revision, new)
GLOBAL_PROTECT(revision_info) // Dont mess with this

/**
  * Code Revision Datum
  *
  * Allows the server code to be aware of the Git environment it is running in, and lets commit hash be viewed
  */
/datum/code_revision
	/// Current commit hash the server is running
	var/commit_hash
	/// Date that this commit was made
	var/commit_date
	/// Origin commit (Only set if running TGS, and will only be different if the server is running testmerges)
	var/origin_commit
	/// List of testmerges (If applicable)
	var/list/testmerges = list()

// Pull info from the rust DLL
/datum/code_revision/New()
	commit_hash = rustlibs_git_revparse("HEAD")
	if(commit_hash)
		commit_date = rustlibs_git_commit_date(commit_hash)

// Pull info from TGS
/datum/code_revision/proc/load_tgs_info()
	testmerges = world.TgsTestMerges()
	var/datum/tgs_revision_information/revinfo = world.TgsRevision()
	if(revinfo)
		commit_hash = revinfo.commit
		origin_commit = revinfo.origin_commit
		commit_date = revinfo.timestamp

/**
  * Code Revision Logging Helper
  *
  * Small proc to simplify logging all this stuff
  */
/datum/code_revision/proc/log_info()
	// Put revision info in the world log
	var/list/logmsgs = list()
	if(commit_hash && commit_date)
		logmsgs += "Running ParaCode commit: [commit_hash] (Date: [commit_date])"
	else
		logmsgs += "Unable to determine revision info! Code may not be running in a git repository."

	// Check if we were on TGS
	if(world.TgsAvailable())
		if(origin_commit && (commit_hash != origin_commit)) // Commits are different, theres likely a testmerge
			logmsgs += "Origin commit: [origin_commit]"
		if(length(testmerges))
			logmsgs += "The following PRs are testmerged:"
			for(var/pr in testmerges)
				var/datum/tgs_revision_information/test_merge/tm = pr
				logmsgs += "PR #[tm.number] at commit [tm.head_commit]"
				// Log these in blackbox so they can be attributed to round IDs easier in the future
				SSblackbox.record_feedback("associative", "testmerged_prs", 1, list("number" = "[tm.number]", "commit" = "[tm.head_commit]", "title" = "[tm.title]", "author" = "[tm.author]"))

	var/logmsg = logmsgs.Join("\n")

	// Log it in all these
	log_world(logmsg)
	log_runtime_txt(logmsg)
	log_runtime_summary(logmsg)


/**
  * Testmerge Chat Message Helper
  *
  * Formats testmerged PRs into a nice message
  * Arguments:
  * * header - Should a header be sent too
  */
/datum/code_revision/proc/get_testmerge_chatmessage(header = FALSE)
	var/list/msg = list()
	if(header)
		msg += "<span class='notice'>The following PRs are currently testmerged:</span>"

	for(var/pr in GLOB.revision_info.testmerges)
		var/datum/tgs_revision_information/test_merge/tm = pr
		msg += "- PR <a href='[tm.url]'>#[tm.number] - [tm.title]</a>"

	return msg.Join("<br>")

/client/verb/get_revision_info()
	set name = "Get Revision Info"
	set category = "OOC"
	set desc = "Retrieve technical information about the server"

	var/list/msg = list()
	msg += "<span class='notice'><b>Server Revision Info</b></span>"
	// Round ID first
	msg += "<b>Round ID:</b> [GLOB.round_id ? GLOB.round_id : "NULL"]"
	#ifdef PARADISE_PRODUCTION_HARDWARE
	msg += "<b>Production-hardware specific compile:</b> Yes"
	#else
	msg += "<b>Production-hardware specific compile:</b> No"
	#endif

	// Commit info
	if(GLOB.revision_info.commit_hash && GLOB.revision_info.commit_date && GLOB.configuration.url.github_url)
		msg += "<b>Server Commit:</b> <a href='[GLOB.configuration.url.github_url]/commit/[GLOB.revision_info.commit_hash]'>[GLOB.revision_info.commit_hash]</a> (Date: [GLOB.revision_info.commit_date])"
		if(GLOB.revision_info.origin_commit && (GLOB.revision_info.commit_hash != GLOB.revision_info.origin_commit))
			msg += "<b>Origin Commit:</b> <a href='[GLOB.configuration.url.github_url]/commit/[GLOB.revision_info.origin_commit]'>[GLOB.revision_info.origin_commit]</a>"
	else
		msg += "<b>Server Commit:</b> <i>Unable to determine</i>"

	msg += "<b>RUST-G Build</b>: [rustg_get_version()]"

	if(world.TgsAvailable())
		var/datum/tgs_version/tgs_ver = world.TgsVersion()
		var/datum/tgs_version/api_ver = world.TgsApiVersion()
		msg += "<b>TGS Version</b>: [tgs_ver.deprefixed_parameter] (API: [api_ver.deprefixed_parameter])"

	if(world.TgsAvailable() && length(GLOB.revision_info.testmerges))
		msg += "<b>Active Testmerges:</b>"
		msg += GLOB.revision_info.get_testmerge_chatmessage(FALSE)

	// Show server BYOND version
	msg += "<b>Server BYOND Version:</b> [world.byond_version].[world.byond_build]"
	// And the clients for good measure
	msg += "<b>Client (your) BYOND Version:</b> [byond_version].[byond_build]"

	to_chat(usr, chat_box_examine(msg.Join("<br>")))
