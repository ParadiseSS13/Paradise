/proc/check_prisonlist(var/K)
	var/noprison_key
	if(!dbcon.IsConnected())
		to_chat(usr, "\red Unable to connect to whitelist database. Please try again later.<br>")
		return 1
	else
		var/DBQuery/query = dbcon.NewQuery("SELECT ckey FROM [format_table_name("bwhitelist")] WHERE ckey='[K]'")
		query.Execute()
		while(query.NextRow())
			noprison_key = query.item[1]
		if(noprison_key == K)
			return 1
	return 0
