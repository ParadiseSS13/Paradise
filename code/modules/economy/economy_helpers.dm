/mob/proc/get_worn_id_account()
	if(!ishuman(src))
		return
	var/mob/living/carbon/human/H = src
	var/obj/item/card/id/I = H.get_idcard()
	if(!istype(I))
		return null
	var/datum/money_account/D = GLOB.station_money_database.find_user_account(I.associated_account_number)
	return D

/datum/mind/proc/set_initial_account(datum/money_account/account) //needed for GC'ing
	initial_account = account
	RegisterSignal(initial_account, COMSIG_PARENT_QDELETING, PROC_REF(clear_initial_account))

/datum/mind/proc/clear_initial_account() //needed for GC'ing
	UnregisterSignal(initial_account, COMSIG_PARENT_QDELETING)
	initial_account = null


///matches a string job name to their department(s) and returns it as a list
/proc/get_departments_from_job(job_name)
	if(!job_name)
		return
	var/list/found_departments = list()
	for(var/datum/station_department/department as anything in SSjobs.station_departments)
		for(var/job in department.department_roles)
			if(job == job_name)
				found_departments += department
	return found_departments

/proc/get_department_from_name(name)
	for(var/datum/station_department/department in SSjobs.station_departments)
		if(department.department_name == name)
			return department
