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
	implants = list(
		/obj/item/implant/mindshield
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

/datum/outfit/job/syndicateofficer
	suit = /obj/item/clothing/suit/space/deathsquad/officer/syndie

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

/datum/outfit/admin/soviet/admiral
	belt = /obj/item/gun/projectile/revolver/reclinable/rsh12

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1,
		/obj/item/ammo_box/speed_loader_mm127 = 3
	)


/obj/item/clothing/under/solgov/srt
	name = "marine uniform"
	desc = "A comfortable and durable combat uniform"

/obj/item/clothing/head/beret/centcom/officer/navy/marine
	name = "navy blue beret"

/obj/item/storage/belt/military/assault/srt/populate_contents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/flash(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/ammo_box/magazine/smgm9mm(src)
	new /obj/item/ammo_box/magazine/smgm9mm(src)
	update_icon()
