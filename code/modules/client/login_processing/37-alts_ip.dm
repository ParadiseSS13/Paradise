/datum/client_login_processor/alts_ip
	priority = 37

/datum/client_login_processor/alts_ip/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey FROM player WHERE ip=:address", list(
		"address" = C.address
	))
	return query

/datum/client_login_processor/alts_ip/process_result(datum/db_query/Q, client/C)
	while(Q.NextRow())
		if("[Q.item[1]]" == C.ckey)
			continue
		C.related_accounts_ip += "[Q.item[1]]"
