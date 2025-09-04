/datum/station_department
	///name of department, used to determine department money account names as well
	var/department_name = "unnamed department"

	///The amount this departments will get endowed with a roundstart in their money account
	var/account_starting_balance = DEPARTMENT_BALANCE_MEDIUM
	///The amount this department will be payed every payday at a minimum (unless deducted otherwise)
	var/account_base_pay = DEPARTMENT_BASE_PAY_MEDIUM
	///The access need to get into this department account, this is a one req access list, used especialy for supply computer
	var/account_access = list()
	///The money account tied to this department
	var/datum/money_account/department_account
	///Will this department's account auto approve crates?
	var/crate_auto_approve = FALSE
	///If there is auto approval, is it capped?
	var/auto_approval_cap = 0

	///The occupation name of the person in charge of this department officially
	var/head_of_staff
	///A list of occupation names in this department
	var/department_roles = list()

	var/list/members = list()

/datum/department_member
	///Name of the department member
	var/name
	///Occupation of the department member
	var/role
	///Can this department member approve crates for the department?
	var/can_approve_crates = FALSE
	///This department members money account
	var/datum/money_account/member_account


/datum/department_member/proc/set_member_account(datum/money_account/account)
	member_account = account
	RegisterSignal(account, COMSIG_PARENT_QDELETING, PROC_REF(clear_member_account))

/datum/department_member/proc/clear_member_account(datum/money_account/account)
	UnregisterSignal(account, COMSIG_PARENT_QDELETING)
	member_account = null

/datum/station_department/can_vv_delete()
	message_admins("An admin attempted to VV delete a station_department datum, please stop doing this it will break cargo")
	return FALSE

///checks to see if the crew members has the right access or is whitelisted on the department account
/datum/station_department/proc/has_account_access(list/access, datum/money_account/account)
	if(!length(account_access))
		return TRUE
	if(has_access(list(), account_access, access))
		return TRUE
	if(!account)
		return FALSE
	for(var/datum/department_member/member as anything in members)
		if(member.can_approve_crates && member.member_account == account)
			return TRUE
	return FALSE

/datum/station_department/command
	department_name = DEPARTMENT_COMMAND

	account_starting_balance = DEPARTMENT_BALANCE_LOW
	account_base_pay = DEPARTMENT_BASE_PAY_LOW
	account_access = list(ACCESS_CAPTAIN, ACCESS_HOP)
	department_roles = list(
		"Captain",
		"Head of Personnel",
		"Head of Security",
		"Chief Engineer",
		"Research Director",
		"Chief Medical Officer",
		"Nanotrasen Representative",
		"Quartermaster"
	)
	head_of_staff = "Captain"

/datum/station_department/security
	department_name = DEPARTMENT_SECURITY

	account_starting_balance = DEPARTMENT_BALANCE_HIGH
	account_access = list(ACCESS_HOS)
	department_roles = list(
		"Head of Security",
		"Warden",
		"Detective",
		"Security Officer",
		"Magistrate"
	)
	head_of_staff = "Head of Security"

/datum/station_department/science
	department_name = DEPARTMENT_SCIENCE

	account_starting_balance = DEPARTMENT_BALANCE_LOW
	account_base_pay = DEPARTMENT_BASE_PAY_LOW
	account_access = list(ACCESS_RD)
	department_roles = list(
		"Research Director",
		"Scientist",
		"Xenobiologist",
		"Xenoarcheologist",
		"Anomalist",
		"Plasma Researcher",
		"Chemical Researcher",
		"Geneticist",
		"Roboticist",
	)
	head_of_staff = "Research Director"

/datum/station_department/service
	department_name = DEPARTMENT_SERVICE

	account_starting_balance = DEPARTMENT_BALANCE_LOW
	account_base_pay = DEPARTMENT_BASE_PAY_LOW
	account_access = list(ACCESS_HOP)
	department_roles = list(
		"Head of Personnel",
		"Bartender",
		"Botanist",
		"Chef",
		"Janitor",
		"Librarian",
		"Internal Affairs Agent",
		"Chaplain",
		"Clown",
		"Mime",
		"Magistrate",
		"Nanotrasen Representative",
		"Blueshield",
		"Explorer"
	)
	head_of_staff = "Head of Personnel"

/datum/station_department/supply
	department_name = DEPARTMENT_SUPPLY

	account_starting_balance = DEPARTMENT_BALANCE_LOW
	account_base_pay = DEPARTMENT_BASE_PAY_LOW
	account_access = list(ACCESS_QM, ACCESS_CARGO) //Supply account is a lot less "secure", CT's need to access it aswell on the supply comp
	department_roles = list(
		"Quartermaster",
		"Cargo Technician",
		"Smith",
		"Shaft Miner",
		"Spelunker"
	)
	head_of_staff = "Quartermaster"

/datum/station_department/engineering
	department_name = DEPARTMENT_ENGINEERING

	account_starting_balance = DEPARTMENT_BALANCE_LOW
	account_access = list(ACCESS_CE)
	department_roles = list(
		"Chief Engineer",
		"Station Engineer",
		"Life Support Specialist",
		"Atmospheric Technician",
		"Maintenance Technician",
		"Engine Technician",
		"Electrician",
	)
	head_of_staff = "Chief Engineer"

/datum/station_department/medical
	department_name = DEPARTMENT_MEDICAL

	account_starting_balance = DEPARTMENT_BALANCE_LOW
	account_base_pay = DEPARTMENT_BASE_PAY_LOW
	account_access = list(ACCESS_CMO)
	department_roles = list(
		"Chief Medical Officer",
		"Medical Doctor",
		"Surgeon",
		"Nurse",
		"Psychiatrist",
		"Chemist",
		"Virologist",
		"Paramedic",
		"Coroner"
	)
	head_of_staff = "Chief Medical Officer"

/datum/station_department/assistant
	department_name = DEPARTMENT_ASSISTANT

	//assistant department gets nothings basically, mostly just an account for HOP/Captain to
	//use at their own discretion for any civilian activies (grant system maybe?)
	account_starting_balance = DEPARTMENT_BALANCE_REALLY_LOW
	account_base_pay = DEPARTMENT_BASE_PAY_NONE
	account_access = list(ACCESS_HEADS) //HoS is listed as HOP, but any head can approve
	department_roles = list("Assistant")
	head_of_staff = "Head of Personnel"
