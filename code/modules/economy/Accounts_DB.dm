/*
  * # Money Account Database
  *
  * Datum for tracking a group of related money account, facilitates account creation, deletion, and interaction
  *
*/
/datum/money_account_database
	///list of money account datums for individual users
	var/list/user_accounts = list()
	///list of actions taken on the money account database, such as creating/deleting accounts
	var/list/database_logs = list()
	///Tracking log of all actions on the account databse, used for admin logging and debugging
	var/list/hidden_database_logs = list()

	var/datum/money_account/vendor_account
	///Will the database permit actions on it? Useful for random events
	var/online = TRUE

/datum/money_account_database/proc/create_account(account_name = "Unnamed", starting_funds = 0, _security_level = ACCOUNT_SECURITY_ID, terminal, supress_log = FALSE)
	var/datum/money_account/new_account = new(account_name, starting_funds, ACCOUNT_SECURITY_ID)
	user_accounts += new_account
	if(!supress_log)
		log_account_action(new_account, "Account Creation", terminal, log_on_database = TRUE)
	return new_account

/datum/money_account_database/proc/create_vendor_account(name)
	var/datum/money_account/new_vendor_account = new("[name] Vendor Account", DEPARTMENT_STARTING_BALANCE, ACCOUNT_SECURITY_RESTRICTED)
	vendor_account = new_vendor_account

///takes in an account_numb and returns either an account if it locates one or null if it finds none
/datum/money_account_database/proc/find_user_account(account_number)
	for(var/datum/money_account/account in user_accounts)
		if(account.account_number == account_number)
			return account

/datum/money_account_database/proc/delete_user_account(account_number, terminal, supress_log = FALSE)
	for(var/datum/money_account/account in user_accounts)
		if(account.account_number == account_number)
			if(!supress_log)
				log_account_action(account, null, "Delete Money Account", terminal, log_on_database = TRUE)
			user_accounts -= account
			return TRUE
	return FALSE

/datum/money_account_database/proc/charge_account(datum/money_account/account, amount, purpose, transactor, allow_overdraft = FALSE, supress_log = FALSE)
	if(!online)
		return
	. = account.try_withdraw_credits(amount, allow_overdraft)
	if(. && !supress_log)
		var/database_log = amount >= DATABASE_LOG_THRESHHOLD ? TRUE : FALSE
		log_account_action(account, amount, purpose, transactor, log_on_database = database_log)

/datum/money_account_database/proc/credit_account(datum/money_account/account, amount, purpose, transactor, supress_log = FALSE)
	if(!online)
		return
	. = account.deposit_credits(amount)
	if(. && !supress_log)
		var/database_log = amount >= DATABASE_LOG_THRESHHOLD ? TRUE : FALSE
		log_account_action(account, amount, purpose, transactor, log_on_database = database_log) //no if check here for now, since deposit credits currently will always return true

/datum/money_account_database/proc/try_authenticate_login(datum/money_account/account, pin, restricted_bypass = FALSE, is_vendor = FALSE, is_admin = FALSE)
	if(!online && !is_admin)
		return
	return account.authenticate_login(pin, restricted_bypass, is_vendor, is_admin)

/datum/money_account_database/proc/log_account_action(datum/money_account/account, amount, purpose, transactor, log_on_database = FALSE)
	var/datum/transaction/T = account.make_transaction_log(amount, purpose, transactor)
	if(T && log_on_database)
		database_logs += T
		hidden_database_logs += T

/*
  * # Main Station Money Account Database
  *
  * Datum for tracking crew member, department, and station accounts
*/
/datum/money_account_database/main_station
	///list of money accounts for each department on station
	var/list/department_accounts = list()

/datum/money_account_database/main_station/create_account(account_name = "Unnamed", starting_funds = CREW_MEMBER_STARTING_BALANCE, _security_level = ACCOUNT_SECURITY_ID, supress_log = FALSE)
	var/datum/money_account/new_account	= ..()
	new_account.set_credits(starting_funds)
	return new_account

/datum/money_account_database/main_station/proc/create_department_account(department)
	if(department_accounts[department])
		return
	var/datum/money_account/department_account = new("[department] Account", DEPARTMENT_STARTING_BALANCE, ACCOUNT_SECURITY_RESTRICTED, ACCOUNT_TYPE_DEPARTMENT)
	department_accounts[department] = department_account

/datum/money_account_database/main_station/create_vendor_account()
	var/datum/money_account/new_vendor_account = new("[station_name()] Vendor Account", DEPARTMENT_STARTING_BALANCE, ACCOUNT_SECURITY_RESTRICTED)
	vendor_account = new_vendor_account

/datum/money_account_database/main_station/proc/get_account_by_department(department)
	return department_accounts[department]

/*
  * # NAS Trurl Money Account Database
  *
  * Datum for tracking CC money account, used for admin CC characters.
*/

/datum/money_account_database/central_command

/datum/money_account_database/central_command/create_account(account_name = "NAS Trurl Account", starting_funds = CC_OFFICER_STARTING_BALANCE, _security_level = ACCOUNT_SECURITY_CC, supress_log = FALSE)
	var/datum/money_account/new_account	= ..()
	new_account.set_credits(starting_funds)
	return new_account
