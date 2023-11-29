/datum/nttc_configuration/New()
	. = ..()
	var/list/job_radio_dict = list()
	for(var/i in (GLOB.medical_positions_ss220 + get_all_medical_alt_titles_ss220()))
		job_radio_dict.Add(list("[i]" = "medradio"))
	for(var/i in (GLOB.security_positions_ss220 + get_all_security_alt_titles_ss220()))
		job_radio_dict.Add(list("[i]" = "secradio"))
	for(var/i in (GLOB.engineering_positions_ss220 + get_all_engineering_alt_titles_ss220()))
		job_radio_dict.Add(list("[i]" = "engradio"))
	for(var/i in (GLOB.science_positions_ss220 + get_all_science_alt_titles_ss220()))
		job_radio_dict.Add(list("[i]" = "scirradio"))

	all_jobs |= job_radio_dict


// =======================================
// relate jobs for relate job slots
// =======================================
/datum/job/proc/try_relate_jobs()
	return FALSE

/datum/job
	var/relate_job // for novice role and etc

/datum/job/doctor
	relate_job = "Intern"
/datum/job/doctor/intern
	relate_job = "Medical Doctor"

/datum/job/scientist
	relate_job = "Student Scientist"
/datum/job/scientist/student
	relate_job = "Scientist"

/datum/job/engineer
	relate_job = "Trainee Engineer"
/datum/job/engineer/trainee
	relate_job = "Station Engineer"

/datum/job/officer
	relate_job = "Security Cadet"
/datum/job/officer/cadet
	relate_job = "Security Officer"

/datum/job/is_position_available()
	if(job_banned_gamemode)
		return FALSE

	if(check_hidden_from_job_prefs())
		return FALSE

	return relate_job ? check_relate_positions() : ..()

/datum/job/proc/check_relate_positions()
	var/datum/job/temp = SSjobs.GetJob(relate_job)

	var/current_count_positions = current_positions + temp.current_positions
	var/total_count_positions = total_positions + temp.total_positions

	if(total_positions == -1)
		total_count_positions = -1

	return (current_count_positions < total_count_positions) || (total_count_positions == -1)

/datum/job/proc/check_hidden_from_job_prefs()
	if(hidden_from_job_prefs)
		for(var/job_title in GLOB.jobs_positions_ss220)
			if(job_title in alt_titles)
				return TRUE
		if(title in GLOB.jobs_positions_ss220)
			return TRUE
	return FALSE

// OFFICIAL parameters: 17 / HOS, Bart / 400 / 700
/datum/character_save/SetChoices(mob/user, limit = 18, list/splitJobs = list("Head of Security", "Bartender"), widthPerColumn = 450, height = 700)
	. = ..()
