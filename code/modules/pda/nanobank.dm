#define TRANSFER_REQUEST_MAX		5000
#define TRANSFER_COOLDOWN           5 SECONDS
#define PREMIUM_COST 250

/datum/data/pda/app/nanobank
	name = "NanoBank"
	icon = "fas fa-university"
	notify_icon = "comments"
	title = "NanoBank 1.2"
	template = "pda_nanobank"
	update = PDA_APP_UPDATE_SLOW //we want to avoid iterating through the data lists constantly

	///the money account tethered to this program
	var/datum/money_account/user_account
	///money account database this PDA is connected to
	var/datum/money_account_database/main_station/account_database
	///world time of last transaction, used for cooldowns (to protect against transfer spams or accidental double clicks)
	var/last_transaction = 0

	/// Has this user purchased NanoBank Premium?
	var/premium_version = FALSE

/datum/data/pda/app/nanobank/start()
	. = ..()
	reconnect_database()

/datum/data/pda/app/nanobank/Destroy()
	if(user_account)
		//because we have a user account, we know its in the user account's anp list
		LAZYREMOVE(user_account.associated_nanobank_programs, src) //removing references to this program
		logout() //removing signals
	return ..()

/datum/data/pda/app/nanobank/proc/reconnect_database()
	account_database = GLOB.station_money_database

/datum/data/pda/app/nanobank/update_ui(mob/user, list/data)

	if(pda.id)
		data["card_account_num"] = pda.id.associated_account_number

	data["requests"] = list()
	data["available_accounts"] = list()
	data["transaction_log"] = list()
	data["db_status"] = account_database.online
	data["logged_in"] = FALSE
	if(user_account)
		data["logged_in"] = TRUE
		data["owner_name"] = user_account.account_name
		data["money"] = user_account.credit_balance
		data["security_level"] = user_account.security_level
		data["is_department_account"] = (user_account.account_type == ACCOUNT_TYPE_DEPARTMENT)
		if(data["is_department_account"])
			data["department_members"] = list()
			for(var/datum/station_department/department as anything in SSjobs.station_departments)
				if(department.department_account == user_account)
					data["auto_approve_amount"] = department.auto_approval_cap
					data["auto_approve"] = department.crate_auto_approve
					for(var/datum/department_member/member in department.members)
						var/list/member_data = list(
							"name" = member.name,
							"job" = member.role,
							"can_approve" = member.can_approve_crates,
						)
						data["department_members"] += list(member_data)
					break
		data["transaction_log"] = list()
		for(var/datum/transaction/T as anything in user_account.account_log)
			var/list/transaction_info = list(
				"time" = T.time,
				"target_name" = T.transactor,
				"purpose" = T.purpose,
				"amount" = T.amount,
				"is_deposit" = T.is_deposit
			)
			data["transaction_log"] += list(transaction_info)


		for(var/datum/transfer_request/request as anything in user_account.transfer_requests)
			var/list/request_data = list(
				"purpose"    = request.purpose,
				"amount"     = request.amount,
				"time"       = FLOOR((world.time - request.time) / (1 MINUTES), 1),
				"requester"  = request.requesting_account.account_name,
				"request_id" = request.UID())
			data["requests"] += list(request_data)

		data["available_accounts"] = get_available_account_data()

	data["is_premium"] = premium_version
	data["supply_requests"] = list()

	if(premium_version && user_account)
		var/list/supply_requests = list()
		for(var/datum/supply_order/order as anything in SSeconomy.request_list)
			//can this specific order request be approved the the mob user?
			var/can_approve = FALSE
			//can this specific order request be denied the the mob user?
			var/can_deny = FALSE

			// Step 0: Initial checks for denial & CT Approval requirements
			if(order.orderedby == user_account.account_name)
				can_deny = TRUE //if it's your crate, you can deny it;

			if(isnull(order.ordered_by_department))
				if(order.orderedby != user_account.account_name)
					continue // non-department personal order, if it's not yours, you don't get to see it
			if(user_account.account_type == ACCOUNT_TYPE_DEPARTMENT)
				can_deny = TRUE // if it's a department account, you can deny crates (only it's department crates will show up)
			if(order.requires_cargo_approval)
				can_approve = FALSE // You cannot remotely approve CT locked transactions :)

			else if(order.requires_head_approval)
				// Step 1: Check if this is a department account and assign permission accordingly
				if(user_account.account_type == ACCOUNT_TYPE_DEPARTMENT) //set to TRUE initially if  account is a Department account
					if(order.ordered_by_department.department_account != user_account)
						continue // department order, but wrong department, skip this order!
					can_approve = TRUE
					can_deny = TRUE

				// Step 2: Check through members
				var/member_identified = FALSE // is this user in the order's department?
				for(var/datum/department_member/member as anything in order.ordered_by_department.members)
					if(member.member_account != user_account)
						continue
					member_identified = TRUE
					if(member.can_approve_crates)
						can_approve = TRUE
						can_deny = TRUE
						member_identified = TRUE
					break

				// Step 3: If user is not a member of order's department & this is a personal account, skip this order in the UI
				if(!member_identified && user_account.account_type == ACCOUNT_TYPE_PERSONAL)
					continue // Don't show this order if it's a department order and the user is not part of that department

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
			supply_requests += list(request_data)
		data["supply_requests"] = supply_requests
	return data

