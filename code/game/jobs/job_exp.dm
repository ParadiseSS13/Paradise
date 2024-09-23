// Playtime requirements for special roles (hours)

GLOBAL_LIST_INIT(role_playtime_requirements, list(
	// NT ROLES
	ROLE_PAI = 0,
	ROLE_SENTIENT = 5,
	ROLE_ERT = 40, // High, because they're team-based, and we want ERT to be robust
	ROLE_DEATHSQUAD = 50, // Higher, see ERT and also they're OP as heck
	ROLE_TRADER = 20, // Very high, because they're an admin-spawned event with powerful items
	ROLE_DRONE = 10, // High, because they're like mini engineering cyborgs that can ignore the AI, ventcrawl, and respawn themselves

	// SOLO ANTAGS
	ROLE_TRAITOR = 5,
	ROLE_CHANGELING = 5,
	ROLE_WIZARD = 20,
	ROLE_VAMPIRE = 5,
	ROLE_BLOB = 20,
	ROLE_REVENANT = 3,
	ROLE_MORPH = 5,
	ROLE_DEMON = 5,
	ROLE_ELITE = 5,

	// DUO ANTAGS
	ROLE_GUARDIAN = 20,

	// TEAM ANTAGS
	// Higher numbers here, because they require more experience to be played correctly
	ROLE_REV = 10,
	ROLE_OPERATIVE = 20,
	ROLE_CULTIST = 20,
	ROLE_ALIEN = 10,
	ROLE_ABDUCTOR = 20,
))

// Admin Verbs

/client/proc/cmd_mentor_check_player_exp()	//Allows admins to determine who the newer players are.
	set category = "Admin"
	set name = "Check Player Playtime"
	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))
		return
	var/list/msg = list()
	msg  += "<html><meta charset='utf-8'><head><title>Playtime Report</title></head><body>"
	var/datum/job/theirjob
	var/jtext
	msg += "<table border ='1'><tr><th>Player</th><th>Job</th><th>Crew</th>"
	for(var/thisdept in EXP_DEPT_TYPE_LIST)
		msg += "<TH>[thisdept]</TH>"
	msg += "</TR>"
	for(var/client/C in GLOB.clients)
		if(C?.holder?.fakekey && !check_rights(R_ADMIN, FALSE))
			continue // Skip those in stealth mode if an admin isnt viewing the panel

		msg += "<TR>"
		if(check_rights(R_ADMIN, 0))
			msg += "<TD>[key_name_admin(C.mob)]</TD>"
		else
			msg += "<TD>[key_name_mentor(C.mob)]</TD>"

		jtext = "-"
		if(C.mob.mind && C.mob.mind.assigned_role)
			theirjob = SSjobs.GetJob(C.mob.mind.assigned_role)
			if(theirjob)
				jtext = theirjob.title
		msg += "<TD>[jtext]</TD>"

		msg += "<TD><A href='byond://?_src_=holder;getplaytimewindow=[C.mob.UID()]'>" + C.get_exp_type(EXP_TYPE_CREW) + "</a></TD>"
		msg += "[C.get_exp_dept_string()]"
		msg += "</TR>"

	msg += "</TABLE></BODY></HTML>"
	src << browse(msg.Join(""), "window=Player_playtime_check")


/datum/admins/proc/cmd_mentor_show_exp_panel(client/C)
	if(!C)
		to_chat(usr, "ERROR: Client not found.")
		return
	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))
		return
	var/body = "<html><head><title>Playtime for [C.key]</title></head><BODY><BR>Playtime:"
	body += C.get_exp_report()
	body += "</BODY></HTML>"
	usr << browse(body, "window=playerplaytime[C.ckey];size=550x615")


// Procs

/proc/role_available_in_playtime(client/C, role)
	// "role" is a special role defined in role_playtime_requirements above. e.g: ROLE_ERT. This is *not* a job title.
	if(!C)
		return 0
	if(!role)
		return 0
	if(!GLOB.configuration.jobs.enable_exp_restrictions)
		return 0
	if(GLOB.configuration.jobs.enable_exp_admin_bypass && check_rights(R_ADMIN, 0, C.mob))
		return 0
	var/list/play_records = params2list(C.prefs.exp)
	var/minimal_player_hrs = GLOB.role_playtime_requirements[role]
	if(!minimal_player_hrs)
		return 0
	var/req_mins = minimal_player_hrs * 60
	var/my_exp = text2num(play_records[EXP_TYPE_CREW])
	if(!isnum(my_exp))
		return req_mins
	return max(0, req_mins - my_exp)


