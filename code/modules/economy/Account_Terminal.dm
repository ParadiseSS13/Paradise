#define AUT_ACCLST 1
#define AUT_ACCINF 2
#define AUT_ACCNEW 3

/obj/machinery/computer/account_database
	name = "Accounts Uplink Terminal"
	desc = "Access transaction logs, account data and all kinds of other financial records."
	icon_screen = "accounts"
	req_one_access = list(ACCESS_HOP, ACCESS_CAPTAIN, ACCESS_CENT_COMMANDER)
	light_color = LIGHT_COLOR_GREEN
	var/receipt_num
	var/machine_id = ""
	var/datum/money_account/detailed_account_view
	var/activated = TRUE
	/// Current UI page
	var/current_page = AUT_ACCLST
	/// Next time a print can be made
	var/next_print = 0

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
	data["is_printing"] = (next_print > world.time)
	ui_login_data(data, user)
	if(data["loginState"]["logged_in"])
		switch(current_page)
			if(AUT_ACCLST)
				var/list/accounts = list()
				for(var/i in 1 to length(GLOB.station_money_database.user_accounts))
					var/datum/money_account/D = GLOB.station_money_database.user_accounts[i]
					accounts.Add(list(list(
						"account_number" = D.account_number,
						"owner_name" = D.account_name,
						"suspended" = D.suspended ? "SUSPENDED" : "Active",
						"account_index" = i)))

				data["accounts"] = accounts

			if(AUT_ACCINF)
				data["account_number"] = detailed_account_view.account_number
				data["owner_name"] = detailed_account_view.account_name
				data["money"] = detailed_account_view.credit_balance
				data["suspended"] = detailed_account_view.suspended

				var/list/transactions = list()
				for(var/datum/transaction/T in detailed_account_view.transaction_log)
					transactions.Add(list(list(
						"date" = T.date,
						"time" = T.time,
						"target_name" = T.target_name,
						"purpose" = T.purpose,
						"amount" = T.amount,
						"source_terminal" = T.source_terminal)))

				data["transactions"] = transactions
	return data


/obj/machinery/computer/account_database/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	if(ui_login_act(action, params))
		return

	if(!ui_login_get().logged_in)
		return

	switch(action)
		if("view_account_detail")
			var/index = text2num(params["index"])
			if(index && index > 0 && index <= length(GLOB.station_money_database.user_accounts))
				detailed_account_view = GLOB.station_money_database.user_accounts[index]
				current_page = AUT_ACCINF

		if("back")
			detailed_account_view = null
			current_page = AUT_ACCLST

		if("toggle_suspension")
			if(detailed_account_view)
				detailed_account_view.suspended = !detailed_account_view.suspended

		if("create_new_account")
			current_page = AUT_ACCNEW

		if("finalise_create_account")
			var/account_name = params["holder_name"]
			var/starting_funds = max(text2num(params["starting_funds"]), 0)
			if(!account_name || !starting_funds)
				return

			starting_funds = min(starting_funds, 0) // Not authorized to put the station in debt.
			GLOB.station_money_database.create_account(account_name, starting_funds, src)
			current_page = AUT_ACCLST


#undef AUT_ACCLST
#undef AUT_ACCINF
#undef AUT_ACCNEW
