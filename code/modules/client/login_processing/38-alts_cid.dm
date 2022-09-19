/datum/client_login_processor/alts_cid
	priority = 38

/datum/client_login_processor/alts_cid/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey FROM player WHERE computerid=:cid", list(
		"cid" = C.computer_id
	))
	return query

/datum/client_login_processor/alts_cid/process_result(datum/db_query/Q, client/C)
	while(Q.NextRow())
		if("[Q.item[1]]" == C.ckey)
			continue
		C.related_accounts_cid += "[Q.item[1]]"
