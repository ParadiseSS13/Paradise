var/global/current_date_string
var/global/num_financial_terminals = 1
//var/global/datum/money_account/station_account
//var/global/list/datum/money_account/department_accounts = list()
var/global/next_account_number = 0
var/global/obj/machinery/account_database/centcomm_account_db
//var/global/datum/money_account/vendor_account
var/global/list/all_money_accounts = list()

/*
/proc/create_station_account()
	if(!station_account)
		next_account_number = rand(111111, 999999)

		station_account = new()
		station_account.owner_name = "[station_name()] Station Account"
		station_account.account_number = rand(111111, 999999)
		station_account.remote_access_pin = rand(1111, 111111)
		station_account.money = 75000

		//create an entry in the account transaction log for when it was created
		var/datum/transaction/T = new()
		T.target_name = station_account.owner_name
		T.purpose = "Account creation"
		T.amount = 75000
		T.date = "2nd April, 2555"
		T.time = "11:24"
		T.source_terminal = "Biesel GalaxyNet Terminal #277"

		//add the account
		station_account.transaction_log.Add(T)
		all_money_accounts.Add(station_account)

/proc/create_department_account(department)
	next_account_number = rand(111111, 999999)

	var/datum/money_account/department_account = new()
	department_account.owner_name = "[department] Account"
	department_account.account_number = rand(111111, 999999)
	department_account.remote_access_pin = rand(1111, 111111)
	department_account.money = 5000

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = department_account.owner_name
	T.purpose = "Account creation"
	T.amount = department_account.money
	T.date = "2nd April, 2555"
	T.time = "11:24"
	T.source_terminal = "Biesel GalaxyNet Terminal #277"

	//add the account
	department_account.transaction_log.Add(T)
	all_money_accounts.Add(department_account)

	department_accounts[department] = department_account

//the current ingame time (hh:mm) can be obtained by calling:
//worldtime2text()
*/
/proc/create_account(var/mob/living/carbon/human/H, var/starting_funds = 0, var/obj/machinery/account_database/source_db, )

	var/DBQuery/query = dbcon.NewQuery("SELECT account_number,account_pin,account_balance FROM characters WHERE ckey='[sql_sanitize_text(H.ckey)]' AND slot='[H.client.prefs.slot_name]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR retrieving bank account information. Error : \[[err]\]\n")
		message_admins("SQL ERROR retrieving bank account information. Error : \[[err]\]\n")
		return


	//general preferences
	while(query.NextRow())
		//create a new account
		var/datum/money_account/M = new()
		M.owner_name = H.real_name
		if(text2num(query.item[1]) == 0)
			M.remote_access_pin = rand(1111, 111111)
			M.money = 1000
			M.account_number = rand(111111, 999999)
			var/DBQuery/query2 = dbcon.NewQuery("UPDATE characters SET account_number='[M.account_number]',account_pin='[M.remote_access_pin]', account_balance='[M.money]' WHERE ckey='[sql_sanitize_text(H.ckey)]' AND slot='[H.client.prefs.slot_name]'")
			if(!query2.Execute())
				var/err = query2.ErrorMsg()
				log_game("SQL ERROR creating bank account. Error : \[[err]\]\n")
				message_admins("SQL ERROR creating bank account. Error : \[[err]\]\n")
				return

		else
			M.remote_access_pin = text2num(query.item[2])
			M.money = text2num(query.item[3])
			M.account_number = text2num(query.item[1])

		all_money_accounts.Add(M)
		return M

/datum/money_account
	var/owner_name = ""
	var/account_number = 0
	var/remote_access_pin = 0
	var/money = 0
	var/suspended = 0
	var/list/transaction_log = list()
	var/security_level = 1	//0 - auto-identify from worn ID, require only account number
							//1 - require manual login / account number and pin
							//2 - require card and manual login

/datum/money_account/New()
	..()
	security_level = pick (0,1) //Stealing is now slightly viable

/datum/transaction
	var/target_name = ""
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""


//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/proc/attempt_account_access(var/attempt_account_number, var/attempt_pin_number, var/security_level_passed = 0,var/pin_needed=1)
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == attempt_account_number)
			if( D.security_level <= security_level_passed && (!D.security_level || D.remote_access_pin == attempt_pin_number || !pin_needed) )
				return D

/obj/machinery/account_database/proc/get_account(var/account_number)
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == account_number)
			return D

/proc/attempt_account_access_nosec(var/attempt_account_number)
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == attempt_account_number)
			return D
