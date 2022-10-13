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
	var/static/list/department_jobs = list(
		"Engineering" = GLOB.engineering_positions,
		"Medical" = GLOB.medical_positions,
		"Science" = GLOB.science_positions,
		"Supply" = GLOB.supply_positions,
		"Service" = GLOB.service_positions,
		"Security" = GLOB.security_positions,
		"Assistant" = GLOB.assistant_positions,
		"Silicon" = GLOB.nonhuman_positions,
		"Command" = GLOB.command_positions, //command being last is important for economy stuff (see subsystem/jobs.dm)
	)
	var/list/found_departments = list()
	for(var/department in department_jobs)
		for(var/job in department_jobs[department])
			if(job == job_name)
				found_departments += department
	return found_departments

