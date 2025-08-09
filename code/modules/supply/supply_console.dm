#define MULTIPLE_CRATE_MAX 10

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
	account_database = GLOB.station_money_database
	cargo_account = account_database.get_account_by_department(DEPARTMENT_SUPPLY)

/obj/machinery/computer/supplycomp/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_hand(mob/user)
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return TRUE

	ui_interact(user)

/obj/machinery/computer/supplycomp/proc/has_ct_access(list/access)
	return (ACCESS_CARGO in access) ? TRUE : FALSE

/obj/machinery/computer/supplycomp/proc/is_authorized(mob/user)
	if(allowed(user))
		return TRUE
	if(user.can_admin_interact())
		return TRUE
	return FALSE

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
		if(SUPPLY_SHUTTLE)
			return "Shuttles"

/obj/machinery/computer/supplycomp/proc/build_request_data(mob/user)
	var/list/requests = list()

	var/is_silicon = issilicon(user)
	var/obj/item/card/id/C
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		C = H.get_idcard(TRUE)

	for(var/datum/supply_order/order as anything in SSeconomy.request_list)
		//can this specific order request be approved the the mob user?
		var/can_approve = FALSE
		//can this specific order request be denied the the mob user?
		var/can_deny = FALSE
		if(C && order.orderedby == C.registered_name)
			can_deny = TRUE //if it's your crate, you can deny it
		if(is_silicon) //robots and admins can do whatever they want
			can_approve = TRUE
			can_deny = TRUE
		if(order.requires_cargo_approval)
			if(C && has_ct_access(C.access)) //if the crate needs CT approval and you have CT access, you get app and deny rights
				can_approve = TRUE
				can_deny = TRUE
		else if(order.requires_head_approval)
			if(C && order.ordered_by_department.has_account_access(C.access, GLOB.station_money_database.find_user_account(C.associated_account_number)))
				can_approve = TRUE //if the crate DOESN'T need CT approval (or CT already approved it), you get app and deny rights
				can_deny = TRUE
			if(C && has_ct_access(C.access))
				can_deny = TRUE //CT can deny any order at any time

		var/list/request_data = list(
			"ordernum" = order.ordernum,
			"supply_type" = order.object.name,
			"orderedby" = order.orderedby,
			"department" = order.ordered_by_department?.department_name,
			"cost" = order.object.get_cost(),
			"comment" = order.comment,
			"req_cargo_approval" = order.requires_cargo_approval,
			"req_head_approval" = order.requires_head_approval,
			"can_approve" = can_approve,
			"can_deny" = can_deny,
			"singleton_id" = initial(order.object?.singleton_group_id)
		)
		//The way approval rights is determined
		//If a crate requires CT approval and head approval - Only CTs can approve it for now, heads can still deny it at this point however
		//If a crate requires head approval - They can approve it as long as they have department account access and the crate doesn't still need CT approval
		requests += list(request_data)
	return requests

/obj/machinery/computer/supplycomp/proc/get_accounts(mob/user)
	if(!ishuman(user))
		if(isobserver(user) && is_admin(user))
			//if an admin is accessing, return all department accounts
			return account_database.get_all_department_accounts()
		return list(cargo_account) //else only the cargo account

	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/C = H.get_idcard(TRUE)
	var/list/accounts = list()
	if(C) //if human and has ID, get accounts associated with crew members assigned role
		var/datum/money_account/customer_account = C.get_card_account()
		if(customer_account) //get customers account and make it the fist entry
			accounts += customer_account
		var/list/department_accounts = list() //time to get department accounts
		if(ACCESS_CAPTAIN in C.access)
			//if captain access, get all accounts
			department_accounts = account_database.get_all_department_accounts()
		else
			//otherwise just get crew members specific departments
			var/list/departments = C.get_departments() //will return up to 2 departments
			for(var/datum/station_department/department in departments)
				accounts += department.department_account
		if(length(department_accounts))
			accounts += department_accounts
	if(!length(accounts) || !(cargo_account in accounts))
		accounts += cargo_account
	return accounts