/datum/data/pda/app/nanobank/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	unnotify()
	var/mob/user = ui.user
	var/play_beep = TRUE

	. = TRUE

	switch(action)
		if("login")
			var/tried_account_num = text2num(params["account_num"])
			var/tried_pin = text2num(params["account_pin"])
			attempt_login(tried_account_num, tried_pin, user)
		if("logout")
			logout()
		if("transfer")
			if(!user_account)
				return
			if(last_transaction + TRANSFER_COOLDOWN >= world.time)
				return
			var/transfer_amount = text2num(params["amount"])
			if(!transfer_amount || transfer_amount < 0) //if null, 0, or negative amount
				return
			var/datum/money_account/transfer_to = locateUID(params["transfer_to_account"])
			if(!istype(transfer_to) || transfer_to == src)
				return //account no longer exists or something fucked is going on
			if(transfer_funds(user, transfer_amount, transfer_to))
				to_chat(user, "<span class='notice'>NanoBank: Transfer Successful</span>")
				last_transaction = world.time
				if(!pda.silent)
					playsound(pda, 'sound/machines/ping.ogg', 50, 0)
		if("transfer_request")
			if(!user_account)
				return
			if(last_transaction + TRANSFER_COOLDOWN >= world.time)
				return
			var/transfer_amount = text2num(params["amount"])
			var/purpose = length(params["purpose"]) ? params["purpose"] : ""
			if(length(purpose) >= MAX_NAME_LEN)
				error_message(user, "Purpose too long, please limit to [MAX_NAME_LEN] characters max")
			if(!transfer_amount || transfer_amount < 0) //if null, 0, or negative amount
				return
			var/datum/money_account/request_from = locateUID(params["transfer_to_account"])
			if(!istype(request_from) || request_from == user_account)
				return //account no longer exists or they're trying to send to themselves
			if(create_fund_request(user, transfer_amount, purpose, request_from))
				to_chat(user, "<span class='notice'>NanoBank: Transfer Request Submitted</span>")
				last_transaction = world.time
				if(!pda.silent)
					playsound(pda, 'sound/machines/ping.ogg', 50, 0)
		if("resolve_transfer_request")
			if(!user_account)
				return
			var/accepted = params["accepted"] ? TRUE : FALSE
			var/datum/transfer_request/request = locateUID(params["requestUID"])
			if(!istype(request) || !(request in user_account.transfer_requests))
				return
			account_database.resolve_transfer_request(request, user_account, accepted)
		if("set_security")
			if(!user_account)
				return
			var/new_sec_level = clamp(text2num(params["new_security_level"]), ACCOUNT_SECURITY_ID, ACCOUNT_SECURITY_PIN)
			if(!new_sec_level)
				return
			var/attempt_pin = 0
			if(user_account.security_level >= ACCOUNT_SECURITY_PIN)
				attempt_pin = input_account_pin(user)
			if(account_database.try_authenticate_login(user_account, attempt_pin, FALSE, FALSE, FALSE))
				user_account.security_level = new_sec_level
				to_chat(user, "<span class='notice'>Nanobank: account security set to [new_sec_level == ACCOUNT_SECURITY_ID ? "*Account Number Only*" : "*Require Pin Entry*"]</span>")
			else
				to_chat(user, "<span class='warning'>Authentification Failure: incorrect pin.</span>")

		if("purchase_premium")
			if(premium_version)
				return
			var/choice = tgui_alert(user, "Purchase NanoBank Premium on this PDA for [PREMIUM_COST] credits?", "Confirm", list("Yes", "No"))
			if(choice != "Yes")
				return
			if(pay_with_account(user, PREMIUM_COST, "NanoBank Premium Purchase", "[pda]", account_database.vendor_account))
				premium_version = TRUE
				title += " Premium" // cash money
				if(!pda.silent)
					playsound(pda, 'sound/machines/ping.ogg', 50, FALSE)
			else
				if(!pda.silent)
					playsound(pda, 'sound/machines/buzz-sigh.ogg', 15, FALSE)

		if("toggle_member_approval")
			for(var/datum/station_department/department as anything in SSjobs.station_departments)
				if(department.department_account == user_account)
					for(var/datum/department_member/member in department.members)
						if(member.name == params["member"] && member.member_account != user_account)
							member.can_approve_crates = !member.can_approve_crates
							break
					break
		if("toggle_auto_approve")
			for(var/datum/station_department/department as anything in SSjobs.station_departments)
				if(department.department_account == user_account)
					department.crate_auto_approve = !department.crate_auto_approve
					break
		if("set_approve_amount")
			var/new_amount = text2num(params["approve_amount"])
			for(var/datum/station_department/department as anything in SSjobs.station_departments)
				if(department.department_account == user_account)
					if(new_amount)
						department.auto_approval_cap = clamp(new_amount, 0, 3000)
					else
						department.auto_approval_cap = 0
		if("approve_crate")
			var/ordernum = text2num(params["ordernum"])
			if(!ordernum)
				return
			approve_crate(ordernum, user)
		if("deny_crate")
			var/ordernum = text2num(params["ordernum"])
			if(!ordernum)
				return
			deny_crate(ordernum, user)
	if(play_beep && !pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

/datum/data/pda/app/nanobank/proc/attempt_login(tried_account_num, tried_pin, mob/user)
	if(!tried_account_num)
		to_chat(user, "<span class='warning'>Authentification Failure: Account number not found.</span>")
		return FALSE

	var/datum/money_account/attempt_account = account_database.find_user_account(tried_account_num, include_departments = TRUE)
	if(!attempt_account)
		to_chat(user, "<span class='warning'>Authentification Failure: User Account Not Found.</span>")
		return FALSE

	if(account_database.try_authenticate_login(attempt_account, tried_pin, TRUE, FALSE, FALSE))
		user_account = attempt_account
		//lets make sure to logout if the account gets deleted somehow (such as cryo'ing)
		RegisterSignal(user_account, COMSIG_PARENT_QDELETING, PROC_REF(logout))
		if(!LAZYLEN(user_account.associated_nanobank_programs) || !(src in user_account.associated_nanobank_programs))
			LAZYADD(user_account.associated_nanobank_programs, src)
		return TRUE

/datum/data/pda/app/nanobank/proc/logout()
	if(!user_account)
		return
	//even though this is a LAZYLIST, we know it has a single entry on it because we're connected to the account
	LAZYREMOVE(user_account.associated_nanobank_programs, src)
	UnregisterSignal(user_account, COMSIG_PARENT_QDELETING)
	user_account = null


/datum/data/pda/app/nanobank/proc/transfer_funds(mob/user, amount, datum/money_account/target)
	if(account_database.charge_account(user_account, amount, "Transfer to [target.account_name]", "NanoBank Transfer Services", FALSE, FALSE))
		account_database.credit_account(target, amount, "Transfer from [user_account.account_name]", "NanoBank Transfer Services", FALSE)
		return TRUE
	else
		error_message(user, "Insufficient Funds")
	return FALSE

/datum/data/pda/app/nanobank/proc/create_fund_request(mob/user, amount, purpose, datum/money_account/target)
	if(!target)
		error_message(user, "Target Account Not Found")
		return FALSE
	if(!amount)
		error_message(user, "Please input an amount to request")
		return FALSE
	account_database.create_transfer_request(user_account, amount, purpose, target)

/datum/data/pda/app/nanobank/proc/change_account_security(mob/user, attempted_pin, new_security_level)
	if(new_security_level >= ACCOUNT_SECURITY_RESTRICTED || new_security_level < ACCOUNT_SECURITY_ID)
		error_message(user, "Unable to apply selected security restrictions")
		///attempted new security level is NOT an available option, likely user spoofing values
		message_admins("[ADMIN_LOOKUPFLW(user)] attempted to set account security to an unavailable option, possible href exploit!")
		return
	if(account_database.try_authenticate_login(user_account, attempted_pin, FALSE, FALSE, FALSE))
		user_account.security_level = new_security_level
	else
		error_message(user, "Incorrect Credentials")

/datum/data/pda/app/nanobank/proc/input_account_pin(mob/user)
	var/attempt_pin = tgui_input_number(user, "Enter pin code", "NanoBank Account Auth", max_value = BANK_PIN_MAX, min_value = BANK_PIN_MIN)
	if(!user_account || isnull(attempt_pin))
		return
	return attempt_pin

/datum/data/pda/app/nanobank/proc/error_message(mob/user, message)
	to_chat(user, "<span class='warning'>ERROR: [message].</span>")
	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_error.ogg', 15, TRUE)

/datum/data/pda/app/nanobank/proc/get_available_account_data()
	var/list/found_accounts = list()
	for(var/datum/money_account/account as anything in account_database.user_accounts)
		if(account != user_account)
			var/list/account_data = list(
				"name" = account.account_name,
				"UID"  = account.UID()
			)
			found_accounts += list(account_data)
	for(var/department in account_database.department_accounts)
		var/datum/money_account/account = account_database.department_accounts[department]
		var/list/account_data = list(
			"name" = account.account_name,
			"UID"  = account.UID()
		)
		found_accounts += list(account_data)
	return found_accounts

/datum/data/pda/app/nanobank/proc/announce_payday(amount)
	if(ishuman(pda.loc))
		var/mob/user = pda.loc
		if(user.stat != UNCONSCIOUS) // Awake or dead people can see their messages
			to_chat(user, "<span class='notice'>NanoBank: Paycheck of [amount] credits received</span>")
	if(!pda.silent)
		playsound(pda, 'sound/machines/ping.ogg', 50, 0)

/datum/data/pda/app/nanobank/proc/can_receive()
	return pda.owner && !hidden


/datum/data/pda/app/nanobank/proc/approve_crate(order_num, mob/user)
	if(!premium_version)
		return // cheater cheater pumpkin eater

	for(var/datum/supply_order/order as anything in SSeconomy.request_list)
		if(order.ordernum != order_num)
			continue
		//can this specific order request be approved the the mob user?
		var/can_approve = FALSE

		if(order.requires_cargo_approval)
			return // You cannot remotely approve CT locked transactions :)
		if(order.requires_head_approval)
			if(user_account.account_type == ACCOUNT_TYPE_DEPARTMENT) //set to TRUE initially if  account is a Department account
				if(order.ordered_by_department.department_account != user_account)
					return // department order, but wrong department, yeet
				can_approve = TRUE

			// Check through members
			var/member_identified = FALSE // is this user in the order's department?
			for(var/datum/department_member/member as anything in order.ordered_by_department.members)
				if(member.member_account != user_account)
					continue
				member_identified = TRUE
				if(member.can_approve_crates)
					can_approve = TRUE
				break

			// Step 3: If user is not a member of order's department & this is a personal account, skip this order in the UI
			if(!member_identified && user_account.account_type == ACCOUNT_TYPE_PERSONAL)
				return // user not in this department, get outta here!

		if(!can_approve)
			return

		var/datum/supply_packs/pack = order.object
		var/datum/money_account/account = order.ordered_by_department.department_account
		///just give the account pin here, its too much work for players to get the department account pin number since approval is access locked anyway
		if(attempt_account_authentification(account, user, account.account_pin))
			if(pay_with_account(user, pack.get_cost(), "[pack.name] Crate Purchase", "[src]", account_database.vendor_account))
				if(!pda.silent)
					playsound(pda, 'sound/machines/ping.ogg', 50, FALSE)
				order.requires_head_approval = FALSE
				SSeconomy.process_supply_order(order, TRUE)
				pda.investigate_log("| [key_name(user)] has authorized an order for [pack.name]. Remaining Cargo Balance: [SSeconomy.cargo_account.credit_balance].", INVESTIGATE_CARGO)
				SSblackbox.record_feedback("tally", "cargo_shuttle_order", 1, pack.name)
			else
				pda.atom_say("ERROR: Account tied to order cannot pay, auto-denying order")
				SSeconomy.request_list -= order

/datum/data/pda/app/nanobank/proc/deny_crate(order_num, user)
	if(!premium_version)
		return // cheater cheater pumpkin eater

	for(var/datum/supply_order/order as anything in SSeconomy.request_list)
		if(order.ordernum != order_num)
			continue

		//can this specific order request be denied by the currently opened NanoBank account?
		var/can_deny = FALSE
		if(order.orderedby == user_account.account_name)
			can_deny = TRUE
		else if(order.requires_head_approval)
			if(user_account.account_type == ACCOUNT_TYPE_DEPARTMENT) //set to TRUE initially if  account is a Department account
				if(order.ordered_by_department.department_account != user_account)
					return // department order, but wrong department
				can_deny = TRUE

			for(var/datum/department_member/member as anything in order.ordered_by_department.members)
				if(member.member_account != user_account)
					continue
				if(member.can_approve_crates)
					can_deny = TRUE
				break

		if(!can_deny)
			return
		SSeconomy.request_list -= order
		pda.investigate_log("| [key_name(user)] has denied an order for [order.object.name] through the Nanobank app.", INVESTIGATE_CARGO)

/datum/data/pda/app/nanobank/proc/pay_with_account(user, amount, purpose, transactor, datum/money_account/target)
	if(user_account.suspended)
		to_chat(user, "<span class='warning'>Unable to access account: account suspended.</span>")
		return FALSE
	if(!account_database.charge_account(user_account, amount, purpose, transactor, allow_overdraft = FALSE, supress_log = FALSE))
		to_chat(user, "<span class='warning'>Unable to complete transaction: account has insufficient credit balance to purchase this.</span>")
		return FALSE
	account_database.credit_account(target, amount, purpose, transactor, FALSE)
	return TRUE

/datum/data/pda/app/nanobank/proc/attempt_account_authentification(datum/money_account/customer_account, mob/user, pin)
	if(customer_account.security_level > ACCOUNT_SECURITY_RESTRICTED)
		return FALSE
	var/attempt_pin = pin
	if(customer_account.security_level != ACCOUNT_SECURITY_ID && !attempt_pin)
		//if pin is not given, we'll prompt them here
		attempt_pin = tgui_input_number(user, "Enter pin code", "Vendor transaction", max_value = BANK_PIN_MAX, min_value = BANK_PIN_MIN)
		if(!attempt_pin)
			return FALSE
	var/is_admin = is_admin(user)
	if(!account_database.try_authenticate_login(customer_account, attempt_pin, TRUE, FALSE, is_admin))
		to_chat(user, "<span class='warning'>Unable to access account: incorrect credentials.</span>")
		return FALSE
	return TRUE

#undef TRANSFER_COOLDOWN

#undef TRANSFER_REQUEST_MAX
#undef PREMIUM_COST
