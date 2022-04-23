/datum/client_login_processor/load_jobbans
	priority = 25

// These look pretty useless, but it allows the client jobban holder to reload bans without proc calling here,
// and we can re-use the same queries and handlers
/datum/client_login_processor/load_jobbans/get_query(client/C)
	return C.jbh.get_query(C)

/datum/client_login_processor/load_jobbans/process_result(datum/db_query/Q, client/C)
	C.jbh.process_query(Q)