/obj/machinery/computer/supplycomp/proc/build_account_data(mob/user)
	var/list/departments = get_accounts(user)
	var/list/accounts = list()
	for(var/datum/money_account/account as anything in departments)
		var/list/account_data = list(
			"name" = account.account_name,
			"balance" = account.credit_balance,
			"account_UID" = account.UID(),
		)
		accounts += list(account_data)
	return accounts

/obj/machinery/computer/supplycomp/proc/build_shopping_list_data()
	var/list/orders = list()
	for(var/datum/supply_order/order as anything in SSeconomy.shopping_list)
		var/list/order_data = list(
			"ordernum" = order.ordernum,
			"supply_type" = order.object.name,
			"orderedby" = order.orderedby,
			"comment" = order.comment,
			"singleton_id" = initial(order.object?.singleton_group_id)
		)
		orders += list(order_data)
	return orders

/obj/machinery/computer/supplycomp/proc/build_shipment_list_data()
	var/list/orders = list()
	for(var/datum/supply_order/order as anything in SSeconomy.delivery_list)
		var/list/order_data = list(
			"ordernum" = order.ordernum,
			"supply_type" = order.object.name,
			"orderedby" = order.orderedby,
			"comment" = order.comment
		)
		orders += list(order_data)
	return orders

/obj/machinery/computer/supplycomp/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/supplycomp/ui_interact(mob/user, datum/tgui/ui = null)
	if(!cargo_account || !account_database)
		reconnect_database()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoConsole", name)
		ui.open()

/obj/machinery/computer/supplycomp/ui_data(mob/user)
	var/list/data = list()

	data["requests"] = build_request_data(user)
	data["accounts"] = build_account_data(user)
	data["orders"] = build_shopping_list_data()
	data["shipments"] = build_shipment_list_data()
	data["is_public"] = is_public
	data["moving"] = SSshuttle.supply.mode != SHUTTLE_IDLE
	data["at_station"] = SSshuttle.supply.getDockedId() == "supply_home"
	data["timeleft"] = SSshuttle.supply.timeLeft(60 SECONDS)

	return data

/obj/machinery/computer/supplycomp/ui_static_data(mob/user)
	var/list/static_data = list()
	var/list/packs_list = list()

	for(var/set_name in SSeconomy.supply_packs)
		var/datum/supply_packs/pack = SSeconomy.supply_packs[set_name]
		var/shown_if_hacked = pack.hidden && hacked
		var/shown_if_contraband = pack.contraband && can_order_contraband
		var/shown_if_cmagged = pack.cmag_hidden && HAS_TRAIT(src, TRAIT_CMAGGED)

		var/shown = (!pack.hidden || shown_if_hacked) && (!pack.contraband || shown_if_contraband) && (!pack.cmag_hidden || shown_if_cmagged)

		if(pack.special)
			shown &= pack.special_enabled

		if(shown)
			packs_list.Add(list(list(
				"name" = pack.name,
				"cost" = pack.get_cost(),
				"ref" = "[pack.UID()]",
				"contents" = pack.ui_manifest,
				"singleton" = pack.singleton,
				"cat" = pack.group)))

	static_data["supply_packs"] = packs_list

	var/list/categories = list()
	for(var/category in SSeconomy.all_supply_groups)
		categories.Add(list(list("name" = get_supply_group_name(category), "category" = category)))

	static_data["categories"] = categories

	return static_data



