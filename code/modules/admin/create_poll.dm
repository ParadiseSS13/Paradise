/client/proc/create_poll()
	set name = "Create Server Poll"
	set category = "Server"
	if(!check_rights(R_PERMISSIONS))	
		return
	if(!dbcon.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/returned = create_poll_function()
	if(returned)
		var/DBQuery/query_check_option = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_option")] WHERE pollid = [returned]")
		if(!query_check_option.Execute())
			var/err = query_check_option.ErrorMsg()
			log_game("SQL ERROR obtaining id from poll_option table. Error : \[[err]\]\n")
			return
		if(query_check_option.NextRow())
			var/DBQuery/query_log_get = dbcon.NewQuery("SELECT polltype, question, adminonly FROM [format_table_name("poll_question")] WHERE id = [returned]")
			if(!query_log_get.Execute())
				var/err = query_log_get.ErrorMsg()
				log_game("SQL ERROR obtaining polltype, question, adminonly from poll_question table. Error : \[[err]\]\n")
				return
			if(query_log_get.NextRow())
				var/polltype = query_log_get.item[1]
				var/question = query_log_get.item[2]
				var/adminonly = query_log_get.item[3]
				log_admin("[key_name(usr)] has created a new server poll. Poll Type: [polltype] - Admin Only: [adminonly ? "Yes" : "No"] - Question: [question]")
				message_admins("[key_name_admin(usr)] has created a new server poll. Poll Type: [polltype] - Admin Only: [adminonly ? "Yes" : "No"]<br>Question: [question]")
		else
			to_chat(src, "Poll question created without any options, poll will be deleted.")
			var/DBQuery/query_del_poll = dbcon.NewQuery("DELETE FROM [format_table_name("poll_question")] WHERE id = [returned]")
			if(!query_del_poll.Execute())
				var/err = query_del_poll.ErrorMsg()
				log_game("SQL ERROR deleting poll question [returned]. Error : \[[err]\]\n")
				return

