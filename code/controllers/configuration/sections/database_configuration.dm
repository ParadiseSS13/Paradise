/// Config holder for all database related things
/datum/configuration_section/database_configuration
	protection_state = PROTECTION_PRIVATE // NO! BAD!
	/// SQL enabled or not
	var/enabled = FALSE
	/// What SQL version are we on
	var/version = 0
	/// Address of the SQL server
	var/address = "127.0.0.1"
	/// Port of the SQL server
	var/port = 3306
	/// SQL usename
	var/username = "root"
	/// SQL password
	var/password = "root" // Dont do this in prod. Please......
	/// Database name
	var/db = "paradise_gamedb"
	/// Time in seconds for async queries to time out
	var/async_query_timeout = 10
	/// Thread limit for async queries
	var/async_thread_limit = 50

/datum/configuration_section/database_configuration/load_data(list/data)
	CONFIG_LOAD_BOOL(enabled, data["sql_enabled"])
	CONFIG_LOAD_NUM(version, data["sql_version"])
	CONFIG_LOAD_STR(address, data["sql_address"])
	CONFIG_LOAD_NUM(port, data["sql_port"])
	CONFIG_LOAD_STR(username, data["sql_username"])
	CONFIG_LOAD_STR(password, data["sql_password"])
	CONFIG_LOAD_STR(db, data["sql_database"])
	CONFIG_LOAD_NUM(async_query_timeout, data["async_query_timeout"])
	CONFIG_LOAD_NUM(async_thread_limit, data["async_thread_limit"])