/obj/machinery/computer/supplycomp/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	var/mob/user = ui.user

	// If its not a public console, and they aint authed, dont let them use this
	if(!is_public && !is_authorized(user))
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
			var/datum/supply_packs/P = locateUID(params["crate"])
			if(!istype(P))
				return

			if(!P.can_order())
				to_chat(user, "<span class='warning'>That cannot be ordered right now. Please try again later.</span>")
				return
			if(P.are_you_sure_you_want_to_be_banned)
				var/we_warned_you = tgui_alert(user, "[P.are_you_sure_you_want_to_be_banned]", "ARE YOU SURE?", list("Yes", "No"))
				if(!we_warned_you || we_warned_you == "No")
					return
			if(!P.singleton && params["multiple"])
				var/num_input = tgui_input_number(user, "Amount", "How many crates?", max_value = MULTIPLE_CRATE_MAX, min_value = 1)
				if(isnull(num_input) || (!is_public && !is_authorized(user)) || ..()) // Make sure they dont walk away
					return
				amount = clamp(round(num_input), 1, MULTIPLE_CRATE_MAX)
			var/reason = tgui_input_text(user, "Reason", "Why do you require this item?", encode = FALSE, timeout = 60 SECONDS)
			if(!reason || (!is_public && !is_authorized(user)) || ..())
				return
			reason = sanitize(copytext_char(reason, 1, 75)) // very long reasons are bad

			//===orderee identification information===
			var/idname = "*None Provided*"
			var/idrank = "*None Provided*"
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				idname = H.get_authentification_name()
				idrank = H.get_assignment()
			else if(issilicon(user))
				idname = user.real_name

			//===orderee account information===
			var/datum/money_account/selected_account = locateUID(params["account"])
			var/successes = 0
			for(var/i in 1 to amount)
				var/datum/supply_order/order = SSeconomy.generate_supply_order(params["crate"], idname, idrank, reason)
				if(istype(order))
					successes++
					order_crate(user, order, selected_account)
					if(successes == 1)
						playsound(loc, 'sound/machines/ping.ogg', 15, FALSE)
						to_chat(user, "<span class='notice'>Order Sent.</span>")
						generate_requisition_paper(order, amount)
			if(successes != amount)
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 15, FALSE)
				to_chat(user, "<span class='warning'>Some items were unable to be ordered. Please check requisition paper and try again at a different time.</span>")

		if("approve")
			var/ordernum = text2num(params["ordernum"])
			if(!ordernum)
				return
			approve_crate(user, ordernum)
		if("deny")
			var/ordernum = text2num(params["ordernum"])
			if(!ordernum)
				return
			deny_crate(user, ordernum)


		// Popup to show CC message logs. Its easier this way to avoid box-spam in TGUI
		if("showMessages")
			// Public consoles cant view messages
			if(is_public)
				return
			var/datum/browser/ccmsg_browser = new(user, "ccmsg", "Central Command Cargo Message Log", 800, 600)
			ccmsg_browser.set_content(SSeconomy.centcom_message)
			ccmsg_browser.open()

/obj/machinery/computer/supplycomp/proc/order_crate(mob/user, datum/supply_order/order, datum/money_account/account)
	var/datum/money_account/selected_account = account
	if(!istype(selected_account)) //if no account found, just default to cargo account
		CRASH("order_crate called without a specified money account")
	if(selected_account.account_type == ACCOUNT_TYPE_DEPARTMENT)
		for(var/datum/station_department/department in SSjobs.station_departments)
			if(department.department_account == selected_account)
				order.ordered_by_department = department //now that we know which department this is for, attach it to the order
				order.set_account(selected_account)
				order.requires_head_approval = TRUE

				if(length(order.object.department_restrictions) && !(department.department_name in order.object.department_restrictions))
					//this crate has a department whitelist description
					//this department is not in this whitelist, require CT approval
					order.requires_cargo_approval = TRUE
				break
	else if(selected_account.account_type == ACCOUNT_TYPE_PERSONAL && length(order.object.department_restrictions))
		order.requires_cargo_approval = TRUE

	//===Handle Supply Order===
	if(selected_account.account_type == ACCOUNT_TYPE_PERSONAL)
		//if the account is a personal account (and doesn't require CT approval), go ahead and pay for it now
		order.set_account(selected_account)
		if(attempt_account_authentification(selected_account, user))
			var/paid_for = FALSE
			if(!order.requires_cargo_approval && pay_with_account(selected_account, order.object.get_cost(), "[order.object.name] Crate Purchase", "Cargo Requests Console", user, account_database.vendor_account))
				paid_for = TRUE
			SSeconomy.process_supply_order(order, paid_for) //add order to shopping list
	else //if its a department account with pin or higher security or need QM approval, go ahead and add this to the departments section in request list
		SSeconomy.process_supply_order(order, FALSE)
		if(order.ordered_by_department.crate_auto_approve && order.ordered_by_department.auto_approval_cap >= order.object.get_cost())
			approve_crate(user, order.ordernum)
		investigate_log("| [key_name(user)] has placed an order for [order.object.amount] [order.object.name] with reason: '[order.comment]'", INVESTIGATE_CARGO)

