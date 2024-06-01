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

/datum/money_account_database/vv_edit_var(var_name, var_value)
	if(var_name == "vendor_account")
		if(!istype(var_value, /datum/money_account))
			return FALSE //this is how you break the economy
	return ..()

/datum/money_account_database/can_vv_delete()
	message_admins("An admin attempted to VV delete a money account database, this will break the economy system for the round, if you know what you are doing please use advanced proccall")
	return FALSE

/datum/money_account_database/proc/create_account(account_name = "Unnamed", starting_funds = 0, _security_level = ACCOUNT_SECURITY_ID, terminal, supress_log = FALSE)
	var/datum/money_account/new_account = new(account_name, starting_funds, ACCOUNT_SECURITY_ID)
	user_accounts += new_account
	new_account.database_holder = src
	if(!supress_log)
		log_account_action(new_account, starting_funds, "Account Creation", terminal, log_on_database = TRUE)
	return new_account

/datum/money_account_database/proc/create_vendor_account()
	if(vendor_account)
		log_debug("create_vendor_account() was called but a vendor account already exists")
		return
	var/datum/money_account/new_vendor_account = new("[station_name()] Vendor Account", DEPARTMENT_BASE_PAY_MEDIUM, ACCOUNT_SECURITY_RESTRICTED)
	vendor_account = new_vendor_account
	vendor_account.database_holder = src

///takes in an account_numb and returns either an account if it locates one or null if it finds none
/datum/money_account_database/proc/find_user_account(account_number, include_departments = FALSE)
	for(var/datum/money_account/account in user_accounts)
		if(account.account_number == account_number)
			return account

/datum/money_account_database/proc/delete_user_account(account_number, terminal, supress_log = FALSE)
	for(var/datum/money_account/account as anything in user_accounts) // <--- this does not include department account for A GOOD REASON
		if(account.account_number == account_number)
			if(!supress_log)
				log_account_action(account, null, "Delete Money Account", terminal, log_on_database = supress_log)
			user_accounts -= account
			qdel(account)
			return TRUE
	return FALSE

/datum/money_account_database/proc/charge_account(datum/money_account/account, amount, purpose, transactor, allow_overdraft = FALSE, supress_log = FALSE)
	if(!online)
		return
	. = account.try_withdraw_credits(amount, allow_overdraft)
	if(. && !supress_log)
		var/database_log = amount >= DATABASE_LOG_THRESHHOLD ? TRUE : FALSE
		log_account_action(account, amount, purpose, transactor, is_deposit = FALSE, log_on_database = database_log)

/datum/money_account_database/proc/credit_account(datum/money_account/account, amount, purpose, transactor, supress_log = FALSE)
	if(!online)
		return
	. = account.deposit_credits(amount)
	if(!.)
		return

	if(!supress_log)
		var/database_log = amount >= DATABASE_LOG_THRESHHOLD ? TRUE : FALSE
		log_account_action(account, amount, purpose, transactor, is_deposit = TRUE, log_on_database = database_log) //no if check here for now, since deposit credits currently will always return true
	if(account == vendor_account)
		SSeconomy.current_10_minute_spending += amount
		SSeconomy.total_space_credits -= amount //space credits go to die in the vendor_account for now
		SSeconomy.space_credits_destroyed += amount

/datum/money_account_database/proc/try_authenticate_login(datum/money_account/account, pin, restricted_bypass = FALSE, is_vendor = FALSE, is_admin = FALSE)
	if(!online && !is_admin)
		return
	return account.authenticate_login(pin, restricted_bypass, is_vendor, is_admin)

/datum/money_account_database/proc/log_account_action(datum/money_account/account, amount, purpose, transactor, is_deposit, log_on_database = FALSE)
	var/datum/transaction/T = account.make_transaction_log(amount, purpose, transactor, is_deposit)
	if(T && log_on_database)
		database_logs += T
		hidden_database_logs += T

/datum/money_account_database/proc/create_transfer_request(datum/money_account/user_account, amount, purpose, datum/money_account/target_account)
	if(!user_account)
		CRASH("Money Account DB attempted to create transfer request from a null money account")
	var/datum/transfer_request/request = new /datum/transfer_request()
	request.requesting_account = user_account
	request.amount = amount
	request.purpose = purpose
	request.time = world.time
	target_account.create_transfer_request(request)

