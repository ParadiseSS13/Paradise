// Playtime requirements for special roles (hours)

var/global/list/role_playtime_requirements = list(
	// NT ROLES
	ROLE_PAI = 0,
	ROLE_POSIBRAIN = 5, // Same as cyborg job.
	ROLE_SENTIENT = 5,
	ROLE_ERT = 10, // High, because they're team-based, and we want ERT to be robust
	ROLE_DEATHSQUAD = 10,
	ROLE_TRADER = 20, // Very high, because they're an admin-spawned event with powerful items
	ROLE_DRONE = 10, // High, because they're like mini engineering cyborgs that can ignore the AI, ventcrawl, and respawn themselves

	// SOLO ANTAGS
	ROLE_TRAITOR = 3,
	ROLE_CHANGELING = 3,
	ROLE_WIZARD = 3,
	ROLE_VAMPIRE = 3,
	ROLE_BLOB = 3,
	ROLE_REVENANT = 3,
	ROLE_BORER = 3,
	ROLE_NINJA = 3,
	ROLE_MORPH = 3,
	ROLE_DEMON = 3,

	// DUO ANTAGS
	ROLE_GUARDIAN = 5,
	ROLE_GSPIDER = 5,

	// TEAM ANTAGS
	// Higher numbers here, because they require more experience to be played correctly
	ROLE_SHADOWLING = 10,
	ROLE_REV = 10,
	ROLE_OPERATIVE = 10,
	ROLE_CULTIST = 10,
	ROLE_RAIDER = 10,
	ROLE_ALIEN = 10,
	ROLE_ABDUCTOR = 10,
)

// Client Verbs

/client/verb/cmd_check_own_playtime()
	set category = "Special Verbs"
	set name = "Check my playtime"

	if(!config.use_exp_tracking)
		to_chat(src, "<span class='warning'>Playtime tracking is not enabled.</span>")
		return

	to_chat(src, "<span class='notice'>Your [EXP_TYPE_CREW] playtime is [get_exp_type(EXP_TYPE_CREW)].</span>")

// Admin Verbs

/client/proc/cmd_mentor_check_player_exp()	//Allows admins to determine who the newer players are.
	set category = "Admin"
	set name = "Check Player Playtime"
	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))
		return
	var/msg = "<html><head><title>Playtime Report</title></head><body>"
	var/datum/job/theirjob
	var/jtext
	msg += "<TABLE border ='1'><TR><TH>Player</TH><TH>Job</TH><TH>Crew</TH>"
	for(var/thisdept in EXP_DEPT_TYPE_LIST)
		msg += "<TH>[thisdept]</TH>"
	msg += "</TR>"
	for(var/client/C in GLOB.clients)
		msg += "<TR>"
		if(check_rights(R_ADMIN, 0))
			msg += "<TD>[key_name_admin(C.mob)]</TD>"
		else
			msg += "<TD>[key_name_mentor(C.mob)]</TD>"

		jtext = "-"
		if(C.mob.mind && C.mob.mind.assigned_role)
			theirjob = job_master.GetJob(C.mob.mind.assigned_role)
			if(theirjob)
				jtext = theirjob.title
		msg += "<TD>[jtext]</TD>"

		msg += "<TD><A href='?_src_=holder;getplaytimewindow=[C.mob.UID()]'>" + C.get_exp_type(EXP_TYPE_CREW) + "</a></TD>"
		msg += "[C.get_exp_dept_string()]"
		msg += "</TR>"

	msg += "</TABLE></BODY></HTML>"
	src << browse(msg, "window=Player_playtime_check")


/datum/admins/proc/cmd_mentor_show_exp_panel(var/client/C)
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
	if(!config.use_exp_restrictions)
		return 0
	if(config.use_exp_restrictions_admin_bypass && check_rights(R_ADMIN, 0, C.mob))
		return 0
	var/list/play_records = params2list(C.prefs.exp)
	var/isexempt = text2num(play_records[EXP_TYPE_EXEMPT])
	if(isexempt)
		return 0
	var/minimal_player_hrs = role_playtime_requirements[role]
	if(!minimal_player_hrs)
		return 0
	var/req_mins = minimal_player_hrs * 60
	var/my_exp = text2num(play_records[EXP_TYPE_CREW])
	if(!isnum(my_exp))
		return req_mins
	return max(0, req_mins - my_exp)


/datum/job/proc/available_in_playtime(client/C)
	if(!C)
		return 0
	if(!exp_requirements || !exp_type)
		return 0
	if(!config.use_exp_restrictions)
		return 0
	if(config.use_exp_restrictions_admin_bypass && check_rights(R_ADMIN, 0, C.mob))
		return 0
	var/list/play_records = params2list(C.prefs.exp)
	var/isexempt = text2num(play_records[EXP_TYPE_EXEMPT])
	if(isexempt)
		return 0
	var/my_exp = text2num(play_records[get_exp_req_type()])
	var/job_requirement = text2num(get_exp_req_amount())
	if(my_exp >= job_requirement)
		return 0
	else
		return (job_requirement - my_exp)

/datum/job/proc/get_exp_req_amount()
	return exp_requirements

/datum/job/proc/get_exp_req_type()
	return exp_type

/mob/proc/get_exp_report()
	if(client)
		return client.get_exp_report()
	else
		return "[src] has no client."

