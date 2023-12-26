/datum/job/officer/cadet
	title = "Security Cadet"
	flag = JOB_CADET
	total_positions = 0	// miss add slots
	spawn_positions = 2
	//selection_color = "#efe6e6"
	alt_titles = list("Security Assistant", "Security Graduate")
	exp_map = list(EXP_TYPE_CREW = NOVICE_CADET_JOB_MINUTES)
	outfit = /datum/outfit/job/officer/cadet
	important_information = "Космический закон это необходимость, а не рекомендация. Ваша должность ограничена во всех взаимодействиях с рабочим имуществом отдела и экипажем станции, при отсутствии приставленного к нему квалифицированного сотрудника или полученного разрешения от вышестоящего начальства."

/datum/outfit/job/officer/cadet
	name = "Security Cadet"
	jobtype = /datum/job/officer/cadet
	uniform = /obj/item/clothing/under/rank/security/officer/cadet
	suit = /obj/item/clothing/suit/armor/vest/security
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/soft/sec
	l_ear = /obj/item/radio/headset/headset_sec/alt
	id = /obj/item/card/id/security/cadet
	l_pocket = /obj/item/reagent_containers/spray/pepper
	suit_store = /obj/item/gun/energy/disabler
	pda = /obj/item/pda/security
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1
	)
	//box = /obj/item/storage/box/survival_security/cadet


/datum/outfit/job/officer/cadet/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()

	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/security/officer/cadet/skirt

	switch(H.mind.role_alt_title)
		if("Security Assistant")
			uniform = /obj/item/clothing/under/rank/security/officer/cadet/assistant
			if(H.gender == FEMALE)
				uniform = /obj/item/clothing/under/rank/security/officer/cadet/assistant/skirt
		if("Security Graduate")
			head = /obj/item/clothing/head/beret/sec

/datum/job/officer
	alt_titles = list("Security Trainer", "Junior Security Officer")

/datum/outfit/job/officer/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/security/officer/skirt

/datum/job/officer
	exp_map = list(EXP_TYPE_SECURITY = (600 + NOVICE_CADET_JOB_MINUTES))

/datum/job/detective
	exp_map = list(EXP_TYPE_SECURITY = (900 + NOVICE_CADET_JOB_MINUTES))

/datum/job/warden
	exp_map = list(EXP_TYPE_SECURITY = (900 + NOVICE_CADET_JOB_MINUTES))

/datum/job/hos
	exp_map = list(EXP_TYPE_SECURITY = (1200 + NOVICE_CADET_JOB_MINUTES))
