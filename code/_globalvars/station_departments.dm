
/datum/station_department
	var/department_name = "unnamed department"

	var/account_starting_balance = DEPARTMENT_BALANCE_MEDIUM
	var/account_base_pay = DEPARTMENT_BASE_PAY_MEDIUM
	var/account_access = list()

	var/head_of_staff
	var/department_roles = list()

/datum/station_department/command
	department_name = DEPARTMENT_COMMAND

	account_starting_balance = DEPARTMENT_BALANCE_LOW
	account_base_pay = DEPARTMENT_BASE_PAY_LOW
	account_access = list(ACCESS_CAPTAIN)

	head_of_staff = "captain"
