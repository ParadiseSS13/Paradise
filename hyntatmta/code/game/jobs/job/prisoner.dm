/datum/job/prisoner
	title = "D-Class Prisoner"
	flag = PRISONER
	department_flag = SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "security officers"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	prisonlist_job = 1
	outfit = /datum/outfit/job/prisoner

/datum/outfit/job/prisoner
	name = "D-Class"
	jobtype = /datum/job/prisoner

	uniform = /obj/item/clothing/under/color/orange
	shoes = /obj/item/clothing/shoes/orange
	r_hand = /obj/item/weapon/storage/box/survival/prisoner
