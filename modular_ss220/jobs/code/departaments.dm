/datum/station_department/engineering/New()
	. = ..()
	department_roles |= GLOB.engineering_positions_ss220 + get_all_engineering_alt_titles_ss220()

/datum/station_department/medical/New()
	. = ..()
	department_roles |= GLOB.medical_positions_ss220 + get_all_medical_alt_titles_ss220()

/datum/station_department/science/New()
	. = ..()
	department_roles |= GLOB.science_positions_ss220 + get_all_science_alt_titles_ss220()

/datum/station_department/security/New()
	. = ..()
	department_roles |= GLOB.security_positions_ss220 + get_all_security_alt_titles_ss220()