/client/proc/create_poll_function()
	if(!check_rights(R_PERMISSIONS))	
		return
	var/polltype = input("Choose poll type.","Poll Type") in list("Single Option","Text Reply","Rating","Multiple Choice")
	var/choice_amount = 0
	switch(polltype)
		if("Single Option")
			polltype = POLLTYPE_OPTION
		if("Text Reply")
			polltype = POLLTYPE_TEXT
		if("Rating")
			polltype = POLLTYPE_RATING
		if("Multiple Choice")
			polltype = POLLTYPE_MULTI
			choice_amount = input("How many choices should be allowed?","Select choice amount") as num|null
			if(!choice_amount)
				return
	var/starttime = SQLtime()
	var/endtime = input("Set end time for poll as format YYYY-MM-DD HH:MM:SS. All times in server time. HH:MM:SS is optional and 24-hour. Must be later than starting time for obvious reasons.", "Set end time", SQLtime()) as text
	if(!endtime)
		return
	endtime = sanitizeSQL(endtime)
	var/DBQuery/query_validate_time = dbcon.NewQuery("SELECT STR_TO_DATE('[endtime]','%Y-%c-%d %T')")
	if(!query_validate_time.Execute())
		var/err = query_validate_time.ErrorMsg()
		log_game("SQL ERROR validating endtime. Error : \[[err]\]\n")
		return
	if(query_validate_time.NextRow())
		endtime = query_validate_time.item[1]
		if(!endtime)
			to_chat(src, "Datetime entered is invalid.")
			return
	var/DBQuery/query_time_later = dbcon.NewQuery("SELECT TIMESTAMP('[endtime]') < NOW()")
	if(!query_time_later.Execute())
		var/err = query_time_later.ErrorMsg()
		log_game("SQL ERROR comparing endtime to NOW(). Error : \[[err]\]\n")
		return
	if(query_time_later.NextRow())
		var/checklate = text2num(query_time_later.item[1])
		if(checklate)
			to_chat(src, "Datetime entered is not later than current server time.")
			return
	var/adminonly
	switch(alert("Admin only poll?",,"Yes","No","Cancel"))
		if("Yes")
			adminonly = 1
		if("No")
			adminonly = 0
		else
			return
	var/sql_ckey = sanitizeSQL(ckey)
	var/question = input("Write your question","Question") as message|null
	if(!question)
		return
	question = sanitizeSQL(question)
	var/DBQuery/query_polladd_question = dbcon.NewQuery("INSERT INTO [format_table_name("poll_question")] (polltype, starttime, endtime, question, adminonly, multiplechoiceoptions, createdby_ckey, createdby_ip) VALUES ('[polltype]', '[starttime]', '[endtime]', '[question]', '[adminonly]', '[choice_amount]', '[sql_ckey]', '[address]')")
	if(!query_polladd_question.Execute())
		var/err = query_polladd_question.ErrorMsg()
		log_game("SQL ERROR adding new poll question to table. Error : \[[err]\]\n")
		return
	if(polltype == POLLTYPE_TEXT)
		log_admin("[key_name(usr)] has created a new server poll. Poll type: [polltype] - Admin Only: [adminonly ? "Yes" : "No"] - Question: [question]")
		message_admins("[key_name_admin(usr)] has created a new server poll. Poll type: [polltype] - Admin Only: [adminonly ? "Yes" : "No"]<br>Question: [question]")
		return
	var/pollid = 0
	var/DBQuery/query_get_id = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE question = '[question]' AND starttime = '[starttime]' AND endtime = '[endtime]' AND createdby_ckey = '[sql_ckey]' AND createdby_ip = '[address]'")
	if(!query_get_id.Execute())
		var/err = query_get_id.ErrorMsg()
		log_game("SQL ERROR obtaining id from poll_question table. Error : \[[err]\]\n")
		return
	if(query_get_id.NextRow())
		pollid = query_get_id.item[1]
	var/add_option = 1
	while(add_option)
		var/option = input("Write your option",POLLTYPE_OPTION) as message|null
		if(!option)
			return pollid
		option = sanitizeSQL(option)
		var/percentagecalc
		switch(alert("Calculate option results as percentage?",,"Yes","No","Cancel"))
			if("Yes")
				percentagecalc = 1
			if("No")
				percentagecalc = 0
			else
				return pollid
		var/minval = 0
		var/maxval = 0
		var/descmin = ""
		var/descmid = ""
		var/descmax = ""
		if(polltype == POLLTYPE_RATING)
			minval = input("Set minimum rating value.","Minimum rating") as num|null
			if(!minval)
				return pollid
			maxval = input("Set maximum rating value.","Maximum rating") as num|null
			if(!maxval)
				return pollid
			if(minval >= maxval)
				to_chat(src, "Minimum rating value can't be more than maximum rating value")
				return pollid
			descmin = input("Optional: Set description for minimum rating","Minimum rating description") as message|null
			if(descmin)
				descmin = sanitizeSQL(descmin)
			else if(descmin == null)
				return pollid
			descmid = input("Optional: Set description for median rating","Median rating description") as message|null
			if(descmid)
				descmid = sanitizeSQL(descmid)
			else if(descmid == null)
				return pollid
			descmax = input("Optional: Set description for maximum rating","Maximum rating description") as message|null
			if(descmax)
				descmax = sanitizeSQL(descmax)
			else if(descmax == null)
				return pollid
		var/DBQuery/query_polladd_option = dbcon.NewQuery("INSERT INTO [format_table_name("poll_option")] (pollid, text, percentagecalc, minval, maxval, descmin, descmid, descmax) VALUES ('[pollid]', '[option]', '[percentagecalc]', '[minval]', '[maxval]', '[descmin]', '[descmid]', '[descmax]')")
		if(!query_polladd_option.Execute())
			var/err = query_polladd_option.ErrorMsg()
			log_game("SQL ERROR adding new poll option to table. Error : \[[err]\]\n")
			return pollid
		switch(alert(" ",,"Add option","Finish"))
			if("Add option")
				add_option = 1
			if("Finish")
				add_option = 0
	return pollid