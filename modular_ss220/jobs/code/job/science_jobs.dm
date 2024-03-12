/datum/job/scientist/student
	title = "Student Scientist"
	flag = JOB_STUDENT
	total_positions = 0
	spawn_positions = 4
	//selection_color = "#ece5ec"
	alt_titles = list("Scientist Assistant", "Scientist Pregraduate", "Scientist Graduate", "Scientist Postgraduate")
	exp_map = list(EXP_TYPE_CREW = NOVICE_JOB_MINUTES)
	outfit = /datum/outfit/job/scientist/student
	important_information = "Ваша должность ограничена во всех взаимодействиях с рабочим имуществом отдела и экипажем станции, при отсутствии приставленного к нему квалифицированного сотрудника или полученного разрешения от вышестоящего начальства."

/datum/outfit/job/scientist/student
	name = "Student Scientist"
	jobtype = /datum/job/scientist/student

	uniform = /obj/item/clothing/under/rank/rnd/scientist/student
	suit = /obj/item/clothing/suit/storage/labcoat/science
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/research/student
	pda = /obj/item/pda/toxins

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science

/datum/outfit/job/scientist/student/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()

	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/rnd/scientist/student/skirt

	switch(H.mind.role_alt_title)
		if("Scientist Assistant")
			uniform = /obj/item/clothing/under/rank/rnd/scientist/student/assistant
			if(H.gender == FEMALE)
				uniform = /obj/item/clothing/under/rank/rnd/scientist/student/assistant/skirt

/datum/outfit/job/scientist/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/rnd/scientist/skirt

/datum/job/rd
	exp_map = list(EXP_TYPE_SCIENCE = (1200 + NOVICE_JOB_MINUTES))

/datum/job/scientist
	exp_map = list(EXP_TYPE_SCIENCE = (300 + NOVICE_JOB_MINUTES))

/datum/job/roboticist
	exp_map = list(EXP_TYPE_SCIENCE = (300 + NOVICE_JOB_MINUTES))

