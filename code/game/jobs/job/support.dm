//Food
/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue, access_weapons)
	minimal_access = list(access_bar, access_maint_tunnels, access_weapons)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/suit/armor/vest(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/under/rank/bartender(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/device/pda/bar(H), slot_wear_pda)

		if(H.backbag == 1)
			var/obj/item/weapon/storage/box/survival/Barpack = new /obj/item/weapon/storage/box/survival(H)
			H.equip_or_collect(Barpack, slot_r_hand)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)

		H.dna.SetSEState(SOBERBLOCK,1)
		H.mutations += M_SOBER
		H.check_mutations = 1

		return 1



/datum/job/chef
	title = "Chef"
	flag = CHEF
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue)
	minimal_access = list(access_kitchen, access_maint_tunnels)
	alt_titles = list("Cook","Culinary Artist","Butcher")


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/clothing/under/rank/chef(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/suit/chef(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/head/chefhat(H), slot_head)
		H.equip_or_collect(new /obj/item/device/pda/chef(H), slot_wear_pda)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1



/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_flag = SUPPORT
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	minimal_access = list(access_hydroponics, access_morgue, access_maint_tunnels) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	alt_titles = list("Hydroponicist")


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/clothing/under/rank/hydroponics(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/gloves/botanic_leather(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/suit/apron(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/device/analyzer/plant_analyzer(H), slot_s_store)
		H.equip_or_collect(new /obj/item/device/pda/botanist(H), slot_wear_pda)
		switch(H.backbag)
			if(1) H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_hyd(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1



//Cargo
/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/quartermaster(H), slot_wear_pda)
//		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_or_collect(new /obj/item/weapon/clipboard(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1



/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_flag = SUPPORT
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/cargo(H), slot_wear_pda)
//		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1



/datum/job/mining
	title = "Shaft Miner"
	flag = MINER
	department_flag = SUPPORT
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_mining, access_mint, access_mining_station, access_mailsorting, access_maint_tunnels)
	alt_titles = list("Spelunker")

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo (H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/device/pda/shaftminer(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/weapon/pickaxe/drill(H), slot_belt)
//		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/weapon/crowbar(H), slot_l_hand)
			H.equip_or_collect(new /obj/item/weapon/storage/bag/ore(H), slot_l_store)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/crowbar(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/storage/bag/ore(H), slot_in_backpack)
		return 1



//Griff //BS12 EDIT

/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_clown, access_theatre, access_maint_tunnels)
	minimal_access = list(access_clown, access_theatre, access_maint_tunnels)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/weapon/storage/backpack/clown(H), slot_back)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		if(H.gender == FEMALE)
			H.equip_or_collect(new /obj/item/clothing/mask/gas/sexyclown(H), slot_wear_mask)
			H.equip_or_collect(new /obj/item/clothing/under/sexyclown(H), slot_w_uniform)
		else
			H.equip_or_collect(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
			H.equip_or_collect(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/clown(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/bikehorn(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/stamp/clown(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/toy/crayon/rainbow(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/fancy/crayons(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/reagent_containers/spray/waterflower(H), slot_in_backpack)
		H.mutations.Add(M_CLUMSY)
		return 1



/datum/job/mime
	title = "Mime"
	flag = MIME
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_mime, access_theatre, access_maint_tunnels)
	minimal_access = list(access_mime, access_theatre, access_maint_tunnels)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(H.backbag == 3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(H.gender == FEMALE)
			H.equip_or_collect(new /obj/item/clothing/under/sexymime(H), slot_w_uniform)
			H.equip_or_collect(new /obj/item/clothing/mask/gas/sexymime(H), slot_wear_mask)
		else
			H.equip_or_collect(new /obj/item/clothing/under/mime(H), slot_w_uniform)
			H.equip_or_collect(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/mime(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/gloves/white(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/head/beret(H), slot_head)
		H.equip_or_collect(new /obj/item/clothing/suit/suspenders(H), slot_wear_suit)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/toy/crayon/mime(H), slot_l_store)
			H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_l_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/toy/crayon/mime(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_in_backpack)
		H.verbs += /client/proc/mimespeak
		H.verbs += /client/proc/mimewall
		H.mind.special_verbs += /client/proc/mimespeak
		H.mind.special_verbs += /client/proc/mimewall
		H.miming = 1
		return 1



/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_janitor, access_maint_tunnels)
	minimal_access = list(access_janitor, access_maint_tunnels)
	alt_titles = list("Custodial Technician")


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/clothing/under/rank/janitor(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/janitor(H), slot_wear_pda)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1



//More or less assistants
/datum/job/librarian
	title = "Librarian"
	flag = LIBRARIAN
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_library, access_maint_tunnels)
	minimal_access = list(access_library, access_maint_tunnels)
	alt_titles = list("Journalist")


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/clothing/under/suit_jacket/red(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/device/pda/librarian(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/weapon/barcodescanner(H), slot_l_hand)
		H.equip_or_collect(new /obj/item/device/laser_pointer(H), slot_l_store)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1

/datum/job/barber
	title = "Barber"
	flag = BARBER
	department_flag = KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_maint_tunnels)
	minimal_access = list(access_maint_tunnels)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/clothing/under/barber(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1
