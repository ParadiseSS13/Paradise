/datum/job/civilian
	title = "Civilian"
	flag = JOB_CIVILIAN
	department_flag = JOBCAT_SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list("Tourist","Businessman","Trader","Assistant")
	outfit = /datum/outfit/job/assistant

/datum/job/civilian/get_access()
	if(config.assistant_maint)
		return list(ACCESS_MAINT_TUNNELS)
	else
		return list()

/datum/outfit/job/assistant
	name = "Civilian"
	jobtype = /datum/job/civilian

	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black


/datum/job/explorer
	title = "Explorer"
	flag = JOB_EXPLORER
	department_flag = JOBCAT_SUPPORT
	total_positions = 0
	spawn_positions = 0
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_GATEWAY, ACCESS_EVA)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_GATEWAY, ACCESS_EVA)
	outfit = /datum/outfit/job/explorer
	hidden_from_job_prefs = TRUE

/datum/outfit/job/explorer
	// This outfit is never used, because there are no slots for this job.
	// To get it, you have to go to the HOP and ask for a transfer to it.
	name = "Explorer"
	jobtype = /datum/job/explorer
	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black
