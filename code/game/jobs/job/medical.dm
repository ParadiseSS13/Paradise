/datum/job

	//The name of the job
	var/title = "NOPE"

	//Job access. The use of minimal_access or access is determined by a config setting: config.jobs_have_minimal_access
	var/list/minimal_access = list()		//Useful for servers which prefer to only have access given to the places a job absolutely needs (Larger server population)
	var/list/access = list()				//Useful for servers which either have fewer players, so each person needs to fill more than one role, or servers which like to give more access, so players can't hide forever in their super secure departments (I'm looking at you, chemistry!)

	//Bitflags for the job
	var/flag = 0
	var/department_flag = 0

	//Players will be allowed to spawn in as jobs that are set to "Station"
	var/list/faction = list("Station")

	//How many players can be this job
	var/total_positions = 0

	//How many players can spawn in as this job
	var/spawn_positions = 0

	//How many players have this job
	var/current_positions = 0

	//Supervisors, who this person answers to directly
	var/supervisors = ""

	//Sellection screen color
	var/selection_color = "#ffffff"

	//the type of the ID the player will have
	var/idtype = /obj/item/weapon/card/id

	//List of alternate titles, if any
	var/list/alt_titles

	//If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/req_admin_notify

	//Various Departmental identifiers
	var/is_supply
	var/is_service
	var/is_command
	var/is_legal
	var/is_engineering
	var/is_medical
	var/is_science
	var/is_security

	//If you have use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/minimal_player_age = 0

	var/exp_requirements = 0
	var/exp_type = ""

	var/admin_only = 0
	var/spawn_ert = 0

	/////////////////////////////////
	// /vg/ feature: Job Objectives!
	/////////////////////////////////
	var/required_objectives=list() // Objectives that are ALWAYS added.
	var/optional_objectives=list() // Objectives that are SOMETIMES added.

/datum/job/proc/equip(var/mob/living/carbon/human/H)
	return 1

/datum/job/proc/get_access()
	if(!config)	//Needed for robots.
		return src.minimal_access.Copy()

	if(config.jobs_have_minimal_access)
		return src.minimal_access.Copy()
	else
		return src.access.Copy()

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	if(available_in_days(C) == 0)
		return 1	//Available in 0 days = available right now = player is old enough to play.
	return 0


/datum/job/proc/available_in_days(client/C)
	if(!C)
		return 0
	if(!config.use_age_restriction_for_jobs)
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	if(!isnum(minimal_player_age))
		return 0

	return max(0, minimal_player_age - C.player_age)

/datum/job/proc/apply_fingerprints(var/mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H.back)
		H.back.add_fingerprint(H,1)	//The 1 sets a flag to ignore gloves
		for(var/obj/item/I in H.back.contents)
			I.add_fingerprint(H,1)
	if(H.wear_id)
		H.wear_id.add_fingerprint(H,1)
	if(H.w_uniform)
		H.w_uniform.add_fingerprint(H,1)
	if(H.wear_suit)
		H.wear_suit.add_fingerprint(H,1)
	if(H.wear_mask)
		H.wear_mask.add_fingerprint(H,1)
	if(H.head)
		H.head.add_fingerprint(H,1)
	if(H.shoes)
		H.shoes.add_fingerprint(H,1)
	if(H.gloves)
		H.gloves.add_fingerprint(H,1)
	if(H.l_ear)
		H.l_ear.add_fingerprint(H,1)
	if(H.r_ear)
		H.r_ear.add_fingerprint(H,1)
	if(H.glasses)
		H.glasses.add_fingerprint(H,1)
	if(H.belt)
		H.belt.add_fingerprint(H,1)
		for(var/obj/item/I in H.belt.contents)
			I.add_fingerprint(H,1)
	if(H.s_store)
		H.s_store.add_fingerprint(H,1)
	if(H.l_store)
		H.l_store.add_fingerprint(H,1)
	if(H.r_store)
		H.r_store.add_fingerprint(H,1)
	return 1

/datum/job/proc/is_position_available()
	return (current_positions < total_positions) || (total_positions == -1)
=======
/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_flag = MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_medical = 1
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
	exp_requirements = 600
	exp_type = EXP_TYPE_CREW

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/cmo(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/chief_medical_officer(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/heads/cmo(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/cmo(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/melee/classic_baton/telescopic(H), slot_in_backpack)
		return 1



/datum/job/doctor
	title = "Medical Doctor"
	flag = DOCTOR
	department_flag = MEDSCI
	total_positions = 5
	spawn_positions = 3
	is_medical = 1
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
						H.equip_or_collect(new /obj/item/clothing/head/surgery/black(H), slot_in_backpack)
						H.equip_or_collect(new /obj/item/weapon/autopsy_scanner(H), slot_in_backpack)
						H.equip_or_collect(new /obj/item/device/mass_spectrometer(H), slot_in_backpack)
						H.equip_or_collect(new /obj/item/weapon/storage/box/bodybags(H), slot_in_backpack)
				if("Surgeon")
					H.equip_or_collect(new /obj/item/clothing/under/rank/medical/blue(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
					H.equip_or_collect(new /obj/item/clothing/head/surgery/blue(H), slot_head)
					H.equip_or_collect(new /obj/item/clothing/glasses/hud/medical(H), slot_glasses)
				if("Medical Doctor")
					H.equip_or_collect(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
					H.equip_or_collect(new /obj/item/clothing/glasses/hud/medical(H), slot_glasses)
				if("Nurse")
					H.equip_or_collect(new /obj/item/clothing/glasses/hud/medical(H), slot_glasses)
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
		H.equip_or_collect(new /obj/item/device/pda/medical(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		return 1



//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro
/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_flag = MEDSCI
	total_positions = 2
	spawn_positions = 2
	is_medical = 1
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
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/chemistry(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_chem(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/glasses/science(H), slot_glasses)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chemist(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/chemist(H), slot_wear_pda)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/chemist(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		return 1



/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_flag = MEDSCI
	total_positions = 2
	spawn_positions = 2
	is_medical = 1
	supervisors = "the chief medical officer and the research director"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_research, access_mineral_storeroom)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_research, access_maint_tunnels)
	minimal_player_age = 3

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/genetics(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_gen(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_medsci(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/geneticist(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/geneticist(H), slot_wear_pda)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/genetics(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), slot_s_store)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		return 1

/datum/job/virologist
	title = "Virologist"
	flag = VIROLOGIST
	department_flag = MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_medical = 1
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
		H.equip_or_collect(new /obj/item/device/pda/viro(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/mask/surgical(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/virologist(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		return 1

/datum/job/psychiatrist
	title = "Psychiatrist"
	flag = PSYCHIATRIST
	department_flag = MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_medical = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_psychiatrist)
	minimal_access = list(access_medical, access_psychiatrist, access_maint_tunnels)
	alt_titles = list("Psychologist","Therapist")

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/glasses/hud/medical(H), slot_glasses)
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
		H.equip_to_slot_or_del(new /obj/item/device/pda/medical(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		return 1

/datum/job/paramedic
	title = "Paramedic"
	flag = PARAMEDIC
	department_flag = MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_medical = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_morgue)
	minimal_access=list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks, access_morgue)
	minimal_player_age = 3


	equip(var/mob/living/carbon/human/H)
		if(!H)  return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/glasses/hud/medical(H), slot_glasses)
		if(H.backbag == 2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic (H), slot_back)
		if(H.backbag == 3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/medical/paramedic(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/medical(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/mask/cigarette(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/clothing/head/soft/blue(H), slot_head)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/device/healthanalyzer(H), slot_in_backpack)
		return 1
