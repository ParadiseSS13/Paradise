/datum/outfit/job/engineer
	name = "Station Engineer"
	jobtype = /datum/job/engineer

	uniform = /obj/item/clothing/under/rank/engineering/engineer
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat
	l_ear = /obj/item/radio/headset/headset_eng
	id = /obj/item/card/id/engineering
	l_pocket = /obj/item/t_scanner
	r_pocket = /obj/item/storage/bag/construction
	pda = /obj/item/pda/engineering

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/engineering
	box = /obj/item/storage/box/engineer

/datum/outfit/job/engineer/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_ELECTRICAL_SPECIALIST, JOB_TRAIT)

/datum/outfit/job/atmos
	name = "Life Support Specialist"
	jobtype = /datum/job/atmos

	uniform = /obj/item/clothing/under/rank/engineering/atmospheric_technician
	r_pocket = /obj/item/storage/bag/construction
	belt = /obj/item/storage/belt/utility/atmostech
	shoes = /obj/item/clothing/shoes/workboots
	l_ear = /obj/item/radio/headset/headset_eng
	id = /obj/item/card/id/atmostech
	pda = /obj/item/pda/atmos

	backpack = /obj/item/storage/backpack/industrial/atmos
	satchel = /obj/item/storage/backpack/satchel_atmos
	dufflebag = /obj/item/storage/backpack/duffel/atmos
	box = /obj/item/storage/box/engineer

/datum/outfit/job/atmos/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_FIRE_FIGHTER, JOB_TRAIT)
