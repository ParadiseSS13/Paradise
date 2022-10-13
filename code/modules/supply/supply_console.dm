/obj/machinery/computer/supplycomp
	name = "Supply Shuttle Console"
	desc = "Used to order supplies."
	icon_screen = "supply"
	req_access = list(ACCESS_CARGO)
	circuit = /obj/item/circuitboard/supplycomp

	/// Is this a public console (Confirm + Shuttle controls are not visible)
	var/is_public = FALSE
	/// Time of last request
	var/reqtime = 0
	/// Can we order special supplies
	var/hacked = FALSE
	/// Can we order contraband
	var/can_order_contraband = FALSE
	///the economy database this machine is connected to
	var/datum/money_account_database/main_station/account_database
	///the department account tethered to this supply console
	var/datum/money_account/cargo_account

/obj/machinery/computer/supplycomp/Initialize(mapload)
	. = ..()
	reconnect_database()

/obj/machinery/computer/supplycomp/proc/reconnect_database()
	if(is_station_level(z))
		account_database = GLOB.station_money_database
		cargo_account = account_database.get_account_by_department("Cargo") //I hate that this is a string and not a define
	else
		account_database = null

/obj/machinery/computer/supplycomp/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_hand(mob/user)
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return TRUE

	ui_interact(user)
	return

/obj/machinery/computer/supplycomp/proc/get_supply_group_name(cat)
	switch(cat)
		if(SUPPLY_EMERGENCY)
			return "Emergency"
		if(SUPPLY_SECURITY)
			return "Security"
		if(SUPPLY_ENGINEER)
			return "Engineering"
		if(SUPPLY_MEDICAL)
			return "Medical"
		if(SUPPLY_SCIENCE)
			return "Science"
		if(SUPPLY_ORGANIC)
			return "Food and Livestock"
		if(SUPPLY_MATERIALS)
			return "Raw Materials"
		if(SUPPLY_MISC)
			return "Miscellaneous"
		if(SUPPLY_VEND)
			return "Vending"

/obj/machinery/computer/supplycomp/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(!cargo_account || !account_database)
		reconnect_database()
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CargoConsole", name, 900, 800, master_ui, state)
		ui.open()

/obj/machinery/computer/supplycomp/ui_data(mob/user)
	var/list/data = list()

	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/C = H.get_idcard(TRUE)
	var/list/departments = C?.get_departments() //get_departments returns a list of departments
	//the account most closely associated with the players occupation, null if no department is found


	data["requests"] = list()
	for(var/department in SSeconomy.requestlist)
		if(!(department in departments))
			continue
		for(var/request in SSeconomy.requestlist[department])
			var/datum/supply_order/SO = request
			if(SO)
				var/list/request_data = list()
				request_data = list(
					"ordernum" = SO.ordernum,
					"supply_type" = SO.object.name,
					"orderedby" = SO.orderedby,
					"comment" = SO.comment ? SO.comment : "No comment.",
					"command1" = list("confirmorder" = SO.ordernum),
					"command2" = list("rreq" = SO.ordernum))
				data["requests"] += list(request_data)

	var/list/orders_list = list()
	for(var/set_name in SSeconomy.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list(
				"ordernum" = SO.ordernum,
				"supply_type" = SO.object.name,
				"orderedby" = SO.orderedby,
				"comment" = SO.comment)))

	data["accounts"] = list()
	if(ishuman(user) && C)
		var/datum/money_account/customer_account = C.get_card_account()
		if(customer_account)
			data["accounts"] += list(list(
				"name" = customer_account.account_name,
				"balance" = customer_account.credit_balance,
				"account_UID" = customer_account.UID(),
			))
		data["user_departments"] = list()
		for(var/department in departments)
			data["user_departments"] += department
			var/datum/money_account/department_account = account_database.get_account_by_department(department)
			if(department_account)
				data["accounts"] += list(list(
					"name" = department_account.account_name,
					"balance" = department_account.credit_balance,
					"account_UID" = department_account.UID(),
				))
	if(cargo_account)
		data["accounts"] += list(list(
			"name" = cargo_account.account_name,
			"balance" = cargo_account.credit_balance,
			"account_UID" = cargo_account.UID(),
		))

	data["orders"] = orders_list

	data["is_public"] = is_public

	data["canapprove"] = (SSshuttle.supply.getDockedId() == "supply_away") && !(SSshuttle.supply.mode != SHUTTLE_IDLE) && !is_public
	data["moving"] = SSshuttle.supply.mode != SHUTTLE_IDLE
	data["at_station"] = SSshuttle.supply.getDockedId() == "supply_home"
	data["timeleft"] = SSshuttle.supply.timeLeft(60 SECONDS)
	data["can_launch"] = !SSshuttle.supply.canMove()

	return data

