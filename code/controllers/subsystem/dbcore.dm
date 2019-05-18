SUBSYSTEM_DEF(dbcore)
	name = "Database"
	flags = SS_NO_INIT|SS_NO_FIRE
	init_order = INIT_ORDER_DBCORE
	var/const/FAILED_DB_CONNECTION_CUTOFF = 5

	var/const/Default_Cursor = 0
	var/const/Client_Cursor = 1
	var/const/Server_Cursor = 2
	//conversions
	var/const/TEXT_CONV = 1
	var/const/RSC_FILE_CONV = 2
	var/const/NUMBER_CONV = 3
	//column flag values:
	var/const/IS_NUMERIC = 1
	var/const/IS_BINARY = 2
	var/const/IS_NOT_NULL = 4
	var/const/IS_PRIMARY_KEY = 8
	var/const/IS_UNSIGNED = 16
// TODO: Investigate more recent type additions and see if I can handle them. - Nadrew

	var/_db_con// This variable contains a reference to the actual database connection.
	var/failed_connections = 0

/datum/controller/subsystem/dbcore/PreInit()
	_db_con = _dm_db_new_con()

/datum/controller/subsystem/dbcore/Recover()
	_db_con = SSdbcore._db_con

/datum/controller/subsystem/dbcore/Shutdown()
	// This is as clsoe as we can get to the true round end before Disconnect() without changing where it's called, deafeating the reason this is a subsystem
	if(SSdbcore.Connect())
		var/sql_station_name = sanitizeSQL(station_name())
		var/datum/DBQuery/query_round_end = SSdbcore.NewQuery("INSERT INTO [format_table_name("round")] (shutdown_datetime, game_mode_result, end_state, station_name) VALUES (Now(), '[SSticker.mode_result]', '[SSticker.end_state]', '[sql_station_name]') WHERE id = [GLOB.round_id]")
		query_round_end.Execute()
	if(IsConnected())
		Disconnect()

//nu
/datum/controller/subsystem/dbcore/can_vv_get(var_name)
	return var_name != "_db_con" && ..()

/datum/controller/subsystem/dbcore/vv_edit_var(var_name, var_value)
	if(var_name == "_db_con")
		return FALSE
	return ..()

