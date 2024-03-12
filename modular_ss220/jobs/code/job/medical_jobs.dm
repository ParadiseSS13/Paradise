/datum/job/doctor/intern
	title = "Medical Intern"
	flag = JOB_INTERN
	total_positions = 0
	spawn_positions = 3
	//selection_color = "#ebe2e3"
	alt_titles = list("Medical Assistant", "Student Medical Doctor")
	exp_map = list(EXP_TYPE_CREW = NOVICE_JOB_MINUTES)
	outfit = /datum/outfit/job/doctor/intern
	important_information = "Ваша должность ограничена во всех взаимодействиях с рабочим имуществом отдела и экипажем станции, при отсутствии приставленного к нему квалифицированного сотрудника или полученного разрешения от вышестоящего начальства."

/datum/outfit/job/doctor/intern
	name = "Medical Intern"
	jobtype = /datum/job/doctor/intern

	uniform = /obj/item/clothing/under/rank/medical/doctor/intern
	suit = /obj/item/clothing/suit/storage/labcoat
	mask = /obj/item/clothing/mask/surgical
	gloves = /obj/item/clothing/gloves/color/latex
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical/intern
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/o2
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/outfit/job/doctor/intern/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()

	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/medical/doctor/intern/skirt

	switch(H.mind.role_alt_title)
		if("Medical Assistant")
			uniform = /obj/item/clothing/under/rank/medical/doctor/intern/assistant
			if(H.gender == FEMALE)
				uniform = /obj/item/clothing/under/rank/medical/doctor/intern/assistant/skirt
		if("Student Medical Doctor")
			head = /obj/item/clothing/head/surgery/green/light
			uniform = /obj/item/clothing/under/rank/medical/scrubs/green/light

/datum/outfit/job/doctor/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/medical/doctor/skirt

/datum/job/cmo
	exp_map = list(EXP_TYPE_MEDICAL = (1200 + NOVICE_JOB_MINUTES))

/datum/job/doctor
	exp_map = list(EXP_TYPE_MEDICAL = (300 + NOVICE_JOB_MINUTES))

/datum/job/coroner
	exp_map = list(EXP_TYPE_MEDICAL = (180 + NOVICE_JOB_MINUTES))

/datum/job/chemist
	exp_map = list(EXP_TYPE_MEDICAL = (300 + NOVICE_JOB_MINUTES))

/datum/job/geneticist
	exp_map = list(EXP_TYPE_MEDICAL = (300 + NOVICE_JOB_MINUTES))

/datum/job/virologist
	exp_map = list(EXP_TYPE_MEDICAL = (300 + NOVICE_JOB_MINUTES))

/datum/job/psychiatrist
	exp_map = list(EXP_TYPE_MEDICAL = NOVICE_JOB_MINUTES)

/datum/job/paramedic
	exp_map = list(EXP_TYPE_MEDICAL = (180 + NOVICE_JOB_MINUTES))

