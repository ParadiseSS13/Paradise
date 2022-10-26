GLOBAL_VAR(current_date_string)
GLOBAL_DATUM_INIT(station_money_database, /datum/money_account_database/main_station, new())
GLOBAL_DATUM_INIT(centcomm_money_database, /datum/money_account_database/central_command, new())

GLOBAL_LIST_INIT(all_supply_groups, list(
	SUPPLY_EMERGENCY,
	SUPPLY_SECURITY,
	SUPPLY_ENGINEER,
	SUPPLY_MEDICAL,
	SUPPLY_SCIENCE,
	SUPPLY_ORGANIC,
	SUPPLY_MATERIALS,
	SUPPLY_MISC,
	SUPPLY_VEND))

GLOBAL_LIST_INIT(station_departments, list(DEPARTMENT_COMMAND, "Medical", "Engineering", "Science", "Security", "Supply", "Support", "Assistant"))
