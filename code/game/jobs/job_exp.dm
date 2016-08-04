
// Globals, Defines, Etc

var/global/list/exp_jobsmap = list(
	"Crew" = list(), // all playtime from all jobs, together
	"Command" = list(titles = command_positions),
	"Engineering" = list(titles = engineering_positions),
	"Security" = list(titles = security_positions),
	"Silicon" = list(titles = nonhuman_positions),
	"Service" = list(titles = service_positions),
	"Medical" = list(titles = medical_positions),
	"Science" = list(titles = science_positions),
	"Supply" = list(titles = supply_positions),
	"Special" = list(), // special_role
	"Ghost" = list(), // dead/observer
	"Exempt" = list() // special grandfather setting
)


// Admin Verbs


/client/proc/cmd_admin_check_player_exp()	//Allows admins to determine who the newer players are.
	set category = "Admin"
	set name = "Check Player Playtime"
	if(!check_rights(R_ADMIN))
		return
	var/msg = "<html><head><title>Playtime Report</title></head><BR>Playtime:<BR>"
	for(var/client/C in clients)
		var/list/play_records = params2list(C.prefs.exp)
		var/gen_exp_time = text2num(play_records["Crew"])
		gen_exp_time = num2text(round(gen_exp_time / 60)) + "h"
		msg += "<BR> - [key_name_admin(C.mob)]: <A href='?_src_=holder;getplaytimewindow=\ref[C.mob]'>" + C.get_exp_general() + "</a> "
	if(msg != "")
		src << browse(msg, "window=Player_playtime_check")
	log_admin("[key_name(usr)] checked player playtime")
	feedback_add_details("admin_verb","MCPP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_show_exp_panel(var/client/C in clients)
	if(!check_rights(R_ADMIN))
		return
	var/body = "<html><head><title>Playtime for [C.key]</title></head><BR>Playtime:"
	body += C.get_exp_report()
	body += "</HTML>"
	src << browse(body, "window=playerplaytime;size=550x615")


// Procs

/proc/has_exp_for_job(mob/M, rank)
	var/datum/job/job = job_master.GetJob(rank)
	if(!job)
		return 1
	if(!job.exp_requirements || !job.exp_type)
		return 1
	if(!job_is_xp_locked(rank))
		return 1
	if(!M.client)
		return 0
	if(check_rights(R_ADMIN, 0, M))
		return 1
	var/list/play_records = params2list(M.client.prefs.exp)
	var/isexempt = text2num(play_records["Exempt"])
	if(isexempt)
		return 1
	var/my_exp = text2num(play_records[job.exp_type])
	var/job_requirement = text2num(job.exp_requirements)
	if(config.use_exp_restrictions_heads_hours && ((rank in command_positions) || rank == "AI"))
		job_requirement = text2num(config.use_exp_restrictions_heads_hours) * 60
	if(my_exp >= job_requirement)
		return 1
	else
		return 0

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
		return "[src] has no records."

	var/return_text = ""

	var/list/exp_data = list()
	for(var/cat in exp_jobsmap)
		if(text2num(play_records[cat]))
			exp_data[cat] = text2num(play_records[cat])
		else
			exp_data[cat] = 0

	for(var/dep in exp_data)
		if(exp_data[dep] > 0)
			if(dep == "Exempt")
				return_text += "<BR>- Exempt (all jobs auto-unlocked)"
			else
				return_text += "<BR>- [dep] " + get_exp_format(exp_data[dep]) + " (" + num2text(round(exp_data[dep]/exp_data["Crew"]*100)) + "%)"

	var/list/jobs_locked = list()
	var/list/jobs_unlocked = list()
	for(var/datum/job/job in job_master.occupations)
		if(job.exp_requirements && job.exp_type)
			if(!job_is_xp_locked(job.title))
				continue
			else if(has_exp_for_job(mob, job.title))
				jobs_unlocked += "<BR>- " + job.title
			else
				var/xp_req = job.exp_requirements
				if(config.use_exp_restrictions_heads_hours && ((job.title in command_positions) || job.title == "AI"))
					xp_req = text2num(config.use_exp_restrictions_heads_hours) * 60
				jobs_locked += "<BR>- " + job.title + " (" + get_exp_format(text2num(play_records[job.exp_type])) + " / " + get_exp_format(xp_req) + " [job.exp_type] EXP)"
	if(jobs_unlocked.len)
		return_text += "<BR><BR>Jobs Unlocked: "
		for(var/text in jobs_unlocked)
			return_text += text
	if(jobs_locked.len)
		return_text += "<BR><BR>Jobs Not Unlocked: "
		for(var/text in jobs_locked)
			return_text += text
	return return_text


/client/proc/get_exp_general()
	var/list/play_records = params2list(prefs.exp)
	var/exp_gen = text2num(play_records["Crew"])
	return get_exp_format(exp_gen)

/client/proc/get_exp_format(var/expnum)
	if(expnum > 0)
		return num2text(round(expnum / 60)) + "h"
	else
		return "0h"

/proc/update_exp(var/minutes, var/announce_changes = 0)
	if(!establish_db_connection())
		return -1
	spawn(0)
		for(var/client/C in clients)
			if(C.inactivity < (10 MINUTES))

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
					play_records["Crew"] += minutes
					if(announce_changes)
						to_chat(C.mob,"<span class='notice'>You got: [minutes] General EXP!")

					for(var/cat in exp_jobsmap)
						if(exp_jobsmap[cat]["titles"])
							if(C.mob.mind.assigned_role in exp_jobsmap[cat]["titles"])
								play_records[cat] += minutes
								if(announce_changes)
									to_chat(C.mob,"<span class='notice'>You got: [minutes] [cat] EXP!")

					if(C.mob.mind.special_role)
						play_records["Special"] += minutes
						if(announce_changes)
							to_chat(C.mob,"<span class='notice'>You got: [minutes] Special EXP!")

				else if(isobserver(C.mob))
					play_records["Ghost"] += minutes
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