/datum/job/proc/is_playable(client/C)
	if(!C)
		return FALSE // No client
	if(!length(exp_map))
		return TRUE // No EXP map, playable
	if(!GLOB.configuration.jobs.enable_exp_restrictions)
		return TRUE // No restrictions, playable
	if(GLOB.configuration.jobs.enable_exp_admin_bypass && check_rights(R_ADMIN, FALSE, C.mob))
		return TRUE // Admin user, playable

	// Now look through their EXP
	var/list/play_records = params2list(C.prefs.exp)
	var/success = TRUE

	// Check their requirements
	for(var/exp_type in exp_map)
		if(!(exp_type in play_records))
			success = FALSE
			continue
		if(text2num(exp_map[exp_type]) > text2num(play_records[exp_type]))
			success = FALSE

	return success

/datum/job/proc/get_exp_restrictions(client/C)
	// Its playable. There are no restrictions!
	if(is_playable(C))
		return null

	var/list/play_records = params2list(C.prefs.exp)
	var/list/innertext = list()

	for(var/exp_type in exp_map)
		if(!(exp_type in play_records))
			innertext += "[get_exp_format(exp_map[exp_type])] as [exp_type]"
			continue
		// You may be saying "Jeez why so many text2num()"
		// The DB loads these as strings for some reason, and I also dont trust coders to use ints in the job lists properly
		if(text2num(exp_map[exp_type]) > text2num(play_records[exp_type]))
			var/diff = text2num(exp_map[exp_type]) - text2num(play_records[exp_type])
			innertext += "[get_exp_format(diff)] as [exp_type]"

	if(length(innertext))
		return innertext.Join(", ")

	return null

/mob/proc/get_exp_report()
	if(client)
		return client.get_exp_report()
	else
		return "[src] has no client."

/client/proc/get_exp_report()
	if(!GLOB.configuration.jobs.enable_exp_tracking)
		return "Tracking is disabled in the server configuration file."
	var/list/play_records = params2list(prefs.exp)
	if(!length(play_records))
		return "[key] has no records."
	var/return_text = "<UL>"
	var/list/exp_data = list()
	for(var/category in GLOB.exp_jobsmap)
		if(text2num(play_records[category]))
			exp_data[category] = text2num(play_records[category])
		else
			exp_data[category] = 0
	for(var/dep in exp_data)
		if(exp_data[dep] > 0)
			if(exp_data[EXP_TYPE_LIVING] > 0)
				return_text += "<LI>[dep]: [get_exp_format(exp_data[dep])]</LI>"
	if(GLOB.configuration.jobs.enable_exp_admin_bypass && check_rights(R_ADMIN, 0, mob))
		return_text += "<LI>Admin</LI>"
	return_text += "</UL>"
	if(GLOB.configuration.jobs.enable_exp_restrictions)
		var/list/jobs_locked = list()
		var/list/jobs_unlocked = list()
		for(var/datum/job/job in SSjobs.occupations)
			if(length(job.exp_map))
				if(job.is_playable(mob.client))
					jobs_unlocked += job.title
				else
					jobs_locked += "[job.title] - [job.get_exp_restrictions(mob.client)]"
		if(length(jobs_unlocked))
			return_text += "<BR><BR>Jobs Unlocked:<UL><LI>"
			return_text += jobs_unlocked.Join("</LI><LI>")
			return_text += "</LI></UL>"
		if(length(jobs_locked))
			return_text += "<BR><BR>Jobs Not Unlocked:<UL><LI>"
			return_text += jobs_locked.Join("</LI><LI>")
			return_text += "</LI></UL>"
	return return_text

/client/proc/get_exp_type(etype)
	return get_exp_format(get_exp_type_num(etype))

/client/proc/get_exp_type_num(etype)
	var/list/play_records = params2list(prefs.exp)
	return text2num(play_records[etype])

/client/proc/get_exp_dept_string()
	var/list/play_records = params2list(prefs.exp)
	var/list/result_text = list()
	for(var/thistype in EXP_DEPT_TYPE_LIST)
		var/thisvalue = text2num(play_records[thistype])
		if(thisvalue)
			result_text.Add("<TD>[get_exp_format(thisvalue)]</TD>")
		else
			result_text.Add("<TD>-</TD>")
	return result_text.Join("")


/proc/get_exp_format(expnum)
	if(expnum > 60)
		return num2text(round(expnum / 60)) + "h"
	else if(expnum > 0)
		return num2text(expnum) + "m"
	else
		return "none"

