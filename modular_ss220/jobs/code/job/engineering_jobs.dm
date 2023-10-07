/datum/job/engineer/New()
	. = ..()
	alt_titles |= get_all_engineering_novice_tittles()

/datum/station_department/engineering/New()
	. = ..()
	department_roles |= get_all_engineering_novice_tittles()

/datum/outfit/job/engineer/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		if(H.mind.role_alt_title in get_all_engineering_novice_tittles())
			uniform = /obj/item/clothing/under/rank/engineer/trainee
			if(H.gender == FEMALE)
				uniform = /obj/item/clothing/under/rank/engineer/trainee/skirt
			id = /obj/item/card/id/engineering/trainee
			gloves = /obj/item/clothing/gloves/color/orange

		switch(H.mind.role_alt_title)
			if("Engineer Assistant")
				uniform = /obj/item/clothing/under/rank/engineer/trainee/assistant
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/engineer/trainee/assistant/skirt
			if("Technical Assistant")
				uniform = /obj/item/clothing/under/rank/engineer/trainee/assistant
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/engineer/trainee/assistant/skirt
				head = /obj/item/clothing/head/soft/orange
			if("Technical Student", "Technical Trainee")
				head = /obj/item/clothing/head/soft/orange
			if("Engineer Student")
				head = /obj/item/clothing/head/beret/eng
