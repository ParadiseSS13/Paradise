/datum/job/civilian
	title = "Civilian"
	flag = CIVILIAN
	department_flag = SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list("Tourist","Businessman","Trader","Assistant")
	outfit = /datum/outfit/job/assistant

/datum/job/civilian/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()

/datum/outfit/job/assistant
	name = "Civilian"
	jobtype = /datum/job/civilian
	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black

/datum/job/explorer
	title = "Gateway Explorer"
	flag = EXPLORER
	department_flag = SUPPORT
	total_positions = 0
	spawn_positions = 0
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_gateway)
	minimal_access = list(access_maint_tunnels, access_gateway)
	outfit = /datum/outfit/job/explorer

/datum/outfit/job/explorer
	name = "Explorer"
	jobtype = /datum/job/explorer
	uniform = /obj/item/clothing/under/rank/explorer
	shoes = /obj/item/clothing/shoes/workboots
	l_ear = /obj/item/device/radio/headset
	pda = /obj/item/device/pda
	backpack_contents = list()
	backpack = /obj/item/weapon/storage/backpack/industrial
	satchel = /obj/item/weapon/storage/backpack/satchel_eng
