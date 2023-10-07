/datum/job/officer/New()
	. = ..()
	alt_titles = get_all_security_novice_tittles() // =, а не |=, т.к. отсутствуют альт. названия

/datum/station_department/security/New()
	. = ..()
	department_roles |= get_all_security_novice_tittles()

/datum/outfit/job/officer/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		if(H.mind.role_alt_title in get_all_security_novice_tittles())
			uniform = /obj/item/clothing/under/rank/security/cadet
			if(H.gender == FEMALE)
				uniform = /obj/item/clothing/under/rank/security/cadet/skirt
			head = /obj/item/clothing/head/soft/sec
			id = /obj/item/card/id/security/cadet
			l_pocket = /obj/item/reagent_containers/spray/pepper
			//box = /obj/item/storage/box/survival_security/cadet
		switch(H.mind.role_alt_title)
			if("Security Assistant")
				uniform = /obj/item/clothing/under/rank/security/cadet/assistant
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/security/cadet/assistant/skirt
			if("Security Graduate")
				head = /obj/item/clothing/head/beret/sec
