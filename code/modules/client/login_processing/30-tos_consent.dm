/datum/client_login_processor/tos_consent
	priority = 30

/datum/client_login_processor/tos_consent/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey FROM privacy WHERE ckey=:ckey AND consent=1", list(
		"ckey" = C.ckey
	))
	return query

/datum/client_login_processor/tos_consent/process_result(datum/db_query/Q, client/C)
	// If there is no TOS, auto accept
	if(!GLOB.join_tos)
		C.tos_consent = TRUE
		return

	// If our query failed dont just assume yes
	if(Q.last_error)
		C.tos_consent = FALSE
		return

	// If we returned a row, they accepted
	while(Q.NextRow())
		C.tos_consent = TRUE