/obj/machinery/computer/supplycomp/proc/approve_crate(mob/user, order_num)
	for(var/datum/supply_order/department_order in SSeconomy.request_list)
		if(department_order.ordernum != order_num)
			continue
		var/datum/supply_order/order = department_order
		var/datum/supply_packs/pack = order.object
		var/datum/money_account/account = order.orderedbyaccount

		if(order.requires_cargo_approval)
			if(!has_ct_access(user.get_access()))
				return FALSE
			order.requires_cargo_approval = FALSE
			if(account.account_type == ACCOUNT_TYPE_PERSONAL || isnull(order.ordered_by_department))
				if(pay_with_account(account, order.object.get_cost(), "[pack.name] Crate Purchase", "Cargo Requests Console", user, account_database.vendor_account))
					SSeconomy.process_supply_order(order, TRUE) //send 'er back through
					if(istype(order.object, /datum/supply_packs/abstract/shuttle))
						update_static_data(user) // pack is going to be disabled, need to update pack data
					SStgui.update_uis(src)
					return TRUE
				atom_say("ERROR: Account tied to order cannot pay, auto-denying order")
				SSeconomy.request_list -= order //just remove order at this poin
			else
				return TRUE
			return TRUE

		if(order.requires_head_approval)
			//if they do not have access to this account
			if(!department_order.ordered_by_department.has_account_access(user.get_access(), user.get_worn_id_account()))
				//and the dept account doesn't have auto approve enabled (or does and the crate is too expensive for auto approve)
				if(!department_order.ordered_by_department.crate_auto_approve || department_order.ordered_by_department.auto_approval_cap < pack.get_cost())
					return //no access!

			///just give the account pin here, its too much work for players to get the department account pin number since approval is access locked anyway
			if(attempt_account_authentification(account, user, account.account_pin))
				if(pay_with_account(account, pack.get_cost(), "[pack.name] Crate Purchase", "[src]", user, account_database.vendor_account))
					order.requires_head_approval = FALSE
					SSeconomy.process_supply_order(order, TRUE)
					if(istype(order.object, /datum/supply_packs/abstract/shuttle))
						update_static_data(user) // pack is going to be disabled, need to update pack data
					SStgui.update_uis(src)
					investigate_log("| [key_name(user)] has authorized an order for [pack.name]. Remaining Cargo Balance: [cargo_account.credit_balance].", INVESTIGATE_CARGO)
					SSblackbox.record_feedback("tally", "cargo_shuttle_order", 1, pack.name)
				else
					atom_say("ERROR: Account tied to order cannot pay, auto-denying order")
					SSeconomy.request_list -= order
		break

/obj/machinery/computer/supplycomp/proc/deny_crate(mob/user, order_num)
	var/obj/item/card/id/C
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		C = H.get_idcard(TRUE)
	for(var/datum/supply_order/department_order as anything in SSeconomy.request_list)
		if(department_order.ordernum != order_num)
			continue
		var/datum/supply_order/order = department_order
		// allow cancelling of our own orders
		if(C && order.orderedby == C.registered_name)
			SSeconomy.request_list -= order
			return
		// If we arent public, were cargo access. CANCELLATIONS FOR EVERYONE
		if(order.requires_cargo_approval && (issilicon(user) || (ACCESS_CARGO in C?.access)))
			SSeconomy.request_list -= order
		else if(order.requires_head_approval && (issilicon(user) || order.ordered_by_department.has_account_access(C?.access)))
			SSeconomy.request_list -= order
		else
			return //how did we get here?
		investigate_log("| [key_name(user)] has denied an order for [order.object.name].", INVESTIGATE_CARGO)
		break

