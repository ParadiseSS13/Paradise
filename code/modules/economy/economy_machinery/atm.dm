#define ATM_SCREEN_DEFAULT   0
#define ATM_SCREEN_SECURITY  1
#define ATM_SCREEN_TRANSFER  2
#define ATM_SCREEN_LOGS      3

#define PRINT_DELAY  (30 SECONDS)
#define LOCKOUT_TIME (10 SECONDS)

/obj/machinery/economy/atm
	name = "Nanotrasen automatic teller machine"
	desc = "For all your monetary needs! Just insert your ID card to make a withdrawal or deposit!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "atm"
	anchored = TRUE
	idle_power_consumption = 10
	density = FALSE
	restricted_bypass = TRUE

	///Current money account the ATM is accessing
	var/datum/money_account/authenticated_account
	///ID Card that is currently inserted into the ATM
	var/obj/item/card/held_card

	///UI screen the ATM is on currently
	var/view_screen = ATM_SCREEN_DEFAULT
	///cooldown inbetween printing balance statements n stuff
	var/print_cooldown = 0
	///the time when the lockout on the ATM is lifted
	var/lockout_time = 0
	///failed login attempts counter, used for locking out the atm
	var/login_attempts = 0

/obj/machinery/economy/atm/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/economy/atm/update_icon_state()
	. = ..()
	if(stat & NOPOWER)
		icon_state = "atm_off"
	else
		icon_state = "atm"

/obj/machinery/economy/atm/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	underlays += emissive_appearance(icon, "atm_lightmask")

/obj/machinery/economy/atm/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon()

/obj/machinery/economy/atm/process()
	if(stat & NOPOWER)
		return

/obj/machinery/economy/atm/attack_hand(mob/user)
	if(..())
		return TRUE
	if(issilicon(user))
		to_chat(user, "<span class='warning'>Artificial unit recognized. Artificial units do not currently receive monetary compensation, as per Nanotrasen regulation #1005.</span>")
		return
	if(!account_database)
		reconnect_database()

	ui_interact(user)

/obj/machinery/economy/atm/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/economy/atm/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/card/id))
		if(has_power())
			handle_id_insert(I, user)
			return TRUE
	else if(authenticated_account)
		if(istype(I, /obj/item/stack/spacecash))
			if(!has_power())
				return
			insert_cash(I, user)
			return TRUE

	return ..()

/obj/machinery/economy/atm/insert_cash(obj/item/stack/spacecash/cash_money, mob/user)
	visible_message("<span class='info'>[user] inserts [cash_money] into [src].</span>")
	cash_stored += cash_money.amount
	account_database.credit_account(authenticated_account, cash_money.amount, "ATM Deposit", name, FALSE)
	cash_money.use(cash_money.amount)
	return TRUE

/obj/machinery/economy/atm/proc/handle_id_insert(obj/item/card/id, mob/user)
	if(held_card)
		return
	user.drop_item()
	id.forceMove(src)
	held_card = id
	RegisterSignal(held_card, COMSIG_PARENT_QDELETING, PROC_REF(clear_held_card))
	if(authenticated_account && held_card.associated_account_number != authenticated_account.account_number)
		clear_account()

/obj/machinery/economy/atm/proc/eject_inserted_id(mob/user)
	if(!held_card)
		return
	held_card.forceMove(loc)
	if(ishuman(user))
		user.put_in_hands(held_card)
	logout()
	clear_held_card()

///ensures proper GC of ID card
/obj/machinery/economy/atm/proc/clear_held_card()
	UnregisterSignal(held_card, COMSIG_PARENT_QDELETING)
	held_card = null

///ensures proper GC of money account
/obj/machinery/economy/atm/proc/clear_account()
	if(!authenticated_account) // In some situations there will be no authenticated account, such as removing your ID without inputting account information
		return
	UnregisterSignal(authenticated_account, COMSIG_PARENT_QDELETING)
	authenticated_account = null

/obj/machinery/economy/atm/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ATM", name, 550, 650)
		ui.open()

/obj/machinery/economy/atm/ui_data(mob/user)
	var/list/data = list()

	data["view_screen"] = view_screen
	data["held_card_name"] = held_card?.name
	data["linked_db"] = account_database ? TRUE : FALSE

	data["authenticated_account"] = authenticated_account
	if(authenticated_account)
		data["owner_name"] = authenticated_account.account_name
		data["money"] = authenticated_account.credit_balance
		data["security_level"] = authenticated_account.security_level

		data["transaction_log"] = list()
		for(var/datum/transaction/T in authenticated_account.account_log)
			var/list/transaction_info = list(
				"time" = T.time,
				"target_name" = T.transactor,
				"purpose" = T.purpose,
				"amount" = T.amount,
				"is_deposit" = T.is_deposit
			)
			data["transaction_log"] += list(transaction_info)


	return data

/obj/machinery/economy/atm/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	var/mob/user = ui.user

	switch(action)
		if("transfer")
			if(!authenticated_account)
				return
			var/transfer_amount = text2num(params["funds_amount"])
			var/target_account_number = text2num(params["target_acc_number"])
			var/transfer_purpose = params["purpose"]
			transfer_credits(transfer_amount, target_account_number, transfer_purpose, user)
		if("view_screen")
			var/list/valid_screen = list(ATM_SCREEN_DEFAULT, ATM_SCREEN_SECURITY, ATM_SCREEN_TRANSFER, ATM_SCREEN_LOGS)
			var/screen_proper = text2num(params["view_screen"])
			if(screen_proper in valid_screen)
				view_screen = screen_proper
			else
				message_admins("Warning: possible href exploit by [key_name(usr)] - Invalid screen number passed into an ATM")
				log_debug("Warning: possible href exploit by [key_name(usr)] - Invalid screen number passed into an ATM")
		if("change_security_level")
			if(authenticated_account)
				var/new_sec_level = max(min(text2num(params["new_security_level"]), 2), 0)
				authenticated_account.security_level = new_sec_level
		if("attempt_auth")
			var/tried_account_num = text2num(params["account_num"]) ? text2num(params["account_num"]) : held_card?.associated_account_number
			var/tried_pin = text2num(params["account_pin"])
			attempt_login(tried_account_num, tried_pin, user)
		if("withdrawal")
			var/amount = max(text2num(params["funds_amount"]), 0)
			if(amount)
				withdraw(amount, user)
		if("balance_statement")
			print_balance_statement()
		if("insert_card")
			if(held_card)
				eject_inserted_id(user)
			else
				var/obj/item/I = user.get_active_hand()
				if(istype(I, /obj/item/card/id))
					handle_id_insert(I, user)
		if("logout")
			logout()

	. = TRUE

