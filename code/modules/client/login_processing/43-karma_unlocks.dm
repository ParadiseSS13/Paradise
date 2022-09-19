/datum/client_login_processor/karma_unlocks
	priority = 43

/datum/client_login_processor/karma_unlocks/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT purchase FROM karma_purchases WHERE ckey=:ckey", list(
		"ckey" = C.ckey
	))
	return query

/datum/client_login_processor/karma_unlocks/process_result(datum/db_query/Q, client/C)
	while(Q.NextRow())
		C.karmaholder.addUnlock(Q.item[1])
