
/proc/has_exp_for_job(mob/M, rank)
	var/datum/job/job = job_master.GetJob(rank)
	if(!job)
		return 1
	if(!job.exp_requirements || !job.exp_type)
		return 1
	if(!config.use_exp_restrictions)
		return 1
	if(!M.client)
		return 0
	//if(check_rights(R_ADMIN, 0, M))
	//	return 1
	var/list/play_records = params2list(M.client.prefs.exp)
	var/my_exp = text2num(play_records[job.exp_type])
	if(my_exp >= text2num(job.exp_requirements))
		//return_text += "<BR><span class='notice'>[C.mob] has [my_exp] of the [job.exp_requirements] [job.exp_type] EXP required for [job.title].</span>"
		return 1
	else
		return 0

/client/verb/check_exp()
	set name = "EXP Check"
	set desc = "Shows your EXP status"
	set category = "EXP"
	if(!establish_db_connection())
		return 0
	var/exp_text = get_exp_text(src)
	to_chat(src,exp_text)

/client/proc/get_exp_text(var/client/C)
	var/return_text = ""
	var/list/play_records = params2list(C.prefs.exp)
	var/exp_all = text2num(play_records["all"])
	var/exp_com = play_records["com"]
	var/exp_sec = play_records["sec"]
	var/exp_sci = play_records["sci"]
	var/exp_eng = play_records["eng"]
	var/exp_med = play_records["med"]
	var/exp_sup = play_records["sup"]
	var/exp_sil = play_records["sil"]
	var/exp_ant = play_records["ant"]
	var/exp_gho = play_records["gho"]
	if(play_records.len)
		return_text += "General EXP: [exp_all]"
		if(exp_com > 0)
			return_text += "<BR>Command EXP: [exp_com]"
		if(exp_sec > 0)
			return_text += "<BR>Security EXP: [exp_sec]"
		if(exp_sci > 0)
			return_text += "<BR>Science EXP: [exp_sci]"
		if(exp_eng > 0)
			return_text += "<BR>Engineering EXP: [exp_eng]"
		if(exp_med > 0)
			return_text += "<BR>Medical EXP: [exp_med]"
		if(exp_sup > 0)
			return_text += "<BR>Support EXP: [exp_sup]"
		if(exp_sil > 0)
			return_text += "<BR>Silicon EXP: [exp_sil]"
		if(exp_ant > 0)
			return_text += "<BR>Antag EXP: [exp_ant]"
		if(exp_gho > 0)
			return_text += "<BR>Ghost EXP: [exp_gho]"
		return_text += "<BR>Jobs"
		for(var/datum/job/job in job_master.occupations)
			if(job.exp_requirements && job.exp_type)
				if(has_exp_for_job(C.mob, job.title))
					return_text += " | <span class='notice'>[job.title]</span> "
				else
					return_text += " | <span class='danger'>[job.title]</span> "
		return(return_text)
	else
		return("[C.mob] has no EXP records.")

/client/verb/add_exp()
	set name = "EXP ADD"
	set desc = "DEBUG"
	set category = "EXP"
	update_exp(25)

/client/proc/cmd_show_exp_panel(var/mob/living/M in mob_list)
	set category = "EXP"
	set name = "Show EXP Panel"
	set desc=""
	if(!check_rights(R_ADMIN))
		return
	if(M.client)
		var/body = "<html><head><title>EXP for [M.key]</title></head>"
		body += M.client.get_exp_text(M.client)
		body += "</HTML>"
		usr << browse(body, "window=adminplayerexp;size=550x615")
	else
		to_chat(usr,"<span class='danger'>Mob [M] has no client.</span>")

/proc/update_exp(var/minutes)
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

			for(var/rtype in list("all","com","sec","sci","eng","med","sup","sil","ant", "gho"))
				if(!text2num(play_records[rtype]))
					play_records[rtype] = 0
				else
					play_records[rtype] = text2num(play_records[rtype])

			if(C.mob.stat == CONSCIOUS && C.mob.mind.assigned_role)
				play_records["all"] += minutes
				to_chat(C.mob,"<span class='notice'>You got: [minutes] EXP!")
				if(C.mob.mind.assigned_role in command_positions)
					play_records["com"] += minutes
					to_chat(C.mob,"<span class='notice'>You got: [minutes] Command EXP!")
				if(C.mob.mind.assigned_role in security_positions)
					play_records["sec"] += minutes
					to_chat(C.mob,"<span class='notice'>You got: [minutes] Security EXP!")
				if(C.mob.mind.assigned_role in science_positions)
					play_records["sci"] += minutes
					to_chat(C.mob,"<span class='notice'>You got: [minutes] Science EXP!")
				if(C.mob.mind.assigned_role in engineering_positions)
					play_records["eng"] += minutes
					to_chat(C.mob,"<span class='notice'>You got: [minutes] Engineering EXP!")
				if(C.mob.mind.assigned_role in medical_positions)
					play_records["med"] += minutes
					to_chat(C.mob,"<span class='notice'>You got: [minutes] Medical EXP!")
				if(C.mob.mind.assigned_role in support_positions)
					play_records["sup"] += minutes
					to_chat(C.mob,"<span class='notice'>You got: [minutes] Support EXP!")
				if(C.mob.mind.assigned_role in nonhuman_positions)
					play_records["sil"] += minutes
					to_chat(C.mob,"<span class='notice'>You got: [minutes] Silicon EXP!")
				if(C.mob.mind.special_role)
					play_records["ant"] += minutes
					to_chat(C.mob,"<span class='notice'>You got: [minutes] Special EXP!")
			else if(isobserver(C.mob))
				play_records["gho"] += minutes
				to_chat(C.mob,"<span class='notice'>You got: [minutes] Ghost EXP!")
			else
				return
			var/new_exp = list2params(play_records)
			C.prefs.exp = new_exp
			new_exp = sanitizeSQL(new_exp)
			var/DBQuery/update_query = dbcon.NewQuery("UPDATE [format_table_name("player")] SET exp = '[new_exp]' WHERE ckey='[C.ckey]'")
			update_query.Execute()


