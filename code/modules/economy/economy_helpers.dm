/mob/proc/get_worn_id_account()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/card/id/I = H.get_idcard()
		if(!istype(I))
			return null
		var/datum/money_account/D = GLOB.station_money_database.find_user_account(I.associated_account_number)
		return D

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
