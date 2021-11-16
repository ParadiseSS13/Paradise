/datum/client_login_processor/karma_numbers
	priority = 42

/datum/client_login_processor/karma_numbers/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT karma, karmaspent FROM karmatotals WHERE byondkey=:ckey", list(
		"ckey" = C.ckey
	))
	return query

/datum/client_login_processor/karma_numbers/process_result(datum/db_query/Q, client/C)
	C.karmaholder = new()
	while(Q.NextRow())
		C.karmaholder.karma_earned = Q.item[1]
		C.karmaholder.karma_spent = Q.item[2]
