/datum/nttc_configuration/New()
	. = ..()
	var/list/job_radio_dict = list()

	for(var/i in get_all_medical_novice_titles())
		job_radio_dict.Add(list("[i]" = "medradio"))
	for(var/i in get_all_security_novice_titles())
		job_radio_dict.Add(list("[i]" = "secradio"))
	for(var/i in get_all_engineering_novice_titles())
		job_radio_dict.Add(list("[i]" = "engradio"))
	for(var/i in get_all_science_novice_titles())
		job_radio_dict.Add(list("[i]" = "scirradio"))

	all_jobs |= job_radio_dict

/datum/job/is_position_available()
	. = ..()

	if(hidden_from_job_prefs)
		for(var/job_title in GLOB.Jobs_titles_SS220)
			if(job_title in alt_titles)
				return FALSE
		if(title in GLOB.Jobs_titles_SS220)
			return FALSE
