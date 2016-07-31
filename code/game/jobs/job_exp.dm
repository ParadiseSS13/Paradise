
// Player Verbs


/client/verb/check_exp()
	set name = "EXP"
	set desc = "Shows your EXP status"
	set category = "Special Verbs"
	//if(!establish_db_connection())
	//	return 0
	var/body = "<html><head><title>EXP for [key]</title></head><BR>"
	body += get_exp_report()
	body += "</HTML>"
	src << browse(body, "window=playerexp;size=550x615")


// Admin Verbs

/client/proc/cmd_mentor_check_player_exp()	//Allows mentors / admins to determine who the newer players are.
	set category = "Admin"
	set name = "Check Player XP"
	if(!check_rights(R_MENTOR|R_MOD|R_ADMIN))
		return
	var/msg = "<html><head><title>EXP Report</title></head><BR>"
	for(var/client/C in clients)
		var/list/play_records = params2list(C.prefs.exp)
		var/gen_exp_time = text2num(play_records["gen"])
		gen_exp_time = num2text(round(gen_exp_time / 60)) + "h"
		msg += "<BR> - [key_name_admin(C.mob)]: <A href='?_src_=holder;getexpwindow=\ref[C.mob]'>" + C.get_exp_general() + "</a> "
	if(msg != "")
		src << browse(msg, "window=Player_exp_check")


/client/proc/cmd_show_exp_panel(var/client/C in clients)
	if(!check_rights(R_MENTOR|R_MOD|R_ADMIN))
		return
	var/body = "<html><head><title>EXP for [C.key]</title></head><BR>"
	body += C.get_exp_report()
	body += "</HTML>"
	src << browse(body, "window=playerexp;size=550x615")


// Debug verbs

/client/verb/add_exp()
	set name = "EXP Add"
	set desc = "DEBUG"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	update_exp(60, 1)



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
	//if(check_rights(R_ADMIN, 0, M))
	//	return 1
	var/list/play_records = params2list(M.client.prefs.exp)
	var/imm = text2num(play_records["imm"])
	if(imm)
		return 1
	var/my_exp = text2num(play_records[job.exp_type])
	if(my_exp >= text2num(job.exp_requirements))
		//return_text += "<BR><span class='notice'>[C.mob] has [my_exp] of the [job.exp_requirements] [job.exp_type] EXP required for [job.title].</span>"
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
	var/return_text = ""
	//to_chat(src,"MARK 1 [return_text]")
	var/list/play_records = params2list(prefs.exp)
	var/exp_gen = text2num(play_records["gen"])
	var/exp_com = text2num(play_records["com"])
	var/exp_sec = text2num(play_records["sec"])
	var/exp_sci = text2num(play_records["sci"])
	var/exp_eng = text2num(play_records["eng"])
	var/exp_med = text2num(play_records["med"])
	var/exp_sup = text2num(play_records["sup"])
	var/exp_sil = text2num(play_records["sil"])
	var/exp_ant = text2num(play_records["ant"])
	var/exp_gho = text2num(play_records["gho"])
	var/exp_imm = text2num(play_records["imm"])
	if(play_records.len)
		//to_chat(src,"MARK 2 [return_text]")
		if(exp_gen > 0)
			return_text += "Experience:<BR>- General: [exp_gen]"
		if(exp_com > 0)
			return_text += "<BR>- Command: [exp_com]"
		if(exp_sec > 0)
			return_text += "<BR>- Security: [exp_sec]"
		if(exp_sci > 0)
			return_text += "<BR>- Science: [exp_sci]"
		if(exp_eng > 0)
			return_text += "<BR>- Engineering: [exp_eng]"
		if(exp_med > 0)
			return_text += "<BR>- Medical: [exp_med]"
		if(exp_sup > 0)
			return_text += "<BR>- Support: [exp_sup]"
		if(exp_sil > 0)
			return_text += "<BR>- Silicon: [exp_sil]"
		if(exp_ant > 0)
			return_text += "<BR>- Special: [exp_ant]"
		if(exp_gho > 0)
			return_text += "<BR>- Ghost: [exp_gho]"
		if(exp_imm > 0)
			return_text += "<BR>- Grandfathered: YES"
		//to_chat(src,"MARK 3 [return_text]")
		var/list/jobs_locked = list()
		var/list/jobs_unlocked = list()
		for(var/datum/job/job in job_master.occupations)
			if(job.exp_requirements && job.exp_type)
				if(!job_is_xp_locked(job.title))
					continue
				else if(has_exp_for_job(mob, job.title))
					jobs_unlocked += "<BR>- " + job.title
				else
					jobs_locked += "<BR>- " + job.title + " (" + play_records[job.exp_type] + " / [job.exp_requirements] [job.exp_type] EXP)"
		if(jobs_unlocked.len)
			return_text += "<BR><BR>Jobs Unlocked: "
			//var/counter = 0
			for(var/text in jobs_unlocked)
				//if(counter)
				//	return_text += ","
				return_text += text
				//counter++
		if(jobs_locked.len)
			return_text += "<BR><BR>Jobs Not Unlocked: "
			//counter = 0
			for(var/text in jobs_locked)
				//if(counter)
				//	return_text += ","
				return_text += text
				//counter++
			//to_chat(src,"MARK 4 [return_text]")
		return return_text
	else
		return "[src] has no EXP records."

