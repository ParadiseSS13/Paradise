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

	var/list/transaction_log = list()
	///Level of security on the money account
	var/security_level
	///Bool - Is this account locked out from being used completely?
	var/suspended = FALSE

/datum/money_account/New(_account_name, starting_balance = 0, _security_level = ACCOUNT_SECURITY_ID)
	account_name = _account_name
	credit_balance = starting_balance
	security_level = _security_level
	account_number = SSeconomy.generate_account_number()
	account_pin = rand(10000, 99999)
	..()

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
	if(!allow_overdraft && (credit_balance - amount < 0))
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

/*
  * # make_transaction_log
  *
  * creates a log of specified financial action that is visible in-game.
  * Arguments:
  * * amount - amount of cash(if any) utilized during the transaction
  * * purpose - what the transaction was for, account creation, charge, deposit, withdrawal, etc
  * * transactor - who performed the action
*/
/datum/money_account/proc/make_transaction_log(amount, purpose, transactor)
	var/datum/transaction/T = new()
	T.account = src
	T.transactor = transactor ? transactor : "Unknown"
	T.purpose = purpose ? purpose : "No Reason Specified"
	T.amount = "[amount ? amount : "N/A"]"
	T.time = station_time_timestamp()
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
