/datum/job/scientist/New()
	. = ..()
	alt_titles |= get_all_science_novice_tittles()

/datum/station_department/science/New()
	. = ..()
	department_roles |= get_all_science_novice_tittles()

/datum/outfit/job/scientist/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		if(H.mind.role_alt_title in get_all_science_novice_tittles())
			uniform = /obj/item/clothing/under/rank/scientist/student
			if(H.gender == FEMALE)
				uniform = /obj/item/clothing/under/rank/scientist/student/skirt
			id = /obj/item/card/id/research/student

		switch(H.mind.role_alt_title)
			if("Scientist Assistant")
				uniform = /obj/item/clothing/under/rank/scientist/student/assistant
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/scientist/student/assistant/skirt
