
// Defines

#define EXP_TYPE_CREW			"Crew"
#define EXP_TYPE_COMMAND		"Command"
#define EXP_TYPE_ENGINEERING	"Engineering"
#define EXP_TYPE_SECURITY		"Security"
#define EXP_TYPE_SILICON		"Silicon"
#define EXP_TYPE_SERVICE		"Service"
#define EXP_TYPE_MEDICAL		"Medical"
#define EXP_TYPE_SCIENCE		"Science"
#define EXP_TYPE_SUPPLY			"Supply"
#define EXP_TYPE_SPECIAL		"Special"
#define EXP_TYPE_GHOST			"Ghost"
#define EXP_TYPE_EXEMPT			"Exempt"

// Globals, Defines, Etc




// Admin Verbs


/client/proc/cmd_admin_check_player_exp()	//Allows admins to determine who the newer players are.
	set category = "Admin"
	set name = "Check Player Playtime"
	if(!check_rights(R_ADMIN))
		return
	var/msg = "<html><head><title>Playtime Report</title></head><body>Playtime:<BR><UL>"
	for(var/client/C in clients)
		var/list/play_records = params2list(C.prefs.exp)
		var/gen_exp_time = text2num(play_records[EXP_TYPE_CREW])
		gen_exp_time = num2text(round(gen_exp_time / 60)) + "h"
		msg += "<LI> - [key_name_admin(C.mob)]: <A href='?_src_=holder;getplaytimewindow=\ref[C.mob]'>" + C.get_exp_general() + "</a></LI>"
	msg += "</UL></BODY></HTML>"
	src << browse(msg, "window=Player_playtime_check")


/client/proc/cmd_show_exp_panel(var/client/C in clients)
	if(!check_rights(R_ADMIN))
		return
	var/body = "<html><head><title>Playtime for [C.key]</title></head><BODY><BR>Playtime:"
	body += C.get_exp_report()
	body += "</BODY></HTML>"
	src << browse(body, "window=playerplaytime;size=550x615")


// Procs


/datum/job/proc/available_in_playtime(client/C)
	if(!C)
		return 0
	if(!exp_requirements || !exp_type)
		return 0
	if(!job_is_xp_locked(src.title))
		return 0
	if(check_rights(R_ADMIN, 0, C.mob))
		return 1
	var/list/play_records = params2list(C.prefs.exp)
	var/isexempt = text2num(play_records[EXP_TYPE_EXEMPT])
	if(isexempt)
		return 0
	var/my_exp = text2num(play_records[exp_type])
	var/job_requirement = text2num(exp_requirements)
	if(config.use_exp_restrictions_heads_hours && ((title in command_positions) || title == "AI"))
		job_requirement = config.use_exp_restrictions_heads_hours * 60
	if(my_exp >= job_requirement)
		return 0
	else
		return (job_requirement - my_exp)



