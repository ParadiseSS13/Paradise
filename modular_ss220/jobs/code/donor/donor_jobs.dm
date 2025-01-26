/datum/job/donor
	title = "Donor" // он тут быть не должен. Но если педали вдруг выдадут, то пускай хотя бы так
	flag = 0
	total_positions = -1
	spawn_positions = -1
	department_flag = JOBCAT_SUPPORT
	job_department_flags = DEP_FLAG_SERVICE
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#fbd5ff"
	access = list(ACCESS_MAINT_TUNNELS)
	alt_titles = null
	outfit = /datum/outfit/job/donor
	hidden_from_job_prefs = TRUE
	is_extra_job = TRUE
	var/ru_title
	var/donator_tier = 999 // I'm unreachable!

/datum/outfit/job/donor
	name = "Donor"
	jobtype = /datum/job/donor

	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black
	pda = /obj/item/pda
	id = /obj/item/card/id/assistant


// ====================================
/datum/job/donor/proc/get_all_titles()
	var/list/all_alt_titles = list()
	if(alt_titles)
		all_alt_titles.Add(title)
		if(ru_title)
			all_alt_titles.Add(ru_title)
		all_alt_titles |= alt_titles
	return all_alt_titles

// Проверка после начала раунда
/mob/new_player/IsJobAvailable(rank)
	if(rank in GLOB.jobs_excluded_from_selection)
		return FALSE
	if(rank in GLOB.all_donor_jobs)
		var/datum/job/job = SSjobs.GetJob(rank)
		if(!job)
			return FALSE
		if(!job.is_donor_allowed(client))
			return FALSE
	. = ..()

/datum/job/proc/is_donor_allowed(client/C)
	return TRUE

/datum/job/donor/is_donor_allowed(client/C)
	if(!C)
		return FALSE // No client
	return C.is_donor_allowed(donator_tier)
