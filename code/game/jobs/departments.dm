/datum/station_department
	var/department_name = "unnamed department"

	///The amount this departments will get endowed with a roundstart in their money account
	var/account_starting_balance = DEPARTMENT_BALANCE_MEDIUM
	///The amount this department will be payed every payday at a minimum (unless deducted otherwise)
	var/account_base_pay = DEPARTMENT_BASE_PAY_MEDIUM
	///The access need to get into this department account
	var/account_access = list()
	///The money account tied to this department
	var/datum/money_account/department_account

	///The occupation name of the person in charge of this department officially
	var/head_of_staff
	///A list of occupation names in this department
	var/department_roles = list()

/datum/station_department/command
	department_name = DEPARTMENT_COMMAND

	account_starting_balance = DEPARTMENT_BALANCE_LOW
	account_base_pay = DEPARTMENT_BASE_PAY_LOW
	account_access = list(ACCESS_CAPTAIN)
	department_roles = list(
		"Captain",
		"Head of Personnel",
		"Head of Security",
		"Chief Engineer",
		"Research Director",
		"Chief Medical Officer",
		"Nanotrasen Representative"
	)
	head_of_staff = "Captain"

/datum/station_department/security
	department_name = DEPARTMENT_SECURITY

	account_starting_balance = DEPARTMENT_BALANCE_HIGH
	account_base_pay = DEPARTMENT_BASE_PAY_HIGH
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
		"Geneticist",	//Part of both medical and science
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
		"Quartermaster",
		"Cargo Technician",
		"Shaft Miner",
		"Internal Affairs Agent",
		"Chaplain",
		"Clown",
		"Mime",
		"Barber",
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
	account_access = list(ACCESS_HOP)
	department_roles = list(
		"Head of Personnel",
		"Quartermaster",
		"Cargo Technician",
		"Shaft Miner"
	)
	head_of_staff = "Head of Personnel"

/datum/station_department/engineering
	department_name = DEPARTMENT_ENGINEERING

	account_starting_balance = DEPARTMENT_BALANCE_LOW
	account_base_pay = DEPARTMENT_BASE_PAY_MEDIUM
	account_access = list(ACCESS_CE)
	department_roles = list(
		"Chief Engineer",
		"Station Engineer",
		"Life Support Specialist",
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
		"Geneticist",
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
	account_access = list(ACCESS_HEADS)
	department_roles = list("Assistant")
	head_of_staff = "None"
