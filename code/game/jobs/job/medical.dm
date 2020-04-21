/datum/job/cmo
	title = "Jefe Medico"
	flag = JOB_CMO
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_medical = 1
	supervisors = "the captain"
	department_head = list("Capitan")
	selection_color = "#ffddf0"
	req_admin_notify = 1
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_PSYCHIATRIST, ACCESS_PARAMEDIC, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_EVA, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_PSYCHIATRIST, ACCESS_MAINT_TUNNELS, ACCESS_PARAMEDIC, ACCESS_MINERAL_STOREROOM)
	minimal_player_age = 21
	exp_requirements = 180
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/cmo

/datum/outfit/job/cmo
	name = "Jefe Medico"
	jobtype = /datum/job/cmo

	uniform = /obj/item/clothing/under/rank/chief_medical_officer
	suit = /obj/item/clothing/suit/storage/labcoat/cmo
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset/heads/cmo
	id = /obj/item/card/id/cmo
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/adv
	pda = /obj/item/pda/heads/cmo
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/job/doctor
	title = "Doctor Medico"
	flag = JOB_DOCTOR
	department_flag = JOBCAT_MEDSCI
	total_positions = 5
	spawn_positions = 3
	is_medical = 1
	supervisors = "the chief medical officer"
	department_head = list("Jefe Medico")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Surgeon","Nurse")
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/doctor

/datum/outfit/job/doctor
	name = "Doctor Medico"
	jobtype = /datum/job/doctor

	uniform = /obj/item/clothing/under/rank/medical
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/adv
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/job/coroner
	title = "Medico Forense"
	flag = JOB_CORONER
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_medical = 1
	supervisors = "the chief medical officer"
	department_head = list("Jefe Medico")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_player_age = 3
	exp_requirements = 120
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/coroner

/datum/outfit/job/coroner
	name = "Medico Forense"
	jobtype = /datum/job/coroner

	uniform = /obj/item/clothing/under/rank/medical/mortician
	suit = /obj/item/clothing/suit/storage/labcoat/mortician
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
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
					/obj/item/storage/box/bodybags = 1)

/datum/outfit/job/doctor/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Surgeon")
				uniform = /obj/item/clothing/under/rank/medical/blue
				head = /obj/item/clothing/head/surgery/blue
			if("Doctor Medico")
				uniform = /obj/item/clothing/under/rank/medical
			if("Nurse")
				if(H.gender == FEMALE)
					if(prob(50))
						uniform = /obj/item/clothing/under/rank/nursesuit
					else
						uniform = /obj/item/clothing/under/rank/nurse
					head = /obj/item/clothing/head/nursehat
				else
					uniform = /obj/item/clothing/under/rank/medical/purple



//Quimico is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro
/datum/job/chemist
	title = "Quimico"
	flag = JOB_CHEMIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	is_medical = 1
	supervisors = "the chief medical officer"
	department_head = list("Jefe Medico")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_CHEMISTRY, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	alt_titles = list("Pharmacist","Pharmacologist")
	outfit = /datum/outfit/job/chemist

/datum/outfit/job/chemist
	name = "Quimico"
	jobtype = /datum/job/chemist

	uniform = /obj/item/clothing/under/rank/chemist
	suit = /obj/item/clothing/suit/storage/labcoat/chemist
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	glasses = /obj/item/clothing/glasses/science
	id = /obj/item/card/id/medical
	pda = /obj/item/pda/chemist

	backpack = /obj/item/storage/backpack/chemistry
	satchel = /obj/item/storage/backpack/satchel_chem
	dufflebag = /obj/item/storage/backpack/duffel/chemistry

/datum/job/geneticist
	title = "Genetista"
	flag = JOB_GENETICIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	is_medical = 1
	supervisors = "the chief medical officer and the research director"
	department_head = list("Jefe Medico", "Director de Ciencias")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_RESEARCH, ACCESS_MAINT_TUNNELS)
	minimal_player_age = 3
	exp_requirements = 120
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/geneticist

/datum/outfit/job/geneticist
	name = "Genetista"
	jobtype = /datum/job/geneticist

	uniform = /obj/item/clothing/under/rank/geneticist
	suit = /obj/item/clothing/suit/storage/labcoat/genetics
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_medsci
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/geneticist

	backpack = /obj/item/storage/backpack/genetics
	satchel = /obj/item/storage/backpack/satchel_gen
	dufflebag = /obj/item/storage/backpack/duffel/genetics


/datum/job/virologist
	title = "Virologo"
	flag = JOB_VIROLOGIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_medical = 1
	supervisors = "the chief medical officer"
	department_head = list("Jefe Medico")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_VIROLOGY, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	alt_titles = list("Pathologist","Microbiologist")
	minimal_player_age = 7
	exp_requirements = 180
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/virologist

/datum/outfit/job/virologist
	name = "Virologo"
	jobtype = /datum/job/virologist

	uniform = /obj/item/clothing/under/rank/virologist
	suit = /obj/item/clothing/suit/storage/labcoat/virologist
	shoes = /obj/item/clothing/shoes/white
	mask = /obj/item/clothing/mask/surgical
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/viro

	backpack = /obj/item/storage/backpack/virology
	satchel = /obj/item/storage/backpack/satchel_vir
	dufflebag = /obj/item/storage/backpack/duffel/virology

/datum/job/psychiatrist
	title = "Psiquiatra"
	flag = JOB_PSYCHIATRIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_medical = 1
	supervisors = "the chief medical officer"
	department_head = list("Jefe Medico")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_PSYCHIATRIST)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_PSYCHIATRIST, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Psychologist","Therapist")
	outfit = /datum/outfit/job/psychiatrist

/datum/outfit/job/psychiatrist
	name = "Psiquiatra"
	jobtype = /datum/job/psychiatrist

	uniform = /obj/item/clothing/under/rank/medical
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/laceup
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/medical

/datum/outfit/job/psychiatrist/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Psiquiatra")
				uniform = /obj/item/clothing/under/rank/psych
			if("Psychologist")
				uniform = /obj/item/clothing/under/rank/psych/turtleneck
			if("Therapist")
				uniform = /obj/item/clothing/under/rank/medical

/datum/job/paramedic
	title = "Paramedico"
	flag = JOB_PARAMEDIC
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_medical = 1
	supervisors = "the chief medical officer"
	department_head = list("Jefe Medico")
	selection_color = "#ffeef0"
	access = list(ACCESS_PARAMEDIC, ACCESS_MEDICAL, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MORGUE)
	minimal_access=list(ACCESS_PARAMEDIC, ACCESS_MEDICAL, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MORGUE)
	outfit = /datum/outfit/job/paramedic

/datum/outfit/job/paramedic
	name = "Paramedico"
	jobtype = /datum/job/paramedic

	uniform = /obj/item/clothing/under/rank/medical/paramedic
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/soft/blue
	mask = /obj/item/clothing/mask/cigarette
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	l_pocket = /obj/item/flashlight/pen
	pda = /obj/item/pda/medical
	backpack_contents = list(
		/obj/item/healthanalyzer = 1
	)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical
	box = /obj/item/storage/box/engineer