/proc/job_is_xp_locked(jobtitle)
	if(!config.use_exp_restrictions_heads && ((jobtitle in command_positions) || jobtitle == "AI"))
		return 0
	if(!config.use_exp_restrictions_other && !((jobtitle in command_positions) || jobtitle == "AI"))
		return 0
	return 1


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
	for(var/cat in exp_jobsmap)
		if(text2num(play_records[cat]))
			exp_data[cat] = text2num(play_records[cat])
		else
			exp_data[cat] = 0

	for(var/dep in exp_data)
		if(exp_data[dep] > 0)
			if(dep == EXP_TYPE_EXEMPT)
				return_text += "<LI>Exempt (all jobs auto-unlocked)</LI>"
			else if(exp_data[EXP_TYPE_CREW] > 0)
				return_text += "<LI>[dep] [get_exp_format(exp_data[dep])] (" + num2text(round(exp_data[dep]/exp_data[EXP_TYPE_CREW]*100)) + "%)</LI>"
	return_text += "</UL>"
	var/list/jobs_locked = list()
	var/list/jobs_unlocked = list()
	for(var/datum/job/job in job_master.occupations)
		if(job.exp_requirements && job.exp_type)
			if(!job_is_xp_locked(job.title))
				continue
			else if(!job.available_in_playtime(mob.client))
				jobs_unlocked += job.title
			else
				var/xp_req = job.exp_requirements
				if(config.use_exp_restrictions_heads_hours && ((job.title in command_positions) || job.title == "AI"))
					xp_req = config.use_exp_restrictions_heads_hours * 60
				jobs_locked += job.title + " (" + get_exp_format(text2num(play_records[job.exp_type])) + " / " + get_exp_format(xp_req) + " [job.exp_type] EXP)"
	if(jobs_unlocked.len)
		return_text += "<BR><BR>Jobs Unlocked:<UL> "
		for(var/text in jobs_unlocked)
			return_text += "<LI>[text]</LI>"
		return_text += "</UL>"
	if(jobs_locked.len)
		return_text += "<BR><BR>Jobs Not Unlocked:<UL>"
		for(var/text in jobs_locked)
			return_text += "<LI>[text]</LI>"
		return_text += "</UL>"
	return return_text


/client/proc/get_exp_general()
	var/list/play_records = params2list(prefs.exp)
	var/exp_gen = text2num(play_records[EXP_TYPE_CREW])
	return get_exp_format(exp_gen)

/proc/get_exp_format(var/expnum)
	if(expnum > 60)
		return num2text(round(expnum / 60)) + "h"
	else if(expnum > 0)
		return num2text(expnum) + "m"
	else
		return "0h"

/proc/update_exp(var/minutes, var/announce_changes = 0)
	if(!establish_db_connection())
		return -1
	spawn(0)
		for(var/client/C in clients)
			if(C.inactivity >= (10 MINUTES))
				continue

			var/DBQuery/exp_read = dbcon.NewQuery("SELECT exp FROM [format_table_name("player")] WHERE ckey='[C.ckey]'")
			exp_read.Execute()
			var/list/read_records = list()
			while(exp_read.NextRow())
				read_records = params2list(exp_read.item[1])

			var/list/play_records = list()
			for(var/rtype in exp_jobsmap)
				if(text2num(read_records[rtype]))
					play_records[rtype] = text2num(read_records[rtype])
				else
					play_records[rtype] = 0
			if(C.mob.stat == CONSCIOUS && C.mob.mind.assigned_role)
				play_records[EXP_TYPE_CREW] += minutes
				if(announce_changes)
					to_chat(C.mob,"<span class='notice'>You got: [minutes] General EXP!")
				for(var/cat in exp_jobsmap)
					if(exp_jobsmap[cat]["titles"])
						if(C.mob.mind.assigned_role in exp_jobsmap[cat]["titles"])
							play_records[cat] += minutes
							if(announce_changes)
								to_chat(C.mob,"<span class='notice'>You got: [minutes] [cat] EXP!")
				if(C.mob.mind.special_role)
					play_records[EXP_TYPE_SPECIAL] += minutes
					if(announce_changes)
						to_chat(C.mob,"<span class='notice'>You got: [minutes] Special EXP!")
			else if(isobserver(C.mob))
				play_records[EXP_TYPE_GHOST] += minutes
				if(announce_changes)
					to_chat(C.mob,"<span class='notice'>You got: [minutes] Ghost EXP!")
			else
				return
			var/new_exp = list2params(play_records)
			C.prefs.exp = new_exp
			new_exp = sanitizeSQL(new_exp)
			var/DBQuery/update_query = dbcon.NewQuery("UPDATE [format_table_name("player")] SET exp = '[new_exp]' WHERE ckey='[C.ckey]'")
			update_query.Execute()
			sleep(10)


/hook/roundstart/proc/exptimer()
	if(!config.sql_enabled || !config.use_exp_tracking)
		return  0
	spawn(0)
		while(TRUE)
			sleep(5 MINUTES)
			update_exp(5,0)
