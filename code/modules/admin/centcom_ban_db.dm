// CCBDB = CentCom Ban DB
// This file contains procs for handling all requests to the CCBDB API, hosted by Bobbahbrown
// API Documentation: https://centcom.melonmesa.com/swagger/index.html
// Please refer to said documentation before editing any of the stuff in here, otherwise it will likely break


/**
  * CCBDB Lookup Initiator
  *
  * Checks the configuration before invoking the request to the CCBDB server.
  *
  * Arguments:
  * * ckey - ckey to be looked up
  */
/datum/admins/proc/create_ccbdb_lookup(ckey)
	// Bail if disabled
	if(!GLOB.configuration.url.centcom_ban_db_url)
		to_chat(usr, "<span class='warning'>The CentCom Ban DB lookup is disabled. Please inform a maintainer or server host.</span>")
		return
	// Bail if no ckey is supplied
	if(!ckey)
		return

	var/datum/callback/cb = CALLBACK(src, TYPE_PROC_REF(/datum/admins, ccbdb_lookup_callback), usr, ckey)
	SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_GET, "[GLOB.configuration.url.centcom_ban_db_url][ckey]", proc_callback=cb)

/**
  * CCBDB Lookup Callback
  *
  * Callback assigned in [/datum/admins/proc/create_ccbdb_lookup] for async operations without a sleep()
  *
  * Arguments:
  * * user - Mob calling the lookup so the UI can be opened
  * * ckey - Ckey being looked up
  * * response - [/datum/http_response] passed through from [SShttp]
  */
/datum/admins/proc/ccbdb_lookup_callback(mob/user, ckey, datum/http_response/response)
	// If the admin DC'd during the lookup, dont try and do things
	if(!user)
		return

	// Bail if it errored
	if(response.errored)
		to_chat(user, "<span class='warning'>Error connecting to CentCom Ban DB. Please inform a maintainer or server host.</span>")
		return

	// Bail if the code isnt 200
	if(response.status_code != 200)
		to_chat(user, "<span class='warning'>Error performing CentCom Ban DB lookup (Code: [response.status_code])</span>")
		return

	var/list/popup_data = list()

	// A body of "[]" means there were no bans on record for the user
	if(response.body == "\[]")
		popup_data += "<center><h3>0 bans detected for [ckey]</h3></center>"
	else
		var/list/bans = list()
		// Wrap this in try/catch because JSON is a finnicky bastard
		try
			bans = json_decode(response.body)
			// Yes I threw a ternary in because I am that obsessed over OCD
			popup_data += "<center><h3>[length(bans)] ban[length(bans) == 1 ? "" : "s"] detected for [ckey]</h3></center>"
			// These vars are also just for OCD (Adding a <hr> between each ban but the last)
			var/total_bans = length(bans)
			var/index = 0
			for(var/list/ban in bans)
				index++
				// For anyone else who edits this. SANITIZE ALL THE DATA. OTHER SERVERS MAY HAVE BAD ACTORS WHO TRY AND XSS PEOPLE.
				popup_data += "<b>Server:</b> [sanitize(ban["sourceName"])] ([sanitize(ban["sourceRoleplayLevel"])] RP)<br>"

				var/ban_status
				// If the ban is active, its, well, active
				if(ban["active"] == TRUE) // The == TRUE is intentional here. Dont remove it.
					ban_status = "<font color='red'>Ban Active</font>"
				// If they have an entry of being unbanned by someone, its been appealed
				else if(ban["unbannedBy"])
					ban_status = "<font color='green'>Ban Appealed</font>"
				else
					ban_status = "<font color='cyan'>Ban Expired</font>"
				popup_data += "<b>Status:</b> [ban_status]<br>"

				// All the other stats
				popup_data += "<b>Ban Type:</b> [sanitize(ban["type"])]<br>"
				popup_data += "<b>Banning Admin:</b> [sanitize(ban["bannedBy"])]<br>"
				popup_data += "<b>Ban Date:</b> [sanitize(ban["bannedOn"])]<br>"
				var/expiration = ban["expires"]
				popup_data += "<b>Expires:</b> [expiration ? "[sanitize(expiration)]" : "Permanent"]<br>"
				popup_data += "<b>Ban Reason:</b> [sanitize(ban["reason"])]<br>"

				// If its a job ban, tell the admin the job list
				if(ban["type"] == "Job")
					var/list/jobs = ban["jobs"]
					popup_data += "<b>Jobs: </b>[sanitize(english_list(jobs))]<br>"

				// Add a newline between bans if its not the last one
				if(index != total_bans)
					popup_data += "<hr>"

		catch
			to_chat(user, "<span class='warning'>Error parsing JSON data from CentCom Ban DB lookup. Please inform a maintainer.</span>")
			return

	var/datum/browser/popup = new(user, "ccbdblookup-[ckey]", "<div align='center'>CC Ban DB Lookup - [ckey]</div>", 700, 600)
	popup.set_content(popup_data.Join())
	popup.open(FALSE)

// Just a simple verb so admins can do manual lookups
/client/proc/ccbdb_lookup_ckey()
	set name = "Global Ban DB Lookup"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/input_ckey = input(usr, "Please enter a ckey to lookup", "Global Ban DB Lookup")
	holder.create_ccbdb_lookup(input_ckey)
