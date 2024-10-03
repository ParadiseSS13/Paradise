// MARK: Soviets
/datum/outfit/admin/soviet/admiral
	belt = /obj/item/gun/projectile/revolver/reclinable/rsh12

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1,
		/obj/item/ammo_box/speed_loader_mm127 = 3
	)

/datum/outfit/admin/soviet/marine/captain

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1,
		/obj/item/gun/projectile/revolver/reclinable/anaconda  = 1,
		/obj/item/ammo_box/speed_loader_d44 = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/item/lighter/zippo/engraved = 1
	)

/datum/outfit/admin/soviet/officer
	belt = /obj/item/gun/projectile/revolver/reclinable/rsh12

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1,
		/obj/item/lighter/zippo = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/item/ammo_box/speed_loader_mm127 = 2
	)

// MARK: NT & Syndie Officers
/datum/outfit/job/syndicateofficer
	suit = /obj/item/clothing/suit/space/deathsquad/officer/syndie

/datum/outfit/job/ntnavyofficer
	l_pocket = /obj/item/melee/baseball_bat/homerun/central_command

/obj/item/clothing/head/beret/centcom/officer/navy/marine
	name = "navy blue beret"

// MARK: NT Officer outfits
/datum/outfit/job/admin/ntnavyofficer
	name = "Nanotrasen Navy Officer"
	jobtype = /datum/job/ntnavyofficer

	uniform = /obj/item/clothing/under/rank/centcom/officer
	gloves =  /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/beret/centcom/officer
	l_ear = /obj/item/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	bio_chips = list(
		/obj/item/bio_chip/mindshield,
		/obj/item/bio_chip/dust
	)
	backpack = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/stamp/centcom = 1,
	)
	box = /obj/item/storage/box/centcomofficer
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/arm/combat/centcom
	)

/datum/outfit/job/admin/ntnavyofficer/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	H.mind.offstation_role = TRUE

/datum/outfit/job/admin/ntspecops
	name = "Special Operations Officer"
	jobtype = /datum/job/ntspecops
	allow_backbag_choice = FALSE
	uniform = /obj/item/clothing/under/rank/centcom/captain
	suit = /obj/item/clothing/suit/space/deathsquad/officer
	belt = /obj/item/storage/belt/military/assault
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	mask = /obj/item/clothing/mask/holo_cigar
	head = /obj/item/clothing/head/helmet/space/deathsquad/beret
	l_ear = /obj/item/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	r_pocket = /obj/item/storage/fancy/matches
	back = /obj/item/storage/backpack/satchel
	box = /obj/item/storage/box/centcomofficer
	backpack_contents = list(
		/obj/item/clothing/shoes/magboots/advance = 1,
		/obj/item/storage/box/zipties = 1
	)
	bio_chips = list(
		/obj/item/bio_chip/mindshield,
		/obj/item/bio_chip/dust
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/eyes/cybernetic/xray/hardened,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/arm/combat/centcom
	)

/datum/outfit/job/admin/ntspecops/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	H.mind.offstation_role = TRUE

/datum/outfit/job/admin/ntspecops/alt
	name = "Specops alt. RSH-12, saber, bandana"
	belt = /obj/item/storage/belt/sheath/saber
	backpack_contents = list(
		/obj/item/gun/projectile/revolver/reclinable/rsh12,
		/obj/item/ammo_box/speed_loader_mm127,
		/obj/item/ammo_box/speed_loader_mm127,
		/obj/item/ammo_box/speed_loader_mm127,
		/obj/item/clothing/mask/bandana/red
	)
	suit_store = /obj/item/ammo_box/box_mm127

/datum/outfit/job/admin/ntnavyofficer/alt
	name = "NT Navy Officer alt. Coat NT, holo, noble, cane"
	mask = /obj/item/clothing/mask/holo_cigar
	suit = /obj/item/clothing/suit/space/deathsquad/officer/field/cloak_nt/coat_nt
	shoes = /obj/item/clothing/shoes/fluff/noble_boot
	belt = /obj/item/melee/classic_baton/ntcane

/datum/outfit/job/admin/ntnavyofficer/alt2
	name = "NT Navy Officer alt. Cloak NT, holo"
	suit = /obj/item/clothing/suit/space/deathsquad/officer/field/cloak_nt
	mask = /obj/item/clothing/mask/holo_cigar

/datum/outfit/job/admin/ntnavyofficer/field
	name = "Nanotrasen Navy Field Officer"

	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/deathsquad/officer/field
	head = /obj/item/clothing/head/helmet/space/deathsquad/beret/field
	l_pocket = /obj/item/melee/baseball_bat/homerun/central_command

	bio_chips = list(
		/obj/item/bio_chip/mindshield,
		/obj/item/bio_chip/dust,
		/obj/item/organ/internal/cyberimp/brain/anti_sleep/hardened,
		/obj/item/organ/internal/cyberimp/chest/reviver/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/eyes/cybernetic/thermals/hardened
	)

