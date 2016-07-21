/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_flag = MEDSCI
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	idtype = /obj/item/weapon/card/id/cmo
	req_admin_notify = 1
	access = list(access_medical, access_morgue, access_genetics, access_heads,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors, access_psychiatrist, access_paramedic, access_mineral_storeroom)
	minimal_access = list(access_eva, access_medical, access_morgue, access_genetics, access_heads,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors, access_psychiatrist, access_maint_tunnels, access_paramedic, access_mineral_storeroom)
	minimal_player_age = 21

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/cmo(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/chief_medical_officer(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/heads/cmo(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/cmo(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/melee/classic_baton/telescopic(H.back), slot_in_backpack)
		return 1



/datum/job/doctor
	title = "Medical Doctor"
	flag = DOCTOR
	department_flag = MEDSCI
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_mineral_storeroom)
	minimal_access = list(access_medical, access_morgue, access_surgery, access_maint_tunnels)
	alt_titles = list("Surgeon","Nurse","Coroner")
	minimal_player_age = 3

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(H.mind.role_alt_title)
			switch(H.mind.role_alt_title)
				if("Coroner")
					H.equip_or_collect(new /obj/item/clothing/under/rank/medical/mortician(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/mortician(H), slot_wear_suit)
					if(H.backbag != 1)
						H.equip_or_collect(new /obj/item/clothing/head/surgery/black(H.back), slot_in_backpack)
						H.equip_or_collect(new /obj/item/weapon/autopsy_scanner(H.back), slot_in_backpack)
						H.equip_or_collect(new /obj/item/device/mass_spectrometer(H.back), slot_in_backpack)
						H.equip_or_collect(new /obj/item/weapon/storage/box/bodybags(H.back), slot_in_backpack)
				if("Surgeon")
					H.equip_or_collect(new /obj/item/clothing/under/rank/medical/blue(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
					H.equip_or_collect(new /obj/item/clothing/head/surgery/blue(H), slot_head)
				if("Medical Doctor")
					H.equip_or_collect(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
				if("Nurse")
					if(H.gender == FEMALE)
						if(prob(50))
							H.equip_or_collect(new /obj/item/clothing/under/rank/nursesuit(H), slot_w_uniform)
						else
							H.equip_or_collect(new /obj/item/clothing/under/rank/nurse(H), slot_w_uniform)
						H.equip_or_collect(new /obj/item/clothing/head/nursehat(H), slot_head)
					else
						H.equip_or_collect(new /obj/item/clothing/under/rank/medical/purple(H), slot_w_uniform)
		else
			H.equip_or_collect(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
			H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/medical(H), slot_belt)
		H.equip_or_collect(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1



//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro
/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_flag = MEDSCI
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_mineral_storeroom)
	minimal_access = list(access_medical, access_chemistry, access_maint_tunnels, access_mineral_storeroom)
	alt_titles = list("Pharmacist","Pharmacologist")
	minimal_player_age = 7


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(1) H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/chemistry(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_chem(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/glasses/science(H), slot_glasses)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chemist(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/chemist(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/chemist(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1



/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_flag = MEDSCI
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer and the research director"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_research, access_mineral_storeroom)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_research, access_maint_tunnels)
	minimal_player_age = 3

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(1) H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/genetics(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_gen(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_medsci(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/geneticist(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/geneticist(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/genetics(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), slot_s_store)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1

/datum/job/virologist
	title = "Virologist"
	flag = VIROLOGIST
	department_flag = MEDSCI
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics)
	minimal_access = list(access_medical, access_virology, access_maint_tunnels, access_mineral_storeroom)
	alt_titles = list("Pathologist","Microbiologist")
	minimal_player_age = 7

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/virology(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_vir(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/virologist(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/device/pda/viro(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/mask/surgical(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/virologist(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1

/datum/job/psychiatrist
	title = "Psychiatrist"
	flag = PSYCHIATRIST
	department_flag = MEDSCI
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_psychiatrist)
	minimal_access = list(access_medical, access_psychiatrist, access_maint_tunnels)
	alt_titles = list("Psychologist","Therapist")

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(H.mind.role_alt_title)
			switch(H.mind.role_alt_title)
				if("Psychiatrist")
					H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/psych(H), slot_w_uniform)
				if("Psychologist")
					H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/psych/turtleneck(H), slot_w_uniform)
				if("Therapist")
					H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
		else
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/medical(H), slot_belt)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1

/datum/job/paramedic
	title = "Paramedic"
	flag = PARAMEDIC
	department_flag = MEDSCI
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_morgue)
	minimal_access=list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_morgue)
	minimal_player_age = 3


	equip(var/mob/living/carbon/human/H)
		if(!H)  return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
		if(H.backbag == 2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic (H), slot_back)
		if(H.backbag == 3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/medical/paramedic(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/medical(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/mask/cigarette(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/clothing/head/soft/blue(H), slot_head)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/device/healthanalyzer(H), slot_l_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/device/healthanalyzer(H.back), slot_in_backpack)
		return 1
