/datum/station_department/engineering/New()
	. = ..()
	department_roles |= get_all_engineering_titles_ss220()

/datum/station_department/medical/New()
	. = ..()
	department_roles |= get_all_medical_titles_ss220()

/datum/station_department/science/New()
	. = ..()
	department_roles |= get_all_science_titles_ss220()

/datum/station_department/security/New()
	. = ..()
	department_roles |= get_all_security_titles_ss220()

/datum/station_department/service/New()
	. = ..()
	department_roles |= get_all_service_titles_ss220()

/datum/station_department/supply/New()
	. = ..()
	department_roles |= get_all_supply_titles_ss220()

/datum/station_department/assistant/New()
	. = ..()
	department_roles |= get_all_assistant_titles_ss220()

/datum/nttc_configuration/New()
	. = ..()
	var/list/job_radio_dict = list()
	for(var/i in get_all_medical_titles_ss220())
		job_radio_dict.Add(list("[i]" = "medradio"))
	for(var/i in get_all_security_titles_ss220())
		job_radio_dict.Add(list("[i]" = "secradio"))
	for(var/i in get_all_engineering_titles_ss220())
		job_radio_dict.Add(list("[i]" = "engradio"))
	for(var/i in get_all_science_titles_ss220())
		job_radio_dict.Add(list("[i]" = "scirradio"))
	for(var/i in (get_all_service_titles_ss220() + get_all_supply_titles_ss220()))
		job_radio_dict.Add(list("[i]" = "srvradio"))
	for(var/i in get_all_assistant_titles_ss220())
		job_radio_dict.Add(list("[i]" = "radio"))

	all_jobs |= job_radio_dict

