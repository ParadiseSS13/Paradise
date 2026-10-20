/datum/outfit/job/doctor
	name = "Medical Doctor"
	jobtype = /datum/job/doctor

	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/storage/labcoat/medical
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/regular/doctor
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/outfit/job/doctor/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_MED_EXAMINE, JOB_TRAIT)

/datum/outfit/job/doctor/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Surgeon")
				uniform = /obj/item/clothing/under/rank/medical/scrubs
				head = /obj/item/clothing/head/surgery/blue
			if("Medical Doctor")
				uniform = /obj/item/clothing/under/rank/medical/doctor
			if("Physician")
				uniform = /obj/item/clothing/under/rank/medical/doctor
			if("Nurse")
				if(H.gender == FEMALE)
					if(prob(50))
						uniform = /obj/item/clothing/under/rank/medical/nursesuit
					else
						uniform = /obj/item/clothing/under/rank/medical/nurse
					head = /obj/item/clothing/head/nursehat
				else
					uniform = /obj/item/clothing/under/rank/medical/scrubs/purple

/datum/outfit/job/coroner
	name = "Coroner"
	jobtype = /datum/job/coroner

	uniform = /obj/item/clothing/under/rank/medical/scrubs/coroner
	suit = /obj/item/clothing/suit/storage/labcoat/mortician
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/coroner
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/clipboard
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

	backpack_contents = list(
		/obj/item/clothing/head/surgery/black = 1,
		/obj/item/autopsy_scanner = 1,
		/obj/item/reagent_scanner = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/box/bodybags = 1,
	)

/datum/outfit/job/coroner/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_CORPSE_RESIST, JOB_TRAIT)

/datum/outfit/job/chemist
	name = "Chemist"
	jobtype = /datum/job/chemist

	uniform = /obj/item/clothing/under/rank/medical/chemist
	r_pocket = /obj/item/storage/bag/chemistry
	suit = /obj/item/clothing/suit/storage/labcoat/chemist
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	glasses = /obj/item/clothing/glasses/science
	id = /obj/item/card/id/chemist
	pda = /obj/item/pda/chemist

	backpack = /obj/item/storage/backpack/chemistry
	satchel = /obj/item/storage/backpack/satchel_chem
	dufflebag = /obj/item/storage/backpack/duffel/chemistry

/datum/outfit/job/chemist/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_QUICK_HEATER, JOB_TRAIT)

/datum/outfit/job/virologist
	name = "Virologist"
	jobtype = /datum/job/virologist

	uniform = /obj/item/clothing/under/rank/medical/virologist
	r_pocket = /obj/item/storage/bag/bio
	suit = /obj/item/clothing/suit/storage/labcoat/virologist
	shoes = /obj/item/clothing/shoes/white
	mask = /obj/item/clothing/mask/surgical
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/virologist
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/viro

	backpack = /obj/item/storage/backpack/virology
	satchel = /obj/item/storage/backpack/satchel_vir
	dufflebag = /obj/item/storage/backpack/duffel/virology

/datum/outfit/job/virologist/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_GERMOPHOBE, JOB_TRAIT)

/datum/outfit/job/psychiatrist
	name = "Psychiatrist"
	jobtype = /datum/job/psychiatrist

	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/storage/labcoat/psych
	shoes = /obj/item/clothing/shoes/laceup
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/psychiatrist
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/medical

/datum/outfit/job/psychiatrist/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Psychiatrist")
				uniform = /obj/item/clothing/under/rank/medical/psych
			if("Psychologist")
				uniform = /obj/item/clothing/under/rank/medical/psych/turtleneck
			if("Therapist")
				uniform = /obj/item/clothing/under/rank/medical/doctor

/datum/outfit/job/paramedic
	name = "Paramedic"
	jobtype = /datum/job/paramedic

	uniform = /obj/item/clothing/under/rank/medical/paramedic
	head = /obj/item/clothing/head/soft/paramedic
	mask = /obj/item/clothing/mask/cigarette
	l_ear = /obj/item/radio/headset/headset_med/para
	id = /obj/item/card/id/paramedic
	l_pocket = /obj/item/flashlight/pen
	pda = /obj/item/pda/medical
	backpack_contents = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/sensor_device = 1,
		/obj/item/pinpointer/crew = 1,
	)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical
	box = /obj/item/storage/box/engineer

/datum/outfit/job/paramedic/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_SPEED_DEMON, JOB_TRAIT)