/datum/controller/subsystem/dbcore/proc/Connect()
	if(IsConnected())
		return TRUE

	if(failed_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect anymore.
		return FALSE

	if(!config.sql_enabled)
		return FALSE

	var/user = global.sqlfdbklogin
	var/pass = global.sqlfdbkpass
	var/db = global.sqlfdbkdb
	var/address = global.sqladdress
	var/port = global.sqlport

	doConnect("dbi:mysql:[db]:[address]:[port]", user, pass)
	. = IsConnected()
	if(!.)
		log_sql("Connect() failed | [ErrorMsg()]")
		++failed_connections

/datum/controller/subsystem/dbcore/proc/SetRoundID()
	if(!Connect())
		return
	var/datum/DBQuery/query_round_initialize = SSdbcore.NewQuery("INSERT INTO [format_table_name("round")] (initialize_datetime, server_ip, server_port) VALUES (Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]')")
	query_round_initialize.Execute()
	var/datum/DBQuery/query_round_last_id = SSdbcore.NewQuery("SELECT LAST_INSERT_ID()")
	query_round_last_id.Execute()
	if(query_round_last_id.NextRow())
		GLOB.round_id = query_round_last_id.item[1]

/datum/controller/subsystem/dbcore/proc/SetRoundStart()
	if(!Connect())
		return
	var/datum/DBQuery/query_round_start = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET start_datetime = Now() WHERE id = [GLOB.round_id]")
	query_round_start.Execute()

/datum/controller/subsystem/dbcore/proc/SetRoundEnd()
	if(!Connect())
		return
	var/sql_station_name = sanitizeSQL(station_name())
	var/datum/DBQuery/query_round_end = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET end_datetime = Now(), game_mode_result = '[sanitizeSQL(SSticker.mode_result)]', station_name = '[sql_station_name]' WHERE id = [GLOB.round_id]")
	query_round_end.Execute()

/datum/controller/subsystem/dbcore/proc/doConnect(dbi_handler, user_handler, password_handler)
	if(!config.sql_enabled)
		return FALSE
	return _dm_db_connect(_db_con, dbi_handler, user_handler, password_handler, Default_Cursor, null)

/datum/controller/subsystem/dbcore/proc/Disconnect()
	failed_connections = 0
	return _dm_db_close(_db_con)

/datum/controller/subsystem/dbcore/proc/IsConnected()
	if(!config.sql_enabled)
		return FALSE
	return _dm_db_is_connected(_db_con)

/datum/controller/subsystem/dbcore/proc/Quote(str)
	return _dm_db_quote(_db_con, str)

/datum/controller/subsystem/dbcore/proc/ErrorMsg()
	return _dm_db_error_msg(_db_con)

/datum/controller/subsystem/dbcore/proc/NewQuery(sql_query, cursor_handler = Default_Cursor)
	return new /datum/DBQuery(sql_query, src, cursor_handler)


/datum/DBQuery
	var/sql // The sql query being executed.
	var/default_cursor
	var/list/columns //list of DB Columns populated by Columns()
	var/list/conversions
	var/list/item  //list of data values populated by NextRow()

	var/datum/controller/subsystem/dbcore/db_connection
	var/_db_query

/datum/DBQuery/New(sql_query, datum/controller/subsystem/dbcore/connection_handler, cursor_handler)
	if(sql_query)
		sql = sql_query
	if(connection_handler)
		db_connection = connection_handler
	if(cursor_handler)
		default_cursor = cursor_handler
	item = list()
	_db_query = _dm_db_new_query()

/datum/DBQuery/proc/Connect(datum/controller/subsystem/dbcore/connection_handler)
	db_connection = connection_handler

/datum/DBQuery/proc/warn_execute()
	. = Execute()
	if(!.)
		to_chat(usr, "<span class='danger'>A SQL error occured during this operation, check the server logs.</span>")

/datum/DBQuery/proc/Execute(sql_query = sql, cursor_handler = default_cursor, log_error = TRUE)
	Close()
	. = _dm_db_execute(_db_query, sql_query, db_connection._db_con, cursor_handler, null)
	if(!. && log_error)
		log_sql("[ErrorMsg()] | Query used: [sql]")

/datum/DBQuery/proc/NextRow()
	return _dm_db_next_row(_db_query,item,conversions)

/datum/DBQuery/proc/RowsAffected()
	return _dm_db_rows_affected(_db_query)

/datum/DBQuery/proc/RowCount()
	return _dm_db_row_count(_db_query)

/datum/DBQuery/proc/ErrorMsg()
	return _dm_db_error_msg(_db_query)

/datum/DBQuery/proc/Columns()
	if(!columns)
		columns = _dm_db_columns(_db_query, /datum/DBColumn)
	return columns

/datum/DBQuery/proc/GetRowData()
	var/list/columns = Columns()
	var/list/results
	if(columns.len)
		results = list()
		for(var/C in columns)
			results+=C
			var/datum/DBColumn/cur_col = columns[C]
			results[C] = src.item[(cur_col.position+1)]
	return results

/datum/DBQuery/proc/Close()
	item.Cut()
	columns = null
	conversions = null
	return _dm_db_close(_db_query)

/datum/DBQuery/proc/Quote(str)
	return db_connection.Quote(str)

/datum/DBQuery/proc/SetConversion(column,conversion)
	if(istext(column))
		column = columns.Find(column)
	if(!conversions)
		conversions = list(column)
	else if(conversions.len < column)
		conversions.len = column
	conversions[column] = conversion


/datum/DBColumn
	var/name
	var/table
	var/position //1-based index into item data
	var/sql_type
	var/flags
	var/length
	var/max_length
	//types
	var/const/TINYINT = 1
	var/const/SMALLINT = 2
	var/const/MEDIUMINT = 3
	var/const/INTEGER = 4
	var/const/BIGINT = 5
	var/const/DECIMAL = 6
	var/const/FLOAT = 7
	var/const/DOUBLE = 8
	var/const/DATE = 9
	var/const/DATETIME = 10
	var/const/TIMESTAMP = 11
	var/const/TIME = 12
	var/const/STRING = 13
	var/const/BLOB = 14

/datum/DBColumn/New(name_handler, table_handler, position_handler, type_handler, flag_handler, length_handler, max_length_handler)
	name = name_handler
	table = table_handler
	position = position_handler
	sql_type = type_handler
	flags = flag_handler
	length = length_handler
	max_length = max_length_handler

/datum/DBColumn/proc/SqlTypeName(type_handler = sql_type)
	switch(type_handler)
		if(TINYINT) return "TINYINT"
		if(SMALLINT) return "SMALLINT"
		if(MEDIUMINT) return "MEDIUMINT"
		if(INTEGER) return "INTEGER"
		if(BIGINT) return "BIGINT"
		if(FLOAT) return "FLOAT"
		if(DOUBLE) return "DOUBLE"
		if(DATE) return "DATE"
		if(DATETIME) return "DATETIME"
		if(TIMESTAMP) return "TIMESTAMP"
		if(TIME) return "TIME"
		if(STRING) return "STRING"
		if(BLOB) return "BLOB"
