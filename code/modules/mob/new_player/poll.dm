/datum/polloption
	var/optionid
	var/optiontext

/client/verb/polls_verb()
	set name = "Show Player Polls"
	set category = "OOC"
	handle_player_polling()

/client/proc/can_vote()
	return istext(player_age) || player_age >= 30

/client/proc/handle_player_polling()
	establish_db_connection()
	if(GLOB.dbcon.IsConnected())
		var/isadmin = 0
		if(holder)
			isadmin = 1

		var/DBQuery/select_query = GLOB.dbcon.NewQuery("SELECT id, question, (id IN (SELECT pollid FROM [format_table_name("poll_vote")] WHERE ckey = '[ckey]') OR id IN (SELECT pollid FROM [format_table_name("poll_textreply")] WHERE ckey = '[ckey]')) AS voted FROM [format_table_name("poll_question")] WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime")
		select_query.Execute()

		var/output = "<div align='center'><B>Player polls</B>"
		if(check_rights(R_SERVER))
			output += "(<a href='?createpollwindow=1'>Create new poll</a>)"
		output +="<hr>"

		output += "<table>"
		var/color1 = "#ececec"
		var/color2 = "#e2e2e2"
		var/i = 0

		output += "<tr><th>Active Polls</th></tr>"
		while(select_query.NextRow())
			var/pollid = select_query.item[1]
			var/pollquestion = select_query.item[2]
			var/voted = text2num(select_query.item[3])
			output += "<tr bgcolor='[(i % 2 == 1) ? color1 : color2 ]'><td><a href=\"byond://?pollid=[pollid]\"><b>[pollquestion]</b></a></td></tr>"
			if(can_vote() && !voted)
				output += "<tr><td>[poll_player(pollid, 1)]</tr></td>"
			i++

		// Show expired polls. Non admins can view admin polls at this stage
		// (just like tgstation's web interface so don't complain)
		// (Also why was there no ingame interface tg not having an ingame
		// interface is retarded because it cucks downstreams)
		select_query = GLOB.dbcon.NewQuery("SELECT id, question FROM [format_table_name("poll_question")] WHERE Now() > endtime ORDER BY id DESC")
		select_query.Execute()

		output += "<tr><th>Expired Polls</th></tr>"
		while(select_query.NextRow())
			var/pollid = select_query.item[1]
			var/pollquestion = select_query.item[2]
			output += "<tr bgcolor='[(i % 2 == 1) ? color1 : color2]'><td><a href=\"byond://?pollresults=[pollid]\"><b>[pollquestion]</b></a></td></tr>"

		output += "</table>"

		src << browse(output,"window=playerpolllist;size=500x300")

