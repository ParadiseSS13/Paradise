////////////////////////
// Ease-of-use
//
// Economy system is such a mess of spaghetti.  This should help.
////////////////////////

/proc/get_money_account(var/account_number, var/from_z=-1)
	for(var/obj/machinery/computer/account_database/DB in GLOB.machines)
		if(from_z > -1 && DB.z != from_z) continue
		if((DB.stat & NOPOWER) || !DB.activated ) continue
		var/datum/money_account/acct = DB.get_account(account_number)
		if(!acct) continue
		return acct

/proc/get_card_account(mob/user)
	if(issilicon(user) && !istype(user, /mob/living/silicon/robot/drone))
		return GLOB.station_account
	var/obj/item/card/id/id = null
	var/mob/living/carbon/human/H = null
	if(ishuman(user))
		H = user
		id = H.get_id_card()
	if(istype(id))
		return get_money_account(id.associated_account_number)
	return null

/obj/machinery/proc/pay_with_cash(obj/item/stack/spacecash/cashmoney, mob/user, price, vended_name)
	if(price > cashmoney.amount)
		// This is not a status display message, since it's something the character
		// themselves is meant to see BEFORE putting the money in
		to_chat(user, "[bicon(cashmoney)] <span class='warning'>That is not enough money.</span>")
		return FALSE

	// Bills (banknotes) cannot really have worth different than face value,
	// so we have to eat the bill and spit out change in a bundle
	// This is really dirty, but there's no superclass for all bills, so we
	// just assume that all spacecash that's not something else is a bill

	visible_message("<span class='notice'>[user] inserts a credit chip into [src].</span>")
	cashmoney.use(price)

	// Vending machines have no idea who paid with cash
	GLOB.vendor_account.credit(price, "Sale of [vended_name]", name, "(cash)")
	return TRUE

/obj/machinery/proc/pay_with_card(mob/M, price, vended_name)
	if(iscarbon(M))
		visible_message("<span class='notice'>[M] swipes a card through [src].</span>")
	var/datum/money_account/customer_account = get_card_account(M)
	if(!customer_account)
		to_chat(M, "<span class='warning'>Error: Unable to access account. Please contact technical support if problem persists.</span>")
		return FALSE
	if(customer_account.suspended)
		to_chat(M, "<span class='warning'>Unable to access account: account suspended.</span>")
		return FALSE
	// Have the customer punch in the PIN before checking if there's enough money.
	// Prevents people from figuring out acct is empty at high security levels
	if(customer_account.security_level)
		// If card requires pin authentication (ie seclevel 1 or 2)
		var/attempt_pin = input("Enter pin code", "Vendor transaction") as num
		if(!attempt_account_access(customer_account.account_number, attempt_pin, 2))
			to_chat(M, "<span class='warning'>Unable to access account: incorrect credentials.</span>")
			return FALSE
	if(price > customer_account.money)
		to_chat(M, "<span class='warning'>Your bank account has insufficient money to purchase this.</span>")
		return FALSE
	// Okay to move the money at this point
	customer_account.charge(price, GLOB.vendor_account,
		"Purchase of [vended_name]", name, GLOB.vendor_account.owner_name,
		"Sale of [vended_name]", customer_account.owner_name)
	if(customer_account.owner_name == GLOB.station_account.owner_name)
		add_game_logs("as silicon purchased [vended_name] in [COORD(src)]", M)
	return TRUE

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
