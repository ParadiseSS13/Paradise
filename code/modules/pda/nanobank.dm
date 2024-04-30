#define TRANSFER_REQUEST_MAX		5000
#define TRANSFER_COOLDOWN           5 SECONDS

/datum/data/pda/app/nanobank
	name = "NanoBank"
	icon = "fas fa-university"
	notify_icon = "comments"
	title = "NanoBank 1.1"
	template = "pda_nanobank"
	update = PDA_APP_UPDATE_SLOW //we want to avoid iterating through the data lists constantly

	///the money account tethered to this program
	var/datum/money_account/user_account
	///money account database this PDA is connected to
	var/datum/money_account_database/main_station/account_database
	///world time of last transaction, used for cooldowns (to protect against transfer spams or accidental double clicks)
	var/last_transaction = 0

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
	var/attempt_pin = tgui_input_number(user, "Enter pin code", "NanoBank Account Auth", max_value = 99999)
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

#undef TRANSFER_COOLDOWN

#undef TRANSFER_REQUEST_MAX
