/datum/client_login_processor/watchlist
	priority = 36

/datum/client_login_processor/watchlist/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT reason FROM watch WHERE ckey=:ckey", list(
		"ckey" = C.ckey
	))
	return query

/datum/client_login_processor/watchlist/process_result(datum/db_query/Q, client/C)
	if(Q.NextRow())
		var/watchreason = Q.item[1]
		message_admins("<font color='red'><B>Notice: </B></font><font color='#EB4E00'>[key_name_admin(C)] is on the watchlist and has just connected - Reason: [watchreason]</font>")
		SSdiscord.send2discord_simple_noadmins("**\[Watchlist]** [key_name(C)] is on the watchlist and has just connected - Reason: [watchreason]")
		C.watchlisted = TRUE
