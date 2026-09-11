/datum/outfit/job/nanotrasenrep
	name = "Nanotrasen Representative"
	jobtype = /datum/job/nanotrasenrep
	uniform = /obj/item/clothing/under/rank/procedure/representative
	suit = /obj/item/clothing/suit/storage/ntrep
	shoes = /obj/item/clothing/shoes/centcom
	glasses = /obj/item/clothing/glasses/hud/skills/sunglasses
	l_ear = /obj/item/radio/headset/heads/ntrep
	id = /obj/item/card/id/ntrep
	l_pocket = /obj/item/lighter/zippo/nt_rep
	pda = /obj/item/pda/heads/ntrep
	backpack_contents = list(
		/obj/item/melee/classic_baton/ntcane = 1
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)

/datum/outfit/job/nanotrasenrep/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_COFFEE_SNOB, JOB_TRAIT)

	if(visualsOnly)
		return

	INVOKE_ASYNC(src, PROC_REF(give_gaze), H)

/datum/outfit/job/blueshield
	name = "Blueshield"
	jobtype = /datum/job/blueshield
	uniform = /obj/item/clothing/under/rank/procedure/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	l_ear = /obj/item/radio/headset/heads/blueshield/alt
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	id = /obj/item/card/id/blueshield
	pda = /obj/item/pda/heads/blueshield
	backpack_contents = list(
		/obj/item/storage/box/deathimp = 1,
		/obj/item/gun/energy/gun/blueshield = 1,
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)
	backpack = /obj/item/storage/backpack/blueshield
	satchel = /obj/item/storage/backpack/satchel_blueshield
	dufflebag = /obj/item/storage/backpack/duffel/blueshield

/datum/outfit/job/nct
	name = "Nanotrasen Career Trainer"
	jobtype = /datum/job/nanotrasentrainer
	uniform = /obj/item/clothing/under/rank/procedure/nct
	suit = /obj/item/clothing/suit/storage/nct
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/beret/nct/green
	glasses = /obj/item/clothing/glasses/hud/skills/sunglasses
	l_ear = /obj/item/radio/headset/headset_nct
	id = /obj/item/card/id/nct
	l_pocket = /obj/item/card/id/nct_data_chip
	r_pocket = /obj/item/flash
	pda = /obj/item/pda/heads/ntrep
	backpack = /obj/item/storage/backpack/satchel

	backpack_contents = list(
		/obj/item/pinpointer/crew = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/book/manual/sop_ntinstructor,
		/obj/item/laser_pointer/blue = 1,
	)

	bio_chips = list(/obj/item/bio_chip/mindshield)

/datum/outfit/job/nct/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/nct_data_chip/I = H.l_store
	I.registered_user = H.mind.current
	I.registered_name = H.real_name
	var/icon/newphoto = get_id_photo(H, "Nanotrasen Career Trainer")
	I.photo = newphoto

/datum/outfit/job/nct/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	H.mind.offstation_role = TRUE