/client/proc/poll_results(var/pollid = -1)
	if(pollid == -1)
		return
	establish_db_connection()
	if(!GLOB.dbcon.IsConnected())
		return
	var/DBQuery/select_query = GLOB.dbcon.NewQuery("SELECT polltype, question, adminonly, multiplechoiceoptions, starttime, endtime FROM [format_table_name("poll_question")] WHERE id = [pollid] AND endtime < Now()")
	select_query.Execute()
	var/question = ""
	var/polltype = ""
	var/adminonly = 0
	var/multiplechoiceoptions = 0
	var/starttime = ""
	var/endtime = ""
	var/found = 0
	while(select_query.NextRow())
		polltype = select_query.item[1]
		question = select_query.item[2]
		adminonly = text2num(select_query.item[3])
		multiplechoiceoptions = text2num(select_query.item[4])
		starttime = select_query.item[5]
		endtime = select_query.item[6]
		found = 1
		break
	if(!found)
		to_chat(src, "<span class='warning'>Poll question details not found. (Maybe the poll isn't expired yet?)</span>")
		return

	if(polltype == POLLTYPE_MULTI)
		question += " (Choose up to [multiplechoiceoptions] options)"
	if(adminonly)
		question = "(<font color='#997700'>Admin only poll</font>) " + question

	var output = "<!DOCTYPE html><html><body>"
	if(polltype == POLLTYPE_MULTI || polltype == POLLTYPE_OPTION)
		select_query = GLOB.dbcon.NewQuery("SELECT text, percentagecalc, (SELECT COUNT(optionid) FROM [format_table_name("poll_vote")] WHERE optionid = poll_option.id GROUP BY optionid) AS votecount FROM [format_table_name("poll_option")] WHERE pollid = [pollid]");
		select_query.Execute()
		var/list/options = list()
		var/total_votes = 1
		var/total_percent_votes = 1
		var/max_votes = 1
		while(select_query.NextRow())
			var/text = select_query.item[1]
			var/percentagecalc = select_query.item[2]
			var/votecount = text2num(select_query.item[3])
			if(percentagecalc)
				total_percent_votes += votecount
			total_votes += votecount
			if(votecount > max_votes)
				max_votes = votecount
			options[++options.len] = list(text, percentagecalc, votecount)
		// fuck ie.
		output += {"
		<table width='900' align='center' bgcolor='#eeffee' cellspacing='0' cellpadding='4'>
		<tr bgcolor='#ddffdd'>
			<th colspan='4' align='center'>[question]<br><font size='1'><b>[starttime] - [endtime]</b></font></th>
		</tr>
		<tr bgcolor='#ddffdd'>
			<th colspan='4' align='center'><div style='width:700px;position:relative'>"}
		var/list/colors = list("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3", "#a6d854", "#ffd92f", "#e5c494", "#b3b3b3")
		var/color_index = 0
		for(var/list/option in options)
			var/bar_width = option[3] * 700 / total_votes
			var/percentage = option[2] ? "[round(option[3] * 100 / total_percent_votes)]%" : "N/A"
			color_index++
			if(color_index > colors.len)
				color_index = 1
			output += "<div style='width:[bar_width]px;height:[5]px;background-color:[colors[color_index]];float:left' title='[option[1]] ([percentage])'></div>"
		output += "</div><br><font size='2'><b>(Hover over the colored bar to read description)</b></font></tr>"
		for(var/list/option in options)
			var/bar_width = option[3] * 390 / max_votes
			var/percentage = option[2] ? "[round(option[3] * 100 / total_percent_votes)]%" : "N/A"
			output += "<tr><td width='300' align='right'>[option[1]]</td>"
			output += "<td width='100' align='center'><b>[option[3]]</b></td>"
			output += "<td width='100' align='center'><b>[percentage]</b></td>"
			output += "<td width='400' align='left'><div style='width:[bar_width]px;height:10px;display:inline-block;background-color:#08b000'></div></td>"
		output += "</table>"
	if(polltype == POLLTYPE_RATING)
		output += {"
		<table width='900' align='center' bgcolor='#eeffee' cellspacing='0' cellpadding='4'>
		<tr bgcolor='#ddffdd'>
			<th colspan='4' align='center'>[question]<br><font size='1'><b>[starttime] - [endtime]</b></font></th>
		</tr>"}
		select_query = GLOB.dbcon.NewQuery("SELECT id, text, (SELECT AVG(rating) FROM [format_table_name("poll_vote")] WHERE optionid = poll_option.id AND rating != 'abstain') AS avgrating, (SELECT COUNT(rating) FROM [format_table_name("poll_vote")] WHERE optionid = poll_option.id AND rating != 'abstain') AS countvotes, minval, maxval FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
		select_query.Execute()
		while(select_query.NextRow())
			output += {"
			<tr>
				<td align='right' width='300'>[select_query.item[2]]</th>
				<td align='center' width='100'><b>N = [select_query.item[4]]</b></th>
				<td align='center' width='100'><b>AVG = [select_query.item[3]]</b></th>
				<td align='left' width='400'><table width='400 style='table-layout: fixed'>"}
			var/optionid = select_query.item[1]
			var/totalvotes = text2num(select_query.item[4])
			var/minval = text2num(select_query.item[5])
			var/maxval = text2num(select_query.item[6])
			var/maxvote = 1
			var/list/votecounts = list()
			for(var/I in minval to maxval)
				var/DBQuery/rating_query = GLOB.dbcon.NewQuery("SELECT COUNT(rating) AS countrating FROM [format_table_name("poll_vote")] WHERE optionid = [optionid] AND rating = [I] GROUP BY rating")
				rating_query.Execute()
				var/votecount = 0
				while(rating_query.NextRow())
					votecount = text2num(rating_query.item[1])
				votecounts["[I]"] = votecount
				if(votecount > maxvote)
					maxvote = votecount
			for(var/I in minval to maxval)
				var/votecount = votecounts["[I]"]
				var/bar_width = votecount * 200 / maxvote
				output += {"
				<tr>
					<td align='center' width='50'><b>[I]</b></td>
					<td align='center' width='50'>[votecount]</td>
					<td align='center' width='75'>([votecount / totalvotes]%)</td>
					<td width='200'><div style='width:[bar_width]px;height:10px;display:inline-block;background-color:#08b000'></div></td>
				</tr>"}
			output += "</table></td></tr>"
		output += "</table>"
	if(polltype == POLLTYPE_TEXT)
		select_query = GLOB.dbcon.NewQuery("SELECT replytext, COUNT(replytext) AS countresponse, GROUP_CONCAT(DISTINCT ckey SEPARATOR ', ') as ckeys FROM [format_table_name("poll_textreply")] WHERE pollid = [pollid] GROUP BY replytext ORDER BY countresponse DESC");
		select_query.Execute()
		output += {"
		<table width='900' align='center' bgcolor='#eeffee' cellspacing='0' cellpadding='4'>
		<tr bgcolor='#ddffdd'>
			<th colspan='2' align='center'>[question]<br><font size='1'><b>[starttime] - [endtime]</b></font></th>
		</tr>"}
		while(select_query.NextRow())
			var/replytext = select_query.item[1]
			var/countresponse = select_query.item[2]
			var/ckeys = select_query.item[3]
			output += {"
			<tr>
				<td>[ckeys] ([countresponse] player\s) responded with:</td>
				<td style='border:1px solid #888888'>[replytext]</td>
			</tr>"}
		output += "</table>"
	output += "</body></html>"

	src << browse(output,"window=pollresults;size=950x500")

/client/proc/poll_player(var/pollid = -1, var/inline = 0)
	if(pollid == -1) return
	establish_db_connection()
	if(GLOB.dbcon.IsConnected())

		var/DBQuery/select_query = GLOB.dbcon.NewQuery("SELECT starttime, endtime, question, polltype, multiplechoiceoptions FROM [format_table_name("poll_question")] WHERE id = [pollid] AND Now() BETWEEN starttime AND endtime [holder ? "AND adminonly = 0" : ""]")
		select_query.Execute()

		var/pollstarttime = ""
		var/pollendtime = ""
		var/pollquestion = ""
		var/polltype = ""
		var/found = 0
		var/multiplechoiceoptions = 0
		var/canvote = can_vote()

		while(select_query.NextRow())
			pollstarttime = select_query.item[1]
			pollendtime = select_query.item[2]
			pollquestion = select_query.item[3]
			polltype = select_query.item[4]
			found = 1
			break

		if(!found)
			to_chat(usr, "<span class='warning'>Poll question details not found. (Maybe you do not have access?)</span>")
			return

		switch(polltype)
			//Polls that have enumerated options
			if(POLLTYPE_OPTION)
				var/DBQuery/voted_query = GLOB.dbcon.NewQuery("SELECT optionid FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
				voted_query.Execute()

				var/voted = 0 // If the can't vote then consider them voted
				var/votedoptionid = 0
				while(voted_query.NextRow())
					votedoptionid = text2num(voted_query.item[1])
					voted = 1
					break

				var/list/datum/polloption/options = list()

				var/DBQuery/options_query = GLOB.dbcon.NewQuery("SELECT id, text FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
				options_query.Execute()
				while(options_query.NextRow())
					var/datum/polloption/PO = new()
					PO.optionid = text2num(options_query.item[1])
					PO.optiontext = options_query.item[2]
					options += PO

				var/output
				if(!inline)
					output += "<div align='center'><B>Player poll</B>"
					output +="<hr>"
				output += "<b>Question: [pollquestion]</b><br>"
				output += "<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"

				if(canvote && !voted)	//Only make this a form if we have not voted yet
					output += "<form name='cardcomp' action='byond://' method='get'>"
					output += "<input type='hidden' name='votepollid' value='[pollid]'>"
					output += "<input type='hidden' name='votetype' value='OPTION'>"

				output += "<table><tr><td>"
				for(var/datum/polloption/O in options)
					if(O.optionid && O.optiontext)
						if(voted || !canvote)
							if(votedoptionid == O.optionid)
								output += "<b>[O.optiontext]</b><br>"
							else
								output += "[O.optiontext]<br>"
						else
							output += "<input type='radio' name='voteoptionid' value='[O.optionid]'> [O.optiontext]<br>"
				output += "</td></tr></table>"

				if(canvote && !voted)	//Only make this a form if we have not voted yet
					output += "<p><input type='submit' value='Vote'>"
					output += "</form>"

				output += "</div>"

				if(inline)
					return output
				else
					src << browse(output,"window=playerpoll;size=500x250")

			//Polls with a text input
			if(POLLTYPE_TEXT)
				var/DBQuery/voted_query = GLOB.dbcon.NewQuery("SELECT replytext FROM [format_table_name("poll_textreply")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
				voted_query.Execute()

				var/voted = 0
				var/vote_text = ""
				while(voted_query.NextRow())
					vote_text = voted_query.item[1]
					voted = 1
					break


				var/output
				if(!inline)
					output += "<div align='center'><B>Player poll</B>"
					output +="<hr>"
				output += "<b>Question: [pollquestion]</b><br>"
				output += "<font size='2'>Feedback gathering runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"

				if(canvote && !voted)	//Only make this a form if we have not voted yet
					output += "<form name='cardcomp' action='byond://' method='get'>"
					output += "<input type='hidden' name='votepollid' value='[pollid]'>"
					output += "<input type='hidden' name='votetype' value='TEXT'>"

					output += "<font size='2'>Please provide feedback below. You can use any letters of the English alphabet, numbers and the symbols: . , ! ? : ; -</font><br>"
					output += "<textarea name='replytext' cols='50' rows='14'></textarea>"

					output += "<p><input type='submit' value='Submit'>"
					output += "</form>"

					output += "<form name='cardcomp' action='byond://' method='get'>"
					output += "<input type='hidden' name='votepollid' value='[pollid]'>"
					output += "<input type='hidden' name='votetype' value='TEXT'>"
					output += "<input type='hidden' name='replytext' value='ABSTAIN'>"
					output += "<input type='submit' value='Abstain'>"
					output += "</form>"
				else
					output += "[vote_text]"

				if(inline)
					return output
				else
					src << browse(output,"window=playerpoll;size=500x500")

			//Polls with a text input
			if(POLLTYPE_RATING)
				var/DBQuery/voted_query = GLOB.dbcon.NewQuery("SELECT o.text, v.rating FROM [format_table_name("poll_option")] o, erro_poll_vote v WHERE o.pollid = [pollid] AND v.ckey = '[ckey]' AND o.id = v.optionid")
				voted_query.Execute()

				var/output
				if(!inline)
					output += "<div align='center'><B>Player poll</B>"
					output +="<hr>"
				output += "<b>Question: [pollquestion]</b><br>"
				output += "<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"

				var/voted = 0
				while(voted_query.NextRow())
					voted = 1

					var/optiontext = voted_query.item[1]
					var/rating = voted_query.item[2]

					output += "<br><b>[optiontext] - [rating]</b>"

				if(canvote && !voted)	//Only make this a form if we have not voted yet
					output += "<form name='cardcomp' action='byond://' method='get'>"
					output += "<input type='hidden' name='votepollid' value='[pollid]'>"
					output += "<input type='hidden' name='votetype' value='NUMVAL'>"

					var/minid = 999999
					var/maxid = 0

					var/DBQuery/option_query = GLOB.dbcon.NewQuery("SELECT id, text, minval, maxval, descmin, descmid, descmax FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
					option_query.Execute()
					while(option_query.NextRow())
						var/optionid = text2num(option_query.item[1])
						var/optiontext = option_query.item[2]
						var/minvalue = text2num(option_query.item[3])
						var/maxvalue = text2num(option_query.item[4])
						var/descmin = option_query.item[5]
						var/descmid = option_query.item[6]
						var/descmax = option_query.item[7]

						if(optionid < minid)
							minid = optionid
						if(optionid > maxid)
							maxid = optionid

						var/midvalue = round( (maxvalue + minvalue) / 2)

						if(isnull(minvalue) || isnull(maxvalue) || (minvalue == maxvalue))
							continue

						output += "<br>[optiontext]: <select name='o[optionid]'>"
						output += "<option value='abstain'>abstain</option>"
						for(var/j = minvalue; j <= maxvalue; j++)
							if(j == minvalue && descmin)
								output += "<option value='[j]'>[j] ([descmin])</option>"
							else if(j == midvalue && descmid)
								output += "<option value='[j]'>[j] ([descmid])</option>"
							else if(j == maxvalue && descmax)
								output += "<option value='[j]'>[j] ([descmax])</option>"
							else
								output += "<option value='[j]'>[j]</option>"

						output += "</select>"

					output += "<input type='hidden' name='minid' value='[minid]'>"
					output += "<input type='hidden' name='maxid' value='[maxid]'>"

					output += "<p><input type='submit' value='Submit'>"
					output += "</form>"

				if(inline)
					return output
				else
					src << browse(output,"window=playerpoll;size=500x500")
			if(POLLTYPE_MULTI)
				var/DBQuery/voted_query = GLOB.dbcon.NewQuery("SELECT optionid FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
				voted_query.Execute()

				var/list/votedfor = list()
				var/voted = 0
				while(voted_query.NextRow())
					votedfor.Add(text2num(voted_query.item[1]))
					voted = 1

				var/list/datum/polloption/options = list()
				var/maxoptionid = 0
				var/minoptionid = 0

				var/DBQuery/options_query = GLOB.dbcon.NewQuery("SELECT id, text FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
				options_query.Execute()
				while(options_query.NextRow())
					var/datum/polloption/PO = new()
					PO.optionid = text2num(options_query.item[1])
					PO.optiontext = options_query.item[2]
					if(PO.optionid > maxoptionid)
						maxoptionid = PO.optionid
					if(PO.optionid < minoptionid || !minoptionid)
						minoptionid = PO.optionid
					options += PO


				if(select_query.item[5])
					multiplechoiceoptions = text2num(select_query.item[5])

				var/output
				if(!inline)
					output += "<div align='center'><B>Player poll</B>"
					output +="<hr>"
				output += "<b>Question: [pollquestion]</b><br>You can select up to [multiplechoiceoptions] options. If you select more, the first [multiplechoiceoptions] will be saved.<br>"
				output += "<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"

				if(canvote && !voted)	//Only make this a form if we have not voted yet
					output += "<form name='cardcomp' action='byond://' method='get'>"
					output += "<input type='hidden' name='votepollid' value='[pollid]'>"
					output += "<input type='hidden' name='votetype' value='MULTICHOICE'>"
					output += "<input type='hidden' name='maxoptionid' value='[maxoptionid]'>"
					output += "<input type='hidden' name='minoptionid' value='[minoptionid]'>"

				output += "<table><tr><td>"
				for(var/datum/polloption/O in options)
					if(O.optionid && O.optiontext)
						if(canvote && voted)
							if(O.optionid in votedfor)
								output += "<b>[O.optiontext]</b><br>"
							else
								output += "[O.optiontext]<br>"
						else
							output += "<input type='checkbox' name='option_[O.optionid]' value='[O.optionid]'> [O.optiontext]<br>"
				output += "</td></tr></table>"

				if(canvote && !voted)	//Only make this a form if we have not voted yet
					output += "<p><input type='submit' value='Vote'>"
					output += "</form>"

				output += "</div>"

				if(inline)
					return output
				else
					src << browse(output,"window=playerpoll;size=600x250")
		return

/client/proc/vote_on_poll(var/pollid = -1, var/optionid = -1, var/multichoice = 0)
	if(pollid == -1 || optionid == -1)
		return

	if(!isnum(pollid) || !isnum(optionid))
		return
	establish_db_connection()
	if(GLOB.dbcon.IsConnected())

		var/DBQuery/select_query = GLOB.dbcon.NewQuery("SELECT starttime, endtime, question, polltype, multiplechoiceoptions FROM [format_table_name("poll_question")] WHERE id = [pollid] AND Now() BETWEEN starttime AND endtime [holder ? "AND adminonly = 0" : ""]")
		select_query.Execute()

		var/validpoll = 0
		var/multiplechoiceoptions = 0

		while(select_query.NextRow())
			if(select_query.item[4] != POLLTYPE_OPTION && select_query.item[4] != POLLTYPE_MULTI)
				return
			validpoll = 1
			if(select_query.item[5])
				multiplechoiceoptions = text2num(select_query.item[5])
			break

		if(!validpoll)
			to_chat(usr, "<span class='warning'>Poll is not valid.</span>")
			return

		var/DBQuery/select_query2 = GLOB.dbcon.NewQuery("SELECT id FROM [format_table_name("poll_option")] WHERE id = [optionid] AND pollid = [pollid]")
		select_query2.Execute()

		var/validoption = 0

		while(select_query2.NextRow())
			validoption = 1
			break

		if(!validoption)
			to_chat(usr, "<span class='warning'>Poll option is not valid.</span>")
			return

		var/alreadyvoted = 0

		var/DBQuery/voted_query = GLOB.dbcon.NewQuery("SELECT id FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
		voted_query.Execute()

		while(voted_query.NextRow())
			alreadyvoted += 1
			if(!multichoice)
				break

		if(!multichoice && alreadyvoted)
			to_chat(usr, "<span class='warning'>You already voted in this poll.</span>")
			return

		if(multichoice && (alreadyvoted >= multiplechoiceoptions))
			to_chat(usr, "<span class='warning'>You already have more than [multiplechoiceoptions] logged votes on this poll. Enough is enough. Contact the database admin if this is an error.</span>")
			return

		var/adminrank = "Player"
		if(usr && usr.client && usr.client.holder)
			adminrank = usr.client.holder.rank


		var/DBQuery/insert_query = GLOB.dbcon.NewQuery("INSERT INTO [format_table_name("poll_vote")] (id ,datetime ,pollid ,optionid ,ckey ,ip ,adminrank) VALUES (null, Now(), [pollid], [optionid], '[ckey]', '[usr.client.address]', '[adminrank]')")
		insert_query.Execute()

		to_chat(usr, "<span class='notice'>Vote successful.</span>")
		usr << browse(null,"window=playerpoll")


/client/proc/log_text_poll_reply(var/pollid = -1, var/replytext = "")
	if(pollid == -1 || replytext == "")
		return

	if(!isnum(pollid) || !istext(replytext))
		return
	establish_db_connection()
	if(GLOB.dbcon.IsConnected())

		var/DBQuery/select_query = GLOB.dbcon.NewQuery("SELECT starttime, endtime, question, polltype FROM [format_table_name("poll_question")] WHERE id = [pollid] AND Now() BETWEEN starttime AND endtime [holder ? "AND adminonly = 0" : ""]")
		select_query.Execute()

		var/validpoll = 0

		while(select_query.NextRow())
			if(select_query.item[4] != POLLTYPE_TEXT)
				return
			validpoll = 1
			break

		if(!validpoll)
			to_chat(usr, "<span class='warning'>Poll is not valid.</span>")
			return

		var/alreadyvoted = 0

		var/DBQuery/voted_query = GLOB.dbcon.NewQuery("SELECT id FROM [format_table_name("poll_textreply")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
		voted_query.Execute()

		while(voted_query.NextRow())
			alreadyvoted = 1
			break

		if(alreadyvoted)
			to_chat(usr, "<span class='warning'>You already sent your feedback for this poll.</span>")
			return

		var/adminrank = "Player"
		if(usr && usr.client && usr.client.holder)
			adminrank = usr.client.holder.rank


		replytext = replacetext(replytext, "%BR%", "")
		replytext = replacetext(replytext, "\n", "%BR%")
		var/text_pass = reject_bad_text(replytext,8000)
		replytext = replacetext(replytext, "%BR%", "<BR>")

		if(!text_pass)
			to_chat(usr, "The text you entered was blank, contained illegal characters or was too long. Please correct the text and submit again.")
			return

		var/DBQuery/insert_query = GLOB.dbcon.NewQuery("INSERT INTO [format_table_name("poll_textreply")] (id ,datetime ,pollid ,ckey ,ip ,replytext ,adminrank) VALUES (null, Now(), [pollid], '[ckey]', '[usr.client.address]', '[replytext]', '[adminrank]')")
		insert_query.Execute()

		to_chat(usr, "<span class='notice'>Feedback logging successful.</span>")
		usr << browse(null,"window=playerpoll")


/client/proc/vote_on_numval_poll(var/pollid = -1, var/optionid = -1, var/rating = null)
	if(pollid == -1 || optionid == -1)
		return

	if(!isnum(pollid) || !isnum(optionid))
		return
	establish_db_connection()
	if(GLOB.dbcon.IsConnected())

		var/DBQuery/select_query = GLOB.dbcon.NewQuery("SELECT starttime, endtime, question, polltype FROM [format_table_name("poll_question")] WHERE id = [pollid] AND Now() BETWEEN starttime AND endtime [holder ? "AND adminonly = 0" : ""]")
		select_query.Execute()

		var/validpoll = 0

		while(select_query.NextRow())
			if(select_query.item[4] != POLLTYPE_RATING)
				return
			validpoll = 1
			break

		if(!validpoll)
			to_chat(usr, "<span class='warning'>Poll is not valid.</span>")
			return

		var/DBQuery/select_query2 = GLOB.dbcon.NewQuery("SELECT id FROM [format_table_name("poll_option")] WHERE id = [optionid] AND pollid = [pollid]")
		select_query2.Execute()

		var/validoption = 0

		while(select_query2.NextRow())
			validoption = 1
			break

		if(!validoption)
			to_chat(usr, "<span class='warning'>Poll option is not valid.</span>")
			return

		var/alreadyvoted = 0

		var/DBQuery/voted_query = GLOB.dbcon.NewQuery("SELECT id FROM [format_table_name("poll_vote")] WHERE optionid = [optionid] AND ckey = '[ckey]'")
		voted_query.Execute()

		while(voted_query.NextRow())
			alreadyvoted = 1
			break

		if(alreadyvoted)
			to_chat(usr, "<span class='warning'>You already voted in this poll.</span>")
			return

		var/adminrank = "Player"
		if(usr && usr.client && usr.client.holder)
			adminrank = usr.client.holder.rank


		var/DBQuery/insert_query = GLOB.dbcon.NewQuery("INSERT INTO [format_table_name("poll_vote")] (id ,datetime ,pollid ,optionid ,ckey ,ip ,adminrank, rating) VALUES (null, Now(), [pollid], [optionid], '[ckey]', '[usr.client.address]', '[adminrank]', [(isnull(rating)) ? "null" : rating])")
		insert_query.Execute()

		to_chat(usr, "<span class='notice'>Vote successful.</span>")
		usr << browse(null,"window=playerpoll")