/*
  * # resolve_transfer_request
  *
  * handles resolving the transfer request on a money account, if succesful, credits requesting account, if no
  * issue occur with processing transfer_request, will return TRUE, else it will return FALSE
  *
  * Arguments:
  * * request - transfer request that is being resolved
  * * user_account - money account where the transfer request is (and account that will be charged)
  * * accepted - Bool, indicates whether or not the user has "accepted" the transfer request
*/
/datum/money_account_database/proc/resolve_transfer_request(datum/transfer_request/request, datum/money_account/user_account, accepted = FALSE)
	if(!accepted) //proc on money account needs to be called first in order to clear the request from the account
		user_account.resolve_transfer_request(request)
		return TRUE
	if(charge_account(user_account, request.amount, "Transfer to [request.requesting_account.account_name]", "NanoBank Transfer Services", FALSE, FALSE))
		credit_account(request.requesting_account, request.amount, "Transfer from [user_account.account_name]", "NanoBank Transfer Services", FALSE)
		if(request.amount >= 5) //we don't care about miniscule transfers
			SSeconomy.total_credit_transfers++
		user_account.resolve_transfer_request(request) //this must be called after we're done referencing of it, cause the request will get deleted
		return TRUE
	return FALSE

/*
  * # Main Station Money Account Database
  *
  * Datum for tracking crew member, department, and station accounts
*/
/datum/money_account_database/main_station
	///list of money accounts for each department on station
	var/list/department_accounts = list()

/datum/money_account_database/main_station/create_account(account_name = "Unnamed", starting_funds = CREW_MEMBER_STARTING_BALANCE, _security_level = ACCOUNT_SECURITY_ID, terminal, supress_log = FALSE)
	var/datum/money_account/new_account = ..(account_name, starting_funds, _security_level, terminal, supress_log)
	new_account.set_credits(starting_funds)
	return new_account

/datum/money_account_database/main_station/proc/create_department_account(department, base_pay, starting_balance)
	if(department_accounts[department])
		log_debug("create_department_account() was called to create a [department] account but account for that department already exists")
		return
	var/datum/money_account/department_account = new("[department] Account", base_pay, ACCOUNT_SECURITY_RESTRICTED, ACCOUNT_TYPE_DEPARTMENT, starting_balance)
	department_account.database_holder = src
	department_accounts[department] = department_account

/datum/money_account_database/main_station/create_vendor_account()
	var/datum/money_account/new_vendor_account = new("[station_name()] Vendor Account", DEPARTMENT_BASE_PAY_MEDIUM, ACCOUNT_SECURITY_RESTRICTED)
	vendor_account = new_vendor_account

/datum/money_account_database/main_station/proc/get_account_by_department(department)
	return department_accounts[department]

/datum/money_account_database/main_station/proc/get_all_user_accounts()
	var/list/account_list = list()
	for(var/datum/money_account/account in user_accounts)
		account_list += account.account_name
	return account_list

/datum/money_account_database/main_station/proc/get_account_from_name(account_name)
	for(var/datum/money_account/account in user_accounts)
		if(account.account_name == account_name)
			return account

/datum/money_account_database/main_station/proc/get_all_department_accounts()
	var/list/account_list = list()
	for(var/department in department_accounts)
		account_list += department_accounts[department]
	return account_list

/datum/money_account_database/main_station/find_user_account(account_number, include_departments = FALSE)
	var/list/accounts_to_search = include_departments ? (user_accounts + get_all_department_accounts()) : user_accounts
	for(var/datum/money_account/account in accounts_to_search)
		if(account.account_number == account_number)
			return account

/*
  * # NAS Trurl Money Account Database
  *
  * Datum for tracking CC money account, used for admin CC characters.
*/

/datum/money_account_database/central_command

/datum/money_account_database/central_command/create_account(account_name = "NAS Trurl Account", starting_funds = CC_OFFICER_STARTING_BALANCE, _security_level = ACCOUNT_SECURITY_CC, supress_log = FALSE)
	var/datum/money_account/new_account = ..()
	new_account.set_credits(starting_funds)
	return new_account