/client/proc/get_exp_report()
	if(!config.use_exp_tracking)
		return "Tracking is disabled in the server configuration file."
	var/list/play_records = params2list(prefs.exp)
	if(!play_records.len)
		return "[key] has no records."
	var/return_text = "<UL>"
	var/list/exp_data = list()
	for(var/category in exp_jobsmap)
		if(text2num(play_records[category]))
			exp_data[category] = text2num(play_records[category])
		else
			exp_data[category] = 0
	for(var/dep in exp_data)
		if(exp_data[dep] > 0)
			if(dep == EXP_TYPE_EXEMPT)
				return_text += "<LI>Exempt (all jobs auto-unlocked)</LI>"
			else if(exp_data[EXP_TYPE_LIVING] > 0)
				return_text += "<LI>[dep]: [get_exp_format(exp_data[dep])]</LI>"
	if(config.use_exp_restrictions_admin_bypass && check_rights(R_ADMIN, 0, mob))
		return_text += "<LI>Admin</LI>"
	return_text += "</UL>"
	if(config.use_exp_restrictions)
		var/list/jobs_locked = list()
		var/list/jobs_unlocked = list()
		for(var/datum/job/job in job_master.occupations)
			if(job.exp_requirements && job.exp_type)
				if(!job.available_in_playtime(mob.client))
					jobs_unlocked += job.title
				else
					var/xp_req = job.get_exp_req_amount()
					jobs_locked += "[job.title] ([get_exp_format(text2num(play_records[job.get_exp_req_type()]))] / [get_exp_format(xp_req)] as [job.get_exp_req_type()])"
		if(jobs_unlocked.len)
			return_text += "<BR><BR>Jobs Unlocked:<UL><LI>"
			return_text += jobs_unlocked.Join("</LI><LI>")
			return_text += "</LI></UL>"
		if(jobs_locked.len)
			return_text += "<BR><BR>Jobs Not Unlocked:<UL><LI>"
			return_text += jobs_locked.Join("</LI><LI>")
			return_text += "</LI></UL>"
	return return_text

/client/proc/get_exp_type(var/etype)
	return get_exp_format(get_exp_type_num(etype))

/client/proc/get_exp_type_num(var/etype)
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


/proc/get_exp_format(var/expnum)
	if(expnum > 60)
		return num2text(round(expnum / 60)) + "h"
	else if(expnum > 0)
		return num2text(expnum) + "m"
	else
		return "none"

/proc/update_exp(var/mins, var/ann = 0)
	if(!establish_db_connection())
		return -1
	spawn(0)
		for(var/client/L in GLOB.clients)
			if(L.inactivity >= (10 MINUTES))
				continue
			spawn(0)
				L.update_exp_client(mins, ann)
			sleep(10)

/client/proc/update_exp_client(var/minutes, var/announce_changes = 0)
	if(!src ||!ckey)
		return
	var/DBQuery/exp_read = dbcon.NewQuery("SELECT exp FROM [format_table_name("player")] WHERE ckey='[ckey]'")
	if(!exp_read.Execute())
		var/err = exp_read.ErrorMsg()
		log_game("SQL ERROR during exp_update_client read. Error : \[[err]\]\n")
		message_admins("SQL ERROR during exp_update_client read. Error : \[[err]\]\n")
		return
	var/list/read_records = list()
	var/hasread = 0
	while(exp_read.NextRow())
		read_records = params2list(exp_read.item[1])
		hasread = 1
	if(!hasread)
		return
	var/list/play_records = list()
	for(var/rtype in exp_jobsmap)
		if(text2num(read_records[rtype]))
			play_records[rtype] = text2num(read_records[rtype])
		else
			play_records[rtype] = 0
	if(mob.stat == CONSCIOUS && mob.mind.assigned_role)
		play_records[EXP_TYPE_LIVING] += minutes
		if(announce_changes)
			to_chat(mob,"<span class='notice'>You got: [minutes] Living EXP!")
		for(var/category in exp_jobsmap)
			if(exp_jobsmap[category]["titles"])
				if(mob.mind.assigned_role in exp_jobsmap[category]["titles"])
					play_records[category] += minutes
					if(announce_changes)
						to_chat(mob,"<span class='notice'>You got: [minutes] [category] EXP!")
		if(mob.mind.special_role)
			play_records[EXP_TYPE_SPECIAL] += minutes
			if(announce_changes)
				to_chat(mob,"<span class='notice'>You got: [minutes] Special EXP!")
	else if(isobserver(mob))
		play_records[EXP_TYPE_GHOST] += minutes
		if(announce_changes)
			to_chat(mob,"<span class='notice'>You got: [minutes] Ghost EXP!")
	else
		return
	var/new_exp = list2params(play_records)
	prefs.exp = new_exp
	new_exp = sanitizeSQL(new_exp)
	var/DBQuery/update_query = dbcon.NewQuery("UPDATE [format_table_name("player")] SET exp = '[new_exp]' WHERE ckey='[ckey]'")
	if(!update_query.Execute())
		var/err = update_query.ErrorMsg()
		log_game("SQL ERROR during exp_update_client write. Error : \[[err]\]\n")
		message_admins("SQL ERROR during exp_update_client write. Error : \[[err]\]\n")
		return

/hook/roundstart/proc/exptimer()
	if(!config.sql_enabled || !config.use_exp_tracking)
		return 1
	spawn(0)
		while(TRUE)
			sleep(5 MINUTES)
			update_exp(5,0)
	return 1
