// =======================================
// relate jobs for relate job slots
// =======================================
/datum/job/proc/try_relate_jobs()
	return FALSE

/datum/job
	var/relate_job // for relate positions and landmark
	var/is_extra_job = FALSE // Special Jobs Window
	var/is_main_job = TRUE // Are we the main job for this relate?
	var/shares_slots_with_relate = FALSE

/datum/job/doctor
	relate_job = "Medical Intern"
	shares_slots_with_relate = TRUE

/datum/job/doctor/intern
	relate_job = "Medical Doctor"
	is_main_job = FALSE

/datum/job/scientist
	relate_job = "Student Scientist"
	shares_slots_with_relate = TRUE

/datum/job/scientist/student
	relate_job = "Scientist"
	is_main_job = FALSE

/datum/job/engineer
	relate_job = "Trainee Engineer"
	shares_slots_with_relate = TRUE

/datum/job/engineer/trainee
	relate_job = "Station Engineer"
	is_main_job = FALSE

/datum/job/officer
	relate_job = "Security Cadet"
	shares_slots_with_relate = TRUE

/datum/job/officer/cadet
	relate_job = "Security Officer"
	is_main_job = FALSE

// ==============================
// PROCS
// ==============================

/datum/job/is_position_available()
	if(job_banned_gamemode)
		return FALSE
	if(check_hidden_from_job_prefs())
		return FALSE
	if(relate_job && shares_slots_with_relate)
		return check_relate_total_positions()

	return ..()

/datum/job/is_spawn_position_available()
	if(job_banned_gamemode)
		return FALSE
	if(check_hidden_from_job_prefs())
		return FALSE
	if(relate_job && shares_slots_with_relate)
		return check_relate_spawn_positions()

	return ..()

/datum/job/proc/check_relate_total_positions()
	var/datum/job/temp = SSjobs.GetJob(relate_job)
	if(!temp)
		return FALSE
	var/combined_current_positions = current_positions + temp.current_positions
	var/maximum_total_positions = is_main_job ? total_positions : temp.total_positions

	if(total_positions == -1)
		if(is_main_job) // Infinite jobs (inf. SecOffs)
			return TRUE
		if(!is_main_job) // Infinite subjobs...
			if(temp.total_positions == -1) // ... AND jobs? We ball (inf. Cadets AND inf. SecOffs)
				return TRUE
			return combined_current_positions < maximum_total_positions // ... WITHIN relate job (any number of Cadets within SecOffs)

	if(!is_main_job && (current_positions >= total_positions)) // SubJobs care about their own limits (limited number of Cadets within SecOffs)
		return FALSE

	return combined_current_positions < maximum_total_positions

/datum/job/proc/check_relate_spawn_positions()
	var/datum/job/temp = SSjobs.GetJob(relate_job)
	if(!temp)
		return FALSE
	var/combined_current_positions = current_positions + temp.current_positions
	var/maximum_spawn_positions = is_main_job ? spawn_positions : temp.spawn_positions

	if(spawn_positions == -1)
		if(is_main_job) // Infinite jobs (inf. SecOffs)
			return TRUE
		if(!is_main_job) // Infinite subjobs...
			if(temp.spawn_positions == -1) // ... AND jobs? We ball (inf. Cadets AND inf. SecOffs)
				return TRUE
			return combined_current_positions < maximum_spawn_positions // ... WITHIN relate job (any number of Cadets within SecOffs)

	if(!is_main_job && (current_positions >= spawn_positions)) // SubJobs care about their own limits (limited number of Cadets within SecOffs)
		return FALSE

	return combined_current_positions < maximum_spawn_positions

/datum/job/proc/check_hidden_from_job_prefs()
	if(hidden_from_job_prefs)
		for(var/job_title in GLOB.all_jobs_ss220)
			if(job_title in alt_titles)
				return TRUE
		if(title in GLOB.all_jobs_ss220)
			return TRUE
	return FALSE