/obj/machinery/computer/supplycomp/ui_static_data(mob/user)
	var/list/static_data = list()
	var/list/packs_list = list()

	for(var/set_name in SSeconomy.supply_packs)
		var/datum/supply_packs/pack = SSeconomy.supply_packs[set_name]
		if((pack.hidden && hacked) || (pack.contraband && can_order_contraband) || (pack.special && pack.special_enabled) || (!pack.contraband && !pack.hidden && !pack.special))
			packs_list.Add(list(list(
				"name" = pack.name,
				"cost" = pack.cost,
				"ref" = "[pack.UID()]",
				"contents" = pack.ui_manifest,
				"cat" = pack.group)))

	static_data["supply_packs"] = packs_list

	var/list/categories = list()
	for(var/category in GLOB.all_supply_groups)
		categories.Add(list(list("name" = get_supply_group_name(category), "category" = category)))

	static_data["categories"] = categories

	return static_data

/obj/machinery/computer/supplycomp/proc/is_authorized(mob/user)
	if(allowed(user))
		return TRUE

	if(user.can_admin_interact())
		return TRUE

	return FALSE

/obj/machinery/computer/supplycomp/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	var/mob/user = ui.user

	// If its not a public console, and they aint authed, dont let them use this
	if(!is_public && !is_authorized(user))
		return

	if(!SSshuttle)
		stack_trace("The SSshuttle controller datum is missing somehow.")
		return

	. = TRUE
	add_fingerprint(user)

	switch(action)
		if("moveShuttle")
			move_shuttle(user)
		if("order")
			if(world.time < reqtime)
				visible_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
				return
			var/amount = 1
			if(params["multiple"] == "1") // 1 is a string here. DO NOT MAKE THIS A BOOLEAN YOU DORK
				var/num_input = input(user, "Amount", "How many crates? (20 Max)") as null|num
				if(!num_input || (!is_public && !is_authorized(user)) || ..()) // Make sure they dont walk away
					return
				amount = clamp(round(num_input), 1, 20)
			var/datum/supply_packs/P = locateUID(params["crate"])
			if(!istype(P))
				return
			var/timeout = world.time + (60 SECONDS) // If you dont type the reason within a minute, theres bigger problems here
			var/reason = input(user, "Reason", "Why do you require this item?","") as null|text
			if(world.time > timeout || !reason || (!is_public && !is_authorized(user)) || ..())
				// Cancel if they take too long, they dont give a reason, they aint authed, or if they walked away
				return
			reason = sanitize(copytext(reason, 1, MAX_MESSAGE_LEN))
			var/idname = "*None Provided*"
			var/idrank = "*None Provided*"
			var/datum/money_account/selected_account = locateUID(params["account"])
			var/datum/supply_order/order = SSeconomy.generate_supply_order(params["crate"], idname, idrank, amount, reason)
			var/department
			for(var/department_key in account_database.department_accounts)
				if(account_database.department_accounts[department_key] == selected_account)
					department = department_key
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				idname = H.get_authentification_name()
				idrank = H.get_assignment()
			else if(issilicon(user))
				idname = user.real_name
			if(!istype(selected_account)) //if no account, just default to cargo account
				selected_account = cargo_account
			if(selected_account.security_level == ACCOUNT_SECURITY_ID || selected_account.account_type != ACCOUNT_TYPE_DEPARTMENT)
				//if the account has only account id level security (or its a personal account), go ahead and just try and pay for it now
				if(pay_with_account(selected_account, order.object.cost, "[P.name] Crate Purchase", "Cargo Requests Console", user, account_database.vendor_account))
					SSeconomy.process_supply_order(order, selected_account, account_database, TRUE, department) //add order to shopping list
			else
				//if its a department account with pin or higher security, go ahead and add this to our request list
				SSeconomy.process_supply_order(order, selected_account, account_database, FALSE, department)
				investigate_log("| [key_name(user)] has placed an order for [amount] [order.object.name] with reason: '[reason]'", "cargo")
		if("approve")
			// Public consoles cant approve stuff
			if(is_public)
				return
			if(SSshuttle.supply.getDockedId() != "supply_away" || SSshuttle.supply.mode != SHUTTLE_IDLE)
				return

			var/ordernum = text2num(params["ordernum"])
			var/datum/supply_order/order
			var/datum/supply_packs/pack

			for(var/department_key in SSeconomy.requestlist)
				for(var/datum/supply_order/department_order in SSeconomy.requestlist[department_key])
					if(department_order.ordernum == ordernum)
						order = department_order
						pack = order.object
						var/datum/money_account/account = account_database.department_accounts[department_key]
						if(account?.credit_balance >= pack.cost)
							if(account_database.charge_account(account, pack.cost, "[pack.name] Crate Purchase", "[src]", FALSE, FALSE))
								SSeconomy.requestlist -= order
								SSeconomy.shoppinglist += order
								investigate_log("| [key_name(user)] has authorized an order for [pack.name]. Remaining Cargo Balance: [cargo_account.credit_balance].", "cargo")
								SSblackbox.record_feedback("tally", "cargo_shuttle_order", 1, pack.name)
						else
							to_chat(user, "<span class='warning'>There are insufficient credits in [account] for this request.</span>")
						break
		if("deny")
			var/ordernum = text2num(params["ordernum"])
			var/datum/supply_order/order
			for(var/department_key in SSeconomy.requestlist)
				for(var/datum/supply_order/department_order in SSeconomy.requestlist[department_key])
					if(department_order.ordernum == ordernum)
						order = department_order
						// If we are on a public console, only allow cancelling of our own orders
						if(is_public)
							var/obj/item/card/id/I = user.get_id_card()
							if(I && order.orderedby == I.registered_name)
								SSeconomy.requestlist[department_key] -= order
								break
						// If we arent public, were cargo access. CANCELLATIONS FOR EVERYONE
						else
							SSeconomy.requestlist[department_key] -= order
							investigate_log("| [key_name(user)] has denied an order for [order.object.name].", "cargo")
							break

		// Popup to show CC message logs. Its easier this way to avoid box-spam in TGUI
		if("showMessages")
			// Public consoles cant view messages
			if(is_public)
				return
			var/datum/browser/ccmsg_browser = new(user, "ccmsg", "Central Command Cargo Message Log", 800, 600)
			ccmsg_browser.set_content(SSeconomy.centcom_message)
			ccmsg_browser.open()