/datum/outfit/job/admin/ntnavyofficer/field/alt
	name = "Nanotrasen Navy Field Officer alt. Ring, mateba, holster"
	gloves =/obj/item/clothing/gloves/ring/silver
	mask = /obj/item/clothing/mask/holo_cigar
	backpack_contents = list(
		/obj/item/clothing/accessory/scarf/purple,
		/obj/item/clothing/gloves/combat,
		/obj/item/gun/projectile/revolver/mateba,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/a357,
		/obj/item/clothing/accessory/holster
	)

/datum/outfit/job/admin/nt_navy_captain
	name = "NT Navy Captain (Advanced)"

	uniform = /obj/item/clothing/under/rank/centcom/captain
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/sheath/saber
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/beret/centcom/captain
	l_ear = /obj/item/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	backpack_contents = list(
		/obj/item/storage/box/centcomofficer,
		/obj/item/bio_chip_implanter/death_alarm,
		/obj/item/stamp/centcom,
		/obj/item/gun/projectile/revolver/reclinable/rsh12,
		/obj/item/ammo_box/speed_loader_mm127,
		/obj/item/ammo_box/speed_loader_mm127
	)
	bio_chips = list(
		/obj/item/bio_chip/mindshield,
		/obj/item/bio_chip/dust
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/eyes/cybernetic/xray/hardened,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened
	)

/datum/outfit/job/admin/nt_navy_captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Nanotrasen Navy Captain"), "Nanotrasen Navy Captain")
	H.sec_hud_set_ID()

/datum/outfit/job/admin/ntnavyofficer/field/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	H.mind.offstation_role = TRUE
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Nanotrasen Navy Officer"), "Nanotrasen Navy Field Officer")
	I.rank = "Nanotrasen Navy Officer"
	I.assignment = "Nanotrasen Navy Field Officer"
	H.sec_hud_set_ID()

/datum/outfit/job/admin/ntnavyofficer/intern
	name = "NT Intern"
	uniform = /obj/item/clothing/under/rank/centcom/intern
	head = /obj/item/clothing/head/beret/centcom/intern
	glasses = /obj/item/clothing/glasses/hud/skills/sunglasses
	gloves = /obj/item/clothing/gloves/fingerless
	id = /obj/item/card/id/centcom
	backpack_contents = list(
		/obj/item/stamp/centcom,
		/obj/item/clipboard,
		/obj/item/stack/spacecash/c200
	)
	bio_chips = list(
		/obj/item/bio_chip/mindshield
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened
	)

/datum/outfit/job/admin/ntnavyofficer/intern/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Nanotrasen Navy Officer"), "Nanotrasen CentCom Intern")
	I.rank = "Nanotrasen Navy Officer"
	I.assignment = "Nanotrasen CentCom Intern"
	H.sec_hud_set_ID()

/obj/item/clothing/head/helmet/space/deathsquad/beret/field
	icon_state = "beret_centcom_officer"

// MARK: SRT
/datum/outfit/admin/srt
	name = "Special Response Team Member"

	uniform = /obj/item/clothing/under/solgov/srt
	suit = /obj/item/clothing/suit/armor/vest/fluff/tactical
	suit_store = /obj/item/gun/energy/gun/blueshield/pdw9
	back = /obj/item/storage/backpack/satchel_blueshield
	belt = /obj/item/storage/belt/military/assault/srt
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat/swat
	head = /obj/item/clothing/head/beret/centcom/officer/navy/marine
	l_ear = /obj/item/radio/headset/ert/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/ert/security
	pda = /obj/item/pda/heads/ert/security
	box = /obj/item/storage/box/responseteam
	r_pocket = /obj/item/flashlight/seclite
	l_pocket = /obj/item/pinpointer/advpinpointer
	backpack_contents = list(
		/obj/item/clothing/mask/gas/explorer/marines,
		/obj/item/storage/box/handcuffs,
		/obj/item/ammo_box/magazine/smgm9mm,
		/obj/item/clothing/accessory/holster,
		/obj/item/gun/projectile/automatic/proto
	)
	bio_chips = list(
		/obj/item/bio_chip/mindshield
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/baton,
		/obj/item/organ/internal/cyberimp/eyes/hud/security
	)
	var/id_icon = "syndie"

/datum/outfit/admin/srt/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Emergency Response Team Member"), "Special Response Team Member")
	I.assignment = "Emergency Response Team Officer"
	H.sec_hud_set_ID()

/obj/item/clothing/under/solgov/srt
	name = "marine uniform"
	desc = "A comfortable and durable combat uniform"

/obj/item/storage/belt/military/assault/srt/populate_contents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/flash(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/ammo_box/magazine/smgm9mm(src)
	new /obj/item/ammo_box/magazine/smgm9mm(src)
	update_icon()

// MARK: ERT
/* Commander */
/datum/outfit/job/centcom/response_team/commander/amber
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

/* Engineer */
/datum/outfit/job/centcom/response_team/engineer/amber
	suit = /obj/item/clothing/suit/space/ert_engineer
	head = /obj/item/clothing/head/helmet/space/ert_engineer
