/datum/outfit/job/warden
	name = "Warden"
	jobtype = /datum/job/warden

	uniform = /obj/item/clothing/under/rank/security/warden
	suit = /obj/item/clothing/suit/armor/vest/warden/alt
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/warden
	l_ear = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/warden
	l_pocket = /obj/item/flash
	suit_store = /obj/item/gun/energy/disabler
	pda = /obj/item/pda/warden
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1
	)

	bio_chips = list(/obj/item/bio_chip/mindshield)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security

/datum/outfit/job/warden/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/sop_legal)
	add_verb(H, /mob/living/carbon/human/proc/space_law)

/datum/outfit/job/detective
	name = "Detective"
	jobtype = /datum/job/detective

	uniform = /obj/item/clothing/under/rank/security/detective
	suit = /obj/item/clothing/suit/storage/det_suit
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/det_hat
	l_ear = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/detective
	l_pocket = /obj/item/toy/crayon/white/chalk
	r_pocket = /obj/item/lighter/zippo
	pda = /obj/item/pda/detective
	backpack_contents = list(
		/obj/item/storage/box/evidence = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)

	bio_chips = list(/obj/item/bio_chip/mindshield)

/datum/outfit/job/detective/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_CORPSE_RESIST, JOB_TRAIT) // too cool to vomit
	add_verb(H, /mob/living/carbon/human/proc/sop_legal)
	add_verb(H, /mob/living/carbon/human/proc/space_law)

/datum/outfit/job/detective/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Forensic Technician")
				suit = /obj/item/clothing/suit/storage/det_suit/forensics/blue
				head = null

/datum/outfit/job/detective/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.dna.SetSEState(GLOB.soberblock, TRUE)
	H.check_mutations = 1

/datum/outfit/job/officer
	name = "Security Officer"
	jobtype = /datum/job/officer
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest/security
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet
	l_ear = /obj/item/radio/headset/headset_sec/alt
	id = /obj/item/card/id/security
	l_pocket = /obj/item/flash
	suit_store = /obj/item/gun/energy/disabler
	pda = /obj/item/pda/security
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security

/datum/outfit/job/officer/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/sop_legal)
	add_verb(H, /mob/living/carbon/human/proc/space_law)
