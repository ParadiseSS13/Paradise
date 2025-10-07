/*
  * # Money Account
  *
  * Datum for tracking an individual account in an account database, facilitates withdrawl, depositing, and authentification
  *
*/
/datum/money_account
	///Full name of the account, set at creation of the account
	var/account_name
	///Unique Account Number Identifier for the account     -Username
	var/account_number = 0
	///4 digit pin password for accessing the money account -Password
	var/account_pin = 0
	///How many space credits are in the account
	var/credit_balance
	///Tracking log of all actions on the account, for IC usage & can have entries deleted
	var/list/account_log = list()
	///Tracking log of all actions on the account, used for admin logging and debugging
	var/list/hidden_account_log = list()

	///reference to parent account database, only used for GC
	var/datum/money_account_database/database_holder

	///Level of security on the money account
	var/security_level
	///Bool - Is this account locked out from being used completely?
	var/suspended = FALSE
	///Type of account this is
	var/account_type = ACCOUNT_TYPE_PERSONAL
	///the amount this account receives every payday
	var/payday_amount = CREW_PAY_ASSISTANT

	///The nanobank programs associated with this account, used for notifying crew members through PDA, this is a lazy list
	var/list/associated_nanobank_programs
	///The requests made to this money_account used for ATM and NanoBank credit transfers, this is a lazy list
	var/list/transfer_requests

	///pay bonuses for the next pay period for this account, this is a lazy list
	var/list/pay_check_bonuses
	///pay deductions for the next pay period for this account, this is a lazy list
	var/list/pay_check_deductions

/datum/money_account/New(_account_name, starting_balance = 0, _security_level = ACCOUNT_SECURITY_ID, _account_type = ACCOUNT_TYPE_PERSONAL, _payday_amount = CREW_PAY_ASSISTANT)
	account_name = _account_name
	credit_balance = starting_balance
	payday_amount = _payday_amount
	security_level = _security_level
	account_number = SSeconomy.generate_account_number()
	account_type = _account_type
	account_pin = rand(BANK_PIN_MIN, BANK_PIN_MAX) // defines are currently housed in misc_defines.dm
	//update SSeconomy stats
	SSeconomy.total_space_credits += starting_balance

/datum/money_account/Destroy(force)
	//we don't need to worry about nanobank programs here because they auto GC themselves
	QDEL_LIST_CONTENTS(account_log)
	QDEL_LIST_CONTENTS(hidden_account_log)
	if(!QDELETED(database_holder))
		if(account_type == ACCOUNT_TYPE_PERSONAL)
			database_holder.user_accounts -= src //remove reference to this account incase this was not deleted the "correct" way through an account db
		else if(!force && istype(database_holder, /datum/money_account_database/main_station) && account_type == ACCOUNT_TYPE_DEPARTMENT)
			return QDEL_HINT_LETMELIVE //we do not want department accounts being deleted ever unless we really really mean to

	for(var/datum/transfer_request/request as anything in transfer_requests)
		resolve_transfer_request(request, FALSE)
		//while we're here, lets do the GC a favor and get rid of these transfer request datums
	database_holder = null
	SSeconomy.total_space_credits -= credit_balance
	SSeconomy.space_credits_destroyed += credit_balance
	return ..()


/*
  * # try_withdraw_credits()
  *
  * makes sure withdraw request is allowed, if succesful it withdraws the amount and returns TRUE, else FALSE
  *
  * Arguments:
  * * amount - The credits being subtracted from the account
  * * allow_overdraft - bool that if true, prevents withdrawals that bring the account balance below 0 credits
  * *
*/
/datum/money_account/proc/try_withdraw_credits(amount, allow_overdraft = FALSE)
	if(!allow_overdraft && credit_balance - amount < 0)
		return FALSE
	credit_balance -= amount
	return TRUE

///set proc for depositing money, changing credit_balance should always be done through procs
/datum/money_account/proc/deposit_credits(amount = 0)
	credit_balance += amount
	return TRUE

///sets the credit balance to specified value, changing credit_balance should always be done through procs
/datum/money_account/proc/set_credits(amount)
	credit_balance = max(0, amount)

