/**
 *  Base machine type for machinery that needs to interact with users spending Space Cash or credit from Money Accounts
 *  has helper procs to automate account authentification and handling transactions.
 */
/obj/machinery/economy
	name = "Financial System Interface"
	desc = "A base economy machine."
	anchored = TRUE
	density = TRUE

	///Can this machine access restricted money accounts?
	var/restricted_bypass = FALSE

	var/accepts_cash = TRUE
	var/accepts_card = TRUE

	///If you beat the shit out of this machine, will money fling out?
	var/smash_and_grab = FALSE
	///Amount of cash "stored" in this machine (used for smashing and grabbing mechanics)
	var/cash_stored = 0
	///Amount of cash inserted into the machine during a transaction
	var/cash_transaction = 0

	///the economy database this machine is connected to
	var/datum/money_account_database/account_database

/obj/machinery/economy/Initialize(mapload)
	. = ..()
	reconnect_database()

/obj/machinery/economy/proc/reconnect_database()
	account_database = GLOB.station_money_database

/obj/machinery/economy/proc/attempt_account_authentification(datum/money_account/customer_account, attempted_pin, mob/user)
	var/attempt_pin = attempted_pin
	if(customer_account.security_level != ACCOUNT_SECURITY_ID && !attempt_pin)
		// if pin is not given, we'll prompt them here
		attempt_pin = tgui_input_number(user, "Enter pin code", "Vendor transaction", max_value = BANK_PIN_MAX, min_value = BANK_PIN_MIN)
		if(!Adjacent(user) || !attempt_pin)
			return FALSE
	var/is_admin = is_admin(user)
	if(!account_database.try_authenticate_login(customer_account, attempt_pin, restricted_bypass, FALSE, is_admin))
		to_chat(user, "<span class='warning'>Unable to access account: incorrect credentials.</span>")
		return FALSE
	return TRUE

/obj/machinery/economy/proc/pay_with_card(obj/item/card/id/I, amount, purpose, transactor, mob/user, datum/money_account/target)
	visible_message("<span class='notice'>[user] swipes a card through [src].</span>")
	return pay_with_account(I.get_card_account(), amount, purpose, transactor, user, target)

/obj/machinery/economy/proc/pay_with_account(datum/money_account/customer_account, amount, purpose, transactor, mob/user, datum/money_account/target)
	if(!customer_account)
		to_chat(user, "<span class='warning'>Error: Unable to access account. Please contact technical support if problem persists.</span>")
		return FALSE
	if(customer_account.suspended)
		to_chat(user, "<span class='warning'>Unable to access account: account suspended.</span>")
		return FALSE
	if(!attempt_account_authentification(customer_account, null, user))
		return FALSE
	if(!account_database.charge_account(customer_account, amount, purpose, transactor, allow_overdraft = FALSE, supress_log = FALSE))
		to_chat(user, "<span class='warning'>Unable to complete transaction: account has insufficient credit balance to purchase this.</span>")
		return FALSE
	account_database.credit_account(target, amount, purpose, transactor, FALSE)
	return TRUE

/obj/machinery/economy/proc/pay_with_cash(item_cost, purpose, transactor, mob/user, datum/money_account/target)
	if(item_cost > cash_transaction)
		to_chat(user, "<span class='warning'>Unable to complete transaction: insufficient space cash inserted.</span>")
		return FALSE

	cash_stored -= item_cost
	cash_transaction -= item_cost
	account_database.credit_account(target, item_cost, purpose, transactor, FALSE)
	return TRUE

/obj/machinery/economy/proc/insert_cash(obj/item/stack/spacecash/cash_money, mob/user, amount)
	if(amount > cash_money.amount)
		return
	var/amount_to_insert = amount ? amount : cash_money.amount
	visible_message("<span class='notice'>[user] inserts [amount_to_insert == 1 ? "[amount_to_insert] credit" : "[amount_to_insert] credits"]  into [src].</span>")
	cash_stored += amount_to_insert
	cash_transaction += amount_to_insert
	cash_money.use(amount_to_insert)
	return TRUE

/**
  * create the most effective combination of space cash piles to make up the requested amount
  *
  * Will create up to 10 stacks of space cash based on the given amount, if there is more than 100,000 given,
  * this proc will return the amount not dispensed.
  *
  * Arguments:
  * * amount - amount of space cash to dispense
  * * user - the mob to dispense the space cash to
  */
//
/obj/machinery/economy/proc/dispense_space_cash(amount, mob/user)
	if(!amount)
		return

	var/stacks_to_dispense = min(CEILING(amount / MAX_STACKABLE_CASH, 1), 10)
	var/remaining_cash = amount

	visible_message("<span class='notice'>[src] spits out [stacks_to_dispense == 1 ? "1 wad" : "[stacks_to_dispense] wads"] of cash.</span>")
	for(var/i in 1 to stacks_to_dispense)
		if(remaining_cash >= MAX_STACKABLE_CASH)
			remaining_cash -= MAX_STACKABLE_CASH
			new /obj/item/stack/spacecash(get_turf(src), MAX_STACKABLE_CASH)
			continue
		var/obj/item/stack/spacecash/C = new(get_turf(src), remaining_cash)
		if(user)
			remaining_cash = 0
			user.put_in_hands(C)
	return remaining_cash

/obj/machinery/economy/proc/give_change(mob/user)
	var/remaining_cash = dispense_space_cash(cash_transaction, user)
	cash_transaction = remaining_cash
