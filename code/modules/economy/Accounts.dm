#define STATION_CREATION_DATE "2 April, 2555"
#define STATION_CREATION_TIME "11:24:30"
#define STATION_START_CASH 75000
#define STATION_SOURCE_TERMINAL "Biesel GalaxyNet Terminal #227"
#define DEPARTMENT_START_CASH 5000

GLOBAL_VAR_INIT(num_financial_terminals, 1)
GLOBAL_DATUM(station_account, /datum/money_account)
GLOBAL_LIST_EMPTY(department_accounts)
GLOBAL_VAR_INIT(next_account_number, 0)
GLOBAL_DATUM(centcomm_account_db, /obj/machinery/computer/account_database) // this being an object hurts me deeply on the inside
GLOBAL_DATUM(vendor_account, /datum/money_account)
GLOBAL_LIST_EMPTY(all_money_accounts)

/proc/create_station_account()
	if(!GLOB.station_account)
		GLOB.next_account_number = rand(111111, 999999)

		GLOB.station_account = new()
		GLOB.station_account.owner_name = "[station_name()] Station Account"
		GLOB.station_account.account_number = rand(111111, 999999)
		GLOB.station_account.remote_access_pin = rand(1111, 111111)
		GLOB.station_account.money = STATION_START_CASH

		//create an entry in the account transaction log for when it was created
		GLOB.station_account.makeTransactionLog(STATION_START_CASH, "Account Creation", STATION_SOURCE_TERMINAL, GLOB.station_account.owner_name, FALSE,
		 STATION_CREATION_DATE, STATION_CREATION_TIME)

		//add the account
		GLOB.all_money_accounts.Add(GLOB.station_account)

/proc/create_department_account(department)
	GLOB.next_account_number = rand(111111, 999999)

	var/datum/money_account/department_account = new()
	department_account.owner_name = "[department] Account"
	department_account.account_number = rand(111111, 999999)
	department_account.remote_access_pin = rand(1111, 111111)
	department_account.money = DEPARTMENT_START_CASH

	//create an entry in the account transaction log for when it was created
	department_account.makeTransactionLog(DEPARTMENT_START_CASH, "Account Creation", STATION_SOURCE_TERMINAL, department_account.owner_name, FALSE,
	 STATION_CREATION_DATE, STATION_CREATION_TIME)

	//add the account
	GLOB.all_money_accounts.Add(department_account)

	GLOB.department_accounts[department] = department_account

//the current ingame time (hh:mm:ss) can be obtained by calling:
//station_time_timestamp("hh:mm:ss")

/proc/create_account(var/new_owner_name = "Default user", var/starting_funds = 0, var/obj/machinery/computer/account_database/source_db)

	//create a new account
	var/datum/money_account/M = new()
	M.owner_name = new_owner_name
	M.remote_access_pin = rand(1111, 111111)
	M.money = starting_funds

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = new_owner_name
	T.purpose = "Account creation"
	T.amount = starting_funds
	if(!source_db)
		//set a random date, time and location some time over the past few decades
		T.date = "[num2text(rand(1,31))] [pick(GLOB.month_names)], [rand(GLOB.game_year - 20,GLOB.game_year - 1)]"
		T.time = "[rand(0,23)]:[rand(0,59)]:[rand(0,59)]"
		T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"

		M.account_number = rand(111111, 999999)
	else
		T.date = GLOB.current_date_string
		T.time = station_time_timestamp()
		T.source_terminal = source_db.machine_id

		M.account_number = GLOB.next_account_number
		GLOB.next_account_number += rand(1,25)

		//create a sealed package containing the account details
		var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(source_db.loc)

		var/obj/item/paper/R = new /obj/item/paper(P)
		playsound(source_db.loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
		P.wrapped = R
		R.name = "Account information: [M.owner_name]"

		var/overseer = "Unknown"
		if(source_db.held_card)
			overseer = source_db.held_card.registered_name
		R.info = {"<b>Account details (confidential)</b><br><hr><br>
			<i>Account holder:</i> [M.owner_name]<br>
			<i>Account number:</i> [M.account_number]<br>
			<i>Account pin:</i> [M.remote_access_pin]<br>
			<i>Starting balance:</i> $[M.money]<br>
			<i>Date and time:</i> [station_time_timestamp()], [GLOB.current_date_string]<br><br>
			<i>Creation terminal ID:</i> [source_db.machine_id]<br>
			<i>Authorised NT officer overseeing creation:</i> [overseer]<br>"}

		//stamp the paper
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.icon_state = "paper_stamp-cent"
		if(!R.stamped)
			R.stamped = new
		R.stamped += /obj/item/stamp
		R.overlays += stampoverlay
		R.stamps += "<HR><i>This paper has been stamped by the Accounts Database.</i>"

	//add the account
	M.transaction_log.Add(T)
	GLOB.all_money_accounts.Add(M)

	return M

/datum/money_account
	var/owner_name = ""
	var/account_number = 0
	var/remote_access_pin = 0
	var/money = 0
	var/suspended = 0
	var/list/transaction_log = list()
	var/security_level = 0	//0 - auto-identify from worn ID, require only account number
							//1 - require manual login / account number and pin
							//2 - require card and manual login

/datum/money_account/New()
	..()

/datum/transaction
	var/target_name = ""
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""

/obj/machinery/computer/account_database/proc/charge_to_account(attempt_account_number, datum/money_account/source, purpose, terminal_id, amount)
	if(!activated)
		return 0
	for(var/datum/money_account/D in GLOB.all_money_accounts)
		if(D.account_number == attempt_account_number && !D.suspended)
			source.charge(amount, D, purpose, terminal_id, "Account #[D.account_number]", "Transfer from [source.owner_name]",
			"[D.owner_name]")
			return 1

	return 0

//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/proc/attempt_account_access(var/attempt_account_number, var/attempt_pin_number, var/security_level_passed = 0,var/pin_needed=1)
	for(var/datum/money_account/D in GLOB.all_money_accounts)
		if(D.account_number == attempt_account_number)
			if( D.security_level <= security_level_passed && (!D.security_level || D.remote_access_pin == attempt_pin_number || !pin_needed) )
				return D

/obj/machinery/computer/account_database/proc/get_account(var/account_number)
	for(var/datum/money_account/D in GLOB.all_money_accounts)
		if(D.account_number == account_number)
			return D

/proc/attempt_account_access_nosec(var/attempt_account_number)
	for(var/datum/money_account/D in GLOB.all_money_accounts)
		if(D.account_number == attempt_account_number)
			return D

#undef STATION_CREATION_DATE
#undef STATION_CREATION_TIME
#undef STATION_START_CASH
#undef STATION_SOURCE_TERMINAL
#undef DEPARTMENT_START_CASH
