/datum/outfit/job/captain
	name = "Captain"
	jobtype = /datum/job/captain
	uniform = /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/caphat
	l_ear = /obj/item/radio/headset/heads/captain/alt
	glasses = /obj/item/clothing/glasses/hud/skills/sunglasses
	id = /obj/item/card/id/captains_spare/assigned
	pda = /obj/item/pda/captain
	backpack_contents = list(
		/obj/item/storage/box/ids = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)
	backpack = /obj/item/storage/backpack/captain
	satchel = /obj/item/storage/backpack/satchel_cap
	dufflebag = /obj/item/storage/backpack/duffel/captain

/datum/outfit/job/captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H && H.w_uniform)
		var/obj/item/clothing/under/U = H.w_uniform
		var/obj/item/clothing/accessory/medal/gold/captain/M = new /obj/item/clothing/accessory/medal/gold/captain(U)
		U.accessories += M
		M.on_attached(U)

/datum/outfit/job/captain/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	H.AddSpell(new /datum/spell/big_voice)

/datum/outfit/job/hos
	name = "Head of Security"
	jobtype = /datum/job/hos

	uniform = /obj/item/clothing/under/rank/security/head_of_security
	suit = /obj/item/clothing/suit/armor/hos
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/hos
	l_ear = /obj/item/radio/headset/heads/hos/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/hos
	suit_store = /obj/item/gun/energy/gun
	pda = /obj/item/pda/heads/hos
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)

	bio_chips = list(/obj/item/bio_chip/mindshield)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security

/datum/outfit/job/hos/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/sop_legal)
	add_verb(H, /mob/living/carbon/human/proc/space_law)

/datum/outfit/job/chief_engineer
	name = "Chief Engineer"
	jobtype = /datum/job/chief_engineer

	uniform = /obj/item/clothing/under/rank/engineering/chief_engineer
	belt = /obj/item/storage/belt/utility/chief/full
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/hardhat/white
	l_ear = /obj/item/radio/headset/heads/ce
	id = /obj/item/card/id/ce
	l_pocket = /obj/item/t_scanner
	r_pocket = /obj/item/storage/bag/construction
	pda = /obj/item/pda/heads/ce
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/engineering
	box = /obj/item/storage/box/engineer

/datum/outfit/job/chief_engineer/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_ELECTRICAL_SPECIALIST, JOB_TRAIT)

/datum/outfit/job/rd
	name = "Research Director"
	jobtype = /datum/job/rd

	uniform = /obj/item/clothing/under/rank/rnd/rd
	suit = /obj/item/clothing/suit/storage/labcoat/rd
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/rd
	l_ear = /obj/item/radio/headset/heads/rd
	id = /obj/item/card/id/rd
	l_hand = /obj/item/clipboard
	pda = /obj/item/pda/heads/rd
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science

/datum/outfit/job/rd/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_CRAFTY, JOB_TRAIT)

/datum/outfit/job/cmo
	name = "Chief Medical Officer"
	jobtype = /datum/job/cmo

	uniform = /obj/item/clothing/under/rank/medical/cmo
	suit = /obj/item/clothing/suit/storage/labcoat/cmo
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/cmo
	l_ear = /obj/item/radio/headset/heads/cmo
	id = /obj/item/card/id/cmo
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/regular/doctor
	pda = /obj/item/pda/heads/cmo
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/outfit/job/cmo/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_MED_EXAMINE, JOB_TRAIT)

/datum/outfit/job/hop
	name = "Head of Personnel"
	jobtype = /datum/job/hop
	uniform = /obj/item/clothing/under/rank/civilian/hop
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/hop
	glasses = /obj/item/clothing/glasses/hud/skills/sunglasses
	l_ear = /obj/item/radio/headset/heads/hop
	id = /obj/item/card/id/hop
	pda = /obj/item/pda/heads/hop
	backpack_contents = list(
		/obj/item/storage/box/ids = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)

	bio_chips = list()

/datum/outfit/job/qm
	name = "Quartermaster"
	jobtype = /datum/job/qm

	uniform = /obj/item/clothing/under/rank/cargo/qm
	shoes = /obj/item/clothing/shoes/workboots/mining
	head = /obj/item/clothing/head/qm
	l_ear = /obj/item/radio/headset/heads/qm
	glasses = /obj/item/clothing/glasses/meson/sunglasses
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	id = /obj/item/card/id/quartermaster
	l_hand = /obj/item/clipboard
	l_pocket = /obj/item/mail_scanner
	pda = /obj/item/pda/heads/qm
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)

/datum/outfit/job/qm/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_PACK_RAT, JOB_TRAIT)

