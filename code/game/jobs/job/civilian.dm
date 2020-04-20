/datum/job/civilian
	title = "Civil"
	flag = JOB_CIVILIAN
	department_flag = JOBCAT_SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "el Jefe de Personal"
	department_head = list("Jefe de Personal")
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list("Turista","Businessman","Trader","Asistente")
	outfit = /datum/outfit/job/assistant

/datum/job/civilian/get_access()
	if(config.assistant_maint)
		return list(ACCESS_MAINT_TUNNELS)
	else
		return list()

/datum/outfit/job/assistant
	name = "Civil"
	jobtype = /datum/job/civilian

	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black


