/datum/job/engineer/trainee
	title = "Trainee Engineer"
	flag = JOB_TRAINEE
	total_positions = 0
	spawn_positions = 3
	//selection_color = "#dbd6c4"
	alt_titles = list("Engineer Assistant", "Technical Assistant", "Engineer Student", "Technical Student", "Technical Trainee")
	exp_map = list(EXP_TYPE_CREW = NOVICE_JOB_MINUTES)
	outfit = /datum/outfit/job/engineer/trainee
	important_information = "Ваша должность ограничена во всех взаимодействиях с рабочим имуществом отдела и экипажем станции, при отсутствии приставленного к нему квалифицированного сотрудника или полученного разрешения от вышестоящего начальства."

/datum/outfit/job/engineer/trainee
	name = "Trainee Engineer"
	jobtype = /datum/job/engineer/trainee

	uniform = /obj/item/clothing/under/rank/engineering/engineer/trainee
	suit = /obj/item/clothing/suit/storage/hazardvest
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/orange
	head = /obj/item/clothing/head/hardhat/orange
	l_ear = /obj/item/radio/headset/headset_eng
	id = /obj/item/card/id/engineering/trainee
	l_pocket = /obj/item/t_scanner
	pda = /obj/item/pda/engineering

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/engineering
	box = /obj/item/storage/box/engineer

/datum/outfit/job/engineer/trainee/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()

	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/engineering/engineer/trainee/skirt

	switch(H.mind.role_alt_title)
		if("Engineer Assistant")
			uniform = /obj/item/clothing/under/rank/engineering/engineer/trainee/assistant
			if(H.gender == FEMALE)
				uniform = /obj/item/clothing/under/rank/engineering/engineer/trainee/assistant/skirt
		if("Technical Assistant")
			uniform = /obj/item/clothing/under/rank/engineering/engineer/trainee/assistant
			if(H.gender == FEMALE)
				uniform = /obj/item/clothing/under/rank/engineering/engineer/trainee/assistant/skirt
			head = /obj/item/clothing/head/soft/orange
		if("Technical Student", "Technical Trainee")
			head = /obj/item/clothing/head/soft/orange
		if("Engineer Student")
			head = /obj/item/clothing/head/beret/eng

/datum/outfit/job/engineer/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/engineering/engineer/skirt

/datum/job/chief_engineer
	exp_map = list(EXP_TYPE_ENGINEERING = (1200 + NOVICE_JOB_MINUTES))

/datum/job/engineer
	exp_map = list(EXP_TYPE_ENGINEERING = (300 + NOVICE_JOB_MINUTES))

/datum/job/atmos
	exp_map = list(EXP_TYPE_ENGINEERING = (300 + NOVICE_JOB_MINUTES))

