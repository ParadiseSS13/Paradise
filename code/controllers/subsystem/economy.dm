SUBSYSTEM_DEF(economy)
	name = "Economy"
	flags = SS_BACKGROUND | SS_NO_FIRE
	wait = 10
	runlevels = RUNLEVEL_GAME
	offline_implications = "Nothing, economy will still function"
	///List of all money account databases existing in the round
	var/list/money_account_databases = list()
	///Total amount of account created during the round, neccesary for generating unique account ids
	var/account_counter = 0

	///The absolute total amount of space cash (not to be confused with credits) in the round, does not count space credits in money accounts
	var/total_space_cash = 0
	///The absolute total amount of space credits in various economy systems, does not count space cash
	var/total_space_credits = 0

	///The amount of space credits that have been irreversibly deleted/removed from the round
	var/space_credits_destroyed = 0
	///The amount of space credits that have been created out of thin air, does not include credits created at round-start
	var/space_credits_created = 0

/datum/controller/subsystem/economy/Initialize()
	///create main station accounts
	if(!GLOB.current_date_string)
		GLOB.current_date_string = "[time2text(world.timeofday, "DD Month")], [GLOB.game_year]"
	if(GLOB.station_money_database)
		populate_station_database()
	if(GLOB.centcomm_money_database)
		populate_cc_database()

	return ..()

/*
  * # generate_account_number()
  *
  * SS proc that will generate a mostly random seven digit account number.
  * This will allow up to 1000 guaranteed unique account numbers
*/
/datum/controller/subsystem/economy/proc/generate_account_number()
	account_counter++
	return (rand(1000, 9999) * 1000) + account_counter

/datum/controller/subsystem/economy/proc/populate_station_database()
	var/datum/money_account_database/main_station/station_db = GLOB.station_money_database
	money_account_databases += station_db
	for(var/department in GLOB.station_departments)
		station_db.create_department_account(department)
	station_db.create_vendor_account()

/datum/controller/subsystem/economy/proc/populate_cc_database()
	var/datum/money_account_database/central_command/cc_db = GLOB.centcomm_money_database
	money_account_databases += cc_db
