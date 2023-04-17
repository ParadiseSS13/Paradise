#define AUT_ACCLST 1
#define AUT_ACCINF 2
#define AUT_ACCNEW 3

/obj/machinery/computer/account_database
	name = "Accounts Uplink Terminal"
	desc = "Access transaction logs, account data and all kinds of other financial records."
	icon_screen = "accounts"
	req_one_access = list(ACCESS_HOP, ACCESS_CAPTAIN, ACCESS_CENT_COMMANDER)
	light_color = LIGHT_COLOR_GREEN

	var/activated = TRUE
	/// Current UI page
	var/current_page = AUT_ACCLST
	///account currently being viewed
	var/datum/money_account/detailed_account_view
	///station account database
	var/datum/money_account_database/account_db

/obj/machinery/computer/account_database/Initialize()
	. = ..()
	reconnect_database()

/obj/machinery/computer/account_database/proc/reconnect_database()
	account_db = GLOB.station_money_database

/obj/machinery/computer/account_database/attackby(obj/O, mob/user, params)
	if(ui_login_attackby(O, user))
		return
	return ..()

/obj/machinery/computer/account_database/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/account_database/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AccountsUplinkTerminal", name, 800, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/account_database/ui_data(mob/user)
	var/list/data = list()
	data["currentPage"] = current_page
	ui_login_data(data, user)
	if(data["loginState"]["logged_in"])
		switch(current_page)
			if(AUT_ACCLST)
				data["accounts"] = list()
				for(var/datum/money_account/account as anything in GLOB.station_money_database.user_accounts)
					var/list/account_data = list(
						"account_number" = "[account.account_number]",
						"owner_name" = account.account_name,
						"suspended" = account.suspended ? "SUSPENDED" : "Active",
						"money" = "[account.credit_balance]") // needs to be strings because of TGUI localeCompare
					data["accounts"] += list(account_data)
				data["department_accounts"] = list()
				for(var/datum/money_account/account as anything in GLOB.station_money_database.get_all_department_accounts())
					var/list/account_data = list(
						"account_number" = account.account_number,
						"name" = account.account_name,
						"suspended" = account.suspended ? "SUSPENDED" : "Active",
						"money" = account.credit_balance)
					data["department_accounts"] += list(account_data)
			if(AUT_ACCINF)
				data["account_number"] = detailed_account_view.account_number
				data["account_pin"] = detailed_account_view.account_pin
				data["owner_name"] = detailed_account_view.account_name
				data["money"] = detailed_account_view.credit_balance
				data["suspended"] = detailed_account_view.suspended

				data["is_department_account"] = (detailed_account_view.account_type == ACCOUNT_TYPE_DEPARTMENT)
				data["transactions"] = list()
				for(var/datum/transaction/T in detailed_account_view.account_log)
					var/list/transaction_info = list(
						"target_name" = T.transactor,
						"time" = T.time,
						"purpose" = T.purpose,
						"amount" = T.amount,
						"is_deposit" = T.is_deposit
					)
					data["transactions"] += list(transaction_info)
	return data


/obj/machinery/computer/account_database/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	. = TRUE

	if(ui_login_act(action, params))
		return

	if(!ui_login_get().logged_in)
		return

	if(!account_db)
		reconnect_database()

	switch(action)
		if("view_account_detail")
			var/account_num = text2num(params["account_num"])
			if(account_num)
				detailed_account_view = GLOB.station_money_database.find_user_account(account_num, include_departments = TRUE)
				RegisterSignal(detailed_account_view, COMSIG_PARENT_QDELETING, PROC_REF(clear_viewed_account))
				current_page = AUT_ACCINF
		if("back")
			clear_viewed_account()
		if("set_account_pin")
			var/account_num = text2num(params["account_number"])
			if(!account_num || !detailed_account_view)
				return
			var/attempt_pin = input("Enter this accounts current pin code", "Account Auth") as num
			if(!attempt_pin || !Adjacent(ui.user))
				return
			if(!account_db.try_authenticate_login(detailed_account_view, attempt_pin, FALSE, FALSE, FALSE) || detailed_account_view.account_pin != attempt_pin)
				to_chat(ui.user, "<span class='warning'>Authentification Failure: Incorrect Pin or insufficient access.</span>")
				return
			var/new_pin = input("Enter the new pin for this account", "New Account Pin") as num
			if(!new_pin || !Adjacent(ui.user))
				return
			if(new_pin < 1 || new_pin >= 1000000)
				to_chat(ui.user, "<span class='warning'>Account Error: New pin must be a number between 000001 and 999999.</span>")
				return
			detailed_account_view.account_pin = new_pin
			to_chat(ui.user, "<span class='notice'>The [detailed_account_view.account_name] account pin has been set to [new_pin] successfully.</span>")
		if("toggle_suspension")
			if(detailed_account_view)
				detailed_account_view.suspended = !detailed_account_view.suspended
		if("create_new_account")
			current_page = AUT_ACCNEW
		if("finalise_create_account")
			var/account_name = params["holder_name"]
			if(!account_name)
				return
			GLOB.station_money_database.create_account(account_name, 0, ACCOUNT_SECURITY_ID, name, supress_log = FALSE)
			current_page = AUT_ACCLST

/obj/machinery/computer/account_database/proc/clear_viewed_account()
	UnregisterSignal(detailed_account_view, COMSIG_PARENT_QDELETING)
	detailed_account_view = null
	current_page = AUT_ACCLST

#undef AUT_ACCLST
#undef AUT_ACCINF
#undef AUT_ACCNEW
