/client/proc/economy_manager()
	set name = "Economy Panel"
	set category = "Event"
	set desc = "Perform Various Event Modification to the Economy"

	if(!check_rights(R_EVENT))
		return

	var/datum/ui_module/economy_manager/E = new()
	E.ui_interact(usr)

/datum/ui_module/economy_manager
	name = "Economy Manager"

/datum/ui_module/economy_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/economy_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EconomyManager", name)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/economy_manager/ui_data(mob/user)
	var/list/data = list()

	data["next_payroll_time"] = round((SSeconomy.next_paycheck_delay - world.time) / (60 SECONDS), 0.1)

	return data

/datum/ui_module/economy_manager/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("payroll_modification")
			var/list/accounts_to_modify = list()
			var/num_input = input(ui.user, "Amount (If for more than 4-5 people, Keep this between +/-$100 for the love of god)", "How much to modify by?") as null|num
			if(!num_input)
				return

			var/message_input = ""
			if(params["mod_type"] != "global")
				message_input = input(ui.user, "Add message (Max 50 Characters):", "If you wish the owner(s) of the account(s) to receive a message, please specify") as null|message
			switch(params["mod_type"])
				if("global")
					if(num_input > 0)
						SSeconomy.global_paycheck_bonus += num_input
					else
						SSeconomy.global_paycheck_deduction += -num_input
					log_and_message_admins("has modified the global payroll by [num_input].")
				if("department")
					var/department_input = input(ui.user, "Department", "Which Department Account?") in (GLOB.station_departments - list(DEPARTMENT_ASSISTANT, DEPARTMENT_SILICON))
					if(!department_input)
						return
					var/datum/money_account/department_account = GLOB.station_money_database.get_account_by_department(department_input)
					if(!department_account)
						return
					accounts_to_modify += department_account
					log_and_message_admins("has modified the payroll of the [department_input] department by [num_input].")
				if("department_members")
					var/department_input = input(ui.user, "Department", "Members from Which Department?") in (GLOB.station_departments - list(DEPARTMENT_ASSISTANT, DEPARTMENT_SILICON))
					var/datum/station_department/department = get_department_from_name(department_input)
					if(!department)
						return
					for(var/datum/department_member/member as anything in department.members)
						if(member.member_account)
							accounts_to_modify += member.member_account
					log_and_message_admins("has modified the payroll of the [department_input] department's members by [num_input].")
				if("crew_member")
					var/account_input = input(ui.user, "Account Number", "Please Specify Account Number.") as null|num
					var/datum/money_account/account = GLOB.station_money_database.find_user_account(account_input, FALSE)
					if(!account)
						return
					accounts_to_modify += account
					log_and_message_admins("has modified the payroll of [account.account_number] by [num_input].")
			if(!length(accounts_to_modify))
				return
			var/sanitized = copytext(trim(sanitize(message_input)), 1, MAX_MESSAGE_LEN)
			for(var/datum/money_account/account as anything in accounts_to_modify)
				account.modify_payroll(num_input, TRUE, sanitized)
		if("delay_payroll")
			var/num_input = input(ui.user, "Amount", "Delay payroll by how many minutes?") as null|num
			if(isnull(num_input))
				return
			SSeconomy.next_paycheck_delay += num_input * (60 SECONDS)
		if("accelerate_payroll")
			var/num_input = input(ui.user, "Amount", "Accelerate payroll by how many minutes?") as null|num
			if(isnull(num_input))
				return
			SSeconomy.next_paycheck_delay -= num_input * (60 SECONDS)
		if("set_payroll")
			var/num_input = input(ui.user, "Amount", "Set payroll delay to how many minutes?") as null|num
			if(isnull(num_input))
				return
			SSeconomy.next_paycheck_delay = world.time + (num_input * 60 SECONDS)

