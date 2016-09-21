/datum/job/prisoner
	title = "D-class Prisoner"
	flag = PRISONER
	department_flag = SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "security officers"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/prisoner
	access = list()
	minimal_access = list()
	prisonlist_job = 1

/datum/job/prisoner/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_or_collect(new /obj/item/clothing/under/color/orange(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/orange(H), slot_shoes)
	H.equip_or_collect(new /obj/item/weapon/storage/box/survival/prisoner(H), slot_r_hand)
	return 1