/client/proc/get_exp_general()
	var/list/play_records = params2list(prefs.exp)
	var/exp_gen = text2num(play_records["gen"])
	return num2text(round(exp_gen / 60)) + "h"


/proc/update_exp(var/minutes, var/announce_changes = 0)
	if(!establish_db_connection())
		return -1
	for(var/client/C in clients)
		if(C.inactivity < (10 MINUTES))
			//var/list/play_records = params2list(C.prefs.exp)

			var/DBQuery/exp_read = dbcon.NewQuery("SELECT exp FROM [format_table_name("player")] WHERE ckey='[C.ckey]'")
			exp_read.Execute()
			var/list/play_records = list()
			while(exp_read.NextRow())
				play_records = params2list(exp_read.item[1])
			// -------------

			for(var/rtype in list("gen","com","sec","sci","eng","med","sup","sil","ant", "gho", "imm"))
				if(!text2num(play_records[rtype]))
					play_records[rtype] = 0
				else
					play_records[rtype] = text2num(play_records[rtype])

			if(C.mob.stat == CONSCIOUS && C.mob.mind.assigned_role)
				play_records["gen"] += minutes
				if(announce_changes)
					to_chat(C.mob,"<span class='notice'>You got: [minutes] General EXP!")
				if(C.mob.mind.assigned_role in command_positions)
					play_records["com"] += minutes
					if(announce_changes)
						to_chat(C.mob,"<span class='notice'>You got: [minutes] Command EXP!")
				if(C.mob.mind.assigned_role in security_positions)
					play_records["sec"] += minutes
					if(announce_changes)
						to_chat(C.mob,"<span class='notice'>You got: [minutes] Security EXP!")
				if(C.mob.mind.assigned_role in science_positions)
					play_records["sci"] += minutes
					if(announce_changes)
						to_chat(C.mob,"<span class='notice'>You got: [minutes] Science EXP!")
				if(C.mob.mind.assigned_role in engineering_positions)
					play_records["eng"] += minutes
					if(announce_changes)
						to_chat(C.mob,"<span class='notice'>You got: [minutes] Engineering EXP!")
				if(C.mob.mind.assigned_role in medical_positions)
					play_records["med"] += minutes
					if(announce_changes)
						to_chat(C.mob,"<span class='notice'>You got: [minutes] Medical EXP!")
				if(C.mob.mind.assigned_role in support_positions)
					play_records["sup"] += minutes
					if(announce_changes)
						to_chat(C.mob,"<span class='notice'>You got: [minutes] Support EXP!")
				if(C.mob.mind.assigned_role in nonhuman_positions)
					play_records["sil"] += minutes
					if(announce_changes)
						to_chat(C.mob,"<span class='notice'>You got: [minutes] Silicon EXP!")
				if(C.mob.mind.special_role)
					play_records["ant"] += minutes
					if(announce_changes)
						to_chat(C.mob,"<span class='notice'>You got: [minutes] Special EXP!")
			else if(isobserver(C.mob))
				play_records["gho"] += minutes
				if(announce_changes)
					to_chat(C.mob,"<span class='notice'>You got: [minutes] Ghost EXP!")
			else
				return
			var/new_exp = list2params(play_records)
			C.prefs.exp = new_exp
			new_exp = sanitizeSQL(new_exp)
			var/DBQuery/update_query = dbcon.NewQuery("UPDATE [format_table_name("player")] SET exp = '[new_exp]' WHERE ckey='[C.ckey]'")
			update_query.Execute()