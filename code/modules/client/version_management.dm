/**
  * # BYOND Version
  *
  * Datum to easier represent a BYOND version in code
  *
  * Used for the version warning/blacklist system
  * Provides an easy means of tacking information onto a build, and a flag whether to just warn the client, or blacklist it entirely
  *
  */
/datum/byond_version
	/// Response type (Either CLIENT_BUILD_WARNING or CLIENT_BUILD_BLACKLISTED)
	var/response_type
	/// Details on why this build is warned/blacklisted
	var/details

/**
  * Proc to format BYOND version info and datumise it
  *
  * Basically simplifies creation of BYOND build info, and returns a datum with all the info
  *
  * Arguments:
  * * restype - What response to give the client if they connect with this build (Either CLIENT_BUILD_WARNING or CLIENT_BUILD_BLACKLISTED)
  * * info - Details on why this version is flagged
  */
/proc/format_byond_version_info(restype, info)
	var/datum/byond_version/BV = new
	BV.response_type = restype
	BV.details = info
	return BV

/**
  * Proc to register all flagged BYOND versions
  *
  * This proc is called from world/New(), and is for registering BYOND versions
  * Add versions to flag into this proc, following the format of the others
  * Please keep these in build version order. Please.
  * VERSION NUMBER MUST BE A STRING BECAUSE OTHERWISE IT USES INDEXES NOT ASSOCIATIONS
  */
/proc/register_flagged_byond_versions()
	// Do not put a . at the end of the details, otherwise it will double-period when the client sees it
	GLOB.flagged_byond_versions["1407"] = format_byond_version_info(CLIENT_BUILD_BLACKLISTED, "This client version contains a bug preventing display overrides from working, which leads to clients being able to see atoms they shouldn't be able to see")
	GLOB.flagged_byond_versions["1408"] = format_byond_version_info(CLIENT_BUILD_BLACKLISTED, "This client version contains a bug preventing display overrides from working, which leads to clients being able to see atoms they shouldn't be able to see")
	GLOB.flagged_byond_versions["1428"] = format_byond_version_info(CLIENT_BUILD_BLACKLISTED, "This client version contains a bug which causes right-click menus to show too many verbs")
	GLOB.flagged_byond_versions["1530"] = format_byond_version_info(CLIENT_BUILD_WARNING, "This client version contains a bug which can cause crashes when near atoms with maptext (Brig cell timers for example)")

/**
  * Proc to check a client against flagged BYOND versions
  *
  * This proc is called from client/New(), and is for checking BYOND versions
  * Called on a timer so that chat output cal actually load
  */

/client/proc/byond_check()
	// Check their client minor version against the list of flagged ones
	if("[byond_build]" in GLOB.flagged_byond_versions)
		var/datum/byond_version/BV = GLOB.flagged_byond_versions["[byond_build]"]
		switch(BV.response_type)
			// Only warn them
			if(CLIENT_BUILD_WARNING)
				to_chat(src, "<span class='alert'><b>WARNING:</b> You are currently playing on a non-recommended client version ([byond_build]). You may experience the following issues: <span class='ancient'>[BV.details]</span>. You have been warned.</span>")
			// Client is blacklisted, warn and kick
			if(CLIENT_BUILD_BLACKLISTED)
				to_chat(src, "<span class='alert'><b>ALERT:</b> You are currently playing on a blacklisted client version ([byond_build]). The reasoning for this is: <span class='ancient'>[BV.details]</span>. Please update your client. You have been kicked from the server.</span>")
				qdel(src)
				return // And were done here
