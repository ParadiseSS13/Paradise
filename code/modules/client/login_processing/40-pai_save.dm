/datum/client_login_processor/pai_save
	priority = 40

/datum/client_login_processor/pai_save/get_query(client/C)
	return C.pai_save.get_query()

/datum/client_login_processor/pai_save/process_result(datum/db_query/Q, client/C)
	C.pai_save.load_data(Q)
