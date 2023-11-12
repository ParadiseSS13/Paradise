/datum/nttc_configuration/New()
	. = ..()
	var/list/job_radio_dict = list()

	for(var/i in get_all_medical_novice_tittles())
		job_radio_dict.Add(list("[i]" = "medradio"))
	for(var/i in get_all_security_novice_tittles())
		job_radio_dict.Add(list("[i]" = "secradio"))
	for(var/i in get_all_engineering_novice_tittles())
		job_radio_dict.Add(list("[i]" = "engradio"))
	for(var/i in get_all_science_novice_tittles())
		job_radio_dict.Add(list("[i]" = "scirradio"))

	all_jobs |= job_radio_dict

/obj/machinery/computer/card/ui_data(mob/user)
	var/list/data = ..()

	switch(mode)
		if(IDCOMPUTER_SCREEN_TRANSFER) // JOB TRANSFER
			if(modify)
				if(!scan)
					return data

				if(!target_dept)
					data["jobs_engineering"] |= "Trainee Engineer"
					data["jobs_medical"] 	|= "Intern"
					data["jobs_science"] 	|= "Student Scientist"
					data["jobs_security"] 	|= "Security Cadet"

	return data
