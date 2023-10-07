/datum/job/doctor/New()
	. = ..()
	alt_titles |= get_all_medical_novice_tittles()

/datum/station_department/medical/New()
	. = ..()
	department_roles |= get_all_medical_novice_tittles()

/datum/outfit/job/doctor/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		if(H.mind.role_alt_title in get_all_medical_novice_tittles())
			uniform = /obj/item/clothing/under/rank/medical/intern
			if(H.gender == FEMALE)
				uniform = /obj/item/clothing/under/rank/medical/intern/skirt
			id = /obj/item/card/id/medical/intern
			l_hand = /obj/item/storage/firstaid/o2
			mask = /obj/item/clothing/mask/surgical
			gloves = /obj/item/clothing/gloves/color/latex

		switch(H.mind.role_alt_title)
			if("Intern")
				uniform = /obj/item/clothing/under/rank/medical/intern
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/medical/intern/skirt
			if("Medical Assistant")
				uniform = /obj/item/clothing/under/rank/medical/intern/assistant
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/medical/intern/assistant/skirt
			if("Student Medical Doctor")
				head = /obj/item/clothing/head/surgery/green/light
				uniform = /obj/item/clothing/under/rank/medical/scrubs/green/light
