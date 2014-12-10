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
	alt_titles = list("Tourist","Businessman","Trader")

/datum/job/civilian/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_or_collect(new /obj/item/clothing/under/color/random(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	if(H.backbag == 1)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	return 1

/datum/job/civilian/get_access()
	return list()
