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

/datum/code_revision/New()
	commit_hash = rustg_git_revparse("HEAD")
	if(commit_hash)
		commit_date = rustg_git_commit_date(commit_hash)

/**
  * Code Revision Logging Helper
  *
  * Small proc to simplify logging all this stuff
  */
/datum/code_revision/proc/log_info()
	// Put revision info in the world log
	var/logmsg
	if(commit_hash && commit_date)
		logmsg = "Running ParaCode commit: [commit_hash] (Date: [commit_date])"
	else
		logmsg = "Unable to determine revision info! Code may not be running in a git repository."

	// Log it in all these
	log_world(logmsg)
	log_runtime_txt(logmsg)
	log_runtime_summary(logmsg)

/client/verb/get_revision_info()
	set name = "Get Revision Info"
	set category = "OOC"
	set desc = "Retrieve technical information about the server"

	var/list/msg = list()
	msg += "<span class='notice'><b>Server Revision Info</b></span>"
	// Round ID first
	msg += "<b>Round ID:</b> [GLOB.round_id ? GLOB.round_id : "NULL"]"

	// Commit info
	if(GLOB.revision_info.commit_hash && GLOB.revision_info.commit_date)
		msg += "<b>Server Commit:</b> <a href='[config.githuburl]/commit/[GLOB.revision_info.commit_hash]'>[GLOB.revision_info.commit_hash]</a> (Date: [GLOB.revision_info.commit_date])"
	else
		msg += "<b>Server Commit:</b> <i>Unable to determine</i>"


	// Show server BYOND version
	msg += "<b>Server BYOND Version:</b> [world.byond_version].[world.byond_build]"
	// And the clients for good measure
	msg += "<b>Client (your) BYOND Version:</b> [byond_version].[byond_build]"

	to_chat(usr, msg.Join("<br>"))
