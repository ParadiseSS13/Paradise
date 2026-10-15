/datum/outfit/job/cargo_tech
	name = "Cargo Technician"
	jobtype = /datum/job/cargo_tech

	uniform = /obj/item/clothing/under/rank/cargo/tech
	l_pocket = /obj/item/mail_scanner
	r_pocket = /obj/item/storage/bag/mail
	l_ear = /obj/item/radio/headset/headset_cargo
	id = /obj/item/card/id/supply
	pda = /obj/item/pda/cargo

/datum/outfit/job/cargo_tech/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_PACK_RAT, JOB_TRAIT)

/datum/outfit/job/smith
	name = "Smith"
	jobtype = /datum/job/smith

	gloves = /obj/item/clothing/gloves/smithing
	uniform = /obj/item/clothing/under/rank/cargo/smith
	r_pocket = /obj/item/storage/bag/smith
	l_ear = /obj/item/radio/headset/headset_cargo
	shoes = /obj/item/clothing/shoes/workboots/smithing
	id = /obj/item/card/id/smith
	pda = /obj/item/pda/cargo
	box = /obj/item/storage/box/survival_mining

/datum/outfit/job/smith/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_SMITH, JOB_TRAIT)

/datum/outfit/job/mining
	name = "Shaft Miner"
	jobtype = /datum/job/mining

	l_ear = /obj/item/radio/headset/headset_cargo/mining
	shoes = /obj/item/clothing/shoes/workboots/mining
	gloves = /obj/item/clothing/gloves/color/black
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	l_pocket = /obj/item/reagent_containers/hypospray/autoinjector/survival
	r_pocket = /obj/item/storage/bag/ore
	id = /obj/item/card/id/shaftminer
	pda = /obj/item/pda/shaftminer
	backpack_contents = list(
		/obj/item/flashlight/seclite = 1,
		/obj/item/kitchen/knife/combat/survival = 1,
		/obj/item/mining_voucher = 1,
		/obj/item/stack/marker_beacon/ten = 1,
	)

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel_explorer
	box = /obj/item/storage/box/survival_mining

/datum/outfit/job/mining/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_BUTCHER, JOB_TRAIT)

/datum/outfit/job/mining/equipped

	suit = /obj/item/clothing/suit/hooded/explorer
	mask = /obj/item/clothing/mask/gas/explorer
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/tank/internals/emergency_oxygen
	internals_slot = ITEM_SLOT_SUIT_STORE
	backpack_contents = list(
		/obj/item/flashlight/seclite = 1,
		/obj/item/kitchen/knife/combat/survival = 1,
		/obj/item/mining_voucher = 1,
		/obj/item/t_scanner/adv_mining_scanner/lesser = 1,
		/obj/item/gun/energy/kinetic_accelerator = 1,
		/obj/item/stack/marker_beacon/ten = 1,
	)

/datum/outfit/job/mining/equipped/less
	backpack_contents = list(
		/obj/item/flashlight/seclite = 1,
		/obj/item/stack/marker_beacon/ten = 1,
	)

/datum/outfit/job/mining/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	if(istype(H.wear_suit, /obj/item/clothing/suit/hooded))
		var/obj/item/clothing/suit/hooded/S = H.wear_suit
		S.ToggleHood()

/datum/outfit/job/mining/equipped/modsuit
	name = "Shaft Miner (Equipment + MODsuit)"
	back = /obj/item/mod/control/pre_equipped/mining/asteroid
	mask = /obj/item/clothing/mask/breath
	suit = null
	backpack = null
	allow_backbag_choice = FALSE

/datum/outfit/job/explorer
	name = "Explorer"
	jobtype = /datum/job/explorer
	l_ear = /obj/item/radio/headset/headset_cargo/expedition
	head = /obj/item/clothing/head/soft/expedition
	uniform = /obj/item/clothing/under/rank/cargo/expedition
	l_pocket = /obj/item/storage/bag/expedition
	r_pocket = /obj/item/storage/bag/ore
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	belt = /obj/item/storage/belt/utility/expedition
	id = /obj/item/card/id/explorer
	pda = /obj/item/pda/explorer
	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel_explorer
	box = /obj/item/storage/box/survival_mining

/datum/outfit/job/explorer/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_BUTCHER, JOB_TRAIT)
