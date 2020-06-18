////////////////////////
// Ease-of-use
//
// Economy system is such a mess of spaghetti.  This should help.
////////////////////////

/proc/get_money_account(var/account_number, var/from_z=-1)
	for(var/obj/machinery/computer/account_database/DB in world)
		if(from_z > -1 && DB.z != from_z) continue
		if((DB.stat & NOPOWER) || !DB.activated ) continue
		var/datum/money_account/acct = DB.get_account(account_number)
		if(!acct) continue
		return acct


/obj/proc/get_card_account(var/obj/item/card/I, var/mob/user=null, var/terminal_name="", var/transaction_purpose="", var/require_pin=0)
	if(terminal_name=="")
		terminal_name=src.name
	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/C = I
		var/attempt_pin=0
		var/datum/money_account/D = get_money_account(C.associated_account_number)
		if(require_pin && user)
			attempt_pin = input(user,"Enter pin code", "Transaction") as num
			if(D.remote_access_pin != attempt_pin)
				return null
		if(D)
			return D

/mob/proc/get_worn_id_account(var/require_pin=0, var/mob/user=null)
	if(ishuman(src))
		var/mob/living/carbon/human/H=src
		var/obj/item/card/id/I=H.get_idcard()
		if(!I || !istype(I))
			return null
		var/attempt_pin=0
		var/datum/money_account/D = get_money_account(I.associated_account_number)
		if(require_pin && user)
			attempt_pin = input(user,"Enter pin code", "Transaction") as num
			if(D.remote_access_pin != attempt_pin)
				return null
		return D
	else if(issilicon(src))
		return GLOB.station_account

/datum/money_account/proc/fmtBalance()
	return "$[num2septext(money)]"

// Seperated from charge so they can reuse the code and also because there's many instances where a log will be made without actually making a transaction
/datum/money_account/proc/makeTransactionLog(transaction_amount = 0, transaction_purpose, terminal_name = "",
 dest_name = "UNKNOWN", charging = TRUE, date = GLOB.current_date_string, time = "")
	var/datum/transaction/T = new()
	T.target_name = dest_name
	T.purpose = transaction_purpose
	if(!charging || transaction_amount == 0)
		T.amount = "[transaction_amount]"
	else
		T.amount = "([transaction_amount])"

	T.source_terminal = terminal_name
	T.date = date
	if(time == "")
		T.time = station_time_timestamp()
	else
		T.time = time
	transaction_log.Add(T)

 // Charge is for transferring money from an account to another. The destination account can possibly not exist (Magical money sink)
/datum/money_account/proc/charge(transaction_amount = 0, datum/money_account/dest, transaction_purpose,
 terminal_name = "", dest_name = "UNKNOWN", dest_purpose, dest_target_name)
	if(suspended)
		to_chat(usr, "<span class='warning'>Unable to access source account: account suspended.</span>")
		return 0

	if(transaction_amount <= money)
		//transfer the money
		money -= transaction_amount
		makeTransactionLog(transaction_amount, transaction_purpose, terminal_name, dest_name)
		if(dest)
			dest.money += transaction_amount
			dest.makeTransactionLog(transaction_amount,
			dest_purpose ? dest_purpose : transaction_purpose, terminal_name, dest_target_name ? dest_target_name : dest_name, FALSE)
		return 1
	else
		to_chat(usr, "<span class='warning'>Insufficient funds in account.</span>")
		return 0

// phantom_charge is for when you want to charge an account, without making any corresponding log (e.g. you make it yourself with custom date
// or there won't be any log for some IC reasons (hacking)
/datum/money_account/proc/phantom_charge(transaction_amount = 0, datum/money_account/dest, suspensionbypass = 0)
	if(suspended && !suspensionbypass)
		return 0

	if(transaction_amount <= money)
		//transfer the money
		money -= transaction_amount
		if(dest)
			dest.money += transaction_amount
		return 1
	else
		return 0

// Credit is for giving money to an account out of thin air. Suspension does not matter.
/datum/money_account/proc/credit(transaction_amount = 0, transaction_purpose,
 terminal_name = "", dest_name = "UNKNOWN", date = GLOB.current_date_string, time = "")

	money += transaction_amount
	makeTransactionLog(transaction_amount, transaction_purpose, terminal_name, dest_name, FALSE, date, time)
	return 1

//phantom_credit is like the above without any log
/datum/money_account/proc/phantom_credit(transaction_amount = 0)
	money += transaction_amount
	return 1
