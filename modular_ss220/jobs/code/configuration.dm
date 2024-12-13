/datum/configuration_section/job_configuration_restriction
	var/list/blacklist_species = list()
	var/enable_black_list = FALSE

/datum/server_configuration
	var/datum/configuration_section/job_configuration_restriction/jobs_restrict

/datum/configuration_section/job_configuration_restriction/load_data(list/data)
	CONFIG_LOAD_BOOL(enable_black_list, data["allow_to_ban_job_for_species"])
	CONFIG_LOAD_LIST(blacklist_species, data["job_species_blacklist"])

/datum/configuration_section/job_configuration_restriction/proc/sanitize_job_checks()
	if(!SSjobs || !GLOB.all_species)
		CRASH("Can't check job_configuration_restriction without SSjobs and GLOB.all_species")

	for(var/job_info in blacklist_species)
		job_exist_in_config(job_info["name"])
		for(var/race_info in job_info["species_blacklist"])
			race_exist_in_config(race_info, job_info["name"])

/datum/configuration_section/job_configuration_restriction/proc/job_exist_in_config(job_name)
	if(job_name in SSjobs.name_occupations)
		return TRUE
	CRASH("Job [job_name] mentioned in job_configuration_restriction not found in SSjobs.name_occupations")

/datum/configuration_section/job_configuration_restriction/proc/race_exist_in_config(race_name, job_name)
	if(race_name in GLOB.all_species)
		return TRUE
	CRASH("Race [race_name] mentioned in config of job_configuration_restriction for job [job_name] not found in global var of all species GLOB.all_species")

/datum/server_configuration/load_all_sections()
	. = ..()
	jobs_restrict = new()
	safe_load(jobs_restrict, "job_configuration_restriction")
