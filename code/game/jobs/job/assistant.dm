/datum/job/assistant
	title = "Assistant"
	flag = JOB_ASSISTANT
	department_flag = JOBCAT_SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	outfit = /datum/outfit/job/assistant

/datum/job/assistant/get_access()
	if(GLOB.configuration.jobs.assistant_maint_access)
		return list(ACCESS_MAINT_TUNNELS)
	else
		return list()

/datum/outfit/job/assistant
	name = "Assistant"
	jobtype = /datum/job/assistant

	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black
	id = /obj/item/card/id/assistant