/obj/machinery/computer/supplycomp/proc/move_shuttle(mob/user)
	if(is_public) // Public consoles cant move the shuttle. Dont allow exploiters.
		return
	if(!SSshuttle.supply.canMove())
		to_chat(user, "<span class='warning'>For safety reasons, the automated supply shuttle cannot transport [SSshuttle.supply.blocking_item].</span>")
	else if(SSshuttle.supply.getDockedId() == "supply_home")
		SSshuttle.toggleShuttle("supply", "supply_home", "supply_away", 1)
		investigate_log("| [key_name(user)] has sent the supply shuttle away. Shuttle contents: [SSeconomy.sold_atoms]", INVESTIGATE_CARGO)
	else
		SSshuttle.supply.request(SSshuttle.getDock("supply_home"))

/obj/machinery/computer/supplycomp/proc/pay_for_crate(datum/money_account/customer_account, mob/user, datum/supply_order/order)
	if(pay_with_account(customer_account, order.object.get_cost(), "Purchase of [order.object.name]", "Cargo Requests Console", user, cargo_account, TRUE))
		return TRUE
	return FALSE

/obj/machinery/computer/supplycomp/proc/attempt_account_authentification(datum/money_account/customer_account, mob/user, pin)
	if(customer_account.security_level > ACCOUNT_SECURITY_RESTRICTED)
		return FALSE
	var/attempt_pin = pin
	if(customer_account.security_level != ACCOUNT_SECURITY_ID && !attempt_pin)
		//if pin is not given, we'll prompt them here
		attempt_pin = tgui_input_number(user, "Enter pin code", "Vendor transaction", max_value = BANK_PIN_MAX, min_value = BANK_PIN_MIN)
		if(!Adjacent(user) || !attempt_pin)
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
	if(!account_database.charge_account(customer_account, amount, purpose, transactor, allow_overdraft = FALSE, supress_log = FALSE))
		to_chat(user, "<span class='warning'>Unable to complete transaction: account has insufficient credit balance to purchase this.</span>")
		return FALSE
	account_database.credit_account(target, amount, purpose, transactor, FALSE)
	return TRUE

/obj/machinery/computer/supplycomp/proc/generate_requisition_paper(datum/supply_order/order, amount)

	var/obj/item/paper/request_form/reqform = new(get_turf(src))
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	reqform.name = "Requisition Form - [amount] '[order.object.name]' for [order.orderedby]"
	reqform.info += "<h3>[station_name()] Supply Requisition Form</h3><hr>"
	reqform.info += "INDEX: #[order.ordernum]<br>"
	reqform.info += "REQUESTED BY: [order.orderedby]<br>"
	reqform.info += "RANK: [order.orderedbyRank]<br>"
	reqform.info += "REASON: [order.comment]<br>"
	reqform.info += "SUPPLY CRATE TYPE: [order.object.name]<br>"
	reqform.info += "NUMBER OF CRATES: [amount]<br>"
	reqform.info += "ACCESS RESTRICTION: [order.object.access ? get_access_desc(order.object.access) : "None"]<br>"
	reqform.info += "CONTENTS:<br>"
	reqform.info += order.object.manifest
	reqform.info += "<hr>"
	reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

	reqform.order_number = order.ordernum

	reqform.update_icon(UPDATE_ICON_STATE)	//Fix for appearing blank when printed.

	return reqform

/obj/machinery/computer/supplycomp/emag_act(mob/user)
	if(!hacked)
		to_chat(user, "<span class='notice'>Special supplies unlocked.</span>")
		hacked = TRUE
		update_static_data(user)
		SStgui.update_uis(src)
		return TRUE

/obj/machinery/computer/supplycomp/cmag_act(mob/user)
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		return FALSE
	to_chat(user, "<span class='notice sans'>Special supplies unlocked.</span>")
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
	update_static_data(user)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/supplycomp/public
	name = "Supply Ordering Console"
	desc = "Used to order supplies from cargo staff."
	icon_screen = "request"
	circuit = /obj/item/circuitboard/ordercomp
	req_access = list()
	is_public = TRUE

#undef MULTIPLE_CRATE_MAX