/obj/machinery/economy/atm/proc/attempt_login(account_number, account_pin, mob/user)

	var/account_to_attempt = account_number ? account_number : held_card?.associated_account_number
	if(!account_to_attempt)
		to_chat(user, "[bicon(src)]<span class='warning'>Authentification Failure: Account number not found.</span>")
		return FALSE

	var/datum/money_account/user_account = account_database.find_user_account(account_number, include_departments = TRUE)
	if(!user_account)
		to_chat(user, "[bicon(src)]<span class='warning'>Authentification Failure: User Account Not Found.</span>")
		return FALSE

	if(attempt_account_authentification(user_account, account_pin, user))
		authenticated_account = user_account
		RegisterSignal(authenticated_account, COMSIG_PARENT_QDELETING, PROC_REF(clear_account))
		if(HAS_TRAIT(src, TRAIT_CMAGGED))
			var/shoutname = uppertext(user_account.account_name)
			atom_say("HELLO '[shoutname]'! YOU'VE SUCCESSFULLY LOGGED IN WITH ACCOUNT NUMBER '[user_account.account_number]' AND PIN NUMBER '[user_account.account_pin]'! HAVE A PARADISE DAY!")
			playsound(loc, 'sound/machines/honkbot_evil_laugh.ogg', 25, TRUE, ignore_walls = FALSE)
		return TRUE

	//else failed login

	login_attempts++
	account_database.log_account_action(user_account, 0, "Unauthorised login attempt", name, log_on_database = FALSE)
	to_chat(user, "[bicon(src)]<span class='warning'>Incorrect pin/account combination entered, [3 - login_attempts] attempt\s remaining.</span>")
	if(login_attempts >= 3)
		playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
		view_screen = ATM_SCREEN_DEFAULT
		lockout_time = world.time + LOCKOUT_TIME

/obj/machinery/economy/atm/proc/logout()
	clear_account()
	view_screen = ATM_SCREEN_DEFAULT
	login_attempts = 0

/obj/machinery/economy/atm/proc/transfer_credits(amount, target_account_number, purpose, mob/user)
	if(!authenticated_account)
		return
	if(amount <= 0)
		to_chat(user, "[bicon(src)]<span class='warning'>That is not a valid transfer amount.</span>")
		return
	if(account_database.charge_account(authenticated_account, amount, FALSE))
		var/datum/money_account/target_account = account_database.find_user_account(target_account_number, include_departments = TRUE)
		if(target_account)
			account_database.credit_account(target_account, amount, purpose, name, FALSE)
			to_chat(user, "[bicon(src)]<span class='info'>Funds transfer successful.</span>")
	else
		to_chat(user, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")

/obj/machinery/economy/atm/proc/withdraw(amount, mob/user)
	if(!authenticated_account)
		return
	if(amount <= 0)
		to_chat(user, "[bicon(src)]<span class='warning'>That is not a valid amount.</span>")
		return

	if(account_database.charge_account(authenticated_account, amount, "Cash Withdrawal", name, FALSE, FALSE))
		playsound(src, 'sound/machines/chime.ogg', 50, TRUE)
		dispense_space_cash(amount, user)

/obj/machinery/economy/atm/proc/print_balance_statement()
	if(!authenticated_account)
		return
	if(world.time <= print_cooldown)
		to_chat(usr, "<span class='notice'>[src] flashes an error on its display.</span>")
		return
	print_cooldown = world.time + PRINT_DELAY
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
	var/obj/item/paper/R = new(loc)
	R.name = "Account balance: [authenticated_account.account_name]"
	R.info = {"<b>NT Automated Teller Account Statement</b><br><br>
		<i>Account holder:</i> [authenticated_account.account_name]<br>
		<i>Account number:</i> [authenticated_account.account_number]<br>
		<i>Balance:</i> $[authenticated_account.credit_balance]<br>
		<i>Date and time:</i> [station_time_timestamp()], [GLOB.current_date_string]"}

	//stamp the paper
	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.icon_state = "paper_stamp-cent"
	if(!R.stamped)
		R.stamped = new()
	R.stamped += /obj/item/stamp
	R.overlays += stampoverlay
	R.stamps += "<HR><i>This paper has been stamped by the Automatic Teller Machine.</i>"

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, TRUE)

/obj/machinery/economy/atm/cmag_act(mob/user)
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		return
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(user, "<span class='warning'>Yellow ooze seeps into the [src]'s card slot...</span>")
	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)

/obj/machinery/economy/atm/examine(mob/user)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_CMAGGED))
		return
	. += "<span class='warning'>Yellow ooze is dripping from the card slot!</span>"

#undef ATM_SCREEN_DEFAULT
#undef ATM_SCREEN_SECURITY
#undef ATM_SCREEN_TRANSFER
#undef ATM_SCREEN_LOGS
#undef LOCKOUT_TIME