/obj/machinery/computer/supplycomp/proc/move_shuttle(mob/user)
	if(is_public) // Public consoles cant move the shuttle. Dont allow exploiters.
		return
	if(SSshuttle.supply.canMove())
		to_chat(user, "<span class='warning'>For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.</span>")
	else if(SSshuttle.supply.getDockedId() == "supply_home")
		SSshuttle.toggleShuttle("supply", "supply_home", "supply_away", 1)
		investigate_log("| [key_name(user)] has sent the supply shuttle away. Shuttle contents: [SSeconomy.sold_atoms]", "cargo")
	else
		SSshuttle.supply.request(SSshuttle.getDock("supply_home"))

/obj/machinery/computer/supplycomp/proc/pay_for_crate(datum/money_account/customer_account, mob/user, datum/supply_order/order)
	if(!attempt_account_authentification(customer_account, null, user))
		return FALSE
	if(pay_with_account(customer_account, order.object.cost, "Purchase of [order.crates]x [order.object.name]", "Cargo Requests Console", user, cargo_account))
		return TRUE
	else if(customer_account.security_level <= ACCOUNT_SECURITY_RESTRICTED)
		if(attempt_account_authentification())
			if(account_database.charge_account(customer_account, order.object.cost, "Purchase of [order.crates]x [order.object.name]", "Cargo Requests Console"))
				return TRUE
	return FALSE

/obj/machinery/computer/supplycomp/proc/attempt_account_authentification(datum/money_account/customer_account, attempted_pin, mob/user)
	var/attempt_pin = attempted_pin
	if(customer_account.security_level != ACCOUNT_SECURITY_ID && !attempted_pin)
		//if pin is not given, we'll prompt them here
		attempt_pin = input("Enter pin code", "Vendor transaction") as num
		if(!Adjacent(user))
			return FALSE
	var/is_admin = is_admin(user)
	if(!account_database.try_authenticate_login(customer_account, attempt_pin, TRUE, FALSE, is_admin))
		to_chat(user, "<span class='warning'>Unable to access account: incorrect credentials.</span>")
		return FALSE
	return TRUE

/obj/machinery/computer/supplycomp/proc/pay_with_account(datum/money_account/customer_account, amount, purpose, transactor, mob/user, datum/money_account/target)
	if(!customer_account)
		to_chat(user, "<span class='warning'>Error: Unable to access account. Please contact technical support if problem persists.</span>")
		return FALSE
	if(customer_account.suspended)
		to_chat(user, "<span class='warning'>Unable to access account: account suspended.</span>")
		return FALSE
	if(!attempt_account_authentification(customer_account, user))
		return FALSE
	if(!account_database.charge_account(customer_account, amount, purpose, transactor, allow_overdraft = FALSE, supress_log = FALSE))
		to_chat(user, "<span class='warning'>Unable to complete transaction: account has insufficient credit balance to purchase this.</span>")
		return FALSE
	account_database.credit_account(target, amount, purpose, transactor, FALSE)
	return TRUE

/obj/machinery/computer/supplycomp/emag_act(mob/user)
	if(!hacked)
		to_chat(user, "<span class='notice'>Special supplies unlocked.</span>")
		hacked = TRUE
		return

/obj/machinery/computer/supplycomp/public
	name = "Supply Ordering Console"
	desc = "Used to order supplies from cargo staff."
	icon = 'icons/obj/computer.dmi'
	icon_screen = "request"
	circuit = /obj/item/circuitboard/ordercomp
	req_access = list()
	is_public = TRUE
