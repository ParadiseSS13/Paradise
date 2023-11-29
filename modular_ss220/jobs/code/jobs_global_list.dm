GLOBAL_LIST_INIT(medical_positions_ss220, list(
	"Intern",
))

GLOBAL_LIST_INIT(science_positions_ss220, list(
	"Student Scientist",
))

GLOBAL_LIST_INIT(engineering_positions_ss220, list(
	"Trainee Engineer",
))

GLOBAL_LIST_INIT(security_positions_ss220, list(
	"Security Cadet",
))

GLOBAL_LIST_INIT(jobs_positions_ss220, (list() + (
	medical_positions_ss220 + science_positions_ss220 + engineering_positions_ss220 + security_positions_ss220)))

/proc/get_alt_titles(list/positions)
	var/list/all_titles = list()
	for(var/rank in positions)
		var/datum/job/job = SSjobs.GetJob(rank)
		if(length(job.alt_titles))
			all_titles |= job.alt_titles
	return all_titles

/proc/get_all_medical_alt_titles_ss220()
	return get_alt_titles(GLOB.medical_positions_ss220)

/proc/get_all_security_alt_titles_ss220()
	return get_alt_titles(GLOB.security_positions_ss220)

/proc/get_all_engineering_alt_titles_ss220()
	return get_alt_titles(GLOB.engineering_positions_ss220)

/proc/get_all_science_alt_titles_ss220()
	return get_alt_titles(GLOB.science_positions_ss220)

/proc/get_all_alt_titles_ss220()
	return get_all_medical_alt_titles_ss220() + get_all_security_alt_titles_ss220() + get_all_engineering_alt_titles_ss220() + get_all_science_alt_titles_ss220()
