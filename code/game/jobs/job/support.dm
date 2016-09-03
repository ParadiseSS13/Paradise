//Food
/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue, access_weapons, access_mineral_storeroom)
	minimal_access = list(access_bar, access_maint_tunnels, access_weapons, access_mineral_storeroom)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses/reagent(H), slot_glasses)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/suit/armor/vest(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/under/rank/bartender(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/device/pda/bar(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/weapon/storage/belt/bandolier/full(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/toy/russian_revolver(H), slot_in_backpack)

		H.dna.SetSEState(SOBERBLOCK,1)
		H.mutations += SOBER
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
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/rank/chef(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/suit/chef(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/head/chefhat(H), slot_head)
		H.equip_or_collect(new /obj/item/device/pda/chef(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		return 1



/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_flag = SUPPORT
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen)
	minimal_access = list(access_hydroponics, access_maint_tunnels)
	alt_titles = list("Hydroponicist", "Botanical Researcher")


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/botany(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_hyd(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/rank/hydroponics(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/gloves/botanic_leather(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/suit/apron(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/device/analyzer/plant_analyzer(H), slot_s_store)
		H.equip_or_collect(new /obj/item/device/pda/botanist(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
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
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/quartermaster(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_or_collect(new /obj/item/weapon/clipboard(H), slot_l_hand)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		return 1



/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_flag = SUPPORT
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting, access_mineral_storeroom)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/cargo(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		return 1



/datum/job/mining
	title = "Shaft Miner"
	flag = MINER
	department_flag = SUPPORT
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_mining, access_mint, access_mining_station, access_mailsorting, access_maint_tunnels, access_mineral_storeroom)
	alt_titles = list("Spelunker")

	equip(var/mob/living/carbon/human/H)
		if(!H)
			return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo/mining(H), slot_l_ear)
		switch(H.backbag)
			if(2)
				H.equip_or_collect(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3)
				H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4)
				H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/gloves/fingerless(H), slot_gloves)
		H.equip_or_collect(new /obj/item/device/pda/shaftminer(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/shoes/workboots(H), slot_shoes)
		H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/pill/patch/styptic(H), slot_l_store)
		H.equip_or_collect(new /obj/item/device/flashlight/seclite(H), slot_r_store)
		H.equip_or_collect(new /obj/item/weapon/mining_voucher(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/bag/ore(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
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
	idtype = /obj/item/weapon/card/id/clown
	access = list(access_clown, access_theatre, access_maint_tunnels)
	minimal_access = list(access_clown, access_theatre, access_maint_tunnels)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/weapon/storage/backpack/clown(H), slot_back)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		if(H.gender == FEMALE)
			H.equip_or_collect(new /obj/item/clothing/mask/gas/sexyclown(H), slot_wear_mask)
			H.equip_or_collect(new /obj/item/clothing/under/sexyclown(H), slot_w_uniform)
		else
			H.equip_or_collect(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
			H.equip_or_collect(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/clown(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/bikehorn(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/stamp/clown(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/toy/crayon/rainbow(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/fancy/crayons(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/reagent_containers/spray/waterflower(H), slot_in_backpack)
		if(H.get_species() == "Machine")
			var/obj/item/organ/internal/cyberimp/brain/clown_voice/implant
			implant = new
			implant.insert(H)
		H.mutations.Add(CLUMSY)
		H.dna.SetSEState(COMICBLOCK,1,1)
		genemutcheck(H,COMICBLOCK,null,MUTCHK_FORCED)
		return 1



/datum/job/mime
	title = "Mime"
	flag = MIME
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/mime
	access = list(access_mime, access_theatre, access_maint_tunnels)
	minimal_access = list(access_mime, access_theatre, access_maint_tunnels)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/weapon/storage/backpack/mime(H), slot_back)
		if(H.gender == FEMALE)
			H.equip_or_collect(new /obj/item/clothing/under/sexymime(H), slot_w_uniform)
			H.equip_or_collect(new /obj/item/clothing/mask/gas/sexymime(H), slot_wear_mask)
		else
			H.equip_or_collect(new /obj/item/clothing/under/mime(H), slot_w_uniform)
			H.equip_or_collect(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/mime(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/gloves/color/white(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/head/beret(H), slot_head)
		H.equip_or_collect(new /obj/item/clothing/suit/suspenders(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/toy/crayon/mime(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/cane(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		if(H.mind)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
			H.mind.miming = 1
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
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/rank/janitor(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/janitor(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
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
		if(!H)
			return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/suit_jacket/red(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/device/pda/librarian(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/weapon/storage/bag/books(H), slot_l_hand)
		H.equip_or_collect(new /obj/item/weapon/barcodescanner(H), slot_r_store)
		H.equip_or_collect(new /obj/item/device/laser_pointer(H), slot_l_store)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		return 1

/datum/job/barber
	title = "Barber"
	flag = BARBER
	department_flag = KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list("Hair Stylist","Beautician")
	access = list(access_maint_tunnels)
	minimal_access = list(access_maint_tunnels)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/barber(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/box/barber(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/box/lip_stick(H), slot_in_backpack)
		return 1