/*
  * # authenticate_login()
  *
  * returns TRUE or FALSE based on whether or not the user is properly authenticated to log into this account
  *
  * Arguments:
  * * provided_pin - the pin given by the user attempting to access the account
  * * restricted_bypass - a bool that if true, allows user to access an acount with Restricted Access
  * * is_vendor - is this user a vendor/npc ?
  * * is_admin - is user an admin?
*/
/datum/money_account/proc/authenticate_login(provided_pin, restricted_bypass = FALSE, is_vendor = FALSE, is_admin = FALSE)
	if(suspended)
		return FALSE
	. = FALSE
	switch(security_level)
		if(ACCOUNT_SECURITY_ID)
			. = TRUE
		if(ACCOUNT_SECURITY_PIN)
			if(account_pin == provided_pin)
				. = TRUE
		if(ACCOUNT_SECURITY_RESTRICTED)
			if(restricted_bypass && account_pin == provided_pin)
				. = TRUE
		if(ACCOUNT_SECURITY_CC)
			if(is_admin)
				. = TRUE
		if(ACCOUNT_SECURITY_VENDOR)
			if(is_vendor)
				. = TRUE

/datum/money_account/proc/set_account_security(new_security_level)
	if(suspended)
		return FALSE
	if(new_security_level < ACCOUNT_SECURITY_ID || new_security_level > ACCOUNT_SECURITY_VENDOR)
		CRASH("set_account_security() called with an invalid security level")
	security_level = new_security_level

/*
  * # make_transaction_log
  *
  * creates a log of specified financial action that is visible in-game.
  * Arguments:
  * * amount - amount of cash(if any) utilized during the transaction
  * * purpose - what the transaction was for, account creation, charge, deposit, withdrawal, etc
  * * transactor - who performed the action
*/
/datum/money_account/proc/make_transaction_log(amount, purpose, transactor, is_deposit = FALSE)
	var/datum/transaction/T = new()
	T.account = src
	T.transactor = transactor ? transactor : "Unknown"
	T.purpose = purpose ? purpose : "No Reason Specified"
	T.amount = "[amount ? amount : "N/A"]"
	T.time = station_time_timestamp()
	T.is_deposit = is_deposit
	account_log += T
	hidden_account_log += T
	return T

/datum/transaction
	///the account this log is attached to, used for money db level logging
	var/account
	///Who performed the action
	var/transactor
	///What this transaction is doing
	var/purpose
	///If money is utilized/changed during this transaction, how much
	var/amount
	///when the transaction occurred
	var/time
	///Whether or not this added or money from the account
	var/is_deposit

/*
  * # create_transfer_request
  *
  * creates a transfer request for this money account, handles lazy list interactions. If accepted, will
  * return FALSE for the account db if there's not a large enough credit balance
  * Arguments:
  * * request -  datum/transfer_request to be added to list
  * * accepted - bool, whether or not user accepted request, determines whether or not to check credit balance
*/
/datum/money_account/proc/create_transfer_request(datum/transfer_request/request)
	if(!request.amount)
		CRASH("Attempted to add a transfer request to a money account ([account_name]) with a null or zero amount")
	if(LAZYLEN(associated_nanobank_programs))
		for(var/datum/data/pda/app/nanobank/program as anything in associated_nanobank_programs)
			program.notify("NanoBank Transfer Request Received", TRUE)
	LAZYADD(transfer_requests, request)

/datum/money_account/proc/resolve_transfer_request(datum/transfer_request/request)
	request.requesting_account = null //gc
	LAZYREMOVE(transfer_requests, request)
	return TRUE

/datum/transfer_request
	///the money account that is requesting money
	var/datum/money_account/requesting_account
	///reason for transfer request
	var/purpose = "No Reason Given"
	///how much money is being request
	var/amount = 0
	///when the money was requested
	var/time = 0

/*
  * # modify_payroll
  *
  * Will add/subtract from the next paycheck for this money account. As long as announce is true, the user
  * will be informed of exactly how much is added/deducted so there is no need to include it with the reason
  * Arguments:
  * * amount - amount to modify payroll, can be negative or positive
  * * announce - should NanoBank accounts associated with this money account get an alert about this modification?
  * * reason - The reason for the modification, will broadcast this reasont to associated NanoBank accounts
*/
/datum/money_account/proc/modify_payroll(amount, announce = FALSE, reason)
	if(!amount)
		CRASH("Attempted to modify payroll on a money account ([account_name]) with a null or zero amount")
	var/bonus = amount > 0 ? TRUE : FALSE
	if(bonus)
		LAZYADD(pay_check_bonuses, amount)
	else
		LAZYADD(pay_check_deductions, -amount) //we need to make the amount positive here
	if(amount)
		if(LAZYLEN(associated_nanobank_programs))
			for(var/datum/data/pda/app/nanobank/program as anything in associated_nanobank_programs)
				if(reason)
					program.notify(reason, FALSE, TRUE)
				program.notify("[amount] credit [bonus ? "bonus" : "deduction"] added to your next paycheck, have a Nanotrasen day!", TRUE)
